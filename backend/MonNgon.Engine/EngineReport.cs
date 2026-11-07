using System.Diagnostics;
using System.Globalization;
using System.Text;
using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed class TestExpect
{
    public bool ExpectAllDaysPass { get; set; }
    public List<string> ForbiddenIngredientIds { get; set; } = [];
    public string Note { get; set; } = "";
}

/// <summary>Một dòng của data/test-profiles.json.</summary>
public sealed class TestProfile
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public string Note { get; set; } = "";
    public Profile Profile { get; set; } = new();
    public Preferences Preferences { get; set; } = new();
    public TestExpect Expect { get; set; } = new();

    public static List<TestProfile> LoadFile(string path) =>
        JsonSerializer.Deserialize<List<TestProfile>>(File.ReadAllText(path), JsonOptions.Default) ?? [];
}

public sealed class ProfileResult
{
    public string Name { get; init; } = "";
    public string Note { get; init; } = "";
    public Targets Targets { get; init; } = new();
    /// <summary>ready | partial | error</summary>
    public string Status { get; init; } = "";
    public string? Error { get; init; }
    public int DaysOk { get; init; }
    public int ProteinDaysOk { get; init; }
    public int KcalDaysOk { get; init; }
    public int DistinctRecipes { get; init; }
    public int DistinctMain { get; init; }
    public double WeekFoodCost { get; init; }
    public double TillCost { get; init; }
    public double Budget { get; init; }
    public double Ms { get; init; }
    public int Iterations { get; init; }
    public List<string> HardViolations { get; init; } = [];
    public bool ExpectAllDaysPass { get; init; }
    /// <summary>Tỉ lệ bữa trưa/tối là mâm ≥ 2 món (T-066); 0 khi chưa có ghép mâm.</summary>
    public double MamRatio { get; init; }
    /// <summary>
    /// Lý do chính khiến bữa trưa/tối không thành mâm (T-077), null khi 100% là mâm:
    /// budget (nới ngân sách thì ghép được nhiều hơn) | equipment (nới dụng cụ thì ghép được nhiều hơn) |
    /// no_side_candidate (không đủ canh/rau/cơm hợp để ghép dù nới ngân sách và dụng cụ).
    /// </summary>
    public string? MamReason { get; init; }
    /// <summary>Chi tiết của <see cref="MamReason"/>: tỉ lệ mâm khi nới từng ràng buộc.</summary>
    public string? MamReasonDetail { get; init; }
    /// <summary>Tỉ lệ bữa trưa/tối có tráng miệng (D-DES-01); số bữa thiếu có cảnh báo dessert_missing.</summary>
    public double DessertRatio { get; init; }
    public int DessertMissing { get; init; }
    /// <summary>Tỉ lệ bữa lên thực đơn dùng từng dụng cụ (một bữa có thể dùng nhiều dụng cụ) — để thấy engine có dồn vào một dụng cụ không.</summary>
    public Dictionary<string, double> EquipmentShare { get; init; } = [];
    /// <summary>D-COM-01: thói quen cơm của hồ sơ; cơm thực tế (g) nhỏ nhất / trung vị trên các bữa mâm có cơm; % bữa mâm có ghi chú rice_reduced; gạo sống cần mua cả tuần (g).</summary>
    public string RiceHabit { get; init; } = "";
    public double RiceMinG { get; init; }
    public double RiceMedianG { get; init; }
    public double RiceTargetG { get; init; }
    public double RiceNoteRatio { get; init; }
    public double RiceBelowFloor { get; init; }
    public double RawRiceNeedG { get; init; }
    /// <summary>Số bữa mâm có cơm (mẫu số của các chỉ số cơm).</summary>
    public int RiceMeals { get; init; }
    /// <summary>D-COM-02: % bữa mâm có ≥ 1 món mang tag khẩu vị "thích" của hồ sơ (null khi hồ sơ không chọn khẩu vị thích) và số loại tráng miệng trong tuần.</summary>
    public double? LikeMatchRatio { get; init; }
    public int DessertKinds { get; init; }
}

