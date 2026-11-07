using MonNgon.Engine.Types;

namespace MonNgon.Engine;

/// <summary>Macro (giá trị chưa làm tròn). Bất biến; mọi phép cộng trả về đối tượng mới.</summary>
public sealed record Macros(double Kcal, double ProteinG, double CarbG, double FatG, double FiberG)
{
    public static readonly Macros Zero = new(0, 0, 0, 0, 0);

    public static Macros operator +(Macros a, Macros b) =>
        new(a.Kcal + b.Kcal, a.ProteinG + b.ProteinG, a.CarbG + b.CarbG, a.FatG + b.FatG, a.FiberG + b.FiberG);

    public static Macros operator -(Macros a, Macros b) =>
        new(a.Kcal - b.Kcal, a.ProteinG - b.ProteinG, a.CarbG - b.CarbG, a.FatG - b.FatG, a.FiberG - b.FiberG);
}

public sealed class GramLine
{
    public string IngredientId { get; set; } = "";
    public double Grams { get; set; }

    public GramLine() { }
    public GramLine(string id, double grams) { IngredientId = id; Grams = grams; }
    public GramLine Clone() => new(IngredientId, Grams);
}

public sealed class MacroLine
{
    public string IngredientId { get; init; } = "";
    public string Name { get; init; } = "";
    public double Grams { get; init; }
    public Macros Macros { get; init; } = Macros.Zero;
    public Source Source { get; init; } = new();
}

public sealed class MacroResult
{
    public Macros Total { get; init; } = Macros.Zero;
    public List<MacroLine> Lines { get; init; } = [];
}

public static class Nutrition
{
    public static Macros MacrosOf(Ingredient ing, double grams)
    {
        var k = grams / 100;
        var m = ing.Per100g;
        return new Macros(m.Kcal * k, m.ProteinG * k, m.CarbG * k, m.FatG * k, m.FiberG * k);
    }

    /// <summary>Macro của một suất (chưa làm tròn). Nguyên liệu không có trong kho thì ném lỗi.</summary>
    public static MacroResult Compute(IEnumerable<GramLine> lines, IReadOnlyDictionary<string, Ingredient> index)
    {
        var total = Macros.Zero;
        var outLines = new List<MacroLine>();
        foreach (var l in lines)
        {
            if (!index.TryGetValue(l.IngredientId, out var ing)) throw new InvalidOperationException($"Nguyên liệu không tồn tại: {l.IngredientId}");
            var m = MacrosOf(ing, l.Grams);
            total += m;
            outLines.Add(new MacroLine { IngredientId = l.IngredientId, Name = ing.Name, Grams = l.Grams, Macros = m, Source = ing.Source });
        }
        return new MacroResult { Total = total, Lines = outLines };
    }

    public static List<GramLine> RecipeBaseLines(Recipe r) => r.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList();

    /// <summary>Làm tròn CHỈ để hiển thị: protein/carb/fat/xơ 1 g, kcal 5 kcal.</summary>
    public static Macros RoundForDisplay(Macros m) =>
        new(Js.Round(m.Kcal / 5) * 5, Js.Round(m.ProteinG), Js.Round(m.CarbG), Js.Round(m.FatG), Js.Round(m.FiberG));

    public static string FormatSource(Source s) => s.Db == "USDA_FDC" ? $"USDA FDC #{s.Code}" : $"Bảng TPDD VN 2007 · mã {s.Code}";
}

public sealed record HouseholdQuantity(string Unit, double Count, string Text);

public static class Units
{
    private static string Fraction(double n)
    {
        var whole = Math.Floor(n);
        var half = n - whole >= 0.5;
        return whole == 0 ? "1/2" : half ? $"{whole:0} 1/2" : $"{whole:0}";
    }

    /// <summary>Chọn đơn vị bếp cho số lượng làm tròn bội 0.5 sát gram thật nhất (sai số ≤ maxError), ưu tiên số đếm gọn (&lt; 10).</summary>
    public static HouseholdQuantity? ToHouseholdUnit(double grams, IReadOnlyList<HouseholdUnit> units, double maxError = 0.15)
    {
        if (grams <= 0) return null;
        (string Unit, double Count, double Err)? best = null;
        foreach (var u in units)
        {
            var raw = grams / u.Grams;
            var count = Js.Round(raw * 2) / 2;
            if (count < 0.5 || count >= 10) continue;
            var err = Math.Abs(count * u.Grams - grams) / grams;
            if (err > maxError) continue;
            if (best is null || err < best.Value.Err - 1e-9 || (Math.Abs(err - best.Value.Err) <= 1e-9 && count < best.Value.Count))
                best = (u.Unit, count, err);
        }
        return best is { } b ? new HouseholdQuantity(b.Unit, b.Count, $"≈ {Fraction(b.Count)} {b.Unit}") : null;
    }
}
