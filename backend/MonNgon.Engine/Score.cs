using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed record ScoreWeights
{
    public double CuisineLike { get; init; } = 2;
    public double CuisineLess { get; init; } = 2;
    public double HealthLeaning { get; init; } = 1;
    /// <summary>Điểm tối đa/thiểu của thành phần chi phí (kẹp ở ±cost).</summary>
    public double Cost { get; init; } = 2;
    public double RepeatOverUse { get; init; } = 3;
    public double FreeUses { get; init; } = 2;
    public double SameDay { get; init; } = 10;
    public double Monotony { get; init; } = 1.5;
    public double MonotonyWindow { get; init; } = 3;
}

public sealed class ScoreContext
{
    public IReadOnlyList<string> CuisineLikes { get; init; } = [];
    public IReadOnlyList<string> CuisineLess { get; init; } = [];
    public IReadOnlyList<string> HealthLeanings { get; init; } = [];
    public double CostVnd { get; init; }
    public double CostReferenceVnd { get; init; }
    public double UsesThisWeek { get; init; }
    public IReadOnlyList<string> SameDayRecipeIds { get; init; } = [];
    public IReadOnlyList<string> RecentMainProteins { get; init; } = [];
}

public static class Score
{
    /// <summary>Nguyên liệu protein chính = nguyên liệu vai trò protein nhiều gram nhất (hòa thì giữ cái đầu).</summary>
    public static string? MainProteinId(Recipe r)
    {
        string? id = null;
        double g = 0;
        foreach (var li in r.Ingredients)
            if (li.Role == "protein" && (id is null || li.Grams > g)) { id = li.IngredientId; g = li.Grams; }
        return id;
    }

    private static int Count(IEnumerable<string> tags, IReadOnlyList<string> wanted) => tags.Count(wanted.Contains);

    public static double Total(Recipe r, ScoreContext ctx, ScoreWeights w)
    {
        var likes = w.CuisineLike * Count(r.CuisineTags, ctx.CuisineLikes);
        var less = -w.CuisineLess * Count(r.CuisineTags, ctx.CuisineLess);
        var health = w.HealthLeaning * Count(r.HealthTags, ctx.HealthLeanings);

        var ratio = ctx.CostReferenceVnd > 0 ? ctx.CostVnd / ctx.CostReferenceVnd : 1;
        var cost = -w.Cost * Math.Max(-1, Math.Min(1, ratio - 1));

        var repeat = -w.RepeatOverUse * Math.Max(0, ctx.UsesThisWeek - w.FreeUses);
        var sameDay = ctx.SameDayRecipeIds.Contains(r.Id) ? -w.SameDay : 0;

        var mp = MainProteinId(r);
        var window = ctx.RecentMainProteins.Skip(Math.Max(0, ctx.RecentMainProteins.Count - (int)w.MonotonyWindow)).ToList();
        var monotony = mp is not null ? -w.Monotony * window.Count(p => p == mp) : 0;

        return likes + less + health + cost + repeat + sameDay + monotony;
    }
}