public sealed record ReportSummary(
    int Profiles, int Ready, int Partial, int Errors, int DaysTotal, int DaysOk, int ProteinDaysOk, int KcalDaysOk,
    int ExpectedPass, int ExpectedPassReady, int HardViolations, double AvgMs, double MaxMs, double MamRatio = 0, double DessertRatio = 0, int DessertMissing = 0);

public static class EngineReport
{
    public static List<string> CheckHardConstraints(WeekPlan plan, TestProfile tp, Dataset ds)
    {
        var prefs = tp.Preferences;
        var res = new List<string>();
        var banned = Filter.BannedIngredients(ds.Ingredients, prefs);
        foreach (var day in plan.Days)
        {
            var mains = day.Meals.Where(m => m.Slot is "lunch" or "dinner" && !string.IsNullOrEmpty(m.RecipeId)).Select(m => m.RecipeId).ToList();
            if (mains.Count == 2 && mains[0] == mains[1]) res.Add($"{day.Date}: trưa và tối cùng món {mains[0]}");
            foreach (var m in day.Meals)
            {
                if (string.IsNullOrEmpty(m.RecipeId)) continue;
                // Mỗi món trong mâm là một công thức thật; ràng buộc cứng áp cho từng món.
                var parts = m.Dishes is { } ds2
                    ? ds2.Where(d => d.RecipeId is not null).Select(d => (r: ds.RecipesById[d.RecipeId!], grams: d.Grams)).ToList()
                    : [(ds.RecipesById[m.RecipeId], m.Grams)];
                foreach (var (r, grams) in parts)
                {
                    if (prefs.BlockedRecipeIds.Contains(r.Id)) res.Add($"món bị chặn: {r.Id}");
                    foreach (var e in r.Equipment) if (!prefs.Equipment.Contains(e)) res.Add($"{r.Id} cần dụng cụ {e}");
                    foreach (var g in grams) if (g.Grams > 0 && banned.ContainsKey(g.IngredientId)) res.Add($"{r.Id} chứa nguyên liệu bị cấm {g.IngredientId}");
                    foreach (var g in grams) if (g.Grams > 0 && tp.Expect.ForbiddenIngredientIds.Contains(g.IngredientId)) res.Add($"{r.Id} chứa nguyên liệu cấm của hồ sơ {g.IngredientId}");
                    if (prefs.LowCarb && m.Slot is "lunch" or "dinner")
                    {
                        if (r.DishRole == "dessert" ? !r.LowCarbOk : !r.IsLowCarb) res.Add($"{r.Id} không phải low-carb nhưng được xếp {m.Slot}");
                        for (var i = 0; i < r.Ingredients.Count; i++)
                            if (r.Ingredients[i].Role == "carb" && grams[i].Grams != 0) res.Add($"{r.Id}: carb ≠ 0 g");
                    }
                }
                if (m.Dishes is { } dd)
                {
                    if (dd.Count(d => d.Role == "main") > 1) res.Add($"{m.Date} {m.Slot}: mâm có hơn một món đạm chính");
                    if (dd.Any(d => d.Role is "soup" or "side_veg") && dd.Count(d => d.Role == "main") == 0) res.Add($"{m.Date} {m.Slot}: canh/rau không có món chính");
                }
            }
        }
        var soupUses = plan.Days.SelectMany(d => d.Meals).Where(m => m.Dishes is not null).SelectMany(m => m.Dishes!).Where(d => d.Role == "soup")
            .GroupBy(d => d.RecipeId).Where(g => g.Count() > 2);
        foreach (var g in soupUses) res.Add($"canh {g.Key} lặp {g.Count()} lần/tuần");
        return res.Distinct().ToList();
    }

