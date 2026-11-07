using System.Text.Json.Serialization;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

/// <summary>
/// Kiểu bữa trưa/tối (T-066).
/// Auto: ứng viên gồm công thức trọn suất (full_meal) VÀ mâm ghép (main + canh + rau + cơm).
/// MamOnly: chỉ mâm (nếu không ghép được cho bữa đó thì dùng trọn suất).
/// FullMealOnly: hành vi cũ của bản parity (T-064): mọi công thức là ứng viên đơn lẻ, KHÔNG ghép mâm — khớp golden/ từng chữ số.
/// </summary>
public enum MealStyle { Auto, FullMealOnly, MamOnly }

public static class MealStyles
{
    public static string ToWire(MealStyle s) => s switch { MealStyle.Auto => "auto", MealStyle.FullMealOnly => "full_meal_only", _ => "mam_only" };
    public static bool TryParse(string? s, out MealStyle style)
    {
        switch (s)
        {
            case "auto": style = MealStyle.Auto; return true;
            case "full_meal_only": style = MealStyle.FullMealOnly; return true;
            case "mam_only": style = MealStyle.MamOnly; return true;
            default: style = MealStyle.Auto; return false;
        }
    }
    public static readonly string[] Wire = ["auto", "full_meal_only", "mam_only"];
}

/// <summary>Một món trong bữa: vai trò (full_meal | main | soup | side_veg | carb_base | extra), gram sau scale và macro.</summary>
public sealed class Dish
{
    public string Role { get; set; } = "";
    /// <summary>null với dòng "extra" (món thêm do engine bù calo/đạm).</summary>
    public string? RecipeId { get; set; }
    public string Name { get; set; } = "";
    public List<GramLine> Grams { get; set; } = [];
    public Macros Macros { get; set; } = Macros.Zero;
}

public sealed record MamPart(string Role, Recipe Recipe, int Start, int Count);

/// <summary>Thông tin một mâm đã ghép: công thức tổng hợp (nối nguyên liệu các món) + các phần để tách lại thành dishes[].</summary>
public sealed class MamInfo
{
    public required Recipe Composite { get; init; }
    public required List<MamPart> Parts { get; init; }
    public required string MainId { get; init; }
    public string? SoupId { get; init; }
    public string? VegId { get; init; }
    public bool HasCarbBase { get; init; }
    /// <summary>D-COM-01: chỉ số dòng cơm trong công thức tổng hợp (-1 nếu mâm không có cơm).</summary>
    public int RiceIdx { get; init; } = -1;
    public double RiceTargetG { get; init; }
    public double RiceFloorG { get; init; }
}

/// <summary>D-COM-01: thói quen ăn cơm → gram cơm chín mỗi bữa mâm (cho người dùng chính).</summary>
public static class RiceHabits
{
    public const string Default = "vua";
    /// <summary>Mức "vừa" cũng là khẩu phần chuẩn của người lớn khác trong hộ.</summary>
    public const double StdG = 150;
    public const double StepG = 25;
    public const double FloorMinG = 60;
    public const double FloorRatio = 0.5;
    /// <summary>Sai số cho phép giữa lượng chọn và lượng thực (làm tròn); thấp hơn nữa là bữa bị giảm cơm → phải có ghi chú.</summary>
    public const double ToleranceG = 10;
    /// <summary>Nguyên liệu tham chiếu để quy tinh bột khác (bún, khoai) ra kcal tương đương.</summary>
    public const string ReferenceIngredient = "com_trang";

    public static double TargetG(string? habit) => habit switch { "it" => 75, "nhieu" => 300, "rat_nhieu" => 450, _ => 150 };

    public static double FloorG(string? habit)
    {
        var t = TargetG(habit);
        return Math.Min(t, Math.Max(FloorMinG, t * FloorRatio));
    }
}

/// <summary>Thói quen ăn cơm + bảng nguyên liệu để quy đổi kcal tương đương cho dòng tinh bột của mâm.</summary>
public sealed record RiceSpec(string? Habit, IReadOnlyDictionary<string, Ingredient> Ingredients);

public static class MamBuilder
{
    /// <summary>Món phụ (canh/rau) chỉ được có đạm "nhẹ" để không thành món đạm thứ hai trong mâm.</summary>
    public const double MaxSideProteinG = 12;

    public const string IdPrefix = "mam:";

