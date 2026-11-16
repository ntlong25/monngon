using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>T-103 / D-ONB-06 ý 2 (TC-1-50): thẻ vuốt khẩu vị nay là bước 2, trước chế độ ăn. Thích một kiểu món có thịt rồi chọn ăn chay
/// thì ràng buộc cứng thắng: tuần không có nguyên liệu bị cấm, engine bỏ phần "thích" không còn hợp lệ.</summary>
public class CuisineVsDietTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));

    private static Preferences Clone(Preferences p) => JsonSerializer.Deserialize<Preferences>(JsonSerializer.Serialize(p, JsonOptions.Default), JsonOptions.Default)!;

    [Theory]
    [InlineData("vegetarian")]
    [InlineData("vegan")]
    public void Thich_the_mon_thit_roi_chon_chay_thi_tuan_khong_co_mon_thit(string diet)
    {
        var tp = Profiles.Single(p => p.Id.StartsWith("p01", StringComparison.Ordinal));
        var prefs = Clone(tp.Preferences);
        // card_01 "Xào nhanh" (tag xao, món thịt heo) và card_02 "Kho" được thích; sau đó chọn chế độ ăn chay (bước 10).
        prefs.CuisineLikes = ["xao", "kho"];
        prefs.CuisineLess = ["canh"];
        prefs.Diet = diet;
        var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(tp.Profile), Prefs = prefs, Data = Data, StartDate = "2026-11-09", Seed = 1 });

        var banned = Filter.BannedIngredients(Data.Ingredients, prefs);
        Assert.NotEmpty(banned);
        var meals = plan.Days.SelectMany(d => d.Meals).Where(m => m.RecipeId is not null).ToList();
        Assert.NotEmpty(meals);
        foreach (var m in meals)
            foreach (var g in m.Grams.Where(g => g.Grams > 0))
                Assert.False(banned.ContainsKey(g.IngredientId), $"{m.RecipeId} dùng {g.IngredientId} (bị cấm bởi chế độ {diet})");
        // thịt bị cấm thật (không phải bộ lọc rỗng): thịt heo xay nằm trong danh sách cấm
        Assert.Contains("thit_heo_xay_nac", banned.Keys);
        Assert.DoesNotContain(meals, m => m.Grams.Any(g => g.Grams > 0 && Data.IngredientsById[g.IngredientId].Aisle == "thit"));
    }
}