    public static ProfileResult RunProfile(TestProfile tp, Dataset ds, long seed, string startDate, PlanOptions? options = null)
    {
        var targets = TargetCalc.Compute(tp.Profile);
        var sw = Stopwatch.StartNew();
        try
        {
            var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = targets, Prefs = tp.Preferences, Data = ds, StartDate = startDate, Seed = seed, Options = options });
            var ms = sw.Elapsed.TotalMilliseconds;
            var days = plan.Validation.Days;
            var mainIds = plan.Days.SelectMany(d => d.Meals).Where(m => m.Slot is "lunch" or "dinner" && !string.IsNullOrEmpty(m.RecipeId)).Select(m => m.RecipeId!).ToHashSet();
            var mamRatio = MamRatioOf(plan);
            var (reason, detail) = mamRatio < 0.999 && (options?.MealStyle ?? MealStyle.Auto) != MealStyle.FullMealOnly
                ? DiagnoseNoMam(tp, ds, targets, seed, startDate, options, mamRatio)
                : (null, null);
            return new ProfileResult
            {
                Name = tp.Id, Note = tp.Name + (tp.Expect.Note.Length > 0 ? " — " + tp.Expect.Note : ""), Targets = targets, Budget = tp.Preferences.WeeklyBudgetVnd,
                ExpectAllDaysPass = tp.Expect.ExpectAllDaysPass, Status = plan.Status,
                DaysOk = days.Count(d => d.Ok), ProteinDaysOk = days.Count(d => d.ProteinShortG <= 1e-6), KcalDaysOk = days.Count(d => d.KcalDelta == 0),
                MamRatio = mamRatio, MamReason = reason, MamReasonDetail = detail, DessertRatio = DessertRatioOf(plan), DessertMissing = DessertMissingOf(plan), EquipmentShare = EquipmentShareOf(plan, ds), DistinctRecipes = plan.DistinctRecipes, DistinctMain = mainIds.Count, WeekFoodCost = plan.Shopping.WeekFoodCost, TillCost = plan.Shopping.TillCost,
                Ms = ms, Iterations = plan.Iterations, HardViolations = CheckHardConstraints(plan, tp, ds),
                RiceHabit = tp.Preferences.RiceHabit, RiceMeals = RiceMealsOf(plan).Count, RiceMinG = RiceMinOf(plan), RiceMedianG = RiceMedianOf(plan),
                RiceTargetG = RiceHabits.TargetG(tp.Preferences.RiceHabit), RiceNoteRatio = RiceNoteRatioOf(plan), RiceBelowFloor = RiceBelowFloorOf(plan),
                LikeMatchRatio = LikeMatchOf(plan, tp.Preferences, ds), DessertKinds = plan.Days.SelectMany(d => d.Meals).Select(m => m.DessertId).OfType<string>().Distinct().Count(),
                RawRiceNeedG = plan.Shopping.Items.Where(i => i.IngredientId is "gao_te" or "gao_lut").Sum(i => i.NeedG),
            };
        }
        catch (Exception e)
        {
            return new ProfileResult
            {
                Name = tp.Id, Note = tp.Name, Targets = targets, Budget = tp.Preferences.WeeklyBudgetVnd, ExpectAllDaysPass = tp.Expect.ExpectAllDaysPass,
                Status = "error", Error = e.Message, Ms = sw.Elapsed.TotalMilliseconds,
            };
        }
    }

    /// <summary>
    /// Vì sao không phải bữa trưa/tối nào cũng là mâm: chạy lại tuần với từng ràng buộc được nới (ngân sách ×10, đủ mọi dụng cụ)
    /// rồi xem tỉ lệ mâm tăng bao nhiêu. Ràng buộc nào nới ra tăng nhiều nhất (≥ 5 điểm %) là lý do chính.
    /// </summary>
    public static (string Reason, string Detail) DiagnoseNoMam(TestProfile tp, Dataset ds, Targets targets, long seed, string startDate, PlanOptions? options, double baseRatio)
    {
        double Ratio(Action<Preferences> relax)
        {
            var prefs = JsonSerializer.Deserialize<Preferences>(JsonSerializer.Serialize(tp.Preferences, JsonOptions.Default), JsonOptions.Default)!;
            relax(prefs);
            var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = targets, Prefs = prefs, Data = ds, StartDate = startDate, Seed = seed, Options = options });
            return MamRatioOf(plan);
        }
        var budget = Ratio(p => p.WeeklyBudgetVnd *= 10);
        var equip = Ratio(p => p.Equipment = [.. Enums.Equipment]);
        var detail = $"nới ngân sách → {Pct(budget)}, đủ dụng cụ → {Pct(equip)}";
        const double Gain = 0.05;
        var gb = budget - baseRatio;
        var ge = equip - baseRatio;
        if (Math.Max(gb, ge) < Gain) return ("no_side_candidate", detail);
        return (gb >= ge ? "budget" : "equipment", detail);
    }

    /// <summary>Tỉ lệ bữa trưa/tối có ≥ 2 món (không tính món thêm do engine bù).</summary>
    public static double MamRatioOf(WeekPlan plan)
    {
        var ld = plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Slot is "lunch" or "dinner").ToList();
        if (ld.Count == 0) return 0;
        return (double)ld.Count(m => m.Dishes is { } d && d.Count(x => x.Role is not ("extra" or "dessert")) >= 2) / ld.Count;
    }

    public static Dictionary<string, double> EquipmentShareOf(WeekPlan plan, Dataset ds)
    {
        var meals = plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && !string.IsNullOrEmpty(m.RecipeId)).ToList();
        var count = new Dictionary<string, int>();
        foreach (var m in meals)
        {
            var recipes = m.Dishes is { } dd
                ? dd.Where(d => d.RecipeId is not null).Select(d => ds.RecipesById[d.RecipeId!])
                : [ds.RecipesById[m.RecipeId!]];
            foreach (var e in recipes.SelectMany(r => r.Equipment).Distinct()) count[e] = count.GetValueOrDefault(e) + 1;
        }
        return Enums.Equipment.Where(count.ContainsKey).ToDictionary(e => e, e => (double)count[e] / meals.Count);
    }

    private static IEnumerable<PlanMeal> LunchDinnerPlanned(WeekPlan plan) =>
        plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Slot is "lunch" or "dinner");

    public static double DessertRatioOf(WeekPlan plan)
    {
        var ld = LunchDinnerPlanned(plan).ToList();
        return ld.Count == 0 ? 0 : (double)ld.Count(m => m.DessertId is not null) / ld.Count;
    }

    public static double? LikeMatchOf(WeekPlan plan, Preferences prefs, Dataset ds)
    {
        if (prefs.CuisineLikes.Count == 0) return null;
        var mam = LunchDinnerPlanned(plan).Where(m => m.Dishes is { } d && d.Count(x => x.Role is not ("extra" or "dessert")) >= 2).ToList();
        if (mam.Count == 0) return null;
        return (double)mam.Count(m => m.Dishes!.Where(d => d.RecipeId is not null).Any(d => ds.RecipesById[d.RecipeId!].CuisineTags.Any(prefs.CuisineLikes.Contains))) / mam.Count;
    }

    public static List<PlanMeal> RiceMealsOf(WeekPlan plan) => plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Rice is not null).ToList();

    public static double RiceMinOf(WeekPlan plan) => RiceMealsOf(plan).Select(m => m.Rice!.ActualG).DefaultIfEmpty(0).Min();

    public static double RiceMedianOf(WeekPlan plan)
    {
        var v = RiceMealsOf(plan).Select(m => m.Rice!.ActualG).OrderBy(x => x).ToList();
        if (v.Count == 0) return 0;
        return v.Count % 2 == 1 ? v[v.Count / 2] : (v[v.Count / 2 - 1] + v[v.Count / 2]) / 2;
    }

    /// <summary>% bữa mâm có cơm mà cơm thực tế thấp hơn mức chọn quá sai số (đều phải có ghi chú rice_reduced).</summary>
    public static double RiceNoteRatioOf(WeekPlan plan)
    {
        var r = RiceMealsOf(plan);
        return r.Count == 0 ? 0 : (double)r.Count(m => m.Notes?.Any(n => n.Code == "rice_reduced") == true) / r.Count;
    }

    /// <summary>Số bữa cơm dưới sàn max(50% mức, 60 g) hoặc giảm cơm mà không có ghi chú — phải bằng 0.</summary>
    public static double RiceBelowFloorOf(WeekPlan plan) => RiceMealsOf(plan).Count(m =>
        m.Rice!.ActualG < RiceHabits.FloorG(m.Rice.Habit) - 1e-6
        || (m.Rice.ActualG < m.Rice.TargetG - RiceHabits.ToleranceG && m.Notes?.Any(n => n.Code == "rice_reduced") != true));

    public static int DessertMissingOf(WeekPlan plan) => LunchDinnerPlanned(plan).Count(m => m.Warnings?.Contains("dessert_missing") == true);

    public static ReportSummary Summarize(IReadOnlyList<ProfileResult> rs)
    {
        var exp = rs.Where(r => r.ExpectAllDaysPass).ToList();
        return new ReportSummary(
            rs.Count, rs.Count(r => r.Status == "ready"), rs.Count(r => r.Status == "partial"), rs.Count(r => r.Status == "error"),
            rs.Count(r => r.Status != "error") * 7, rs.Sum(r => r.DaysOk), rs.Sum(r => r.ProteinDaysOk), rs.Sum(r => r.KcalDaysOk),
            exp.Count, exp.Count(r => r.Status == "ready"), rs.Sum(r => r.HardViolations.Count),
            rs.Sum(r => r.Ms) / Math.Max(1, rs.Count), rs.Select(r => r.Ms).DefaultIfEmpty(0).Max(),
            rs.Where(r => r.Status != "error").Select(r => r.MamRatio).DefaultIfEmpty(0).Average(),
            rs.Where(r => r.Status != "error").Select(r => r.DessertRatio).DefaultIfEmpty(0).Average(), rs.Sum(r => r.DessertMissing));
    }

    private static string Fmt(double n) => Js.Round(n).ToString("N0", CultureInfo.InvariantCulture).Replace(',', '.');
    private static string Pct(double ratio) => Js.Round(ratio * 100).ToString("0", CultureInfo.InvariantCulture) + "%";
    private static string Pct(int a, int b) => (b > 0 ? Js.Round((double)a / b * 100).ToString("0", CultureInfo.InvariantCulture) : "0") + "%";

    /// <summary>Cùng định dạng với bản TS (không gồm phần chẩn đoán chi tiết và ma trận phủ món).</summary>
    public static string Format(IReadOnlyList<ProfileResult> rs)
    {
        var L = new List<string> { "BÁO CÁO ENGINE (C#)", "" };
        foreach (var r in rs)
        {
            var flag = r.Status == "ready" ? "ĐẠT " : r.Status == "partial" ? "PARTIAL" : "LỖI";
            L.Add($"[{flag}] {r.Name} — {r.Note}");
            L.Add($"   chỉ tiêu: {Js.Num(r.Targets.KcalMin)}–{Js.Num(r.Targets.KcalMax)} kcal, protein ≥ {Js.Num(r.Targets.ProteinG)} g");
            if (r.Status == "error") L.Add($"   lỗi: {r.Error}");
            else
            {
                L.Add($"   ngày đạt {r.DaysOk}/7 (protein {r.ProteinDaysOk}/7, kcal {r.KcalDaysOk}/7) · món khác nhau {r.DistinctRecipes} (trưa/tối {r.DistinctMain}) · {r.Ms.ToString("0", CultureInfo.InvariantCulture)} ms · {r.Iterations} vòng · % bữa ghép mâm {Pct(r.MamRatio)} · % có tráng miệng {Pct(r.DessertRatio)}");
                L.Add($"   chi phí món ăn {Fmt(r.WeekFoodCost)} ₫ / ngân sách {Fmt(r.Budget)} ₫ {(r.WeekFoodCost <= r.Budget ? "✓" : "✗ VƯỢT")} · trả tại quầy ~{Fmt(r.TillCost)} ₫");
            }
            if (r.Status != "error" && r.RiceMeals > 0)
                L.Add($"   cơm ({r.RiceHabit}, mức {Fmt(r.RiceTargetG)} g): thực tế min {Fmt(r.RiceMinG)} g · trung vị {Fmt(r.RiceMedianG)} g · {Pct(r.RiceNoteRatio)} bữa mâm có ghi chú giảm cơm ({r.RiceMeals} bữa) · gạo sống cần mua {Fmt(r.RawRiceNeedG)} g/tuần");
            if (r.Status != "error")
                L.Add($"   khẩu vị thích: {(r.LikeMatchRatio is { } lm ? Pct(lm) + " bữa mâm khớp" : "không chọn")} · {r.DessertKinds} loại tráng miệng/tuần");
            if (r.MamReason is not null) L.Add($"   lý do không ghép mâm: {r.MamReason} ({r.MamReasonDetail})");
            if (r.EquipmentShare.Count > 0) L.Add("   dụng cụ (% bữa): " + string.Join(" · ", r.EquipmentShare.OrderByDescending(kv => kv.Value).Select(kv => $"{kv.Key} {Pct(kv.Value)}")));
            if (r.HardViolations.Count > 0) L.Add($"   !!! VI PHẠM RÀNG BUỘC CỨNG: {string.Join(" | ", r.HardViolations)}");
            L.Add("");
        }
        var s = Summarize(rs);
        L.Add("TỔNG HỢP");
        L.Add($"  Hồ sơ đạt 7/7: {s.Ready}/{s.Profiles} · partial {s.Partial} · lỗi {s.Errors}");
        L.Add($"  Hồ sơ kỳ vọng đạt: {s.ExpectedPassReady}/{s.ExpectedPass} ({Pct(s.ExpectedPassReady, s.ExpectedPass)})");
        L.Add($"  Ngày đạt: {s.DaysOk}/{s.DaysTotal} ({Pct(s.DaysOk, s.DaysTotal)}) · sàn protein {Pct(s.ProteinDaysOk, s.DaysTotal)} · dải calo {Pct(s.KcalDaysOk, s.DaysTotal)}");
        L.Add($"  % bữa ghép mâm (trưa/tối ≥ 2 món): {Pct(s.MamRatio)}");
        var eq = rs.Where(r => r.Status != "error").SelectMany(r => r.EquipmentShare).GroupBy(kv => kv.Key).Select(g => (g.Key, Avg: g.Sum(x => x.Value) / rs.Count(r => r.Status != "error"))).OrderByDescending(x => x.Avg);
        L.Add("  Dụng cụ (% bữa, trung bình các hồ sơ): " + string.Join(" · ", eq.Select(x => $"{x.Key} {Pct(x.Avg)}")));
        var rr = rs.Where(r => r.Status != "error" && r.RiceMeals > 0).ToList();
        if (rr.Count > 0)
            L.Add($"  Cơm: {rr.Count} hồ sơ có bữa mâm cơm · ghi chú giảm cơm TB {Pct(rr.Average(r => r.RiceNoteRatio))} · hồ sơ >20% bữa có ghi chú: {string.Join(", ", rr.Where(r => r.RiceNoteRatio > 0.2 + 1e-9).Select(r => r.Name).DefaultIfEmpty("không"))} · dưới sàn/không ghi chú: {rr.Sum(r => r.RiceBelowFloor)}");
        L.Add($"  % bữa trưa/tối có tráng miệng: {Pct(s.DessertRatio)} · thiếu (dessert_missing): {s.DessertMissing}");
        L.Add($"  Vi phạm ràng buộc cứng: {s.HardViolations} · thời gian TB {s.AvgMs.ToString("0", CultureInfo.InvariantCulture)} ms, tối đa {s.MaxMs.ToString("0", CultureInfo.InvariantCulture)} ms");
        var sb = new StringBuilder();
        foreach (var l in L) sb.Append(l).Append('\n');
        return sb.ToString().TrimEnd('\n');
    }
}
