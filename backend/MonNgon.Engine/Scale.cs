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

    /// <summary>Dòng scale được (protein/carb không ghim, min_g &lt; max_g) dùng để dựng vector ứng viên.</summary>
    private sealed class Line
    {
        public double Base, Lo, Hi, KcalPerG, ProtPerG;
    }

    private static List<double[]> CandidateVectors(List<Line> lines, double step)
    {
        if (lines.Count == 0) return [[]];
        // Vector tăng đơn điệu theo f nên các vector trùng nhau luôn liền kề: chỉ cần so với vector trước (giữ lần xuất hiện đầu, như Set trong bản TS).
        // T-101: tính vào một mảng tạm và chỉ cấp phát khi khác vector trước (~800 bước f nhưng chỉ vài chục vector khác nhau).
        var res = new List<double[]>();
        var cur = new double[lines.Count];
        double[]? last = null;
        for (double f = 0; f <= 4.0001; f += 0.005)
        {
            for (var i = 0; i < cur.Length; i++)
            {
                var l = lines[i];
                cur[i] = Math.Min(l.Hi, Math.Max(l.Lo, Js.Round(l.Base * f / step) * step));
            }
            if (last is not null && cur.AsSpan().SequenceEqual(last)) continue;
            last = (double[])cur.Clone();
            res.Add(last);
        }
        return res;
    }

    /// <summary>Tập ứng viên của một nhóm dòng (protein hoặc carb) ở dạng mảng song song: kcal, đạm, khoảng cách tới gram gốc, và các vector gram (phẳng: ứng viên × số dòng).</summary>
    private sealed class CandSet
    {
        public int Lines;
        public double[] K = [], P = [], Dist = [], V = [];
    }

    private static CandSet BuildSet(List<Line> lines, double step)
    {
        var cands = CandidateVectors(lines, step);
        var n = lines.Count;
        var set = new CandSet { Lines = n, K = new double[cands.Count], P = new double[cands.Count], Dist = new double[cands.Count], V = new double[cands.Count * n] };
        for (var c = 0; c < cands.Count; c++)
        {
            var v = cands[c];
            double k = 0, p = 0, dist = 0;
            for (var j = 0; j < n; j++)
            {
                var l = lines[j];
                k += l.KcalPerG * v[j];
                p += l.ProtPerG * v[j];
                dist += l.Base > 0 ? Math.Abs(v[j] - l.Base) / l.Base : 0;
                set.V[c * n + j] = v[j];
            }
            set.K[c] = k;
            set.P[c] = p;
            set.Dist[c] = dist;
        }
        return set;
    }

    /// <summary>Ứng viên protein × carb của một công thức ở một chế độ (ép 0 carb) và bước; không phụ thuộc mục tiêu bữa lẫn gram cơm ghim.</summary>
    private sealed class Cands
    {
        public int[] ProtIdx = [], CarbIdx = [];
        public CandSet Prot = null!, Carb = null!;
    }

    /// <summary>Phần phụ thuộc gram cơm ghim: gram nền của từng dòng và tổng kcal/đạm của các dòng không scale.</summary>
    private sealed class Prepared
    {
        public double[] Grams0 = [];
        public double Kcal0, Prot0;
        public Cands Cands = null!;
    }

    /// <summary>
    /// T-101: mọi thứ không phụ thuộc mục tiêu bữa chỉ phụ thuộc công thức + (ép 0 carb, cơm ghim, bước) nên dựng một lần rồi dùng lại cho hàng triệu lần scale của một lần lập tuần
    /// (dựng lại mỗi lần gọi từng chiếm ~80% thời gian lập tuần ở mức 3+ chén). Kết quả không đổi so với dựng lại mỗi lần (đã kiểm: băm JSON 216 tuần trùng bản cũ).
    /// </summary>
    private sealed class RecipeCache
    {
        public double[] KcalPerG = [], ProtPerG = [], CarbPerG = [], FatPerG = [], FiberPerG = [];
        public readonly System.Collections.Concurrent.ConcurrentDictionary<(bool Zero, double Step), Cands> ByZero = new();
        public readonly System.Collections.Concurrent.ConcurrentDictionary<(bool Zero, double? Rice, double Step), Prepared> ByOpts = new();
    }

    private static readonly System.Runtime.CompilerServices.ConditionalWeakTable<Recipe, RecipeCache> Cache = new();

    /// <summary>
    /// Dùng chung giữa các lần lập chạy song song (mỗi phương án dựng lại cùng một bộ mâm): khoá theo nội dung công thức (dòng nguyên liệu, gram, vai trò, biên, cơm ghim và dinh dưỡng trên 100 g của từng dòng),
    /// nên hai công thức khác đối tượng nhưng cùng nội dung dùng chung dữ liệu chuẩn bị. Quá <see cref="SharedLimit"/> mục thì xoá hết (bộ nhớ có trần).
    /// </summary>
    private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, RecipeCache> Shared = new();
    private const int SharedLimit = 4000;

    /// <summary>Số công thức đang giữ dữ liệu chuẩn bị dùng chung (để bench/test theo dõi bộ nhớ).</summary>
    public static int SharedCount => Shared.Count;

    private static string R(double x) => x.ToString("R", System.Globalization.CultureInfo.InvariantCulture);

    private static RecipeCache CacheOf(Recipe recipe, IReadOnlyDictionary<string, Ingredient> index) =>
        Cache.GetValue(recipe, r =>
        {
            var sb = new System.Text.StringBuilder(r.Id.Length + r.Ingredients.Count * 64);
            sb.Append(r.Id);
            foreach (var li in r.Ingredients)
            {
                if (!index.TryGetValue(li.IngredientId, out var ing)) throw new InvalidOperationException($"Nguyên liệu không tồn tại: {li.IngredientId}");
                var m = ing.Per100g;
                sb.Append('|').Append(li.IngredientId).Append(',').Append(R(li.Grams)).Append(',').Append(li.Role).Append(',').Append(R(li.MinG)).Append(',').Append(R(li.MaxG)).Append(',')
                    .Append(li.RiceTargetG is { } rt ? R(rt) : "").Append(',').Append(R(m.Kcal)).Append(',').Append(R(m.ProteinG)).Append(',').Append(R(m.CarbG)).Append(',').Append(R(m.FatG)).Append(',').Append(R(m.FiberG));
            }
            if (Shared.Count > SharedLimit) Shared.Clear();
            return Shared.GetOrAdd(sb.ToString(), _ =>
            {
                var n = r.Ingredients.Count;
                var rc = new RecipeCache { KcalPerG = new double[n], ProtPerG = new double[n], CarbPerG = new double[n], FatPerG = new double[n], FiberPerG = new double[n] };
                for (var i = 0; i < n; i++)
                {
                    var m = index[r.Ingredients[i].IngredientId].Per100g;
                    rc.KcalPerG[i] = m.Kcal / 100;
                    rc.ProtPerG[i] = m.ProteinG / 100;
                    rc.CarbPerG[i] = m.CarbG / 100;
                    rc.FatPerG[i] = m.FatG / 100;
                    rc.FiberPerG[i] = m.FiberG / 100;
                }
                return rc;
            });
        });

    /// <summary>Gram nền/biên của một dòng theo chế độ (ép 0 carb) và gram cơm ghim (D-COM-01: dòng cơm của mâm ghim ở lượng người dùng chọn, không co giãn tự do).</summary>
    private static (double Base, double Lo, double Hi) LineBounds(RecipeIngredient li, bool forceZeroCarb, double? riceOverride)
    {
        var zero = forceZeroCarb && li.Role == "carb";
        var pinned = li.RiceTargetG is not null && !zero;
        var pinG = riceOverride ?? li.RiceTargetG ?? li.Grams;
        var scalable = li.Role is "protein" or "carb" && !pinned;
        return (zero ? 0 : pinned ? pinG : li.Grams, zero ? 0 : pinned ? pinG : scalable ? li.MinG : li.Grams, zero ? 0 : pinned ? pinG : scalable ? li.MaxG : li.Grams);
    }

    private static Cands BuildCands(Recipe recipe, RecipeCache rc, bool zero, double step)
    {
        // Dòng scale được không phụ thuộc gram cơm ghim (dòng ghim có min = max) nên bỏ qua override ở đây.
        var protIdx = new List<int>();
        var carbIdx = new List<int>();
        var protLines = new List<Line>();
        var carbLines = new List<Line>();
        for (var i = 0; i < recipe.Ingredients.Count; i++)
        {
            var li = recipe.Ingredients[i];
            var (b, lo, hi) = LineBounds(li, zero, null);
            if (lo >= hi) continue;
            var line = new Line { Base = b, Lo = lo, Hi = hi, KcalPerG = rc.KcalPerG[i], ProtPerG = rc.ProtPerG[i] };
            if (li.Role == "protein") { protIdx.Add(i); protLines.Add(line); }
            else if (li.Role == "carb") { carbIdx.Add(i); carbLines.Add(line); }
        }
        return new Cands { ProtIdx = [.. protIdx], CarbIdx = [.. carbIdx], Prot = BuildSet(protLines, step), Carb = BuildSet(carbLines, step) };
    }

    private static Prepared Prepare(Recipe recipe, RecipeCache rc, ScaleOptions opts)
    {
        var cands = rc.ByZero.GetOrAdd((opts.ForceZeroCarb, opts.Step), _ => BuildCands(recipe, rc, opts.ForceZeroCarb, opts.Step));
        var n = recipe.Ingredients.Count;
        var grams = new double[n];
        double kcal0 = 0, prot0 = 0;
        for (var i = 0; i < n; i++)
        {
            var li = recipe.Ingredients[i];
            var (b, lo, hi) = LineBounds(li, opts.ForceZeroCarb, opts.RiceOverrideG);
            grams[i] = lo == hi ? lo : b;
            if (li.Role is "protein" or "carb" && lo < hi) continue; // dòng scale được: tính trong ứng viên
            kcal0 += rc.KcalPerG[i] * grams[i];
            prot0 += rc.ProtPerG[i] * grams[i];
        }
        return new Prepared { Grams0 = grams, Kcal0 = kcal0, Prot0 = prot0, Cands = cands };
    }

    public static ScaleResult Scale(Recipe recipe, IReadOnlyDictionary<string, Ingredient> index, ScaleTarget target, ScaleOptions? opts = null)
    {
        opts ??= new ScaleOptions();
        var pTol = opts.ProteinToleranceG;
        var kTol = opts.KcalTolerancePct;

        var rc = CacheOf(recipe, index);
        var key = (opts.ForceZeroCarb, opts.RiceOverrideG, opts.Step);
        if (!rc.ByOpts.TryGetValue(key, out var prep))
        {
            prep = Prepare(recipe, rc, opts);
            rc.ByOpts[key] = prep;
        }
        var cands = prep.Cands;
        var ps = cands.Prot;
        var cs = cands.Carb;
        var grams = (double[])prep.Grams0.Clone();
        var prot0 = prep.Prot0;
        var kcal0 = prep.Kcal0;
        var kDen = Math.Max(1, kTol * target.Kcal);

        // Tìm vét cạn (đạm × carb) — cùng biểu thức/thứ tự cộng như bản gốc nên chọn đúng cùng nghiệm (hòa giữ cặp đầu tiên).
        var bestCost = double.PositiveInfinity;
        int bestPi = 0, bestCi = 0;
        for (var pi = 0; pi < ps.K.Length; pi++)
        {
            var aP = ps.P[pi];
            var aK = ps.K[pi];
            var aD = ps.Dist[pi];
            for (var ci = 0; ci < cs.K.Length; ci++)
            {
                var dP = prot0 + aP + cs.P[ci] - target.ProteinG;
                var dK = kcal0 + aK + cs.K[ci] - target.Kcal;
                var pTerm = (dP < 0 ? -dP : dP * OverProteinWeight) / pTol;
                var kTerm = Math.Abs(dK) / kDen;
                var cost =
                    pTerm * pTerm + kTerm * kTerm +
                    ViolationPenalty * (Math.Max(0, pTerm - 1) + Math.Max(0, kTerm - 1)) +
                    1e-6 * (aD + cs.Dist[ci]);
                if (cost < bestCost) { bestCost = cost; bestPi = pi; bestCi = ci; }
            }
        }

        for (var n = 0; n < ps.Lines; n++) grams[cands.ProtIdx[n]] = ps.V[bestPi * ps.Lines + n];
        for (var n = 0; n < cs.Lines; n++) grams[cands.CarbIdx[n]] = cs.V[bestCi * cs.Lines + n];

        double kc = 0, pr = 0, cb = 0, ft = 0, fb = 0;
        for (var i = 0; i < grams.Length; i++)
        {
            var g = grams[i];
            kc += rc.KcalPerG[i] * g;
            pr += rc.ProtPerG[i] * g;
            cb += rc.CarbPerG[i] * g;
            ft += rc.FatPerG[i] * g;
            fb += rc.FiberPerG[i] * g;
        }
        var macros = new Macros(kc, pr, cb, ft, fb);
        var dProt = macros.ProteinG - target.ProteinG;
        var dKcal = macros.Kcal - target.Kcal;
        var kcalPct = target.Kcal > 0 ? dKcal / target.Kcal : 0;
        var lines = new List<GramLine>(grams.Length);
        for (var i = 0; i < grams.Length; i++) lines.Add(new GramLine(recipe.Ingredients[i].IngredientId, grams[i]));
        return new ScaleResult
        {
            Grams = lines,
            Macros = macros,
            Deviation = new ScaleDeviation { ProteinG = dProt, Kcal = dKcal, KcalPct = kcalPct },
            Infeasible = -dProt > pTol || Math.Abs(kcalPct) > kTol,
        };
    }
}
