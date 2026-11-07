namespace MonNgon.Engine;

public sealed class DayTotal
{
    public string Date { get; init; } = "";
    /// <summary>Tổng protein/kcal của cả ngày (đã gồm phần dự kiến của bữa "tôi tự lo").</summary>
    public double ProteinG { get; init; }
    public double Kcal { get; init; }
    /// <summary>Ngày có bữa ăn ngoài/bỏ bữa: không tính là không đạt.</summary>
    public bool Exempt { get; init; }
}

public sealed class Shortfall
{
    public string Date { get; init; } = "";
    /// <summary>protein_low | kcal_low | kcal_high</summary>
    public string Kind { get; init; } = "";
    /// <summary>Mức thiếu/vượt (luôn dương): g protein hoặc kcal.</summary>
    public double Amount { get; init; }
}

public sealed class DayValidation
{
    public string Date { get; init; } = "";
    public bool Ok { get; init; }
    public bool Exempt { get; init; }
    public double ProteinShortG { get; init; }
    /// <summary>Âm = dưới dải, dương = trên dải, 0 = trong dải.</summary>
    public double KcalDelta { get; init; }
}

public sealed class WeekValidation
{
    public bool Ok { get; init; }
    public List<DayValidation> Days { get; init; } = [];
    public List<Shortfall> Shortfalls { get; init; } = [];
    public int DaysMissing { get; init; }
    public double BudgetOverVnd { get; init; }
}

public static class WeekValidator
{
    private const double Eps = 1e-6;

    public static WeekValidation Validate(IReadOnlyList<DayTotal> days, Targets targets, double budgetVnd, double weekFoodCost)
    {
        var outDays = new List<DayValidation>();
        var shortfalls = new List<Shortfall>();
        foreach (var d in days)
        {
            var proteinShort = Math.Max(0, targets.ProteinG - d.ProteinG);
            var kcalDelta = d.Kcal < targets.KcalMin ? d.Kcal - targets.KcalMin : d.Kcal > targets.KcalMax ? d.Kcal - targets.KcalMax : 0;
            var bad = proteinShort > Eps || Math.Abs(kcalDelta) > Eps;
            outDays.Add(new DayValidation { Date = d.Date, Ok = !bad || d.Exempt, Exempt = d.Exempt, ProteinShortG = proteinShort, KcalDelta = kcalDelta });
            if (bad && !d.Exempt)
            {
                if (proteinShort > Eps) shortfalls.Add(new Shortfall { Date = d.Date, Kind = "protein_low", Amount = proteinShort });
                if (kcalDelta < -Eps) shortfalls.Add(new Shortfall { Date = d.Date, Kind = "kcal_low", Amount = -kcalDelta });
                if (kcalDelta > Eps) shortfalls.Add(new Shortfall { Date = d.Date, Kind = "kcal_high", Amount = kcalDelta });
            }
        }
        var daysMissing = outDays.Count(d => !d.Ok);
        var over = Math.Max(0, weekFoodCost - budgetVnd);
        return new WeekValidation { Ok = daysMissing == 0 && over == 0, Days = outDays, Shortfalls = shortfalls, DaysMissing = daysMissing, BudgetOverVnd = over };
    }
}
