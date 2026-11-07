using System.Text.RegularExpressions;
using System.Text.Json.Serialization;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed record ShoppingIngredient(string IngredientId, double Grams, double StandardGrams);

public sealed class ShoppingMeal
{
    public List<ShoppingIngredient> Ingredients { get; init; } = [];
}

public sealed record Household(int Adults, int Children);

public sealed class ShoppingItem
{
    public string IngredientId { get; init; } = "";
    public string Name { get; init; } = "";
    public string Aisle { get; init; } = "";
    /// <summary>Lượng cần mua (g), đã tính phần không ăn được (edible_portion).</summary>
    public double NeedG { get; init; }
    public int Packs { get; init; }
    public double PackG { get; init; }
    public string PackLabel { get; init; } = "";
    public double PriceVndPerPack { get; init; }
    /// <summary>Chi phí theo gram dùng (món ăn) và theo gói (trả tại quầy), chưa làm tròn.</summary>
    public double UsedCostVnd { get; init; }
    public double TillCostVnd { get; init; }
    public double LeftoverG { get; init; }
    public double LeftoverDays { get; init; }
    public string PriceStoreId { get; init; } = "";
    public bool PriceFallback { get; init; }
    /// <summary>Lượng theo đơn vị mua, ví dụ "3 quả", "1 lốc", "2 kg" (suy từ pack_label). null khi chạy chế độ parity.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? DisplayQty { get; init; }
    /// <summary>Nguyên liệu mặc định "nhà có sẵn" (gia vị, dầu...). null khi chạy chế độ parity.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public bool? IsDefaultPantry { get; init; }
    /// <summary>
    /// D-SHP-01: dòng này đang được coi là "nhà có sẵn" (theo `pantry_ids` của request, hoặc mặc định `default_pantry` khi không gửi).
    /// Dòng vẫn nằm trong danh sách (để người dùng bỏ đánh dấu) nhưng không tính vào `till_cost`. null khi chạy chế độ parity.
    /// </summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public bool? IsPantry { get; init; }
}

public sealed class AisleGroup
{
    public string Aisle { get; init; } = "";
    public List<ShoppingItem> Items { get; init; } = [];
}

public sealed class ShoppingList
{
    public List<ShoppingItem> Items { get; init; } = [];
    public List<AisleGroup> ByAisle { get; init; } = [];
    public List<string> SkippedPantry { get; init; } = [];
    /// <summary>Chi phí món ăn tuần này (theo gram dùng), làm tròn 1.000 ₫.</summary>
    public double WeekFoodCost { get; init; }
    /// <summary>Ước tính trả tại quầy (theo gói), làm tròn 1.000 ₫. Không gồm các dòng nhà có sẵn (D-SHP-01).</summary>
    public double TillCost { get; init; }
    /// <summary>"Nếu phải mua": tiền theo gói của các dòng nhà có sẵn, làm tròn 1.000 ₫. null khi chạy chế độ parity.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public double? PantryCostIfBuyVnd { get; init; }
}

public static class Shopping
{
    public const double ChildPortion = 0.6;
    public const double MoneyRoundVnd = 1000;
    private const double Eps = 1e-9;

    private static double RoundMoney(double x) => Js.Round(x / MoneyRoundVnd) * MoneyRoundVnd;

    public static List<string> DefaultPantryIds(IEnumerable<Ingredient> ingredients) =>
        ingredients.Where(i => i.DefaultPantry).Select(i => i.Id).ToList();

    /// <summary>D-SHP-02: nguyên liệu thực sự mua và hệ số quy đổi từ gram đã nấu (cơm chín 1 g → gạo sống 0,36 g).</summary>
    public static (string IngredientId, double Factor) PurchaseTarget(Dataset book, string ingredientId) =>
        book.IngredientsById.TryGetValue(ingredientId, out var i) && i.PurchaseAs is { } pa ? (pa.IngredientId, pa.Factor) : (ingredientId, 1.0);

    /// <summary>Hệ số nhân khẩu phần chuẩn cho những người ăn cùng ngoài "bạn".</summary>
    public static double OtherEatersFactor(Household h) => Math.Max(0, h.Adults - 1) + h.Children * ChildPortion;

    private static (Price Price, bool Fallback) ResolvePrice(Dataset book, string ingredientId, string storeId)
    {
        book.PricesByIngredient.TryGetValue(ingredientId, out var m);
        if (m is not null && m.TryGetValue(storeId, out var own)) return (own, false);
        if (m is null || !m.TryGetValue(Dataset.FallbackStoreId, out var fb))
            throw new InvalidOperationException($"Không có giá cho \"{ingredientId}\" (cả ở cửa hàng \"{storeId}\" lẫn \"{Dataset.FallbackStoreId}\")");
        return (fb, storeId != Dataset.FallbackStoreId);
    }

