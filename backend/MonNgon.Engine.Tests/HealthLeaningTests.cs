using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>T-076 / D-HLT-02 — xu hướng sức khỏe và khẩu vị chỉ là ưu tiên mềm: không được làm rớt chỉ tiêu cứng, kể cả khi số món mang thẻ rất ít.</summary>
public class HealthLeaningTests
{
    private static readonly Dataset Base = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";
    private static readonly string[] Leanings = ["nhieu_xo", "it_duong", "tot_cho_tim", "it_beo"];

    private static T Clone<T>(T x) => JsonSerializer.Deserialize<T>(JsonSerializer.Serialize(x, JsonOptions.Default), JsonOptions.Default)!;

    /// <summary>Giữ thẻ <paramref name="tag"/> chỉ ở <paramref name="keep"/> món đầu — mô phỏng dữ liệu thẻ thưa (hoặc ngưỡng xơ bị siết).</summary>
    private static Dataset Scarce(string tag, int keep)
    {
        var left = keep;
        var recipes = Base.Recipes.Select(r =>
        {
            var c = Clone(r);
            if (c.HealthTags.Contains(tag))
            {
                if (left > 0) left--;
                else c.HealthTags = c.HealthTags.Where(t => t != tag).ToList();
            }
            return c;
        }).ToList();
        return new Dataset(Base.Ingredients, recipes, Base.Stores, Base.Prices);
    }

    private static int DaysOk(Dataset ds, TestProfile p, Action<Preferences> edit, MealStyle style, bool dessert)
    {
        var prefs = Clone(p.Preferences);
        edit(prefs);
        var plan = WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = ds, StartDate = Start, Seed = 1,
            Options = new PlanOptions { MealStyle = style, IncludeDessert = dessert },
        });
        return plan.Validation.Days.Count(d => d.Ok);
    }

    private static void NoLeanings(Preferences p) { p.HealthLeanings = []; p.CuisineLikes = []; p.CuisineLess = []; }
    private static void AllLeanings(Preferences p) => p.HealthLeanings = Leanings.ToList();

    [Theory]
    [InlineData("nhieu_xo", 0)]
    [InlineData("nhieu_xo", 3)]
    [InlineData("nhieu_xo", 10)]
    [InlineData("it_duong", 2)]
    [InlineData("tot_cho_tim", 5)]
    public void Bat_xu_huong_khong_lam_giam_so_ngay_dat_so_voi_tat_xu_huong_khi_the_thua(string tag, int keep)
    {
        var ds = Scarce(tag, keep);
        foreach (var p in Profiles)
        {
            var off = DaysOk(ds, p, p2 => { p2.HealthLeanings = []; }, MealStyle.Auto, true);
            var on = DaysOk(ds, p, p2 => { p2.HealthLeanings = Leanings.ToList(); }, MealStyle.Auto, true);
            Assert.True(on >= off, $"{p.Id} thẻ {tag}≤{keep} món: bật xu hướng {on}/7 < tắt {off}/7");
        }
    }

    [Fact]
    public void Ho_so_p01_thich_nhieu_xo_van_dat_du_khi_chi_con_vai_mon_co_the()
    {
        var p = Profiles.Single(x => x.Id.StartsWith("p01", StringComparison.Ordinal));
        foreach (var keep in new[] { 0, 2, 5, 10 })
            Assert.Equal(7, DaysOk(Scarce("nhieu_xo", keep), p, pr => pr.HealthLeanings = ["nhieu_xo"], MealStyle.Auto, true));
    }

    [Fact]
    public void Khau_vi_cung_chi_la_uu_tien_mem()
    {
        foreach (var p in Profiles)
        {
            var off = DaysOk(Base, p, NoLeanings, MealStyle.Auto, true);
            var on = DaysOk(Base, p, pr => { pr.CuisineLikes = ["kho", "ham"]; pr.CuisineLess = ["xao", "canh"]; AllLeanings(pr); }, MealStyle.Auto, true);
            Assert.True(on >= off, $"{p.Id}: {on}/7 < {off}/7");
        }
    }

    [Fact]
    public void Che_do_tuong_thich_full_meal_only_khong_dessert_cung_khong_rot()
    {
        foreach (var p in Profiles)
        {
            var off = DaysOk(Base, p, NoLeanings, MealStyle.FullMealOnly, false);
            var on = DaysOk(Base, p, AllLeanings, MealStyle.FullMealOnly, false);
            Assert.True(on >= Math.Min(off, 7), $"{p.Id}: {on}/7 < {off}/7");
        }
    }

    [Fact]
    public void Khi_phai_noi_uu_tien_mem_ket_qua_ghi_ro_va_tuan_dat_chi_tieu()
    {
        var p = Profiles.Single(x => x.Id.StartsWith("p01", StringComparison.Ordinal));
        var prefs = Clone(p.Preferences);
        prefs.HealthLeanings = Leanings.ToList();
        var plan = WeekPlanner.Plan(new PlanWeekInput
        {
            Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = Scarce("nhieu_xo", 0), StartDate = Start, Seed = 1,
            Options = new PlanOptions { MealStyle = MealStyle.Auto },
        });
        Assert.Equal("ready", plan.Status);
        Assert.True(plan.RelaxedPreferences is null || plan.RelaxedPreferences.All(x => x is "health_leanings" or "cuisine"));
    }

    [Fact]
    public void Tuan_da_dat_thi_khong_bi_nhac_toi_uu_tien_mem()
    {
        var p = Profiles.Single(x => x.Id.StartsWith("p03", StringComparison.Ordinal));
        var prefs = Clone(p.Preferences);
        prefs.HealthLeanings = ["it_beo"];
        var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = Base, StartDate = Start, Seed = 1 });
        Assert.Equal("ready", plan.Status);
        Assert.Null(plan.RelaxedPreferences);
    }
}
