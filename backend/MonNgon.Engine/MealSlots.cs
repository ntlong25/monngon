using System.Text.Json.Serialization;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed class SlotTarget
{
    public string Slot { get; init; } = "";
    public string Mode { get; init; } = "on";
    /// <summary>Tỉ lệ kcal đã chuẩn hóa trong ngày (0 nếu skip); đã tính phần dồn kcal sang trưa/tối của mức cơm nhiều (D-COM-04).</summary>
    public double Share { get; init; }
    /// <summary>Tỉ lệ đạm đã chuẩn hóa trong ngày: phân bổ mặc định, không đổi theo phần dồn kcal.</summary>
    [JsonIgnore]
    public double ProteinShare { get; init; }
    public double Kcal { get; init; }
    public double ProteinG { get; init; }
    /// <summary>Chỉ "on" mới lên món; "self" giữ phần chỉ tiêu nhưng không có món.</summary>
    public bool Planned { get; init; }
}

public sealed class NoMainMealException()
    : Exception("Cần ít nhất 1 bữa chính (sáng/trưa/tối) ở chế độ \"Lên thực đơn\"");

public static class MealSlots
{
    public static readonly string[] MainSlots = ["breakfast", "lunch", "dinner"];

    public static double DefaultShare(string slot) => slot switch
    {
        "breakfast" => 0.2, "lunch" => 0.35, "dinner" => 0.35, "snack_am" => 0.05, "snack_pm" => 0.05,
        _ => throw new ArgumentOutOfRangeException(nameof(slot), slot, null),
    };

    /// <summary>
    /// <paramref name="kcalShift"/> (D-COM-04, mức cơm nhiều): tối đa phần này của kcal cả ngày được chuyển từ bữa sáng/bữa phụ (đang "on")
    /// sang bữa trưa/tối (đang "on"), chia đều cho trưa/tối; không chuyển quá nửa phần của sáng/phụ. Đạm giữ phân bổ mặc định.
    /// </summary>
    public static List<SlotTarget> Allocate(Targets targets, SlotsConfig cfg, double kcalShift = 0)
    {
        if (!MainSlots.Any(s => cfg.Mode(s) == "on")) throw new NoMainMealException();
        double total = 0;
        foreach (var s in Enums.Slots) total += cfg.Mode(s) == "skip" ? 0 : DefaultShare(s);
        var kShare = new Dictionary<string, double>();
        foreach (var slot in Enums.Slots) kShare[slot] = cfg.Mode(slot) == "skip" ? 0 : DefaultShare(slot) / total;
        var takers = new[] { "lunch", "dinner" }.Where(s => cfg.Mode(s) == "on").ToList();
        var givers = new[] { "breakfast", "snack_am", "snack_pm" }.Where(s => cfg.Mode(s) == "on").ToList();
        if (kcalShift > 0 && takers.Count > 0 && givers.Count > 0)
        {
            var pool = givers.Sum(s => kShare[s]);
            var moved = Math.Min(kcalShift, 0.5 * pool);
            foreach (var s in givers) kShare[s] -= moved * kShare[s] / pool;
            foreach (var s in takers) kShare[s] += moved / takers.Count;
        }
        var res = new List<SlotTarget>();
        foreach (var slot in Enums.Slots)
        {
            var mode = cfg.Mode(slot);
            var pShare = mode == "skip" ? 0 : DefaultShare(slot) / total;
            res.Add(new SlotTarget
            {
                Slot = slot, Mode = mode, Share = kShare[slot], ProteinShare = pShare,
                Kcal = targets.KcalTarget * kShare[slot], ProteinG = targets.ProteinG * pShare, Planned = mode == "on",
            });
        }
        return res;
    }
}
