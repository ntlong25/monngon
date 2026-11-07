using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed record ScaleTarget(double Kcal, double ProteinG);

public sealed class ScaleOptions
{
    /// <summary>Ít tinh bột: ép mọi nguyên liệu vai trò carb = 0 g.</summary>
    public bool ForceZeroCarb { get; init; }
    public double Step { get; init; } = 5;
    public double ProteinToleranceG { get; init; } = 3;
    public double KcalTolerancePct { get; init; } = 0.05;
    /// <summary>D-COM-01: gram hiện tại của dòng cơm đã ghim (sau khi giảm cơm); null = dùng lượng người dùng chọn của dòng đó.</summary>
    public double? RiceOverrideG { get; init; }
}

public sealed class ScaleDeviation
{
    public double ProteinG { get; init; }
    public double Kcal { get; init; }
    public double KcalPct { get; init; }
}

public sealed class ScaleResult
{
    public List<GramLine> Grams { get; init; } = [];
    public Macros Macros { get; init; } = Macros.Zero;
    public ScaleDeviation Deviation { get; init; } = new();
    public bool Infeasible { get; init; }
}

/// <summary>T-007 — Scale khẩu phần: chỉnh gram nguyên liệu protein/carb trong [min_g, max_g] (bước 5 g) để khớp mục tiêu 1 bữa.</summary>
public static class Scaler
{
    private const double OverProteinWeight = 0.5;
    private const double ViolationPenalty = 1000;

    private sealed class Line
    {
        public double Base, Lo, Hi, KcalPerG, ProtPerG, CarbPerG, FatPerG, FiberPerG;
    }

    private sealed record Agg(double[] V, double K, double P, double Dist);

    private static List<double[]> CandidateVectors(List<Line> lines, double step)
    {
        if (lines.Count == 0) return [[]];
        // Vector tăng đơn điệu theo f nên các vector trùng nhau luôn liền kề: chỉ cần so với vector trước (giữ lần xuất hiện đầu, như Set trong bản TS).
        var res = new List<double[]>();
        double[]? last = null;
        for (double f = 0; f <= 4.0001; f += 0.005)
        {
            var v = new double[lines.Count];
            for (var i = 0; i < v.Length; i++)
            {
                var l = lines[i];
                v[i] = Math.Min(l.Hi, Math.Max(l.Lo, Js.Round(l.Base * f / step) * step));
            }
            if (last is not null && v.AsSpan().SequenceEqual(last)) continue;
            res.Add(v);
            last = v;
        }
        return res;
    }

