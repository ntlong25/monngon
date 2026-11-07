using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed class SlotTarget
{
    public string Slot { get; init; } = "";
    public string Mode { get; init; } = "on";
    /// <summary>Tỉ lệ đã chuẩn hóa trong ngày (0 nếu skip).</summary>
    public double Share { get; init; }
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

    public static List<SlotTarget> Allocate(Targets targets, SlotsConfig cfg)
    {
        if (!MainSlots.Any(s => cfg.Mode(s) == "on")) throw new NoMainMealException();
        double total = 0;
        foreach (var s in Enums.Slots) total += cfg.Mode(s) == "skip" ? 0 : DefaultShare(s);
        var res = new List<SlotTarget>();
        foreach (var slot in Enums.Slots)
        {
            var mode = cfg.Mode(slot);
            var share = mode == "skip" ? 0 : DefaultShare(slot) / total;
            res.Add(new SlotTarget
            {
                Slot = slot, Mode = mode, Share = share,
                Kcal = targets.KcalTarget * share, ProteinG = targets.ProteinG * share, Planned = mode == "on",
            });
        }
        return res;
    }
}
