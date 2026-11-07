using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>Macro của bữa luôn bằng tổng macro các món (kể cả tráng miệng và "Món thêm") sau mọi bước sửa, nhất là sửa ngân sách.</summary>
public class MealMacrosConsistencyTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));

    [Fact]
    public void Macro_bua_bang_tong_cac_mon_o_moi_ho_so()
    {
        foreach (var p in Profiles)
        {
            var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
            var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = Data, StartDate = "2026-11-09", Seed = 1, Options = new PlanOptions() });
            foreach (var m in plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned" && m.Dishes is not null))
            {
                var sum = m.Dishes!.Aggregate(Macros.Zero, (a, d) => a + d.Macros);
                Assert.True(Math.Abs(sum.Kcal - m.Macros.Kcal) < 0.01 && Math.Abs(sum.ProteinG - m.Macros.ProteinG) < 0.01,
                    $"{p.Id} {m.Date} {m.Slot}: bữa {m.Macros.Kcal:F2} kcal ≠ tổng món {sum.Kcal:F2}");
            }
        }
    }
}
