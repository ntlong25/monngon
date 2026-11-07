using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>T-094 / D-COM-01 — lượng cơm theo thói quen: cơm mâm ghim theo mức, chỉ giảm khi cần và luôn có ghi chú.</summary>
public class RiceTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";

    private static TestProfile P(string id) => Profiles.Single(p => p.Id.StartsWith(id, StringComparison.Ordinal));

    private static WeekPlan Plan(TestProfile p, string? habit = null, long seed = 1, MealStyle style = MealStyle.Auto)
    {
        var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        if (habit is not null) prefs.RiceHabit = habit;
        return WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = Data, StartDate = Start, Seed = seed,
            Options = new PlanOptions { MealStyle = style },
        });
    }

    private static List<PlanMeal> RiceMeals(WeekPlan plan) => EngineReport.RiceMealsOf(plan);

    [Fact]
    public void Thieu_rice_habit_la_vua_va_gram_cac_muc_dung_theo_PRD()
    {
        Assert.Equal("vua", new Preferences().RiceHabit);
        Assert.Equal(75, RiceHabits.TargetG("it"));
        Assert.Equal(150, RiceHabits.TargetG("vua"));
        Assert.Equal(300, RiceHabits.TargetG("nhieu"));
        Assert.Equal(450, RiceHabits.TargetG("rat_nhieu"));
        Assert.Equal(150, RiceHabits.TargetG(null));
        // sàn = max(50% mức, 60 g), nhưng không vượt mức
        Assert.Equal(60, RiceHabits.FloorG("it"));
        Assert.Equal(75, RiceHabits.FloorG("vua"));
        Assert.Equal(150, RiceHabits.FloorG("nhieu"));
        Assert.Equal(225, RiceHabits.FloorG("rat_nhieu"));
    }

    /// <summary>AC1: 16 hồ sơ × 3 seed, mức vừa — cơm đúng mức (±10 g) hoặc có ghi chú rice_reduced với cơm ≥ sàn; không giảm mà thiếu ghi chú.</summary>
    [Fact]
    public void Bat_bien_com_dung_muc_hoac_co_ghi_chu_va_khong_duoi_san()
    {
        foreach (var p in Profiles)
            foreach (var seed in new long[] { 1, 2, 3 })
            {
                var plan = Plan(p, null, seed);
                foreach (var m in RiceMeals(plan))
                {
                    var r = m.Rice!;
                    var where = $"{p.Id} seed {seed} {m.Date} {m.Slot}";
                    Assert.Equal("vua", r.Habit);
                    Assert.True(r.ActualG >= RiceHabits.FloorG(r.Habit) - 1e-6, $"{where}: cơm {r.ActualG} g dưới sàn");
                    var note = m.Notes?.SingleOrDefault(n => n.Code == "rice_reduced");
                    if (r.ActualG < r.TargetG - RiceHabits.ToleranceG)
                    {
                        Assert.NotNull(note);
                        Assert.Equal(r.TargetG, note!.TargetG);
                        Assert.Equal(r.ActualG, note.ActualG);
                        Assert.Contains(note.Reason, new[] { "kcal", "protein" });
                    }
                    else Assert.Null(note);
                    Assert.True(Math.Abs(r.ActualG - m.Grams[RiceIdx(m)].Grams) < 1e-9);
                }
            }
    }

    /// <summary>Chỉ số dòng cơm trong Grams: mâm đủ → dòng cơm của mâm; món trọn suất có cơm (T-098) → dòng carb đầu tiên của công thức.</summary>
    private static int RiceIdx(PlanMeal m)
    {
        var mam = MamBuilder.Rebuild(m.RecipeId!, Data, "vua");
        if (mam is { RiceIdx: >= 0 }) return mam.RiceIdx;
        return Data.RecipesById[m.RecipeId!].Ingredients.FindIndex(i => i.Role == "carb");
    }

    /// <summary>AC2: p01 mức vừa — mỗi bữa mâm có cơm ≥ 140 g trừ bữa có ghi chú.</summary>
    [Fact]
    public void P01_vua_moi_bua_mam_com_tu_140_g_tru_bua_co_ghi_chu()
    {
        var plan = Plan(P("p01"));
        var meals = RiceMeals(plan);
        Assert.NotEmpty(meals);
        foreach (var m in meals)
            Assert.True(m.Rice!.ActualG >= 140 || m.Notes?.Any(n => n.Code == "rice_reduced") == true, $"{m.Date} {m.Slot}: cơm {m.Rice!.ActualG} g không ghi chú");
    }

    /// <summary>AC3: ma trận p01 × 4 mức — cơm trung vị và gạo cần mua tăng dần theo mức.</summary>
    [Fact]
    public void P01_bon_muc_com_trung_vi_va_gao_can_mua_tang_dan()
    {
        var med = new List<double>();
        var raw = new List<double>();
        foreach (var h in Enums.RiceHabits)
        {
            var plan = Plan(P("p01"), h);
            Assert.Equal("ready", plan.Status);
            med.Add(EngineReport.RiceMedianOf(plan));
            raw.Add(plan.Shopping.Items.Where(i => i.IngredientId is "gao_te" or "gao_lut").Sum(i => i.NeedG));
        }
        // T-096: p01 chỉ tiêu 1.400 kcal nên mức nhiều/rất nhiều bị trần kcal chặn: cơm trung vị không giảm theo mức, nhưng bữa nguyên (không cơm) thay cho mâm bớt cơm
        // làm gạo cần mua của hai mức cao không tăng thêm — chỉ khẳng định it < vừa ở gạo cần mua.
        for (var i = 1; i < med.Count; i++)
            Assert.True(med[i] >= med[i - 1], $"cơm trung vị giảm: {string.Join(" ≤ ", med)}");
        Assert.True(med[1] > med[0] && med[^1] > med[1], $"cơm trung vị không tăng giữa các mức: {string.Join(" ≤ ", med)}");
        Assert.True(raw[1] > raw[0], $"gạo cần mua không tăng từ ít lên vừa: {string.Join(" ≤ ", raw)}");
    }

    /// <summary>AC4: 16 hồ sơ mức vừa vẫn đạt 7/7, kcal/protein, không vi phạm cứng, ≥ 60% bữa trưa/tối là mâm.</summary>
    [Fact]
    public void Muc_vua_16_ho_so_van_dat_7_tren_7_va_ghep_mam_nhieu()
    {
        var results = Profiles.Select(p => EngineReport.RunProfile(p, Data, 1, Start)).ToList();
        var s = EngineReport.Summarize(results);
        Assert.Equal(0, s.HardViolations);
        Assert.Equal(16, s.Ready);
        Assert.Equal(s.DaysTotal, s.DaysOk);
        Assert.True(s.MamRatio >= 0.6, $"mâm {s.MamRatio:P0}");
        Assert.All(results, r => Assert.Equal(0, r.RiceBelowFloor));
    }

    /// <summary>T-096 AC1+AC2: mức vừa — p01 ≤ 20% bữa mâm bị giảm cơm, trung vị ≥ 140 g; không hồ sơ nào > 20%; trung bình 16 hồ sơ ≤ 5% (3 seed).</summary>
    [Fact]
    public void T096_muc_vua_giu_com_khau_vi_khong_lam_giam_com()
    {
        foreach (var seed in new long[] { 1, 2, 3 })
        {
            var ratios = new List<double>();
            foreach (var p in Profiles)
            {
                var plan = Plan(p, null, seed);
                if (RiceMeals(plan).Count == 0) continue;
                var ratio = EngineReport.RiceNoteRatioOf(plan);
                ratios.Add(ratio);
                Assert.True(ratio <= 0.2 + 1e-9, $"{p.Id} seed {seed}: {ratio:P0} bữa mâm giảm cơm");
                if (p.Id.StartsWith("p01", StringComparison.Ordinal))
                    Assert.True(EngineReport.RiceMedianOf(plan) >= 140, $"p01 seed {seed}: cơm trung vị {EngineReport.RiceMedianOf(plan)} g");
            }
            Assert.True(ratios.Average() <= 0.05 + 1e-9, $"seed {seed}: trung bình {ratios.Average():P1}");
        }
    }

    /// <summary>T-096: khẩu vị "thích" chỉ xếp hạng trong nhóm giữ được cơm — p01 vẫn ≥ 50% bữa mâm khớp khẩu vị thích.</summary>
    [Fact]
    public void T096_p01_van_khop_khau_vi_thich_it_nhat_50_phan_tram()
    {
        foreach (var seed in new long[] { 1, 2, 3 })
        {
            var like = EngineReport.LikeMatchOf(Plan(P("p01"), null, seed), P("p01").Preferences, Data);
            Assert.NotNull(like);
            Assert.True(like >= 0.5, $"seed {seed}: {like:P0}");
        }
    }

    /// <summary>T-096: mâm không có hai món canh (món chính dạng canh tính là canh).</summary>
    [Fact]
    public void T096_mam_khong_co_hai_canh()
    {
        foreach (var h in new[] { "vua", "nhieu" })
            foreach (var p in Profiles)
                foreach (var m in Plan(p, h).Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Dishes is not null))
                {
                    var soups = m.Dishes!.Count(d => d.Role == "soup" || (d.Role == "main" && d.RecipeId is not null && Data.RecipesById[d.RecipeId].CuisineTags.Contains("canh")));
                    Assert.True(soups <= 1, $"{p.Id} {h} {m.Date} {m.Slot}: {soups} món canh");
                }
    }

    /// <summary>T-096 (P1): bữa phụ được lên món phải ≥ 40 kcal ở mọi mức cơm.</summary>
    [Fact]
    public void T096_bua_phu_len_mon_phai_tu_40_kcal()
    {
        foreach (var h in Enums.RiceHabits)
            foreach (var p in Profiles)
                foreach (var m in Plan(p, h).Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Slot is "snack_am" or "snack_pm"))
                    Assert.True(m.Macros.Kcal >= 40, $"{p.Id} {h} {m.Date} {m.Slot}: {m.Macros.Kcal:0} kcal ({m.RecipeId})");
    }

    /// <summary>Mọi mức đều giữ 7/7 và không có bữa giảm cơm thiếu ghi chú.</summary>
    [Fact]
    public void Bon_muc_deu_dat_7_tren_7_va_khong_giam_com_thieu_ghi_chu()
    {
        foreach (var h in Enums.RiceHabits)
            foreach (var p in Profiles)
            {
                var plan = Plan(p, h);
                Assert.True(plan.Validation.Days.All(d => d.Ok), $"{p.Id} {h}: không đạt 7/7");
                Assert.Equal(0, EngineReport.RiceBelowFloorOf(plan));
            }
    }

    /// <summary>Ít tinh bột (low_carb): mâm không có cơm → không có rice/ghi chú.</summary>
    [Fact]
    public void Low_carb_khong_co_com_va_che_do_parity_khong_co_thong_tin_com()
    {
        var plan = Plan(P("p05"));
        Assert.True(P("p05").Preferences.LowCarb);
        Assert.Empty(RiceMeals(plan));
        var parity = Plan(P("p01"), null, 1, MealStyle.FullMealOnly);
        Assert.All(parity.Days.SelectMany(d => d.Meals), m => { Assert.Null(m.Rice); Assert.Null(m.Notes); });
    }

    /// <summary>Cơm trắng và gạo lứt dùng cùng số gram; bún/khoai quy theo kcal tương đương cơm trắng.</summary>
    [Fact]
    public void Gram_com_trang_va_gao_lut_nhu_nhau_va_tinh_bot_khac_quy_theo_kcal()
    {
        var white = Data.RecipesById.Values.First(r => r.DishRole == "carb_base" && r.Ingredients.Any(i => i.IngredientId == "com_trang"));
        var brown = Data.RecipesById.Values.First(r => r.DishRole == "carb_base" && r.Ingredients.Any(i => i.IngredientId == "gao_lut_nau_chin"));
        double Target(Recipe carb)
        {
            var main = Data.Recipes.First(r => r.DishRole == "main");
            var info = MamBuilder.Rebuild($"{MamBuilder.IdPrefix}{main.Id}+{carb.Id}", Data, "nhieu")!;
            return info.RiceTargetG;
        }
        Assert.Equal(300, Target(white));
        Assert.Equal(300, Target(brown));
        var other = Data.RecipesById.Values.FirstOrDefault(r => r.DishRole == "carb_base" && r.Ingredients.Any(i => i.Role == "carb" && Data.IngredientsById[i.IngredientId].PurchaseAs is null && i.IngredientId != "com_trang"));
        if (other is not null)
        {
            var ing = Data.IngredientsById[other.Ingredients.First(i => i.Role == "carb").IngredientId];
            var expect = Math.Round(300 * Data.IngredientsById["com_trang"].Per100g.Kcal / ing.Per100g.Kcal / 5) * 5;
            Assert.Equal(expect, Target(other));
        }
    }

    /// <summary>Đổi món giữ mức cơm: đổi sang mâm khác thì cơm vẫn ở mức đã chọn (hoặc có ghi chú nếu buộc phải giảm).</summary>
    [Fact]
    public void Doi_mon_giu_muc_com()
    {
        var p = P("p04");
        var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        prefs.RiceHabit = "nhieu";
        var targets = TargetCalc.Compute(p.Profile);
        var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = targets, Prefs = prefs, Data = Data, StartDate = Start, Seed = 1, Options = new PlanOptions { MealStyle = MealStyle.Auto } });
        var inp = new EditInput { Targets = targets, Prefs = prefs, Data = Data, Plan = plan };
        var meal = plan.Days[2].Meals.First(m => m.Rice is not null);
        var sugg = WeekPlanner.SuggestSwaps(inp, meal.Date, meal.Slot, 5);
        var pick = sugg.Items.FirstOrDefault(o => o.RecipeId.StartsWith("mam:", StringComparison.Ordinal));
        if (pick is null) return;
        var after = WeekPlanner.ApplySwap(inp, meal.Date, meal.Slot, pick.RecipeId);
        var swapped = after.Days.SelectMany(d => d.Meals).Single(m => m.Date == meal.Date && m.Slot == meal.Slot);
        Assert.NotNull(swapped.Rice);
        Assert.Equal("nhieu", swapped.Rice!.Habit);
        Assert.True(swapped.Rice.ActualG >= swapped.Rice.TargetG - RiceHabits.ToleranceG || swapped.Notes?.Any(n => n.Code == "rice_reduced") == true);
    }

    /// <summary>Đổi mức ở tab Bạn → lên lại các ngày còn lại: ngày đã qua giữ mức cũ, ngày mới theo mức mới.</summary>
    [Fact]
    public void Regenerate_rest_doi_muc_com_chi_ap_cho_ngay_con_lai()
    {
        var p = P("p04");
        var targets = TargetCalc.Compute(p.Profile);
        var plan = Plan(p);
        var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        prefs.RiceHabit = "nhieu";
        var inp = new EditInput { Targets = targets, Prefs = prefs, Data = Data, Plan = plan };
        var today = plan.Days[2].Date;
        var after = WeekPlanner.RegenerateRest(inp, today, null);
        foreach (var d in after.Days.Take(2)) Assert.All(d.Meals.Where(m => m.Rice is not null), m => Assert.Equal("vua", m.Rice!.Habit));
        var later = after.Days.Skip(3).SelectMany(d => d.Meals).Where(m => m.Rice is not null).ToList();
        Assert.NotEmpty(later);
        Assert.All(later, m => Assert.Equal("nhieu", m.Rice!.Habit));
        Assert.True(EngineReport.RiceMedianOf(after) > EngineReport.RiceMedianOf(plan));
    }
}