    public static List<MamInfo> Build(IReadOnlyList<Recipe> valid, Func<Recipe, double> cost, IReadOnlyDictionary<string, Ingredient> ingredients, Preferences prefs, int variants)
    {
        var rice = new RiceSpec(prefs.RiceHabit, ingredients);
        var low = prefs.LowCarb;
        var mains = valid.Where(r => r.DishRole == "main" && (!low || r.IsLowCarb)).ToList();
        if (mains.Count == 0) return [];

        double Protein(Recipe r) => Nutrition.Compute(r.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList(), ingredients).Total.ProteinG;
        List<Recipe> Sides(string role) => valid
            .Where(r => r.DishRole == role && (!low || r.IsLowCarb) && Protein(r) <= MaxSideProteinG)
            .ToList();
        var soups = Sides("soup");
        var vegs = Sides("side_veg");
        var carbs = low ? [] : valid.Where(r => r.DishRole == "carb_base").OrderBy(cost).ThenBy(r => r.Id, StringComparer.Ordinal).ToList();
        var packed = prefs.Slots.LunchStyle == "packed";

        List<Recipe> Rank(List<Recipe> pool, Recipe main) => pool
            .OrderByDescending(s => s.PairsWith.Count(main.CuisineTags.Contains))
            .ThenBy(cost).ThenBy(s => s.Id, StringComparer.Ordinal)
            .Take(8).ToList();

        var res = new List<MamInfo>();
        var seen = new HashSet<string>();
        for (var mi = 0; mi < mains.Count; mi++)
        {
            var main = mains[mi];
            var rs = Rank(soups, main);
            var rv = Rank(vegs, main);
            for (var k = 0; k < Math.Max(1, variants); k++)
            {
                // Biến thể cuối (khi có ≥ 3 biến thể) không có canh: mâm rau + cơm, làm "van xả" khi canh đã dùng đủ lượt trong tuần.
                // D-COM-02: món chính dạng canh (tag "canh", id *_mam) đã là canh của mâm → không ghép thêm canh thứ hai.
                var soupMain = main.CuisineTags.Contains("canh");
                var soup = !soupMain && rs.Count > 0 && !(variants >= 3 && k == variants - 1) ? rs[(mi * 2 + k * 3) % rs.Count] : null;
                var veg = rv.Count > 0 ? rv[(mi * 3 + k * 5) % rv.Count] : null;
                var carb = carbs.Count > 0 ? carbs[k % carbs.Count] : null;
                if (soup is null && veg is null && carb is null) continue;
                var info = Compose(main, soup, veg, carb, packed, rice);
                if (seen.Add(info.Composite.Id)) res.Add(info);

                // Trưa mang đi: canh không mang đi được → mâm riêng cho bữa trưa gồm món chính + rau + cơm đều "packed" (bữa tối vẫn có canh).
                if (packed && main.MealTypes.Contains("lunch") && main.LunchStyle.Contains("packed"))
                {
                    var pv = rv.Where(v => v.LunchStyle.Contains("packed")).ToList();
                    var pc = carbs.Where(c => c.LunchStyle.Contains("packed")).ToList();
                    var veg2 = pv.Count > 0 ? pv[(mi * 3 + k * 5) % pv.Count] : null;
                    var carb2 = pc.Count > 0 ? pc[k % pc.Count] : null;
                    if (veg2 is null && carb2 is null) continue;
                    var lunch = Compose(main, null, veg2, carb2, false, rice);
                    lunch.Composite.Id += "~L";
                    lunch.Composite.MealTypes = ["lunch"];
                    lunch.Composite.LunchStyle = ["packed"];
                    if (seen.Add(lunch.Composite.Id)) res.Add(lunch);
                }
            }
        }
        return res;
    }

    /// <summary>
    /// Dựng lại một mâm đã có từ id ("mam:{main}+{canh}+{rau}+{cơm}", có thể kèm "~L" cho trưa mang đi) — dùng khi chỉnh tuần đã lập:
    /// mâm cũ phải tra được dù bộ lọc hiện tại (vd món vừa bị chặn) không còn tạo ra nó. null nếu id không hợp lệ hoặc công thức không còn trong kho.
    /// </summary>
    public static MamInfo? Rebuild(string id, MonNgon.Engine.Data.Dataset data, string? riceHabit = null)
    {
        var rice = new RiceSpec(riceHabit, data.IngredientsById);
        if (!id.StartsWith(IdPrefix, StringComparison.Ordinal)) return null;
        var packedLunch = id.EndsWith("~L", StringComparison.Ordinal);
        var body = id[IdPrefix.Length..];
        if (packedLunch) body = body[..^2];
        Recipe? main = null, soup = null, veg = null, carb = null;
        foreach (var rid in body.Split('+'))
        {
            if (!data.RecipesById.TryGetValue(rid, out var r)) return null;
            switch (r.DishRole)
            {
                case "main" when main is null: main = r; break;
                case "soup" when soup is null: soup = r; break;
                case "side_veg" when veg is null: veg = r; break;
                case "carb_base" when carb is null: carb = r; break;
                default: return null;
            }
        }
        if (main is null) return null;
        var info = Compose(main, soup, veg, carb, false, rice);
        if (packedLunch)
        {
            info.Composite.Id += "~L";
            info.Composite.MealTypes = ["lunch"];
            info.Composite.LunchStyle = ["packed"];
        }
        return info.Composite.Id == id ? info : null;
    }

