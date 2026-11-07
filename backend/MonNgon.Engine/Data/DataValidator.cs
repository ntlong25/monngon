using System.Globalization;
using System.Text.Json;
using System.Text.RegularExpressions;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Data;

public sealed record DataIssue(string Severity, string File, string Id, string Field, string Message)
{
    public override string ToString() => $"{(Severity == "error" ? "LỖI" : "CẢNH BÁO")} {File}.json · {Id} · {Field}: {Message}";
}

public sealed record ValidationResult(IReadOnlyList<DataIssue> Issues, Dataset Dataset)
{
    public int Errors => Issues.Count(i => i.Severity == "error");
    public int Warnings => Issues.Count(i => i.Severity == "warning");
}

/// <summary>Port của src/data/validate.ts (+ schema zod): kiểm kiểu/giá trị từng dòng rồi các quy tắc chéo.</summary>
public static partial class DataValidator
{
    private const double KcalTolerance = 0.15;

    [GeneratedRegex("^[a-z0-9]+(_[a-z0-9]+)*$")]
    private static partial Regex IdRegex();

    public static double KcalDeviation(MacrosPer100g m)
    {
        var plain = 4 * m.ProteinG + 4 * m.CarbG + 9 * m.FatG;
        var fiberAware = 4 * m.ProteinG + 4 * Math.Max(0, m.CarbG - m.FiberG) + 2 * m.FiberG + 9 * m.FatG;
        double Rel(double est) => Math.Abs(est - m.Kcal) / Math.Max(m.Kcal, 1);
        return Math.Min(Rel(plain), Rel(fiberAware));
    }

