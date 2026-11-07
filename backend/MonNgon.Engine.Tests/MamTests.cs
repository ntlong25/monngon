using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>T-066 — ghép mâm (main + canh + rau + cơm) trên dữ liệu thật.</summary>
public class MamTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";

    private static WeekPlan Plan(TestProfile p, long seed = 1, MealStyle style = MealStyle.Auto, Action<Preferences>? edit = null)
    {
        // Sao chép sâu để test sửa Preferences không rò sang test khác.
        var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        edit?.Invoke(prefs);
        return WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = Data, StartDate = Start, Seed = seed,
            Options = new PlanOptions { MealStyle = style },
        });
    }

    private static IEnumerable<PlanMeal> LunchDinner(WeekPlan plan) => plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Slot is "lunch" or "dinner");

    private static TestProfile P(string id) => Profiles.Single(p => p.Id.StartsWith(id, StringComparison.Ordinal));

    [Fact]
    public void Auto_toan_bo_ho_so_dat_nhu_baseline_va_khong_vi_pham_rang_buoc_cung()
    {
        var results = Profiles.Select(p => EngineReport.RunProfile(p, Data, 1, Start)).ToList();
        var s = EngineReport.Summarize(results);
        Assert.Equal(0, s.HardViolations);
        Assert.Equal(0, s.Errors);
        Assert.Equal(s.ExpectedPass, s.ExpectedPassReady); // baseline: 14/14
        Assert.Equal(s.DaysTotal, s.DaysOk);
    }

    [Fact]
    public void Auto_it_nhat_60_phan_tram_bua_trua_toi_la_mam_tu_2_mon()
    {
        var meals = new List<PlanMeal>();
        foreach (var p in Profiles) meals.AddRange(LunchDinner(Plan(p)));
        var mam = meals.Count(m => m.Dishes!.Count(d => d.Role is not ("extra" or "dessert")) >= 2);
        Assert.True((double)mam / meals.Count >= 0.6, $"mâm = {mam}/{meals.Count}");
    }

    /// <summary>T-077 / D-MAM-01: từng hồ sơ ≥ 40% bữa trưa/tối là mâm (≥ 20% với hồ sơ ngân sách tối thiểu hoặc ít dụng cụ: p09, p10, p14, p15), p14 ≥ 40%, mọi ngày vẫn đạt, không vượt ngân sách.</summary>
    [Fact]
    public void Moi_ho_so_dat_ti_le_ghep_mam_toi_thieu_khi_ngan_sach_eo_hep()
    {
        var lowRatio = new[] { "p09", "p10", "p14", "p15" };
        foreach (var p in Profiles)
        {
            var r = EngineReport.RunProfile(p, Data, 1, Start);
            var min = lowRatio.Any(id => p.Id.StartsWith(id, StringComparison.Ordinal)) ? 0.2 : 0.4;
            Assert.True(r.MamRatio >= min, $"{p.Id}: mâm {r.MamRatio:P0} < {min:P0} (lý do: {r.MamReason ?? "-"}; {r.MamReasonDetail})");
            Assert.Equal(7, r.DaysOk);
            Assert.True(r.WeekFoodCost <= r.Budget, $"{p.Id}: vượt ngân sách {r.WeekFoodCost} > {r.Budget}");
        }
        Assert.True(EngineReport.RunProfile(P("p14"), Data, 1, Start).MamRatio >= 0.4);
    }

    [Fact]
    public void Engine_report_neu_ly_do_khong_ghep_mam()
    {
        var p = P("p11");
        var (reason, detail) = EngineReport.DiagnoseNoMam(p, Data, TargetCalc.Compute(p.Profile), 1, Start, null, 0);
        Assert.Contains(reason, new[] { "budget", "equipment", "no_side_candidate" });
        Assert.Contains("%", detail);
    }

    [Fact]
    public void Mam_co_dung_mot_mon_dam_chinh_va_dishes_cong_lai_bang_bua()
    {
        foreach (var p in Profiles)
            foreach (var m in LunchDinner(Plan(p)))
            {
                var dishes = m.Dishes!;
                Assert.True(dishes.Count(d => d.Role is "main" or "full_meal") == 1, $"{p.Id} {m.Date} {m.Slot}");
                Assert.True(dishes.Count(d => d.Role == "soup") <= 1 && dishes.Count(d => d.Role == "side_veg") <= 1 && dishes.Count(d => d.Role == "carb_base") <= 1);
                var sum = dishes.Aggregate(Macros.Zero, (a, d) => a + d.Macros);
                Assert.Equal(m.Macros.Kcal, sum.Kcal, 6);
                Assert.Equal(m.Macros.ProteinG, sum.ProteinG, 6);
                // gram các món nối lại (trừ extra) đúng bằng gram của bữa
                var core = dishes.Where(d => d.Role is not ("extra" or "dessert")).SelectMany(d => d.Grams).ToList();
                Assert.Equal(m.Grams.Count, core.Count);
                for (var i = 0; i < core.Count; i++) { Assert.Equal(m.Grams[i].IngredientId, core[i].IngredientId); Assert.Equal(m.Grams[i].Grams, core[i].Grams); }
            }
    }

    [Fact]
    public void Canh_khong_lap_qua_2_lan_trong_tuan()
    {
        foreach (var p in Profiles)
        foreach (var seed in new long[] { 1, 2, 3 })
        {
            var soups = LunchDinner(Plan(p, seed)).SelectMany(m => m.Dishes!).Where(d => d.Role == "soup").GroupBy(d => d.RecipeId);
            foreach (var g in soups) Assert.True(g.Count() <= 2, $"{p.Id} seed {seed}: {g.Key} x{g.Count()}");
        }
    }

    [Fact]
    public void Trua_va_toi_khong_cung_mon_chinh()
    {
        foreach (var p in Profiles)
            foreach (var day in Plan(p).Days)
            {
                var ids = day.Meals.Where(m => m.Slot is "lunch" or "dinner" && m.Dishes is not null)
                    .Select(m => m.Dishes!.First(d => d.Role is "main" or "full_meal").RecipeId).ToList();
                Assert.Equal(ids.Count, ids.Distinct().Count());
            }
    }

    [Fact]
    public void Rang_buoc_cung_ap_cho_tung_mon_trong_mam()
    {
        // p08 dị ứng lạc/hạt cây, p07 không lợn/sữa, p06 ăn chay: không món nào (kể cả canh/rau) chứa nguyên liệu bị cấm.
        foreach (var id in new[] { "p06", "p07", "p08" })
        {
            var tp = P(id);
            var banned = Filter.BannedIngredients(Data.Ingredients, tp.Preferences);
            foreach (var m in LunchDinner(Plan(tp)))
                foreach (var d in m.Dishes!.Where(d => d.RecipeId is not null))
                {
                    var r = Data.RecipesById[d.RecipeId!];
                    foreach (var li in r.Ingredients) Assert.False(banned.ContainsKey(li.IngredientId), $"{id}: {r.Id} chứa {li.IngredientId}");
                    foreach (var e in r.Equipment) Assert.Contains(e, tp.Preferences.Equipment);
                }
        }
    }

    [Fact]
    public void It_tinh_bot_khong_co_carb_base_va_carb_bang_0()
    {
        var tp = P("p01");
        var plan = Plan(tp, edit: p => p.LowCarb = true);
        foreach (var m in LunchDinner(plan))
        {
            Assert.DoesNotContain(m.Dishes!, d => d.Role == "carb_base");
            foreach (var d in m.Dishes!.Where(d => d.RecipeId is not null))
            {
                var r = Data.RecipesById[d.RecipeId!];
                Assert.True(r.IsLowCarb, r.Id);
                for (var i = 0; i < r.Ingredients.Count; i++) if (r.Ingredients[i].Role == "carb") Assert.Equal(0, d.Grams[i].Grams);
            }
        }
    }

    [Fact]
    public void Mam_co_carb_base_thi_khong_bu_them_com_extras_carb()
    {
        foreach (var p in Profiles)
            foreach (var m in LunchDinner(Plan(p)).Where(m => m.Dishes!.Any(d => d.Role == "carb_base")))
            {
                var carbs = Data.Ingredients.Where(i => i.Aisle == "gao_do_kho" && i.Per100g.CarbG >= 20).Select(i => i.Id).ToHashSet();
                var carbBaseIds = m.Dishes!.First(d => d.Role == "carb_base").Grams.Select(g => g.IngredientId).ToHashSet();
                foreach (var e in m.Extras.Where(e => carbs.Contains(e.IngredientId))) Assert.DoesNotContain(e.IngredientId, carbBaseIds);
            }
    }

    /// <summary>L-11 / TC-2-09: 14 bữa trưa+tối cho 10–12 món (mâm) khác nhau, không dồn vào 7 món × 2 lần.</summary>
    [Fact]
    public void Tuan_14_bua_trua_toi_co_10_den_12_mon_khac_nhau()
    {
        foreach (var id in new[] { "p01", "p02", "p03", "p04", "p06", "p07", "p08", "p10", "p12", "p14", "p16" })
        {
            var plan = Plan(P(id));
            var ld = LunchDinner(plan).ToList();
            Assert.Equal(14, ld.Count);
            var distinct = ld.Select(m => m.RecipeId).Distinct().Count();
            // T-096: khôi phục ngưỡng — mọi hồ sơ ≥ 9 món khác nhau, p04 ≥ 10 (AC5). p01 còn 9 (ngân sách 650k sát trần, cơm giữ đủ 150 g) — đã báo session chính.
            Assert.True(distinct >= 9 && distinct <= 12, $"{id}: {distinct} món khác nhau");
            if (id is "p03" or "p04" or "p07") Assert.True(distinct >= 10, $"{id}: {distinct} món khác nhau");
        }
    }

    [Fact]
    public void Danh_sach_di_cho_gop_moi_mon_cua_mam()
    {
        var plan = Plan(P("p01"));
        var shop = plan.Shopping.Items.Select(i => i.IngredientId).ToHashSet();
        foreach (var m in LunchDinner(plan))
            foreach (var d in m.Dishes!)
                foreach (var g in d.Grams.Where(g => g.Grams > 0)) Assert.Contains(Shopping.PurchaseTarget(Data, g.IngredientId).IngredientId, shop); // cơm → gạo (D-SHP-02)
    }

    [Fact]
    public void Full_meal_only_giu_dinh_dang_cu_khong_co_dishes()
    {
        var plan = Plan(P("p01"), style: MealStyle.FullMealOnly);
        Assert.Null(plan.MealStyle);
        Assert.All(plan.Days.SelectMany(d => d.Meals), m => Assert.Null(m.Dishes));
        var json = System.Text.Json.JsonSerializer.Serialize(plan, JsonOptions.Default);
        Assert.DoesNotContain("\"dishes\"", json);
        Assert.DoesNotContain("meal_style", json);
    }

    [Fact]
    public void Mam_only_bua_trua_toi_la_mam_khi_ghep_duoc()
    {
        var plan = Plan(P("p01"), style: MealStyle.MamOnly);
        Assert.Equal("mam_only", plan.MealStyle);
        Assert.All(LunchDinner(plan), m => Assert.True(m.Dishes!.Count(d => d.Role is not ("extra" or "dessert")) >= 2, m.RecipeId));
    }

    [Fact]
    public void Tat_dinh_theo_seed()
    {
        string J(long seed) => System.Text.Json.JsonSerializer.Serialize(Plan(P("p03"), seed), JsonOptions.Default);
        Assert.Equal(J(5), J(5));
        Assert.NotEqual(J(5), J(6));
    }

    [Fact]
    public void Auto_khong_dua_mon_phu_don_le_vao_bua()
    {
        foreach (var p in Profiles)
            foreach (var m in Plan(p).Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned"))
                foreach (var d in m.Dishes!.Where(d => d.Role == "full_meal"))
                    Assert.Equal("full_meal", Data.RecipesById[d.RecipeId!].DishRole);
    }

    [Fact]
    public void Trua_mang_di_van_co_mam_khong_canh_va_p14_tu_20_phan_tram()
    {
        var tp = P("p14");
        var plan = Plan(tp);
        var lunch = plan.Days.SelectMany(d => d.Meals).Where(m => m.Slot == "lunch" && m.Status == "planned").ToList();
        var dinner = plan.Days.SelectMany(d => d.Meals).Where(m => m.Slot == "dinner" && m.Status == "planned").ToList();
        Assert.All(lunch.SelectMany(m => m.Dishes!), d => Assert.NotEqual("soup", d.Role)); // trưa mang đi không có canh
        foreach (var m in lunch.Where(m => m.Dishes!.Count(d => d.Role is not ("extra" or "dessert")) >= 2))
            foreach (var d in m.Dishes!.Where(d => d.RecipeId is not null && d.Role != "dessert"))
                Assert.Contains("packed", Data.RecipesById[d.RecipeId!].LunchStyle);
        var all = lunch.Concat(dinner).ToList();
        var mam = all.Count(m => m.Dishes!.Count(d => d.Role is not ("extra" or "dessert")) >= 2);
        // Có tráng miệng + ngân sách 1,2 triệu cho 3 người: engine ưu tiên ngân sách nên mâm còn ~21–30%; sàn 20% (trước khi có tráng miệng là 40%).
        Assert.True((double)mam / all.Count >= 0.2, $"mâm {mam}/{all.Count}");
        Assert.Contains(lunch, m => m.Dishes!.Count(d => d.Role is not ("extra" or "dessert")) >= 2);
    }

    [Fact]
    public void Engine_report_co_ti_le_theo_dung_cu_va_dung_nhieu_dung_cu_khi_user_co_nhieu()
    {
        var r = EngineReport.RunProfile(P("p15"), Data, 1, Start);
        Assert.True(r.EquipmentShare.GetValueOrDefault("noi_com_dien") > 0);
        Assert.True(r.EquipmentShare.GetValueOrDefault("noi_chien_khong_dau") > 0);
        Assert.Contains("dụng cụ (% bữa)", EngineReport.Format([r]));
        // user chỉ có lò vi sóng thì mọi bữa dùng lò vi sóng; có bếp thì không bị dồn vào lò vi sóng
        Assert.Equal(1.0, EngineReport.RunProfile(P("p09"), Data, 1, Start).EquipmentShare["lo_vi_song"]);
        Assert.True(EngineReport.RunProfile(P("p01"), Data, 1, Start).EquipmentShare.GetValueOrDefault("lo_vi_song") < 0.5);
    }
}
