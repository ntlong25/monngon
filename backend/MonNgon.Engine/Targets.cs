using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed class TargetOptions
{
    /// <summary>Dải calo lập tuần = [target × (1 − below), target × (1 + above)]. Mặc định ±5% (Q3).</summary>
    public double BandBelowPct { get; init; } = 0.05;
    public double BandAbovePct { get; init; } = 0.05;
}

public sealed class TargetSteps
{
    public double Bmr { get; init; }
    public double ActivityFactor { get; init; }
    public double Tdee { get; init; }
    public double GoalFactor { get; init; }
    public double KcalUnrounded { get; init; }
    public double ReferenceWeightKg { get; init; }
    public double ProteinGPerKg { get; init; }
    public double ProteinRawG { get; init; }
    public double ProteinCapG { get; init; }
    public double ProteinFloorG { get; init; }
    /// <summary>none | cap | floor</summary>
    public string ProteinLimitedBy { get; init; } = "none";
}

public sealed class Targets
{
    /// <summary>formula | manual</summary>
    public string Mode { get; init; } = "formula";
    public double KcalTarget { get; init; }
    public double KcalMin { get; init; }
    public double KcalMax { get; init; }
    /// <summary>Protein tối thiểu mỗi ngày (đã áp trần/sàn).</summary>
    public double ProteinG { get; init; }
    public TargetSteps? Steps { get; init; }
}

public static class TargetCalc
{
    public static double ActivityFactor(string activity) => activity switch
    {
        "sedentary" => 1.2, "light" => 1.375, "moderate" => 1.55, "high" => 1.725, "athlete" => 1.9,
        _ => throw new ArgumentOutOfRangeException(nameof(activity), activity, null),
    };
    public static double GoalKcalFactor(string goal) => goal switch { "lose" => 0.8, "hold" => 1.0, "build" => 1.1, _ => throw new ArgumentOutOfRangeException(nameof(goal), goal, null) };
    public static double ProteinGPerKg(string goal) => goal switch { "lose" => 2.2, "hold" => 1.8, "build" => 2.0, _ => throw new ArgumentOutOfRangeException(nameof(goal), goal, null) };
    public const double ProteinCapKcalShare = 0.35;
    public const double ProteinFloorLose = 1.76;
    public const double ProteinFloorOther = 1.2;

    public static double RoundTo(double x, double step) => Js.Round(x / step) * step;
    private static double FloorTo(double x, double step) => Math.Floor(x / step) * step;

    public static double Bmr(Profile p) => 10 * p.WeightKg + 6.25 * p.HeightCm - 5 * p.Age + (p.Sex == "male" ? 5 : -161);

    public static double ReferenceWeightKg(Profile p)
    {
        if (p.Goal != "lose") return p.WeightKg;
        var m = p.HeightCm / 100;
        return Math.Min(p.WeightKg, 25 * m * m);
    }

    public static (double KcalMin, double KcalMax) CalorieBand(double kcal, TargetOptions? opts = null)
    {
        opts ??= new TargetOptions();
        return (Js.Round(kcal * (1 - opts.BandBelowPct)), Js.Round(kcal * (1 + opts.BandAbovePct)));
    }

    public static Targets Compute(Profile profile, TargetOptions? opts = null)
    {
        if (profile.TargetMode == "manual")
        {
            if (profile.ManualKcal is not { } k || profile.ManualProteinG is not { } pr || k == 0 || pr == 0)
                throw new InvalidOperationException("Chế độ tự nhập cần manual_kcal và manual_protein_g");
            var (mn, mx) = CalorieBand(k, opts);
            return new Targets { Mode = "manual", KcalTarget = k, KcalMin = mn, KcalMax = mx, ProteinG = pr, Steps = null };
        }

        var bmr = Bmr(profile);
        var activityFactor = ActivityFactor(profile.Activity);
        var tdee = bmr * activityFactor;
        var goalFactor = GoalKcalFactor(profile.Goal);
        var kcalUnrounded = tdee * goalFactor;
        var kcalTarget = RoundTo(kcalUnrounded, 50);

        var refW = ReferenceWeightKg(profile);
        var gPerKg = ProteinGPerKg(profile.Goal);
        var proteinRaw = RoundTo(gPerKg * refW, 5);
        var proteinCap = FloorTo(ProteinCapKcalShare * kcalTarget / 4, 5);
        var floorPerKg = profile.Goal == "lose" ? ProteinFloorLose : ProteinFloorOther;
        var proteinFloor = Js.Round(floorPerKg * (profile.Goal == "lose" ? refW : profile.WeightKg));

        // Sàn thắng trần: max(sàn, min(mục tiêu, trần)).
        var capped = Math.Min(proteinRaw, proteinCap);
        var protein = Math.Max(proteinFloor, capped);
        var limitedBy = proteinFloor > capped ? "floor" : capped < proteinRaw ? "cap" : "none";
        var (kmin, kmax) = CalorieBand(kcalTarget, opts);

        return new Targets
        {
            Mode = "formula", KcalTarget = kcalTarget, KcalMin = kmin, KcalMax = kmax, ProteinG = protein,
            Steps = new TargetSteps
            {
                Bmr = bmr, ActivityFactor = activityFactor, Tdee = tdee, GoalFactor = goalFactor, KcalUnrounded = kcalUnrounded,
                ReferenceWeightKg = refW, ProteinGPerKg = gPerKg, ProteinRawG = proteinRaw, ProteinCapG = proteinCap,
                ProteinFloorG = proteinFloor, ProteinLimitedBy = limitedBy,
            },
        };
    }
}
