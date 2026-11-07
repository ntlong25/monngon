using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

// Port của src/engine/planWeek.test.ts (phần chính) trên fixture.
public class PlanWeekTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Fixtures);

    internal static Targets Manual(double kcal, double protein) => TargetCalc.Compute(new Profile
    {
        Goal = "hold", Sex = "male", Age = 30, HeightCm = 175, WeightKg = 70, Activity = "moderate", TargetMode = "manual", ManualKcal = kcal, ManualProteinG = protein,
    });

    private static Preferences Prefs(Action<Preferences>? edit = null, double budget = 1_000_000)
    {
        var p = new Preferences
        {
            StoreId = "winmart", WeeklyBudgetVnd = budget, Equipment = ["bep", "noi_com_dien", "lo_vi_song"],
            Slots = new SlotsConfig { Breakfast = "on", Lunch = "on", Dinner = "on", SnackAm = "skip", SnackPm = "skip" },
        };
        edit?.Invoke(p);
        return p;
    }

    /// <summary>Các test cũ kiểm tra hành vi parity T-064 (không ghép mâm).</summary>
    internal static readonly PlanOptions Legacy = new() { MealStyle = MealStyle.FullMealOnly };

    internal static WeekPlan Run(Targets t, Action<Preferences>? edit = null, long seed = 1, double budget = 1_000_000, PlanOptions? options = null, string start = "2026-11-07") =>
        WeekPlanner.Plan(new PlanWeekInput { Targets = t, Prefs = Prefs(edit, budget), Data = Data, StartDate = start, Seed = seed, Options = options ?? Legacy });

    private static IEnumerable<PlanMeal> Meals(WeekPlan p) => p.Days.SelectMany(d => d.Meals);

    // ---- WeekValidator ----
    private static readonly Targets T = new() { ProteinG = 100, KcalMin = 1900, KcalMax = 2000 };
    private static DayTotal Day(string d, double p, double k, bool ex = false) => new() { Date = d, ProteinG = p, Kcal = k, Exempt = ex };

    [Fact] public void Validator_dat_het() { var v = WeekValidator.Validate([Day("a", 100, 1950), Day("b", 120, 2000)], T, 500000, 400000); Assert.True(v.Ok); Assert.Empty(v.Shortfalls); }

    [Fact]
    public void Validator_thieu_protein()
    {
        var v = WeekValidator.Validate([Day("thu5", 92, 1950), Day("thu6", 100, 1950)], T, 1, 0);
        Assert.False(v.Ok);
        Assert.Equal(1, v.DaysMissing);
        var s = Assert.Single(v.Shortfalls);
        Assert.Equal(("thu5", "protein_low", 8.0), (s.Date, s.Kind, s.Amount));
    }

    [Fact]
    public void Validator_kcal_duoi_tren()
    {
        var v = WeekValidator.Validate([Day("a", 100, 1800), Day("b", 100, 2150)], T, 1, 0);
        Assert.Equal([("a", "kcal_low", 100.0), ("b", "kcal_high", 150.0)], v.Shortfalls.Select(s => (s.Date, s.Kind, s.Amount)));
    }

    [Fact] public void Validator_nhieu_loi() => Assert.Equal(["protein_low", "kcal_low"], WeekValidator.Validate([Day("a", 80, 1700)], T, 1, 0).Shortfalls.Select(s => s.Kind));
    [Fact] public void Validator_vuot_ngan_sach() { var v = WeekValidator.Validate([Day("a", 100, 1950)], T, 500000, 530000); Assert.False(v.Ok); Assert.Equal(30000, v.BudgetOverVnd); }
    [Fact] public void Validator_exempt() { var v = WeekValidator.Validate([Day("a", 10, 100, true)], T, 1, 0); Assert.True(v.Ok); Assert.Empty(v.Shortfalls); }
    [Fact] public void Validator_khong_lay_trung_binh() => Assert.Equal(1, WeekValidator.Validate([Day("a", 200, 1950), Day("b", 90, 1950)], T, 1, 0).DaysMissing);

    // ---- hồ sơ dễ ----
    [Fact]
    public void Ho_so_de_7_7_ngay_dat()
    {
        var t = Manual(1800, 100);
        var plan = Run(t);
        Assert.Equal("ready", plan.Status);
        Assert.Equal(0, plan.Validation.DaysMissing);
        Assert.Equal(7, plan.Days.Count);
        foreach (var d in plan.Days)
        {
            Assert.True(d.Totals.ProteinG >= t.ProteinG);
            Assert.InRange(d.Totals.Kcal, t.KcalMin, t.KcalMax);
        }
        Assert.True(plan.Shopping.WeekFoodCost <= plan.BudgetVnd);
        Assert.Equal(Enumerable.Range(0, 7).Select(i => WeekPlanner.AddDays("2026-11-07", i)), plan.Days.Select(d => d.Date));
        Assert.Equal("2027-01-02", WeekPlanner.AddDays("2026-12-30", 3));
        foreach (var d in plan.Days) Assert.Equal(["breakfast", "dinner", "lunch"], d.Meals.Select(m => m.Slot).Order(StringComparer.Ordinal));
    }

    [Fact]
    public void Macro_moi_bua_khop_tinh_lai_va_batch_group()
    {
        var plan = Run(Manual(1800, 100));
        foreach (var m in Meals(plan))
        {
            var re = Nutrition.Compute(m.Grams, Data.IngredientsById).Total;
            Assert.Equal(re.Kcal, m.Macros.Kcal, 6);
            Assert.Equal(re.ProteinG, m.Macros.ProteinG, 6);
        }
        foreach (var d in plan.Days) Assert.NotEqual(d.Meals.First(m => m.Slot == "lunch").RecipeId, d.Meals.First(m => m.Slot == "dinner").RecipeId);
        var groups = Meals(plan).GroupBy(m => m.BatchGroupId).Select(g => g.Count()).ToList();
        Assert.Contains(2, groups);
        Assert.All(groups, n => Assert.True(n <= 2));
    }

    [Fact]
    public void Tat_dinh_va_khong_dung_vao_dau_vao()
    {
        var t = Manual(1800, 100);
        var a = System.Text.Json.JsonSerializer.Serialize(Run(t, seed: 42), JsonOptions.Default);
        var b = System.Text.Json.JsonSerializer.Serialize(Run(t, seed: 42), JsonOptions.Default);
        Assert.Equal(a, b);
        var prefs = Prefs();
        var snap = System.Text.Json.JsonSerializer.Serialize(prefs, JsonOptions.Default);
        WeekPlanner.Plan(new PlanWeekInput { Targets = t, Prefs = prefs, Data = Data, StartDate = "2026-11-07", Seed = 3, Options = Legacy });
        Assert.Equal(snap, System.Text.Json.JsonSerializer.Serialize(prefs, JsonOptions.Default));
    }

    // ---- bất khả thi ----
    [Fact]
    public void Protein_qua_cao_partial_voi_muc_thieu_dung()
    {
        var t = Manual(1500, 250);
        var plan = Run(t);
        Assert.Equal("partial", plan.Status);
        var short_ = plan.Validation.Shortfalls.Where(s => s.Kind == "protein_low").ToList();
        Assert.NotEmpty(short_);
        foreach (var s in short_) Assert.Equal(t.ProteinG - plan.Days.First(x => x.Date == s.Date).Totals.ProteinG, s.Amount, 6);
    }

    [Fact]
    public void Ngan_sach_qua_thap_partial()
    {
        var plan = Run(Manual(1800, 100), budget: 50_000);
        Assert.Equal("partial", plan.Status);
        Assert.Equal(plan.Shopping.WeekFoodCost - 50_000, plan.Validation.BudgetOverVnd);
        Assert.Equal(0, plan.Validation.DaysMissing);
    }

    // ---- ràng buộc cứng ----
    public static IEnumerable<object[]> HardCases() =>
    [
        [0], [1], [2], [3], [4], [5], [6],
    ];

    private static void ApplyHard(int i, Preferences p)
    {
        switch (i)
        {
            case 0: p.Exclusions = ["no_pork"]; break;
            case 1: p.Exclusions = ["no_fish", "no_pork"]; break;
            case 2: p.Diet = "vegetarian"; break;
            case 3: p.Exclusions = ["no_peanut", "no_tree_nut"]; break;
            case 4: p.DislikedIngredientIds = ["rau_muong"]; break;
            case 5: p.BlockedRecipeIds = ["uc_ga_xao_sup_lo_toi"]; break;
            case 6: p.Equipment = ["bep"]; break;
        }
    }

    [Theory]
    [MemberData(nameof(HardCases))]
    public void Rang_buoc_cung_khong_vi_pham(int i)
    {
        var prefs = Prefs(p => ApplyHard(i, p));
        var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = Manual(1800, 90), Prefs = prefs, Data = Data, StartDate = "2026-11-07", Seed = 5, Options = Legacy });
        var banned = Filter.BannedIngredients(Data.Ingredients, prefs);
        foreach (var m in Meals(plan))
        {
            if (m.RecipeId is null) continue;
            Assert.DoesNotContain(m.RecipeId, prefs.BlockedRecipeIds);
            foreach (var e in Data.RecipesById[m.RecipeId].Equipment) Assert.Contains(e, prefs.Equipment);
            foreach (var g in m.Grams) Assert.False(banned.ContainsKey(g.IngredientId));
        }
    }

    [Fact]
    public void It_tinh_bot_low_carb_va_carb_0()
    {
        var plan = Run(Manual(1800, 100), p => p.LowCarb = true);
        foreach (var m in Meals(plan).Where(m => m.Slot is "lunch" or "dinner"))
        {
            Assert.True(Data.RecipesById[m.RecipeId!].IsLowCarb);
            Assert.Equal(0, m.Grams.First(g => g.IngredientId == "com_trang").Grams);
        }
    }

    [Fact]
    public void Khong_con_cong_thuc_cho_mot_bua_khong_nem_loi()
    {
        var plan = Run(Manual(1800, 100), p => p.Exclusions = ["no_egg"]);
        Assert.Equal("partial", plan.Status);
        Assert.Equal(["breakfast"], plan.UnfilledSlots);
        foreach (var d in plan.Days)
        {
            var bf = d.Meals.First(m => m.Slot == "breakfast");
            Assert.Equal("unfilled", bf.Status);
            Assert.Null(bf.RecipeId);
            Assert.Empty(bf.Grams);
        }
    }

    [Fact]
    public void Khong_co_cong_thuc_nao_thieu_du_7_ngay()
    {
        var t = Manual(1800, 100);
        var plan = Run(t, p => p.Equipment = ["lo_vi_song"]);
        Assert.Equal("partial", plan.Status);
        Assert.Equal(["breakfast", "dinner", "lunch"], plan.UnfilledSlots.Order(StringComparer.Ordinal));
        Assert.Equal(7, plan.Validation.DaysMissing);
        var p7 = plan.Validation.Shortfalls.Where(s => s.Kind == "protein_low").ToList();
        Assert.Equal(7, p7.Count);
        foreach (var s in p7) Assert.Equal(t.ProteinG, s.Amount, 6);
        Assert.Empty(plan.Shopping.Items);
    }

    [Fact]
    public void Thuan_chay_it_tinh_bot_protein_cao_khong_nem_loi()
    {
        var plan = Run(Manual(1800, 190), p => { p.Diet = "vegan"; p.LowCarb = true; });
        Assert.Contains(plan.Status, new[] { "ready", "partial" });
        Assert.Equal(7, plan.Days.Count);
    }

    [Fact]
    public void Bua_self_khong_len_mon_nhung_tinh_du_chi_tieu()
    {
        var plan = Run(Manual(1800, 100), p => p.Slots.Breakfast = "self");
        foreach (var d in plan.Days)
        {
            var bf = d.Meals.First(m => m.Slot == "breakfast");
            Assert.Equal("self", bf.Status);
            Assert.Equal(1800 * (0.2 / 0.9), bf.Macros.Kcal, 6);
            Assert.Equal(2, d.Meals.Count(m => m.Status == "planned"));
        }
        Assert.Equal("ready", plan.Status);
    }

    // ---- món phụ & sửa ngân sách ----
    [Fact]
    public void Mon_phu_bu_chi_tieu()
    {
        var t = Manual(2800, 140);
        var without = Run(t, budget: 2_000_000, start: "2026-11-09", options: new PlanOptions { MealStyle = MealStyle.FullMealOnly, Extras = false, BudgetRepair = false });
        var withEx = Run(t, budget: 2_000_000, start: "2026-11-09");
        Assert.Equal("partial", without.Status);
        Assert.Equal("ready", withEx.Status);
        var ex = Meals(withEx).Where(m => m.Extras.Count > 0).ToList();
        Assert.NotEmpty(ex);
        foreach (var m in ex)
        {
            Assert.Contains(m.Slot, new[] { "breakfast", "lunch", "dinner" });
            var core = Nutrition.Compute(m.Grams, Data.IngredientsById).Total;
            var extra = Nutrition.Compute(m.Extras, Data.IngredientsById).Total;
            Assert.Equal(core.Kcal + extra.Kcal, m.Macros.Kcal, 6);
            foreach (var e in m.Extras) Assert.Equal(0, e.Grams % 5);
        }
    }

    [Fact]
    public void Sua_ngan_sach_giam_chi_phi()
    {
        var t = Manual(1800, 100);
        var generous = Run(t, budget: 5_000_000);
        var budget = generous.Shopping.WeekFoodCost - 60_000;
        var off = Run(t, budget: budget, options: new PlanOptions { MealStyle = MealStyle.FullMealOnly, BudgetRepair = false });
        var on = Run(t, budget: budget);
        Assert.True(on.Repairs > 0);
        Assert.True(on.Shopping.WeekFoodCost < off.Shopping.WeekFoodCost);
        Assert.True(on.Validation.DaysMissing <= off.Validation.DaysMissing);
        foreach (var m in Meals(on).Where(m => m.Status == "planned"))
        {
            var re = Nutrition.Compute(m.Grams.Concat(m.Extras), Data.IngredientsById).Total;
            Assert.Equal(re.Kcal, m.Macros.Kcal, 6);
            Assert.Equal(m.Grams.Count, m.StandardGrams.Count);
        }
        Assert.Equal(0, Run(t).Repairs);
    }

}

