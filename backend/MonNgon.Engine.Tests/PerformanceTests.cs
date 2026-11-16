using System.Diagnostics;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine.Tests;

/// <summary>
/// T-101 — chặn hồi quy hiệu năng lập tuần ở mức cơm cao (trước T-101: tối đa ~17 s ở 3+ chén, timeout app 30 s).
/// Hai lớp chặn:
///  1. Ngân sách công việc (không phụ thuộc máy): số byte cấp phát của MỘT phương án xếp hạng chạy trên luồng test (RiceOnlyAttempt) — tỉ lệ thuận số lần scale/thử cứu ngày,
///     nên quay lại thử cứu ngày vô ích (đo trước T-101: gấp ~8 lần) hoặc dựng lại dữ liệu scale mỗi lần gọi đều làm test hỏng ngay cả trên máy nhanh.
///  2. Thời gian thật của cả lần lập (7 phương án song song + lập mức dưới) ở bản Debug của máy CI: ngưỡng rất rộng (xem <see cref="WallLimitSeconds"/>), chỉ bắt lỗi nặng.
/// Số liệu Release đầy đủ (18 hồ sơ × 4 mức × 3 seed): dotnet backend/MonNgon.Tools/bin/Release/net10.0/MonNgon.Tools.dll bench — xem docs/dev/perf-t101.md.
/// </summary>
public class PerformanceTests
{
    private static readonly Dataset Data = Dataset.LoadDirectory(TestPaths.Data);
    private static readonly List<TestProfile> Profiles = TestProfile.LoadFile(Path.Combine(TestPaths.Data, "test-profiles.json"));
    private const string Start = "2026-11-09";

    /// <summary>
    /// Ngưỡng thời gian thật cho một lần lập tuần (giây) ở bản Debug: đo trên máy dev 12 lõi ≈ 3–6 s cho ca nặng nhất; Release ≈ 1 s. Ngưỡng 25 s (≈ 4–8 lần) cho máy CI ít lõi,
    /// vẫn thấp hơn timeout 30 s của app — trước T-101 ca này mất 12–17 s ở Release (nhiều lần ở Debug trên máy ít lõi).
    /// </summary>
    private const double WallLimitSeconds = 25;

    private static TestProfile P(string id) => Profiles.Single(p => p.Id.StartsWith(id, StringComparison.Ordinal));

    private static PlanWeekInput Input(string profile, string habit, PlanOptions? options = null, long seed = 1)
    {
        var p = P(profile);
        var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p.Preferences, JsonOptions.Default), JsonOptions.Default)!;
        prefs.RiceHabit = habit;
        return new PlanWeekInput { Targets = TargetCalc.Compute(p.Profile), Prefs = prefs, Data = Data, StartDate = Start, Seed = seed, Options = options };
    }

    /// <summary>Số byte cấp phát trên luồng hiện tại khi chạy đúng một phương án (không song song nên đo được trên luồng test).</summary>
    private static (WeekPlan Plan, long Bytes) Allocated(string profile, string habit, int attempt)
    {
        // Chạy một lần khởi động (JIT, dữ liệu dùng chung) để số đo không dính chi phí một lần.
        WeekPlanner.Plan(Input("p03", "it"));
        var input = Input(profile, habit, new PlanOptions { RiceOnlyAttempt = attempt });
        var before = GC.GetAllocatedBytesForCurrentThread();
        var plan = WeekPlanner.Plan(input);
        return (plan, GC.GetAllocatedBytesForCurrentThread() - before);
    }

    /// <summary>
    /// Ca nặng của p01 ở mức 3+ chén: phương án 1 (đúng thứ tự PM, tối đa 6 vòng) không đạt 7/7 nên dùng hết 6 vòng. Đo T-101: ~0,85 GB cấp phát trên luồng gọi (Release/Debug như nhau); ngưỡng gấp đôi.
    /// </summary>
    [Fact]
    public void Ngan_sach_cong_viec_p01_rat_nhieu_phuong_an_1()
    {
        var (_, bytes) = Allocated("p01", "rat_nhieu", 1);
        Assert.True(bytes < BudgetP01Bytes, $"cấp phát {bytes / 1e6:0} MB ≥ ngân sách {BudgetP01Bytes / 1e6:0} MB — lập tuần chậm đi (T-101)");
    }

    /// <summary>Ca p02 (nữ nhỏ ngân sách sát) ở phương án 7 (không xếp hạng cơm), đạt sau 3 vòng. Đo T-101: ~62 MB; ngưỡng gấp đôi.</summary>
    [Fact]
    public void Ngan_sach_cong_viec_p02_rat_nhieu_phuong_an_7()
    {
        var (plan, bytes) = Allocated("p02", "rat_nhieu", 7);
        Assert.Equal("ready", plan.Status);
        Assert.True(bytes < BudgetP02Bytes, $"cấp phát {bytes / 1e6:0} MB ≥ ngân sách {BudgetP02Bytes / 1e6:0} MB — lập tuần chậm đi (T-101)");
    }

    private const long BudgetP01Bytes = 1_700_000_000;
    private const long BudgetP02Bytes = 130_000_000;

    /// <summary>
    /// Cả lần lập (như POST /v1/plans) ở các ca nặng nhất mức 3+ chén phải xong trong ngưỡng rộng và vẫn đạt 7/7 trong ngân sách.
    /// </summary>
    [Theory]
    [InlineData("p01", "rat_nhieu")]
    [InlineData("p02", "rat_nhieu")]
    [InlineData("p14", "rat_nhieu")]
    [InlineData("p09", "nhieu")]
    public void Thoi_gian_lap_tuan_muc_cao_khong_qua_nguong(string profile, string habit)
    {
        WeekPlanner.Plan(Input("p03", "it")); // khởi động
        var sw = Stopwatch.StartNew();
        var plan = WeekPlanner.Plan(Input(profile, habit));
        sw.Stop();
        Assert.Equal("ready", plan.Status);
        Assert.True(sw.Elapsed.TotalSeconds < WallLimitSeconds, $"{profile} {habit}: {sw.Elapsed.TotalSeconds:0.0} s ≥ {WallLimitSeconds} s (timeout app 30 s)");
    }
}
