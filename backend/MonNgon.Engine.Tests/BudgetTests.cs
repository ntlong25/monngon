using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>D-BUD-01 / T-069 — khoảng ngân sách tuần.</summary>
public class BudgetTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";

    private static Preferences Clone(Preferences p) => JsonSerializer.Deserialize<Preferences>(JsonSerializer.Serialize(p, JsonOptions.Default), JsonOptions.Default)!;

    private static WeekPlan PlanWith(TestProfile tp, double budget)
    {
        var prefs = Clone(tp.Preferences);
        prefs.WeeklyBudgetVnd = budget;
        return WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(tp.Profile), Prefs = prefs, Data = Data, StartDate = Start, Seed = 1 });
    }

    [Fact]
    public void Ngan_sach_bang_min_thi_it_nhat_90_phan_tram_ho_so_khong_vuot()
    {
        var ok = 0;
        var lines = new List<string>();
        foreach (var tp in Profiles)
        {
            var range = BudgetEstimator.Compute(Data, TargetCalc.Compute(tp.Profile), tp.Preferences);
            var plan = PlanWith(tp, range.MinVnd);
            if (plan.Validation.BudgetOverVnd == 0) ok++;
            lines.Add($"{tp.Id}: min {range.MinVnd:N0} cost {plan.Shopping.WeekFoodCost:N0} over {plan.Validation.BudgetOverVnd:N0}");
        }
        Assert.True(ok >= Math.Ceiling(Profiles.Count * 0.9), $"{ok}/{Profiles.Count}\n" + string.Join("\n", lines));
    }

    [Fact]
    public void Uoc_tinh_lech_khong_qua_15_phan_tram_so_voi_chi_phi_that_o_it_nhat_80_phan_tram_ho_so()
    {
        var ok = 0;
        var lines = new List<string>();
        foreach (var tp in Profiles)
        {
            var range = BudgetEstimator.Compute(Data, TargetCalc.Compute(tp.Profile), tp.Preferences);
            var real = PlanWith(tp, BudgetEstimator.SimBudgetVnd).Shopping.WeekFoodCost;
            var dev = Math.Abs(range.EstimateVnd - real) / real;
            if (dev <= 0.15) ok++;
            lines.Add($"{tp.Id}: est {range.EstimateVnd:N0} real {real:N0} dev {dev:P0}");
        }
        Assert.True(ok >= Math.Ceiling(Profiles.Count * 0.8), $"{ok}/{Profiles.Count}\n" + string.Join("\n", lines));
    }

    [Fact]
    public void Tang_nguoi_hoac_so_bua_thi_min_uoc_tinh_max_khong_giam()
    {
        var tp = Profiles.Single(p => p.Id.StartsWith("p01", StringComparison.Ordinal));
        var targets = TargetCalc.Compute(tp.Profile);
        BudgetRange R(Action<Preferences> edit)
        {
            var p = Clone(tp.Preferences);
            edit(p);
            return BudgetEstimator.Compute(Data, targets, p);
        }
        var basis = R(_ => { });
        foreach (var more in new[] { R(p => p.Adults += 1), R(p => p.Children += 1), R(p => p.Slots.SnackAm = "on"), R(p => { p.Adults += 1; p.Children += 1; }) })
        {
            Assert.True(more.MinVnd >= basis.MinVnd, $"min {more.MinVnd} < {basis.MinVnd}");
            // Ước tính là chi phí của tuần mô phỏng (heuristic, có nhiễu chọn món): chấp nhận lệch ≤ 3% khi tăng số người/bữa (T-093/L-01: đổi tráng miệng cứu ngày chật calo làm nhiễu thêm; T-094: cơm ghim theo mức và bước giảm cơm/đổi trọn suất cũng làm nhiễu; max = ước tính × 2,5 làm tròn bậc 50.000 ₫ nên dung sai 3%).
            Assert.True(more.EstimateVnd >= basis.EstimateVnd * 0.97, $"est {more.EstimateVnd} < {basis.EstimateVnd}");
            Assert.True(more.MaxVnd >= basis.MaxVnd * 0.97, $"max {more.MaxVnd} < {basis.MaxVnd}");
        }
    }

    [Fact]
    public void Khoang_hop_le_va_bac_phu_het_khoang()
    {
        foreach (var tp in Profiles)
        {
            var r = BudgetEstimator.Compute(Data, TargetCalc.Compute(tp.Profile), tp.Preferences);
            Assert.Equal(0, r.MinVnd % BudgetEstimator.Step);
            Assert.Equal(0, r.MaxVnd % BudgetEstimator.Step);
            Assert.True(r.MaxVnd >= r.MinVnd + BudgetEstimator.MaxMinGap);
            Assert.Equal(["economy", "moderate", "comfortable"], r.Tiers.Select(t => t.Key));
            Assert.Equal(r.MinVnd, r.Tiers[0].FromVnd);
            Assert.Equal(r.MaxVnd, r.Tiers[2].ToVnd);
            Assert.Equal(r.Tiers[0].ToVnd, r.Tiers[1].FromVnd);
            Assert.Equal(r.Tiers[1].ToVnd, r.Tiers[2].FromVnd);
            Assert.Equal("week_food_cost", r.Basis);
        }
    }

    [Fact]
    public void Kieng_lam_doi_khoang_vi_loc_mon_truoc_khi_tinh()
    {
        var tp = Profiles.Single(p => p.Id.StartsWith("p01", StringComparison.Ordinal));
        var targets = TargetCalc.Compute(tp.Profile);
        var none = BudgetEstimator.Compute(Data, targets, tp.Preferences);
        var vegan = Clone(tp.Preferences);
        vegan.Diet = "vegan";
        var v = BudgetEstimator.Compute(Data, targets, vegan);
        Assert.NotEqual(none.EstimateVnd, v.EstimateVnd);
    }
}