// Port của src/engine/__tests__/profiles.test.ts trên data/ thật.
[CollectionDefinition("Perf", DisableParallelization = true)]
public class PerfCollection;

/// <summary>Chứa test đo thời gian: chạy riêng, không song song với test khác để không bị nhiễu.</summary>
[Collection("Perf")]
public class PerfTests
{
    [Fact]
    public void Hieu_nang_duoi_2_giay_ca_ho_so_kho()
    {
        // Chạy riêng (collection Perf không song song) + một lượt khởi động (JIT, nạp dữ liệu) rồi lấy lần nhanh nhất trong 3 lần,
        // để tải nặng của máy (build, test khác) không làm test đỏ ngẫu nhiên.
        PlanWeekTests.Run(PlanWeekTests.Manual(1500, 250));
        var best = long.MaxValue;
        for (var i = 0; i < 3; i++)
        {
            var sw = System.Diagnostics.Stopwatch.StartNew();
            PlanWeekTests.Run(PlanWeekTests.Manual(1500, 250));
            best = Math.Min(best, sw.ElapsedMilliseconds);
        }
        Assert.True(best < 2000, $"lần nhanh nhất {best} ms");
    }
}

[Collection("Perf")]
public class ProfilesTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));

    [Fact]
    public void Rang_buoc_cung_100_phan_tram_va_ti_le_dat()
    {
        var results = Profiles.Select(p => EngineReport.RunProfile(p, Data, 1, "2026-11-09", PlanWeekTests.Legacy)).ToList();
        var s = EngineReport.Summarize(results);
        Assert.Equal(0, s.HardViolations);
        Assert.True(s.ExpectedPass > 0);
        Assert.True((double)s.ExpectedPassReady / s.ExpectedPass >= 0.9, EngineReport.Format(results));
        foreach (var r in results.Where(r => r.Status == "error")) Assert.False(r.ExpectAllDaysPass, $"{r.Name}: {r.Error}");
        Assert.Contains("TỔNG HỢP", EngineReport.Format(results));
    }

    [Fact]
    public void Moi_ho_so_duoi_200ms_p95()
    {
        var ms = new List<double>();
        foreach (var p in Profiles)
            for (var seed = 1; seed <= 3; seed++) ms.Add(EngineReport.RunProfile(p, Data, seed, "2026-11-09", PlanWeekTests.Legacy).Ms);
        ms.Sort();
        Assert.True(ms[(int)(ms.Count * 0.95)] <= 200, $"p95 = {ms[(int)(ms.Count * 0.95)]:0} ms");
    }

    [Fact]
    public void Tat_dinh()
    {
        string Run1() => StripMs(EngineReport.Format(Profiles.Select(p => EngineReport.RunProfile(p, Data, 1, "2026-11-09", PlanWeekTests.Legacy)).ToList()));
        Assert.Equal(Run1(), Run1());
    }

    private static string StripMs(string s) => string.Join("|", s.Split((char)10).Where(l => !l.Contains(" ms")));
}