    /// <summary>
    /// `pantryIds`: null → ở chế độ hiển thị (displayQty) dùng danh sách `default_pantry`, ở chế độ parity không coi gì là có sẵn; `[]` → không coi gì là có sẵn (D-SHP-01).
    /// Dòng nhà có sẵn vẫn nằm trong danh sách (cờ `is_pantry`), nhưng chỉ `week_food_cost` (gram đã dùng) tính chúng; `till_cost` thì bỏ.
    /// </summary>
    public static ShoppingList BuildShoppingList(IEnumerable<ShoppingMeal> meals, Household household, Dataset book, string storeId, IEnumerable<string>? pantryIds = null, bool displayQty = false)
    {
        var others = OtherEatersFactor(household);
        var pantry = (pantryIds ?? (displayQty ? DefaultPantryIds(book.Ingredients) : [])).ToHashSet();
        // Giữ thứ tự chèn đầu tiên (như Map của JS).
        var order = new List<string>();
        var eatenG = new Dictionary<string, double>();
        foreach (var meal in meals)
            foreach (var li in meal.Ingredients)
            {
                // D-SHP-02: chỉ ở chế độ hiển thị; parity giữ nguyên bản TS (không có purchase_as).
                var (key, factor) = displayQty ? PurchaseTarget(book, li.IngredientId) : (li.IngredientId, 1.0);
                if (!eatenG.TryGetValue(key, out var cur)) { order.Add(key); cur = 0; }
                eatenG[key] = cur + (li.Grams + others * li.StandardGrams) * factor;
            }

        var items = new List<ShoppingItem>();
        var skipped = new List<string>();
        foreach (var id in order)
        {
            var grams = eatenG[id];
            if (grams <= 0) continue;
            var inPantry = pantry.Contains(id);
            if (inPantry) skipped.Add(id);
            if (!book.IngredientsById.TryGetValue(id, out var ing)) throw new InvalidOperationException($"Nguyên liệu không tồn tại: {id}");
            var (price, fallback) = ResolvePrice(book, id, storeId);
            var need = grams / ing.EdiblePortion;
            var packs = (int)Math.Max(1, Math.Ceiling(need / price.PackG - Eps));
            items.Add(new ShoppingItem
            {
                IngredientId = id, Name = ing.Name, Aisle = ing.Aisle, NeedG = need, Packs = packs,
                PackG = price.PackG, PackLabel = price.PackLabel, PriceVndPerPack = price.PriceVnd,
                UsedCostVnd = need / price.PackG * price.PriceVnd,
                TillCostVnd = packs * price.PriceVnd,
                LeftoverG = packs * price.PackG - need,
                LeftoverDays = price.ShelfLifeDays,
                PriceStoreId = price.StoreId, PriceFallback = fallback,
                DisplayQty = displayQty ? DisplayQtyOf(packs, price.PackLabel) : null,
                IsDefaultPantry = displayQty ? ing.DefaultPantry : null,
                IsPantry = displayQty ? inPantry : null,
            });
        }

        var aisles = Enums.Aisles;
        var sorted = items.OrderBy(i => Array.IndexOf(aisles, i.Aisle)).ThenBy(i => i.Name, ViCollator.Instance).ToList();
        var byAisle = aisles
            .Select(a => new AisleGroup { Aisle = a, Items = sorted.Where(i => i.Aisle == a).ToList() })
            .Where(g => g.Items.Count > 0).ToList();
        skipped.Sort(StringComparer.Ordinal);

        double used = 0, till = 0, ifBuy = 0;
        foreach (var i in sorted)
        {
            used += i.UsedCostVnd;
            if (pantry.Contains(i.IngredientId)) ifBuy += i.TillCostVnd; else till += i.TillCostVnd;
        }
        return new ShoppingList
        {
            Items = sorted, ByAisle = byAisle, SkippedPantry = skipped, WeekFoodCost = RoundMoney(used), TillCost = RoundMoney(till),
            PantryCostIfBuyVnd = displayQty ? RoundMoney(ifBuy) : null,
        };
    }

    private static readonly Regex OneUnit = new(@"^1\s+(\S.*)$", RegexOptions.Compiled);
    private static readonly Regex LeadingUnit = new(@"^(lốc|hộp|gói|chai|túi|bó|vỉ|hũ|khay|lon|thùng|bịch)(\s|$)", RegexOptions.Compiled | RegexOptions.IgnoreCase);

    /// <summary>"1 quả" × 3 → "3 quả"; "lốc 4 hộp 180 ml" × 1 → "1 lốc"; còn lại "2 × 500 g".</summary>
    public static string DisplayQtyOf(int packs, string packLabel)
    {
        var label = packLabel.Trim();
        var one = OneUnit.Match(label);
        if (one.Success) return $"{packs} {one.Groups[1].Value}";
        var lead = LeadingUnit.Match(label);
        if (lead.Success) return $"{packs} {lead.Groups[1].Value.ToLowerInvariant()}";
        return $"{packs} × {label}";
    }

    /// <summary>Chi phí ước tính của 1 suất (theo gram dùng, chưa làm tròn) — dùng cho chấm điểm chi phí.</summary>
    /// <param name="purchaseAs">true: tính theo nguyên liệu thực mua (cơm → gạo, D-SHP-02); false: chế độ parity.</param>
    public static double ServingCostVnd(IEnumerable<GramLine> lines, Dataset book, string storeId, bool purchaseAs = true)
    {
        double total = 0;
        foreach (var l in lines)
        {
            if (l.Grams <= 0) continue;
            var (id, factor) = purchaseAs ? PurchaseTarget(book, l.IngredientId) : (l.IngredientId, 1.0);
            if (!book.IngredientsById.TryGetValue(id, out var ing)) throw new InvalidOperationException($"Nguyên liệu không tồn tại: {id}");
            var (price, _) = ResolvePrice(book, id, storeId);
            total += l.Grams * factor / ing.EdiblePortion / price.PackG * price.PriceVnd;
        }
        return total;
    }

    public static double RecipeServingCostVnd(Recipe r, Dataset book, string storeId, bool purchaseAs = true) =>
        ServingCostVnd(r.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)), book, storeId, purchaseAs);
}