    public static ValidationResult Validate(RawDataset raw)
    {
        var issues = new List<DataIssue>();
        var ingredients = ParseEach<Ingredient>("ingredients", raw.Ingredients, RowId, CheckIngredient, issues);
        var recipes = ParseEach<Recipe>("recipes", raw.Recipes, RowId, CheckRecipe, issues);
        var stores = ParseEach<Store>("stores", raw.Stores, RowId, CheckStore, issues);
        var prices = ParseEach<Price>("prices", raw.Prices, PriceId, CheckPrice, issues);

        Dupes("ingredients", ingredients.Select(i => i.Id), issues);
        Dupes("recipes", recipes.Select(r => r.Id), issues);
        Dupes("stores", stores.Select(s => s.Id), issues);
        Dupes("prices", prices.Select(p => $"{p.IngredientId}@{p.StoreId}"), issues);

        var ingIds = ingredients.Select(i => i.Id).ToHashSet();
        var storeIds = stores.Select(s => s.Id).ToHashSet();

        foreach (var r in recipes)
        {
            for (var n = 0; n < r.Ingredients.Count; n++)
            {
                var li = r.Ingredients[n];
                var f = $"ingredients[{n}]";
                if (!ingIds.Contains(li.IngredientId))
                    Err(issues, "recipes", r.Id, $"{f}.ingredient_id", $"nguyên liệu \"{li.IngredientId}\" không tồn tại");
                if (!(li.MinG <= li.Grams && li.Grams <= li.MaxG))
                    Err(issues, "recipes", r.Id, $"{f}.grams", $"phải thỏa min_g ≤ grams ≤ max_g ({Num(li.MinG)} ≤ {Num(li.Grams)} ≤ {Num(li.MaxG)})");
                if (li.Role != "protein" && li.Role != "carb" && (li.MinG != li.Grams || li.MaxG != li.Grams))
                    Err(issues, "recipes", r.Id, $"{f}.min_g/max_g", $"vai trò \"{li.Role}\" cố định: min_g = max_g = grams");
            }
            if (r.IsLowCarb)
                foreach (var li in r.Ingredients)
                    if (li.Role == "carb" && li.MinG != 0)
                        Err(issues, "recipes", r.Id, "is_low_carb", $"is_low_carb nhưng \"{li.IngredientId}\" (carb) có min_g = {Num(li.MinG)} ≠ 0");
            if (r.MealTypes.Contains("lunch") && r.LunchStyle.Count == 0)
                Warn(issues, "recipes", r.Id, "lunch_style", "món trưa chưa khai báo hot/packed");
            if ((r.MealTypes.Contains("snack_am") || r.MealTypes.Contains("snack_pm")) && r.SnackStyle is null)
                Warn(issues, "recipes", r.Id, "snack_style", "bữa phụ chưa khai báo sweet/savory");
        }

        // D-SHP-02: purchase_as phải trỏ tới nguyên liệu có thật, có giá ở cửa hàng fallback, không trỏ về chính nó và không nối chuỗi.
        var byId = new Dictionary<string, Ingredient>();
        foreach (var i in ingredients) byId.TryAdd(i.Id, i); // id trùng đã báo ở bước Dupes
        var pricedFallback = prices.Where(p => p.StoreId == Dataset.FallbackStoreId).Select(p => p.IngredientId).ToHashSet();
        foreach (var i in ingredients.Where(i => i.PurchaseAs is not null))
        {
            var t = i.PurchaseAs!.IngredientId;
            if (t == i.Id) Err(issues, "ingredients", i.Id, "purchase_as.ingredient_id", "không được trỏ về chính nó");
            else if (!byId.TryGetValue(t, out var target)) Err(issues, "ingredients", i.Id, "purchase_as.ingredient_id", $"nguyên liệu \"{t}\" không tồn tại");
            else
            {
                if (target.PurchaseAs is not null) Err(issues, "ingredients", i.Id, "purchase_as.ingredient_id", $"\"{t}\" cũng có purchase_as (không nối chuỗi)");
                if (!pricedFallback.Contains(t)) Err(issues, "ingredients", i.Id, "purchase_as.ingredient_id", $"\"{t}\" chưa có giá ở \"{Dataset.FallbackStoreId}\"");
            }
        }

        foreach (var p in prices)
        {
            var id = $"{p.IngredientId}@{p.StoreId}";
            if (!ingIds.Contains(p.IngredientId)) Err(issues, "prices", id, "ingredient_id", $"nguyên liệu \"{p.IngredientId}\" không tồn tại");
            if (!storeIds.Contains(p.StoreId)) Err(issues, "prices", id, "store_id", $"cửa hàng \"{p.StoreId}\" không tồn tại");
        }
        var fallbackCovered = prices.Where(p => p.StoreId == Dataset.FallbackStoreId).Select(p => p.IngredientId).ToHashSet();
        if (!storeIds.Contains(Dataset.FallbackStoreId))
            Err(issues, "stores", Dataset.FallbackStoreId, "id", "thiếu cửa hàng fallback \"cho_khac\"");
        // D-SHP-02: nguyên liệu có purchase_as lấy giá từ nguyên liệu đích (đã kiểm ở trên) nên không bắt buộc có giá riêng ở cho_khac.
        foreach (var i in ingredients.Where(i => i.PurchaseAs is null))
            if (!fallbackCovered.Contains(i.Id))
                Err(issues, "prices", $"{i.Id}@{Dataset.FallbackStoreId}", "store_id", $"nguyên liệu \"{i.Id}\" chưa có giá ở \"cho_khac\"");

        foreach (var i in ingredients)
        {
            var dev = KcalDeviation(i.Per100g);
            if (dev > KcalTolerance)
                Warn(issues, "ingredients", i.Id, "per_100g.kcal",
                    $"kcal khai báo lệch {(dev * 100).ToString("F0", CultureInfo.InvariantCulture)}% so với 4/4/9 (ngưỡng {Num(KcalTolerance * 100)}%)");
        }
        return new ValidationResult(issues, new Dataset(ingredients, recipes, stores, prices));
    }

    // ---------- helpers ----------
    private static string Num(double d) => d.ToString("R", CultureInfo.InvariantCulture);
    private static void Err(List<DataIssue> l, string file, string id, string field, string msg) => l.Add(new DataIssue("error", file, id, field, msg));
    private static void Warn(List<DataIssue> l, string file, string id, string field, string msg) => l.Add(new DataIssue("warning", file, id, field, msg));

    private static string RowId(JsonElement r) =>
        r.ValueKind == JsonValueKind.Object && r.TryGetProperty("id", out var v) && v.ValueKind == JsonValueKind.String ? v.GetString()! : "";

    private static string PriceId(JsonElement r)
    {
        string S(string k) => r.ValueKind == JsonValueKind.Object && r.TryGetProperty(k, out var v) && v.ValueKind != JsonValueKind.Null
            ? (v.ValueKind == JsonValueKind.String ? v.GetString()! : v.ToString()) : "?";
        return $"{S("ingredient_id")}@{S("store_id")}";
    }

