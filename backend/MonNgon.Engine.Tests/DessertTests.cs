using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>D-DES-01 / T-071 — tráng miệng ở bữa trưa và tối. data/ nay đã có món tráng miệng thật; các test ở đây dùng bộ món cố định (NoDessert + món tự dựng) để không phụ thuộc nội dung tráng miệng trong data/.</summary>
public class DessertTests
{
    private static readonly Dataset Base = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";

    private static Recipe Dessert(string id, string ingredient, double g, double min, double max, bool portable, bool lowCarbOk) => new()
    {
        Id = id, Name = id, MealTypes = ["lunch", "dinner"], LunchStyle = ["hot", "packed"], DishRole = "dessert", Portable = portable, LowCarbOk = lowCarbOk,
        IsLowCarb = lowCarbOk, Batchable = false, CookMinutes = 0,
        Ingredients = [new RecipeIngredient { IngredientId = ingredient, Grams = g, Role = "protein", MinG = min, MaxG = max }],
        Steps = ["Dùng ngay."],
    };

    private static Ingredient Fruit(string id, string name, double kcal, double protein, double carb, double fiber) => new()
    {
        Id = id, Name = name, Aisle = "trai_cay", Per100g = new MacrosPer100g { Kcal = kcal, ProteinG = protein, CarbG = carb, FatG = 0.3, FiberG = fiber },
        Source = new Source { Db = "USDA_FDC", Code = "test", Note = "fixture" }, DietTags = ["plant"], EdiblePortion = 1,
    };

    private static Price Cheap(string id) => new() { IngredientId = id, StoreId = "cho_khac", PackG = 1000, PackLabel = "1 kg", PriceVnd = 25_000, ShelfLifeDays = 5 };

    /// <summary>Dữ liệu thật đã loại mọi món tráng miệng: nền cố định cho các test về tráng miệng.</summary>
    private static Dataset NoDessert() => new(Base.Ingredients, Base.Recipes.Where(r => r.DishRole != "dessert"), Base.Stores, Base.Prices);

    private static Dataset WithDesserts() => new(
        Base.Ingredients.Concat([Fruit("chuoi_test", "Chuối", 89, 1.1, 22.8, 2.6), Fruit("oi_test", "Ổi", 68, 2.6, 14.3, 5.4)]),
        NoDessert().Recipes.Concat([
            Dessert("dessert_chuoi", "chuoi_test", 100, 80, 150, true, false),
            Dessert("dessert_oi", "oi_test", 120, 80, 200, true, true),
            Dessert("dessert_sua_dau_nanh", "sua_dau_nanh", 200, 150, 250, false, true),
        ]), Base.Stores, Base.Prices.Concat([Cheap("chuoi_test"), Cheap("oi_test")]));

    private static TestProfile P(string id) => Profiles.Single(p => p.Id.StartsWith(id, StringComparison.Ordinal));

