using System.Text.Json.Serialization;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

/// <summary>T-116 / D-SHP-06: nhóm mua của một nguyên liệu, suy từ `storage.json` + quầy (không có file thứ hai).</summary>
public enum BuyMode { Week, Day }

public sealed record BuyInfo(
    BuyMode Group,
    /// <summary>Số ngày còn tươi theo cận dưới (ngăn mát, nếu không có thì để ngoài). null khi không có số.</summary>
    int? FreshDays,
    /// <summary>`chua_co_nguon` hoặc không có dòng bảo quản: UI ghi "Chưa có thông tin hạn dùng".</summary>
    bool NoShelfInfo,
    /// <summary>Thịt/cá tươi cấp đông được: công tắc "Mua thịt cá cả tuần rồi cấp đông" chuyển dòng này sang Theo tuần.</summary>
    bool FreezableMeat);

public sealed class ShoppingTrip
{
    /// <summary>Ngày trong tuần (0 = ngày đầu của kế hoạch) mà đợt mua này phục vụ — đợt mua diễn ra vào ngày này.</summary>
    public int DayIndex { get; init; }
    /// <summary>Các dòng của đợt (chỉ nhóm Theo ngày), gram và số gói tính riêng cho đợt.</summary>
    public List<ShoppingItem> Items { get; init; } = [];
    /// <summary>Tiền theo gói của đợt, làm tròn 1.000 ₫ (không trừ nhà có sẵn).</summary>
    public double TillCost { get; init; }
}

public static class ShoppingGroups
{
    /// <summary>Số ngày tối đa của đợt mua theo ngày: nguyên liệu không có số ngày (đã xếp Theo ngày theo quầy) coi như dùng ngay.</summary>
    private const int DefaultFreshDays = 1;

    /// <summary>Quầy đồ khô, khô/gia vị: khi chưa có dữ liệu → Theo tuần (D-SHP-07).</summary>
    private static bool DryAisle(string aisle) => aisle is "gao_do_kho" or "gia_vi_dau";

    private static bool FreshMeatAisle(string aisle) => aisle is "thit" or "ca_hai_san";

    /// <summary>
    /// Quy tắc D-SHP-06 (bảng đầy đủ: docs/research/ingredient-storage-groups.md):
    /// 1) thịt/cá tươi → Theo ngày (cấp đông được thì có công tắc đưa sang Theo tuần);
    /// 2) `long_term` → Theo tuần; 3) còn lại theo số ngày ngăn mát (không có thì ngoài tủ) cận dưới: ≤ 5 → Theo ngày, ≥ 6 → Theo tuần
    /// (trứng 21 ngày nên rơi vào Theo tuần); 4) không có số liệu → theo quầy, ghi "Chưa có thông tin hạn dùng".
    /// </summary>
    public static BuyInfo Classify(Dataset book, string ingredientId)
    {
        var aisle = book.IngredientsById.TryGetValue(ingredientId, out var ing) ? ing.Aisle : "";
        book.StorageByIngredient.TryGetValue(ingredientId, out var s);
        var noInfo = s is null || s.Status == "chua_co_nguon";
        int? days = s is null ? null : s.FridgeDays ?? s.PantryDays;

        if (FreshMeatAisle(aisle))
            return new BuyInfo(BuyMode.Day, noInfo ? null : days, noInfo, s?.Freezable == true);
        if (noInfo)
        {
            // Không có số liệu: để lâu hoặc quầy khô → tuần; còn lại (rau, quả, sữa, đậu phụ) → ngày. Không đoán số ngày.
            var week = s?.LongTerm == true || DryAisle(aisle);
            return new BuyInfo(week ? BuyMode.Week : BuyMode.Day, null, true, false);
        }
        if (s!.LongTerm) return new BuyInfo(BuyMode.Week, days, false, false);
        if (days is null) return new BuyInfo(BuyMode.Week, null, false, false);
        return new BuyInfo(days.Value <= 5 ? BuyMode.Day : BuyMode.Week, days, false, false);
    }