    private static List<T> ParseEach<T>(string file, JsonElement rows, Func<JsonElement, string> idOf,
        Action<JsonElement, Action<string, string>> check, List<DataIssue> issues)
    {
        var res = new List<T>();
        if (rows.ValueKind != JsonValueKind.Array)
        {
            Err(issues, file, "(file)", "(root)", "phải là một mảng JSON");
            return res;
        }
        var idx = 0;
        foreach (var row in rows.EnumerateArray())
        {
            var id = idOf(row);
            if (id.Length == 0) id = $"(dòng #{idx})";
            var bad = false;
            check(row, (field, msg) => { bad = true; Err(issues, file, id, field, msg); });
            if (!bad)
            {
                try { res.Add(row.Deserialize<T>(JsonOptions.Default)!); }
                catch (JsonException e) { Err(issues, file, id, "(root)", e.Message); }
            }
            idx++;
        }
        return res;
    }

    private static void Dupes(string file, IEnumerable<string> ids, List<DataIssue> issues)
    {
        var seen = new HashSet<string>();
        foreach (var id in ids)
            if (!seen.Add(id)) Err(issues, file, id, "id", "id bị trùng");
    }

    // ---------- kiểm schema từng loại (tương đương zod) ----------
    private sealed class Obj(JsonElement e, string path, Action<string, string> fail)
    {
        private string P(string k) => path.Length == 0 ? k : $"{path}.{k}";
        public bool Has(string k, out JsonElement v)
        {
            v = default;
            return e.ValueKind == JsonValueKind.Object && e.TryGetProperty(k, out v);
        }

        public string? Str(string k, bool required = true, bool minLen1 = false)
        {
            if (!Has(k, out var v) || v.ValueKind == JsonValueKind.Null)
            {
                if (required) fail(P(k), "bắt buộc");
                return null;
            }
            if (v.ValueKind != JsonValueKind.String) { fail(P(k), "phải là chuỗi"); return null; }
            var s = v.GetString()!;
            if (minLen1 && s.Length == 0) fail(P(k), "không được rỗng");
            return s;
        }

        public void Id(string k)
        {
            var s = Str(k);
            if (s is not null && !IdRegex().IsMatch(s)) fail(P(k), "id phải là snake_case ASCII không dấu");
        }

        public void Enum(string k, string[] allowed, bool required = true)
        {
            var s = Str(k, required);
            if (s is not null && !allowed.Contains(s)) fail(P(k), $"giá trị \"{s}\" không hợp lệ");
        }

        public double? Num(string k, bool required = true, bool nonNeg = false, bool positive = false)
        {
            if (!Has(k, out var v) || v.ValueKind == JsonValueKind.Null)
            {
                if (required) fail(P(k), "bắt buộc");
                return null;
            }
            if (v.ValueKind != JsonValueKind.Number) { fail(P(k), "phải là số"); return null; }
            var d = v.GetDouble();
            if (!double.IsFinite(d)) { fail(P(k), "phải hữu hạn"); return null; }
            if (nonNeg && d < 0) fail(P(k), "không được âm");
            if (positive && d <= 0) fail(P(k), "phải > 0");
            return d;
        }

        public void Bool(string k)
        {
            if (Has(k, out var v) && v.ValueKind != JsonValueKind.True && v.ValueKind != JsonValueKind.False) fail(P(k), "phải là true/false");
        }

        public void StrArray(string k, string[]? allowed = null, int min = 0)
        {
            if (!Has(k, out var v)) { if (min > 0) fail(P(k), "bắt buộc"); return; }
            if (v.ValueKind != JsonValueKind.Array) { fail(P(k), "phải là mảng"); return; }
            var n = 0;
            foreach (var x in v.EnumerateArray())
            {
                if (x.ValueKind != JsonValueKind.String) fail($"{P(k)}.{n}", "phải là chuỗi");
                else if (allowed is not null && !allowed.Contains(x.GetString()!)) fail($"{P(k)}.{n}", $"giá trị \"{x.GetString()}\" không hợp lệ");
                n++;
            }
            if (n < min) fail(P(k), $"cần ít nhất {min} phần tử");
        }

        public Obj? Child(string k)
        {
            if (!Has(k, out var v)) { fail(P(k), "bắt buộc"); return null; }
            if (v.ValueKind != JsonValueKind.Object) { fail(P(k), "phải là đối tượng"); return null; }
            return new Obj(v, P(k), fail);
        }