    public static ScaleResult Scale(Recipe recipe, IReadOnlyDictionary<string, Ingredient> index, ScaleTarget target, ScaleOptions? opts = null)
    {
        opts ??= new ScaleOptions();
        var step = opts.Step;
        var pTol = opts.ProteinToleranceG;
        var kTol = opts.KcalTolerancePct;

        var lines = new List<Line>();
        foreach (var li in recipe.Ingredients)
        {
            if (!index.TryGetValue(li.IngredientId, out var ing)) throw new InvalidOperationException($"Nguyên liệu không tồn tại: {li.IngredientId}");
            var zero = opts.ForceZeroCarb && li.Role == "carb";
            // Dòng cơm của mâm (D-COM-01) được ghim ở lượng người dùng chọn: không co giãn tự do.
            var pinned = li.RiceTargetG is not null && !zero;
            var pinG = opts.RiceOverrideG ?? li.RiceTargetG ?? li.Grams;
            var scalable = li.Role is "protein" or "carb" && !pinned;
            var m = ing.Per100g;
            lines.Add(new Line
            {
                Base = zero ? 0 : pinned ? pinG : li.Grams,
                Lo = zero ? 0 : pinned ? pinG : scalable ? li.MinG : li.Grams,
                Hi = zero ? 0 : pinned ? pinG : scalable ? li.MaxG : li.Grams,
                KcalPerG = m.Kcal / 100, ProtPerG = m.ProteinG / 100, CarbPerG = m.CarbG / 100, FatPerG = m.FatG / 100, FiberPerG = m.FiberG / 100,
            });
        }

        List<int> ScalableIdx(string role)
        {
            var r = new List<int>();
            for (var i = 0; i < recipe.Ingredients.Count; i++)
                if (recipe.Ingredients[i].Role == role && lines[i].Lo < lines[i].Hi) r.Add(i);
            return r;
        }
        var protIdx = ScalableIdx("protein");
        var carbIdx = ScalableIdx("carb");

        var grams = lines.Select(l => l.Lo == l.Hi ? l.Lo : l.Base).ToArray();
        double kcal0 = 0, prot0 = 0;
        var free = new HashSet<int>(protIdx.Concat(carbIdx));
        for (var i = 0; i < lines.Count; i++)
        {
            if (free.Contains(i)) continue;
            kcal0 += lines[i].KcalPerG * grams[i];
            prot0 += lines[i].ProtPerG * grams[i];
        }

        var protCands = CandidateVectors(protIdx.Select(i => lines[i]).ToList(), step);
        var carbCands = CandidateVectors(carbIdx.Select(i => lines[i]).ToList(), step);
        List<Agg> Aggregate(List<int> idx, List<double[]> cands)
        {
            var res = new List<Agg>();
            foreach (var v in cands)
            {
                double k = 0, p = 0, dist = 0;
                for (var n = 0; n < v.Length; n++)
                {
                    var l = lines[idx[n]];
                    k += l.KcalPerG * v[n];
                    p += l.ProtPerG * v[n];
                    dist += l.Base > 0 ? Math.Abs(v[n] - l.Base) / l.Base : 0;
                }
                res.Add(new Agg(v, k, p, dist));
            }
            return res;
        }
        var pA = Aggregate(protIdx, protCands);
        var cA = Aggregate(carbIdx, carbCands);

        var bestCost = double.PositiveInfinity;
        int bestPi = 0, bestCi = 0;
        for (var pi = 0; pi < pA.Count; pi++)
        {
            var a = pA[pi];
            for (var ci = 0; ci < cA.Count; ci++)
            {
                var b = cA[ci];
                var dP = prot0 + a.P + b.P - target.ProteinG;
                var dK = kcal0 + a.K + b.K - target.Kcal;
                var pTerm = (dP < 0 ? -dP : dP * OverProteinWeight) / pTol;
                var kTerm = Math.Abs(dK) / Math.Max(1, kTol * target.Kcal);
                var cost =
                    pTerm * pTerm + kTerm * kTerm +
                    ViolationPenalty * (Math.Max(0, pTerm - 1) + Math.Max(0, kTerm - 1)) +
                    1e-6 * (a.Dist + b.Dist);
                if (cost < bestCost) { bestCost = cost; bestPi = pi; bestCi = ci; }
            }
        }

        for (var n = 0; n < pA[bestPi].V.Length; n++) grams[protIdx[n]] = pA[bestPi].V[n];
        for (var n = 0; n < cA[bestCi].V.Length; n++) grams[carbIdx[n]] = cA[bestCi].V[n];

        double kc = 0, pr = 0, cb = 0, ft = 0, fb = 0;
        for (var i = 0; i < lines.Count; i++)
        {
            var l = lines[i];
            var g = grams[i];
            kc += l.KcalPerG * g;
            pr += l.ProtPerG * g;
            cb += l.CarbPerG * g;
            ft += l.FatPerG * g;
            fb += l.FiberPerG * g;
        }
        var macros = new Macros(kc, pr, cb, ft, fb);
        var dProt = macros.ProteinG - target.ProteinG;
        var dKcal = macros.Kcal - target.Kcal;
        var kcalPct = target.Kcal > 0 ? dKcal / target.Kcal : 0;
        return new ScaleResult
        {
            Grams = recipe.Ingredients.Select((li, i) => new GramLine(li.IngredientId, grams[i])).ToList(),
            Macros = macros,
            Deviation = new ScaleDeviation { ProteinG = dProt, Kcal = dKcal, KcalPct = kcalPct },
            Infeasible = -dProt > pTol || Math.Abs(kcalPct) > kTol,
        };
    }
}