    private static WeekPlan Plan(Dataset ds, TestProfile p, MealStyle style = MealStyle.Auto, long seed = 1, Action<Preferences>? edit = null)
    {
        var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        edit?.Invoke(prefs);
        return WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = ds, StartDate = Start, Seed = seed, Options = new PlanOptions { MealStyle = style },
        });
    }

    private static IEnumerable<PlanMeal> LunchDinner(WeekPlan plan) =>
        plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Slot is "lunch" or "dinner");

    [Fact]
    public void Khong_co_mon_trang_mieng_trong_du_lieu_thi_bao_dessert_missing_khong_nem_loi()
    {
        var plan = Plan(NoDessert(), P("p01"));
        Assert.All(LunchDinner(plan), m => { Assert.Null(m.DessertId); Assert.Contains("dessert_missing", m.Warnings!); });
        Assert.Equal("ready", plan.Status); // thiếu tráng miệng không tính là ngày không đạt
    }

    [Fact]
    public void Moi_bua_trua_toi_co_dung_mot_trang_mieng_tinh_vao_macro()
    {
        var ds = WithDesserts();
        foreach (var id in new[] { "p01", "p03", "p06", "p10" })
        {
            var plan = Plan(ds, P(id));
            foreach (var m in LunchDinner(plan))
            {
                Assert.NotNull(m.DessertId);
                Assert.Null(m.Warnings);
                var dishes = m.Dishes!;
                Assert.Single(dishes, d => d.Role == "dessert");
                var sum = dishes.Aggregate(Macros.Zero, (a, d) => a + d.Macros);
                Assert.Equal(m.Macros.Kcal, sum.Kcal, 6);
                Assert.Equal(m.Macros.ProteinG, sum.ProteinG, 6);
                Assert.True(dishes.Single(d => d.Role == "dessert").Macros.Kcal is >= 20 and <= 180);
            }
        }
    }

    [Fact]
    public void Tat_ca_ho_so_van_dat_va_khong_vi_pham_rang_buoc_cung_voi_trang_mieng()
    {
        var ds = WithDesserts();
        var results = Profiles.Select(p => EngineReport.RunProfile(p, ds, 1, Start)).ToList();
        var s = EngineReport.Summarize(results);
        Assert.Equal(0, s.HardViolations);
        Assert.Equal(0, s.Errors);
        // PRD D-DES-01: không thấp hơn baseline (14/14) quá 1 hồ sơ.
        Assert.True(s.ExpectedPassReady >= s.ExpectedPass - 1, EngineReport.Format(results));
        // 100% bữa trưa/tối có tráng miệng, trừ khi thiếu có cảnh báo (kiêng loại hết ứng viên)
        foreach (var r in results) Assert.True(r.DessertRatio > 0.99 || r.DessertMissing > 0, $"{r.Name}: {r.DessertRatio}");
    }

    [Fact]
    public void Khong_lap_trang_mieng_trong_ngay_va_co_it_nhat_3_mon_khac_nhau_trong_tuan()
    {
        var plan = Plan(WithDesserts(), P("p01"));
        foreach (var day in plan.Days)
        {
            var ids = day.Meals.Where(m => m.DessertId is not null).Select(m => m.DessertId).ToList();
            Assert.Equal(ids.Count, ids.Distinct().Count());
        }
        Assert.True(LunchDinner(plan).Select(m => m.DessertId).Distinct().Count() >= 2, string.Join(",", LunchDinner(plan).Select(m => m.DessertId ?? "-")));
        // T-096: với dữ liệu thật (có đủ món tráng miệng) p01 phải có ≥ 3 loại/tuần (T-094 từng nới còn ≥ 2). Bộ 3 món giả ở trên chỉ có 2 món vừa kcal của p01.
        var real = Plan(Base, P("p01"));
        Assert.True(LunchDinner(real).Select(m => m.DessertId).Distinct().Count() >= 3, string.Join(",", LunchDinner(real).Select(m => m.DessertId ?? "-")));
    }

    [Fact]
    public void Ngay_van_nam_trong_dai_calo_va_dat_san_protein()
    {
        var plan = Plan(WithDesserts(), P("p03"));
        Assert.True(plan.Validation.Days.All(d => d.Ok));
    }

    [Fact]
    public void Kieng_va_ghet_het_ung_vien_thi_bua_van_len_kem_canh_bao()
    {
        var plan = Plan(WithDesserts(), P("p01"), edit: p => { p.Exclusions = ["no_soy"]; p.DislikedIngredientIds = ["chuoi_test", "oi_test"]; });
        Assert.All(LunchDinner(plan), m => { Assert.Null(m.DessertId); Assert.Contains("dessert_missing", m.Warnings!); });
    }

    [Fact]
    public void Chay_thuan_khong_co_sua_bo()
    {
        var plan = Plan(WithDesserts(), P("p05"), edit: p => p.DislikedIngredientIds = ["chuoi_test", "oi_test"]);
        Assert.All(LunchDinner(plan), m => Assert.Equal("dessert_sua_dau_nanh", m.DessertId));
    }

    [Fact]
    public void It_tinh_bot_chi_nhan_mon_low_carb_ok()
    {
        var ds = WithDesserts();
        var plan = Plan(ds, P("p01"), edit: p => p.LowCarb = true);
        Assert.All(LunchDinner(plan), m => Assert.True(ds.RecipesById[m.DessertId!].LowCarbOk, m.DessertId));
    }

    [Fact]
    public void Trua_mang_di_chi_nhan_mon_portable()
    {
        var ds = WithDesserts();
        var plan = Plan(ds, P("p01"), edit: p => p.Slots.LunchStyle = "packed");
        foreach (var m in LunchDinner(plan).Where(m => m.Slot == "lunch")) Assert.True(ds.RecipesById[m.DessertId!].Portable, m.DessertId);
    }

    [Fact]
    public void Full_meal_only_khong_them_trang_mieng()
    {
        var plan = Plan(WithDesserts(), P("p01"), MealStyle.FullMealOnly);
        Assert.All(plan.Days.SelectMany(d => d.Meals), m => { Assert.Null(m.DessertId); Assert.Null(m.Warnings); });
    }

    /// <summary>D-QA-04 / L-01: tráng miệng chỉ scale dòng scale được; dòng cố định (min_g = max_g) giữ gram công thức; mọi gram nằm trong [min_g, max_g]; dòng scale được làm tròn 5 g.</summary>
    [Fact]
    public void Gram_trang_mieng_luon_trong_min_max_va_dong_co_dinh_giu_nguyen_cong_thuc()
    {
        var ds = Base; // dữ liệu thật (món tráng miệng thật)
        var checkedLines = 0;
        foreach (var p in Profiles)
            foreach (var seed in new long[] { 1, 2, 3 })
                foreach (var m in LunchDinner(Plan(ds, p, seed: seed)).Where(m => m.DessertId is not null))
                {
                    var recipe = ds.RecipesById[m.DessertId!];
                    Assert.Equal(recipe.Ingredients.Count, m.Dessert!.Count);
                    foreach (var line in m.Dessert!)
                    {
                        var li = recipe.Ingredients.Single(i => i.IngredientId == line.IngredientId);
                        var where = $"{p.Id} seed={seed} {m.DessertId}/{line.IngredientId}: {line.Grams} g (min {li.MinG}, max {li.MaxG}, công thức {li.Grams})";
                        Assert.True(line.Grams >= li.MinG - 1e-9 && line.Grams <= li.MaxG + 1e-9, where);
                        if (li.MinG >= li.MaxG) Assert.True(Math.Abs(line.Grams - li.Grams) < 1e-9, where);
                        else Assert.True(Math.Abs(line.Grams / 5 - Math.Round(line.Grams / 5)) < 1e-9 || Math.Abs(line.Grams - li.Grams) < 1e-9, where);
                        checkedLines++;
                    }
                }
        Assert.True(checkedLines > 100, $"quá ít dòng được kiểm: {checkedLines}");
    }

    [Fact]
    public void Danh_sach_di_cho_co_nguyen_lieu_cua_trang_mieng()
    {
        var plan = Plan(WithDesserts(), P("p01"));
        var ids = LunchDinner(plan).SelectMany(m => m.Dessert!).Select(g => g.IngredientId).ToHashSet();
        var shop = plan.Shopping.Items.Select(i => i.IngredientId).ToHashSet();
        Assert.All(ids, i => Assert.Contains(i, shop));
    }

    [Fact]
    public void Bua_sang_bua_phu_va_bua_tu_lo_khong_co_trang_mieng()
    {
        var plan = Plan(WithDesserts(), P("p12"));
        Assert.All(plan.Days.SelectMany(d => d.Meals).Where(m => m.Slot is not ("lunch" or "dinner") || m.Status != "planned"), m => Assert.Null(m.DessertId));
    }

    [Fact]
    public void Include_dessert_false_tat_tinh_nang_va_khong_canh_bao()
    {
        var prefs = P("p01").Preferences;
        var plan = WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(P("p01").Profile), Prefs = prefs, Data = WithDesserts(), StartDate = Start, Seed = 1,
            Options = new PlanOptions { IncludeDessert = false },
        });
        Assert.All(plan.Days.SelectMany(d => d.Meals), m => { Assert.Null(m.DessertId); Assert.Null(m.Warnings); });
    }

    [Theory]
    [InlineData(3, "1 quả", "3 quả")]
    [InlineData(1, "lốc 4 hộp 180 ml", "1 lốc")]
    [InlineData(2, "1 kg", "2 kg")]
    [InlineData(2, "500 g", "2 × 500 g")]
    public void Display_qty_theo_don_vi_mua(int packs, string label, string expected) => Assert.Equal(expected, Shopping.DisplayQtyOf(packs, label));

    [Fact]
    public void Danh_sach_di_cho_co_display_qty_o_che_do_auto_va_khong_o_parity()
    {
        var auto = Plan(Base, P("p01"));
        Assert.All(auto.Shopping.Items, i => Assert.False(string.IsNullOrEmpty(i.DisplayQty)));
        var legacy = Plan(Base, P("p01"), MealStyle.FullMealOnly);
        Assert.All(legacy.Shopping.Items, i => Assert.Null(i.DisplayQty));
    }
}
