using System.Text.Json;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Data;

/// <summary>Bộ dữ liệu đã nạp. Các từ điển chỉ để tra cứu; mọi vòng lặp ảnh hưởng kết quả phải duyệt các List (giữ thứ tự file).</summary>
public sealed class Dataset
{
    public const string FallbackStoreId = "cho_khac";

    public IReadOnlyList<Ingredient> Ingredients { get; }
    public IReadOnlyList<Recipe> Recipes { get; }
    public IReadOnlyList<Store> Stores { get; }
    public IReadOnlyList<Price> Prices { get; }
    public IReadOnlyDictionary<string, Ingredient> IngredientsById { get; }
    public IReadOnlyDictionary<string, Recipe> RecipesById { get; }
    public IReadOnlyDictionary<string, Store> StoresById { get; }
    /// <summary>ingredient_id → store_id → Price</summary>
    public IReadOnlyDictionary<string, IReadOnlyDictionary<string, Price>> PricesByIngredient { get; }

    public Dataset(IEnumerable<Ingredient> ingredients, IEnumerable<Recipe> recipes, IEnumerable<Store> stores, IEnumerable<Price> prices)
    {
        Ingredients = ingredients.ToList();
        Recipes = recipes.ToList();
        Stores = stores.ToList();
        Prices = prices.ToList();
        IngredientsById = Last(Ingredients, i => i.Id);
        RecipesById = Last(Recipes, r => r.Id);
        StoresById = Last(Stores, s => s.Id);
        var pb = new Dictionary<string, Dictionary<string, Price>>();
        foreach (var p in Prices)
        {
            if (!pb.TryGetValue(p.IngredientId, out var m)) pb[p.IngredientId] = m = new Dictionary<string, Price>();
            m[p.StoreId] = p;
        }
        PricesByIngredient = pb.ToDictionary(kv => kv.Key, kv => (IReadOnlyDictionary<string, Price>)kv.Value);
    }

    private static Dictionary<string, T> Last<T>(IEnumerable<T> items, Func<T, string> key)
    {
        var d = new Dictionary<string, T>();
        foreach (var x in items) d[key(x)] = x;
        return d;
    }

    /// <summary>Giá của nguyên liệu tại cửa hàng; thiếu thì dùng cho_khac.</summary>
    public (Price Price, bool Fallback)? FindPrice(string ingredientId, string storeId)
    {
        if (!PricesByIngredient.TryGetValue(ingredientId, out var m)) return null;
        if (m.TryGetValue(storeId, out var own)) return (own, false);
        if (m.TryGetValue(FallbackStoreId, out var fb)) return (fb, storeId != FallbackStoreId);
        return null;
    }

    /// <summary>Nạp nghiêm ngặt: có lỗi validate thì ném <see cref="DataException"/> (kèm file + id + trường).</summary>
    public static Dataset Load(RawDataset raw)
    {
        var res = DataValidator.Validate(raw);
        var errors = res.Issues.Where(i => i.Severity == "error").ToList();
        if (errors.Count > 0) throw new DataException(errors);
        return res.Dataset;
    }

    public static Dataset LoadDirectory(string dir) => Load(RawDataset.ReadDirectory(dir));
}

public sealed class DataException(IReadOnlyList<DataIssue> issues)
    : Exception($"Dữ liệu không hợp lệ ({issues.Count} lỗi). Đầu tiên: {(issues.Count > 0 ? issues[0].ToString() : "")}")
{
    public IReadOnlyList<DataIssue> Issues { get; } = issues;
}

/// <summary>Bốn file dữ liệu dạng JSON thô.</summary>
public sealed class RawDataset
{
    public JsonElement Ingredients { get; init; }
    public JsonElement Recipes { get; init; }
    public JsonElement Stores { get; init; }
    public JsonElement Prices { get; init; }

    public static RawDataset ReadDirectory(string dir)
    {
        JsonElement Rd(string name)
        {
            using var doc = JsonDocument.Parse(File.ReadAllText(Path.Combine(dir, name + ".json")));
            return doc.RootElement.Clone();
        }
        return new RawDataset { Ingredients = Rd("ingredients"), Recipes = Rd("recipes"), Stores = Rd("stores"), Prices = Rd("prices") };
    }
}