    private static double Round5(double x) => Math.Round(x / 5, MidpointRounding.AwayFromZero) * 5;

    private static RecipeIngredient Copy(RecipeIngredient i, bool pin) => new()
    {
        IngredientId = i.IngredientId, Grams = i.Grams, Role = i.Role, SwapGroup = i.SwapGroup,
        MinG = pin ? i.Grams : i.MinG, MaxG = pin ? i.Grams : i.MaxG,
    };

    /// <summary>
    /// D-COM-01: dòng tinh bột của phần carb_base. Cơm trắng/gạo lứt (có purchase_as) dùng cùng số gram với mức đã chọn;
    /// tinh bột khác (bún, khoai) quy theo kcal tương đương cơm trắng (làm tròn 5 g). Gram chuẩn (Grams) = mức "vừa" cho người ăn cùng.
    /// </summary>
    private static RecipeIngredient RiceLine(RecipeIngredient i, RiceSpec spec)
    {
        var ratio = 1.0;
        if (spec.Ingredients.TryGetValue(i.IngredientId, out var ing) && ing.PurchaseAs is null
            && spec.Ingredients.TryGetValue(RiceHabits.ReferenceIngredient, out var refRice) && ing.Per100g.Kcal > 0)
            ratio = refRice.Per100g.Kcal / ing.Per100g.Kcal;
        var target = Round5(RiceHabits.TargetG(spec.Habit) * ratio);
        var std = Round5(RiceHabits.StdG * ratio);
        var floor = Math.Min(target, Math.Ceiling(RiceHabits.FloorG(spec.Habit) * ratio / 5) * 5);
        return new()
        {
            IngredientId = i.IngredientId, Grams = std, Role = i.Role, SwapGroup = i.SwapGroup,
            MinG = Math.Min(i.MinG, floor), MaxG = Math.Max(i.MaxG, Math.Max(target, std)),
            RiceTargetG = target, RiceFloorG = floor,
        };
    }

    internal static MamInfo Compose(Recipe main, Recipe? soup, Recipe? veg, Recipe? carb, bool packedLunch, RiceSpec? rice = null)
    {
        var riceIdx = -1;
        double riceTarget = 0, riceFloor = 0;
        var ings = new List<RecipeIngredient>();
        var parts = new List<MamPart>();
        var steps = new List<string>();
        void Add(string role, Recipe? r, bool pin)
        {
            if (r is null) return;
            parts.Add(new MamPart(role, r, ings.Count, r.Ingredients.Count));
            foreach (var i in r.Ingredients)
            {
                if (role == "carb_base" && rice is not null && i.Role == "carb" && riceIdx < 0)
                {
                    var rl = RiceLine(i, rice);
                    riceIdx = ings.Count;
                    riceTarget = rl.RiceTargetG!.Value;
                    riceFloor = rl.RiceFloorG!.Value;
                    ings.Add(rl);
                }
                else ings.Add(Copy(i, pin));
            }
            if (r.Steps.Count > 0) { steps.Add($"— {r.Name} —"); steps.AddRange(r.Steps); }
        }
        Add("main", main, false);
        Add("soup", soup, true);
        Add("side_veg", veg, true);
        Add("carb_base", carb, false);

        var recipes = parts.Select(p => p.Recipe).ToList();
        var composite = new Recipe
        {
            Id = IdPrefix + string.Join("+", recipes.Select(r => r.Id)),
            Name = string.Join(" + ", recipes.Select(r => r.Name)),
            MealTypes = packedLunch ? main.MealTypes.Where(t => t != "lunch").ToList() : [.. main.MealTypes],
            LunchStyle = [.. main.LunchStyle],
            SnackStyle = null,
            CuisineTags = recipes.SelectMany(r => r.CuisineTags).Distinct().ToList(),
            HealthTags = recipes.SelectMany(r => r.HealthTags).Distinct().ToList(),
            Equipment = recipes.SelectMany(r => r.Equipment).Distinct().ToList(),
            CookMinutes = recipes.Sum(r => r.CookMinutes),
            Batchable = recipes.All(r => r.Batchable),
            IsLowCarb = carb is null && recipes.All(r => r.IsLowCarb),
            Ingredients = ings,
            Steps = steps,
            Image = null,
            DishRole = "mam",
        };
        return new MamInfo { Composite = composite, Parts = parts, MainId = main.Id, SoupId = soup?.Id, VegId = veg?.Id, HasCarbBase = carb is not null, RiceIdx = riceIdx, RiceTargetG = riceTarget, RiceFloorG = riceFloor };
    }
}