        public List<Obj> Items(string k, int min = 0)
        {
            var list = new List<Obj>();
            if (!Has(k, out var v)) { if (min > 0) fail(P(k), "bắt buộc"); return list; }
            if (v.ValueKind != JsonValueKind.Array) { fail(P(k), "phải là mảng"); return list; }
            var n = 0;
            foreach (var x in v.EnumerateArray())
            {
                var p = $"{P(k)}.{n}";
                if (x.ValueKind != JsonValueKind.Object) fail(p, "phải là đối tượng");
                else list.Add(new Obj(x, p, fail));
                n++;
            }
            if (n < min) fail(P(k), $"cần ít nhất {min} phần tử");
            return list;
        }
    }

    private static Obj? Root(JsonElement e, Action<string, string> fail)
    {
        if (e.ValueKind == JsonValueKind.Object) return new Obj(e, "", fail);
        fail("(root)", "phải là đối tượng");
        return null;
    }

    private static void CheckIngredient(JsonElement e, Action<string, string> fail)
    {
        var o = Root(e, fail);
        if (o is null) return;
        o.Id("id"); o.Str("name", minLen1: true); o.StrArray("aliases"); o.Enum("aisle", Enums.Aisles);
        var m = o.Child("per_100g");
        if (m is not null) foreach (var k in new[] { "kcal", "protein_g", "carb_g", "fat_g", "fiber_g" }) m.Num(k, nonNeg: true);
        var s = o.Child("source");
        if (s is not null) { s.Enum("db", ["VN_FCT_2007", "USDA_FDC"]); s.Str("code", minLen1: true); s.Str("note", required: false); }
        o.StrArray("allergen_tags", Enums.AllergenTags); o.StrArray("diet_tags", Enums.DietTags);
        foreach (var u in o.Items("household_units")) { u.Str("unit", minLen1: true); u.Num("grams", positive: true); }
        if (o.Has("edible_portion", out _))
        {
            var ep = o.Num("edible_portion");
            if (ep is { } d && (d <= 0 || d > 1)) fail("edible_portion", "phải trong (0, 1]");
        }
        o.Bool("default_pantry");
        if (o.Has("purchase_as", out _))
        {
            var pa = o.Child("purchase_as");
            if (pa is not null)
            {
                pa.Id("ingredient_id");
                var f = pa.Num("factor");
                if (f is { } d && (d <= 0 || d > 1)) fail("purchase_as.factor", "phải trong (0, 1]");
            }
        }
    }

    private static void CheckRecipe(JsonElement e, Action<string, string> fail)
    {
        var o = Root(e, fail);
        if (o is null) return;
        o.Id("id"); o.Str("name", minLen1: true);
        o.StrArray("meal_types", Enums.MealTypes, min: 1);
        o.StrArray("lunch_style", ["hot", "packed"]);
        o.Enum("snack_style", ["sweet", "savory"], required: false);
        o.StrArray("cuisine_tags"); o.StrArray("health_tags"); o.StrArray("equipment", Enums.Equipment);
        o.Num("cook_minutes", nonNeg: true); o.Bool("batchable"); o.Bool("is_low_carb");
        foreach (var li in o.Items("ingredients", min: 1))
        {
            li.Id("ingredient_id"); li.Num("grams", positive: true); li.Enum("role", Enums.Roles);
            li.Num("min_g", nonNeg: true); li.Num("max_g", nonNeg: true); li.Str("swap_group", required: false);
        }
        o.StrArray("steps"); o.Str("image", required: false);
        o.Enum("dish_role", Enums.DishRoles, required: false);
        o.StrArray("pairs_with");
        o.Bool("portable"); o.Bool("low_carb_ok");
    }

    private static void CheckStore(JsonElement e, Action<string, string> fail)
    {
        var o = Root(e, fail);
        if (o is null) return;
        o.Id("id"); o.Str("name", minLen1: true); o.Str("price_survey_date", required: false);
    }

    private static void CheckPrice(JsonElement e, Action<string, string> fail)
    {
        var o = Root(e, fail);
        if (o is null) return;
        o.Id("ingredient_id"); o.Id("store_id"); o.Num("pack_g", positive: true); o.Str("pack_label", minLen1: true);
        o.Num("price_vnd", nonNeg: true);
        var d = o.Num("shelf_life_days", positive: true);
        if (d is { } v && v != Math.Floor(v)) fail("shelf_life_days", "phải là số nguyên");
        o.Str("source_url", required: false); o.Str("surveyed_on", required: false);
    }
}
