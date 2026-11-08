using System.Collections.Concurrent;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>
/// T-098 / D-COM-03,04 — xếp hạng trưa/tối theo cơm (mâm đủ cơm → mâm bớt cơm → trọn suất có cơm → trọn suất không cơm), dồn kcal sang trưa/tối ở mức nhiều/rất nhiều,
/// khai báo loại tinh bột (kind/rice_equiv_g) và mức cơm khả thi cho bước chọn thói quen ăn cơm.
/// Mỗi (hồ sơ, mức cơm, seed) chỉ xếp một lần cho cả lớp test (lập kế hoạch ở mức nhiều tốn vài giây).
/// </summary>
public class Rice98Tests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";
    private static readonly ConcurrentDictionary<(string, string, long), Lazy<WeekPlan>> Cache = new();

    private static TestProfile P(string id) => Profiles.Single(p => p.Id.StartsWith(id, StringComparison.Ordinal));

    private static Preferences WithHabit(TestProfile p, string habit)
    {
        var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        prefs.RiceHabit = habit;
        return prefs;
    }

    private static WeekPlan Plan(TestProfile p, string habit, long seed = 1) =>
        Cache.GetOrAdd((p.Id, habit, seed), _ => new Lazy<WeekPlan>(() => WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(p.Profile), Prefs = WithHabit(p, habit), Data = Data, StartDate = Start, Seed = seed,
        }))).Value;

    private static double RawRice(WeekPlan plan) => plan.Shopping.Items.Where(i => i.IngredientId is "gao_te" or "gao_lut").Sum(i => i.NeedG);

    private static bool Planned(PlanMeal m) => m.Status == "planned" && m.RecipeId is not null;

    // ---- Hồi quy mức Vừa: nhà nhiều người + ngân sách sát (phát hiện ở integration it-10, T-099) ----

    /// <summary>
    /// Trọn suất có dòng cơm ghim theo mức xếp bậc 1 — trên mâm không khả thi (bậc 0) — nên ở mức Vừa, hộ 2 lớn + 1 nhỏ ngân sách 1,5 triệu mất sạch mâm (T-096: 12/14 bữa mâm, T-098 lỗi: 0/14).
    /// Mức ít/vừa không ghim cơm cho món trọn suất; test giữ số mâm ≈ T-096 (đo: 12 / 9 / 8) và vẫn trong ngân sách.
    /// </summary>
    [Theory]
    [InlineData(2, 1, 1_500_000, 11)]
    [InlineData(3, 0, 1_500_000, 8)]
    [InlineData(2, 1, 1_200_000, 7)]
    public void Vua_ho_nhieu_nguoi_ngan_sach_sat_van_con_mam(int adults, int children, int budget, int minMam)
    {
        var src = P("p01");
        var prefs = WithHabit(src, "vua");
        prefs.Adults = adults;
        prefs.Children = children;
        prefs.WeeklyBudgetVnd = budget;
        var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(src.Profile), Prefs = prefs, Data = Data, StartDate = Start, Seed = 1 });
        Assert.Equal("ready", plan.Status);
        Assert.True(plan.Shopping.WeekFoodCost <= budget, $"chi phí {plan.Shopping.WeekFoodCost} > ngân sách {budget}");
        var lunchDinner = plan.Days.SelectMany(d => d.Meals).Where(m => Planned(m) && m.Slot is "lunch" or "dinner").ToList();
        var mam = lunchDinner.Count(m => m.Dishes?.Any(x => x.Role == "main") ?? false);
        Assert.True(mam >= minMam, $"{adults}+{children} người, {budget}: chỉ {mam}/{lunchDinner.Count} bữa ghép mâm (cần ≥ {minMam})");
    }

    // ---- AC3: bất biến xếp hạng ----

    /// <summary>
    /// AC3: ở phương án xếp hạng đầu tiên (đúng thứ tự PM), món được chọn cho mỗi bữa trưa/tối luôn thuộc bậc cao nhất trong các ứng viên hợp lệ còn lại
    /// — không bao giờ chọn trọn suất không cơm khi còn mâm bớt cơm hợp lệ (bậc 2), cũng không chọn trọn suất có cơm (bậc 1) khi còn mâm.
    /// </summary>
    [Theory]
    [InlineData("p01", "nhieu")]
    [InlineData("p03", "rat_nhieu")]
    [InlineData("p08", "rat_nhieu")]
    [InlineData("p11", "nhieu")]
    [InlineData("p13", "rat_nhieu")]
    public void AC3_khong_chon_bac_thap_khi_con_bac_cao(string profile, string habit)
    {
        var p = P(profile);
        var picks = new List<PickLog>();
        var plan = WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(p.Profile), Prefs = WithHabit(p, habit), Data = Data, StartDate = Start, Seed = 1,
            Options = new PlanOptions { RiceOnlyAttempt = 1, PickLog = picks.Add },
        });
        Assert.Equal(1, plan.RiceAttempt);
        Assert.NotEmpty(picks);
        Assert.All(picks, x => Assert.True(x.Tier == x.BestTier, $"{profile} {habit} {x.Date} {x.Slot}: chọn {x.RecipeId} bậc {x.Tier} trong khi còn bậc {x.BestTier}"));
        // Ghi nhận bậc: có ít nhất một lựa chọn mâm (bậc 2 hoặc 3).
        Assert.Contains(picks, x => x.Tier >= 2);
    }

    // ---- AC5: khoai/bún ----

    /// <summary>AC5: rice.kind = com cho cơm trắng/gạo lứt (rice_equiv_g = gram thực); khoai/bún là other với rice_equiv_g = gram quy kcal cơm trắng ±5 g.</summary>
    [Fact]
    public void AC5_khoai_bun_la_other_va_rice_equiv_theo_kcal()
    {
        var comKcal = Data.IngredientsById["com_trang"].Per100g.Kcal;
        var seenOther = 0;
        var seenCom = 0;
        foreach (var id in new[] { "p13", "p10", "p06" })
            foreach (var h in new[] { "nhieu", "rat_nhieu" })
                foreach (var m in Plan(P(id), h).Days.SelectMany(d => d.Meals).Where(m => Planned(m) && m.Rice is not null))
                {
                    var r = m.Rice!;
                    var carb = m.Dishes?.FirstOrDefault(d => d.Role == "carb_base");
                    var ingId = carb is not null ? Data.RecipesById[carb.RecipeId!].Ingredients.First(i => i.Role == "carb").IngredientId
                        : Data.RecipesById[m.RecipeId!].Ingredients.First(i => i.Role == "carb").IngredientId;
                    var ing = Data.IngredientsById[ingId];
                    if (ing.PurchaseAs is not null)
                    {
                        seenCom++;
                        Assert.Equal("com", r.Kind);
                        Assert.Equal(r.ActualG, r.RiceEquivG, 1e-6);
                    }
                    else
                    {
                        seenOther++;
                        Assert.Equal("other", r.Kind);
                        Assert.InRange(r.RiceEquivG, r.ActualG * ing.Per100g.Kcal / comKcal - 5, r.ActualG * ing.Per100g.Kcal / comKcal + 5);
                    }
                }
        Assert.True(seenCom > 0, "không thấy bữa cơm");
        Assert.True(seenOther > 0, "không thấy bữa khoai/bún để kiểm tra");
    }

    // ---- Ngoại lệ "ngân sách sát" (D-COM-05) ----

    /// <summary>Một ô (hồ sơ, mức) được miễn vì ràng buộc cứng của người dùng thắng; Reason luôn là "budget" (ngân sách) — danh sách tường minh, không nới ngưỡng chung.</summary>
    private sealed record Exemption(string Profile, string Habit, string Reason);

    /// <summary>
    /// Đo được (seed 1): mọi phương án giữ ≥ 12/14 bữa có cơm ở ô này đều vượt ngân sách của hồ sơ, và mức nhiều của cùng hồ sơ có cơm ở bữa nào cũng dưới sàn của mức rất nhiều
    /// (nên không thể "nâng" tuần mức nhiều lên). Ngân sách đã đo: p02 vừa 595k/600k, p09 vừa 600k/600k, p14 vừa 1.189k/1.200k; p02 rất nhiều cần ≥ 652k, p09 rất nhiều ≥ 686k, p14 rất nhiều ≥ 1.489k.
    /// p14 nhiều đã rời danh sách: tuần mức vừa (14/14 bữa có cơm, đủ ngân sách) được dùng làm tuần mức nhiều, cơm 150 g có ghi chú.
    /// </summary>
    private static readonly Exemption[] BudgetExemptions =
    [
        new("p02", "rat_nhieu", "budget"), new("p09", "rat_nhieu", "budget"), new("p14", "rat_nhieu", "budget"),
    ];

    private static bool Exempt(TestProfile p, string habit) => BudgetExemptions.Any(x => p.Id.StartsWith(x.Profile, StringComparison.Ordinal) && x.Habit == habit);

    private static double RiceEquivWeek(WeekPlan plan) => EngineReport.RiceEquivWeekOf(plan);

    // ---- AC1: tổng tinh bột quy ra cơm cả tuần không giảm khi tăng mức ----

    /// <summary>
    /// AC1 (D-COM-05): Σ rice_equiv_g cả tuần (khoai/bún quy ra cơm) it ≤ vừa ≤ nhiều ≤ rất nhiều, sai số làm tròn ≤ 2%, với mọi hồ sơ không low-carb;
    /// ô thuộc <see cref="BudgetExemptions"/> được miễn. Gạo sống chỉ ghi trong báo cáo (khoai/bún thay cơm là hợp lệ).
    /// </summary>
    [Fact]
    public void AC1_tong_com_quy_doi_ca_tuan_khong_giam_khi_tang_muc()
    {
        foreach (var p in Profiles.Where(p => !p.Preferences.LowCarb))
        {
            var sums = Enums.RiceHabits.Select(h => RiceEquivWeek(Plan(p, h))).ToList();
            for (var i = 1; i < sums.Count; i++)
            {
                if (Exempt(p, Enums.RiceHabits[i])) continue;
                Assert.True(sums[i] >= sums[i - 1] * 0.98, $"{p.Id}: cơm quy đổi cả tuần {string.Join(" → ", sums.Select(x => x.ToString("0")))} (giảm ở mức {Enums.RiceHabits[i]})");
            }
        }
    }

    // ---- AC2: bữa trưa/tối có cơm ----

    /// <summary>
    /// AC2: ≥ 12/14 bữa trưa/tối có cơm ở mức nhiều/rất nhiều với hồ sơ lên cả trưa lẫn tối (trừ low-carb), ngoại trừ <see cref="BudgetExemptions"/>.
    /// Mỗi ngoại lệ phải còn đúng (thật sự &lt; 12/14 hoặc đủ cơm nhưng vượt ngân sách) và phải có cảnh báo lý do budget kèm ngân sách cần &gt; ngân sách hiện có.
    /// </summary>
    [Fact]
    public void AC2_it_nhat_12_tren_14_bua_trua_toi_co_com_o_muc_nhieu_tru_ngoai_le_ngan_sach_sat()
    {
        foreach (var p in Profiles.Where(p => !p.Preferences.LowCarb && p.Preferences.Slots.Mode("lunch") == "on" && p.Preferences.Slots.Mode("dinner") == "on"))
            foreach (var h in new[] { "nhieu", "rat_nhieu" })
            {
                var plan = Plan(p, h);
                var ld = EngineReport.LunchDinnerOf(plan);
                var withRice = ld.Count(m => m.Rice is not null);
                if (!Exempt(p, h))
                {
                    Assert.True(withRice >= 12, $"{p.Id} {h}: {withRice}/{ld.Count} bữa trưa/tối có cơm");
                    continue;
                }
                Assert.True(withRice < 12, $"{p.Id} {h}: ngoại lệ ngân sách sát nhưng đã đạt {withRice}/{ld.Count} — bỏ khỏi danh sách");
                var item = Feas(p, h);
                Assert.False(item.Feasible);
                Assert.True(item.BudgetNeededVnd is { } need && need > p.Preferences.WeeklyBudgetVnd, $"{p.Id} {h}: ngân sách cần {item.BudgetNeededVnd} không lớn hơn {p.Preferences.WeeklyBudgetVnd}");
            }
    }

    private static RiceFeasibilityItem Feas(TestProfile p, string habit) =>
        RiceFeasibility.Evaluate(TargetCalc.Compute(p.Profile), WithHabit(p, habit), new Dictionary<string, WeekPlan> { [habit] = Plan(p, habit) }).Single(f => f.Habit == habit);

    // ---- AC4: cảnh báo onboarding ----

    /// <summary>
    /// AC4 (D-COM-05, không ngoại lệ): 16 hồ sơ × 4 mức = 64 ô — hồ sơ × mức có &gt; 20% bữa mâm bị ghi chú bớt cơm (hoặc &gt; 20% bữa trưa/tối không đủ cơm) thì cờ cảnh báo bật, kèm lý do
    /// (kcal_protein | budget). Chiều ngược lại: đủ cơm mọi bữa và kcal/đạm đủ chỗ thì không cảnh báo.
    /// </summary>
    [Fact]
    public void AC4_64_o_ghi_chu_giam_com_tren_20_phan_tram_thi_canh_bao_bat_khong_ngoai_le()
    {
        var cells = 0;
        foreach (var p in Profiles)
            foreach (var h in Enums.RiceHabits)
            {
                cells++;
                var plan = Plan(p, h);
                var item = Feas(p, h);
                var rm = EngineReport.RiceMealsOf(plan);
                var ld = EngineReport.LunchDinnerOf(plan);
                var ratio = EngineReport.RiceNoteRatioOf(plan);
                var withoutFull = ld.Count - ld.Count(m => m.Rice is not null && m.Notes?.Any(n => n.Code == "rice_reduced") != true);
                if (!p.Preferences.LowCarb && (ratio > 0.2 + 1e-9 || withoutFull > 0.2 * ld.Count + 1e-9))
                {
                    Assert.False(item.Feasible, $"{p.Id} {h}: {ratio:P0} bữa ghi chú giảm cơm, {withoutFull}/{ld.Count} bữa không đủ cơm nhưng không có cảnh báo");
                    Assert.Contains(item.Reason, new[] { "kcal_protein", "budget" });
                }
                if (!item.Feasible && item.Reason == "budget") Assert.True(withoutFull > 0.2 * ld.Count, $"{p.Id} {h}: cảnh báo ngân sách thừa");
                if (rm.Count == ld.Count && rm.Count > 0 && ratio == 0) Assert.True(item.Feasible, $"{p.Id} {h}: cảnh báo thừa (đủ cơm mọi bữa; {item.Reason})");
            }
        Assert.Equal(64, cells);
        // p14 mức 2 chén (nhiều) phải cảnh báo vì ngân sách
        var p14 = Feas(P("p14"), "nhieu");
        Assert.False(p14.Feasible);
        Assert.Equal("budget", p14.Reason);
    }

    [Fact]
    public void Muc_com_kha_thi_p01_1_chen_o_vua_va_duoi_muc_o_nhieu()
    {
        var p = P("p01");
        var f = RiceFeasibility.Compute(TargetCalc.Compute(p.Profile), p.Preferences.Slots);
        Assert.Equal(4, f.Count);
        Assert.Equal(["it", "vua", "nhieu", "rat_nhieu"], f.Select(x => x.Habit));
        Assert.True(f.Single(x => x.Habit == "vua").Feasible);
        Assert.Equal(1.0, f.Single(x => x.Habit == "vua").FeasibleCups);
        var nhieu = f.Single(x => x.Habit == "nhieu");
        Assert.False(nhieu.Feasible);
        Assert.InRange(nhieu.FeasibleCups, 1, 1.5);
        Assert.Equal(2.0, nhieu.TargetCups);
        // khả thi không bao giờ vượt mức chọn và không giảm khi mức tăng (cùng kcal)
        Assert.All(f, x => Assert.True(x.FeasibleG <= x.TargetG));
    }

    [Fact]
    public void Muc_com_kha_thi_chi_tieu_lon_thi_du_muc_cao()
    {
        var p = P("p03");
        var f = RiceFeasibility.Compute(TargetCalc.Compute(p.Profile), p.Preferences.Slots);
        Assert.All(f, x => Assert.True(x.Feasible, $"{x.Habit}: {x.FeasibleG} g"));
        Assert.Equal(3.0, f.Single(x => x.Habit == "rat_nhieu").FeasibleCups);
    }

    // ---- Dồn kcal ----

    [Fact]
    public void Don_kcal_chi_o_muc_nhieu_va_toi_da_15_phan_tram_tu_sang_va_bua_phu()
    {
        var p = P("p03");
        var t = TargetCalc.Compute(p.Profile);
        var cfg = p.Preferences.Slots;
        var baseSlots = MealSlots.Allocate(t, cfg);
        Assert.Equal(0, RiceHabits.KcalShift("vua", 0.15));
        var shifted = MealSlots.Allocate(t, cfg, RiceHabits.KcalShift("rat_nhieu", 0.15));
        Assert.Equal(baseSlots.Sum(s => s.Kcal), shifted.Sum(s => s.Kcal), 1e-6);
        var moved = shifted.Single(s => s.Slot == "lunch").Kcal + shifted.Single(s => s.Slot == "dinner").Kcal - baseSlots.Single(s => s.Slot == "lunch").Kcal - baseSlots.Single(s => s.Slot == "dinner").Kcal;
        Assert.InRange(moved / t.KcalTarget, 0.1 - 1e-9, 0.15 + 1e-9);
        // sáng/phụ không bị rút quá nửa phần
        foreach (var s in new[] { "breakfast", "snack_am", "snack_pm" })
            Assert.True(shifted.Single(x => x.Slot == s).Kcal >= 0.5 * baseSlots.Single(x => x.Slot == s).Kcal - 1e-6);
        // đạm không đổi
        Assert.All(shifted, s => Assert.Equal(baseSlots.Single(x => x.Slot == s.Slot).ProteinG, s.ProteinG, 1e-6));
    }

    // ---- AC6: không hồi quy so với T-096 ở mức ít/vừa ----

    [Fact]
    public void AC6_it_va_vua_16_ho_so_van_dat_7_tren_7_va_trong_ngan_sach()
    {
        foreach (var h in new[] { "it", "vua" })
            foreach (var p in Profiles)
            {
                var plan = Plan(p, h);
                var where = $"{p.Id} {h}";
                Assert.Equal("ready", plan.Status);
                Assert.True(plan.Validation.Days.All(d => d.Ok), $"{where}: không đạt 7/7");
                Assert.True(plan.Shopping.WeekFoodCost <= p.Preferences.WeeklyBudgetVnd + 1e-6, $"{where}: vượt ngân sách");
                Assert.Empty(EngineReport.CheckHardConstraints(plan, p, Data));
                var rm = EngineReport.RiceMealsOf(plan);
                if (rm.Count > 0) Assert.True(EngineReport.RiceNoteRatioOf(plan) <= 0.2 + 1e-9, $"{where}: {EngineReport.RiceNoteRatioOf(plan):P0} ghi chú giảm cơm");
            }
        Assert.True(EngineReport.RiceMedianOf(Plan(P("p01"), "vua")) >= 140);
    }

    /// <summary>Mức nhiều/rất nhiều: 16/16 hồ sơ vẫn 7/7, trong ngân sách, không vi phạm ràng buộc cứng, kcal trong dải.</summary>
    [Fact]
    public void Muc_nhieu_va_rat_nhieu_16_ho_so_dat_7_tren_7_trong_ngan_sach()
    {
        foreach (var h in new[] { "nhieu", "rat_nhieu" })
            foreach (var p in Profiles)
            {
                var plan = Plan(p, h);
                var where = $"{p.Id} {h}";
                Assert.Equal("ready", plan.Status);
                Assert.True(plan.Validation.Days.All(d => d.Ok), $"{where}: không đạt 7/7");
                Assert.True(plan.Shopping.WeekFoodCost <= p.Preferences.WeeklyBudgetVnd + 1e-6, $"{where}: vượt ngân sách");
                Assert.Empty(EngineReport.CheckHardConstraints(plan, p, Data));
                Assert.Equal(0, EngineReport.RiceBelowFloorOf(plan));
            }
    }

    /// <summary>AC7 (D-COM-05): ở 2 chén / 3+ chén chấp nhận ≥ 6 món trưa/tối khác nhau trong tuần (½ và 1 chén giữ ngưỡng D-DIV-01/02, kiểm ở các test mâm).</summary>
    [Fact]
    public void AC7_muc_nhieu_va_rat_nhieu_it_nhat_6_mon_trua_toi_khac_nhau()
    {
        foreach (var p in Profiles)
            foreach (var h in new[] { "nhieu", "rat_nhieu" })
            {
                var n = EngineReport.LunchDinnerOf(Plan(p, h)).Select(m => m.RecipeId).Distinct().Count();
                Assert.True(n >= 6, $"{p.Id} {h}: chỉ {n} món trưa/tối khác nhau");
            }
    }
}