    /// <summary>
    /// Đợt mua theo ngày: với mỗi nguyên liệu nhóm Theo ngày, các ngày dùng được gộp vào đợt sớm nhất còn tươi
    /// (mua ngày d dùng được đến ngày d + N − 1, N = số ngày tươi cận dưới). Gram mỗi nguyên liệu qua các đợt cộng lại bằng cả tuần;
    /// số gói làm tròn riêng từng đợt. Đợt xếp theo ngày, dòng trong đợt theo quầy rồi tên.
    /// </summary>
    internal static List<ShoppingTrip> BuildTrips(Dataset book, string storeId, IReadOnlyDictionary<string, SortedDictionary<int, double>> usageByDay,
        IReadOnlyDictionary<string, BuyInfo> info, bool displayQty, ISet<string> pantry)
    {
        var byDay = new SortedDictionary<int, List<ShoppingItem>>();
        foreach (var (id, uses) in usageByDay)
        {
            if (!info.TryGetValue(id, out var bi)) continue; // tổng gram ≤ 0: không có dòng trong danh sách
            if (bi.Group != BuyMode.Day) continue;
            var ing = book.IngredientsById[id];
            var (price, fallback) = Shopping.ResolvePrice(book, id, storeId);
            var window = Math.Max(DefaultFreshDays, bi.FreshDays ?? DefaultFreshDays);
            var days = uses.Keys.ToList();
            for (var i = 0; i < days.Count;)
            {
                var buyDay = days[i];
                double grams = 0;
                while (i < days.Count && days[i] <= buyDay + window - 1) { grams += uses[days[i]]; i++; }
                if (grams <= 0) continue;
                var need = grams / ing.EdiblePortion;
                var packs = (int)Math.Max(1, Math.Ceiling(need / price.PackG - 1e-9));
                if (!byDay.TryGetValue(buyDay, out var list)) byDay[buyDay] = list = [];
                list.Add(new ShoppingItem
                {
                    IngredientId = id, Name = ing.Name, Aisle = ing.Aisle, NeedG = need, Packs = packs,
                    PackG = price.PackG, PackLabel = price.PackLabel, PriceVndPerPack = price.PriceVnd,
                    UsedCostVnd = need / price.PackG * price.PriceVnd,
                    TillCostVnd = packs * price.PriceVnd,
                    LeftoverG = packs * price.PackG - need,
                    LeftoverDays = price.ShelfLifeDays,
                    PriceStoreId = price.StoreId, PriceFallback = fallback,
                    DisplayQty = displayQty ? Shopping.DisplayQtyOf(packs, price.PackLabel) : null,
                    IsDefaultPantry = displayQty ? ing.DefaultPantry : null,
                    IsPantry = displayQty ? pantry.Contains(id) : null,
                    BuyGroup = "day", FreshDays = bi.FreshDays, NoShelfInfo = bi.NoShelfInfo, FreezableMeat = bi.FreezableMeat,
                });
            }
        }
        var aisles = Enums.Aisles;
        return byDay.Select(kv =>
        {
            var sorted = kv.Value.OrderBy(i => Array.IndexOf(aisles, i.Aisle)).ThenBy(i => i.Name, ViCollator.Instance).ToList();
            return new ShoppingTrip { DayIndex = kv.Key, Items = sorted, TillCost = Shopping.RoundMoney(sorted.Where(i => !pantry.Contains(i.IngredientId)).Sum(i => i.TillCostVnd)) };
        }).ToList();
    }

    /// <summary>
    /// Tổng tiền tại quầy của cả tuần theo hai chế độ (cùng cách tính với app): các dòng nhà có sẵn không tính;
    /// `freezeMeat` = thịt cá cấp đông được mua cả tuần (chuyển từ các đợt sang Theo tuần).
    /// </summary>
    public static (double Week, double Day, double Total) TillTotals(ShoppingList list, ISet<string> pantry, bool freezeMeat)
    {
        bool Frozen(ShoppingItem i) => freezeMeat && i.FreezableMeat == true;
        var week = Shopping.RoundMoney(list.Items.Where(i => (i.BuyGroup == "week" || Frozen(i)) && !pantry.Contains(i.IngredientId)).Sum(i => i.TillCostVnd));
        var day = (list.Trips ?? []).Sum(t => Shopping.RoundMoney(t.Items.Where(i => !Frozen(i) && !pantry.Contains(i.IngredientId)).Sum(i => i.TillCostVnd)));
        return (week, day, week + day);
    }
}
