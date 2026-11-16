using System.Diagnostics;
using System.Text.Json;
using MonNgon.Engine;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Api;

/// <summary>T-117 / D-PERF-03: trạng thái sẵn sàng của API. Liveness (`/health`) luôn OK; readiness (`/health/ready`) chỉ OK sau khi làm nóng xong.</summary>
public sealed class Readiness
{
    private volatile bool _ready;
    public bool IsReady => _ready;
    public double? WarmUpSeconds { get; private set; }
    public int WarmUpPlans { get; private set; }
    public string? Error { get; private set; }

    public void MarkReady(double seconds, int plans) { WarmUpSeconds = seconds; WarmUpPlans = plans; _ready = true; }

    /// <summary>Làm nóng lỗi thì vẫn báo sẵn sàng (API vẫn dùng được, chỉ kế hoạch đầu chậm hơn) và ghi lỗi để xem.</summary>
    public void MarkFailed(string error, double seconds) { Error = error; WarmUpSeconds = seconds; _ready = true; }
}

/// <summary>
/// Lập vài tuần mẫu khi API khởi động để nạp bộ đệm của `Scaler`, JIT và bộ đệm số trước khi nhận lưu lượng.
/// Kết quả bị bỏ; engine không giữ trạng thái giữa các lần lập ngoài bộ đệm thuần (tất định không đổi).
/// Cấu hình: `WarmUp:Enabled` (mặc định true), `WarmUp:Levels` (mặc định mọi mức cơm, cách nhau bằng dấu phẩy).
/// </summary>
public sealed class WarmUpService(Dataset data, Readiness readiness, IConfiguration config, ILogger<WarmUpService> log) : BackgroundService
{
    private static readonly string[] AllLevels = ["rat_nhieu", "nhieu", "vua", "it"];

    // Hồ sơ nặng như p01 (nữ giảm mỡ, ngân sách vừa, bếp + nồi cơm điện): đủ chạm các đường chậm nhất của engine.
    private const string ProfileJson = """{"goal":"lose","sex":"female","age":32,"height_cm":162,"weight_kg":60,"activity":"light","target_mode":"formula"}""";
    private const string PrefsJson = """
        {"store_id":"bach_hoa_xanh","weekly_budget_vnd":650000,"adults":1,"children":0,
         "slots":{"breakfast":"on","lunch":"on","dinner":"on","snack_am":"skip","snack_pm":"on","lunch_style":"hot","snack_pm_style":"savory"},
         "diet":"none","low_carb":false,"exclusions":[],"disliked_ingredient_ids":[],"health_leanings":["nhieu_xo"],
         "cuisine_likes":["xao","canh"],"cuisine_less":[],"equipment":["bep","noi_com_dien"],"blocked_recipe_ids":[]}
        """;

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (!config.GetValue("WarmUp:Enabled", true))
        {
            readiness.MarkReady(0, 0);
            return Task.CompletedTask;
        }
        // Chạy trên thread riêng để không chặn khởi động host (Kestrel nhận kết nối ngay; /health/ready trả 503 tới khi xong).
        return Task.Run(() => Run(stoppingToken), stoppingToken);
    }

    private void Run(CancellationToken ct)
    {
        var sw = Stopwatch.StartNew();
        var plans = 0;
        try
        {
            var levels = (config["WarmUp:Levels"] ?? string.Join(',', AllLevels)).Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            var profile = JsonSerializer.Deserialize<Profile>(ProfileJson, JsonOptions.Default)!;
            var targets = TargetCalc.Compute(profile);
            foreach (var level in levels)
            {
                ct.ThrowIfCancellationRequested();
                var prefs = JsonSerializer.Deserialize<Preferences>(PrefsJson, JsonOptions.Default)!;
                prefs.RiceHabit = level;
                var plan = WeekPlanner.Plan(new PlanWeekInput { Targets = targets, Prefs = prefs, Data = data, StartDate = "2026-01-05", Seed = 1, Options = new PlanOptions { IncludeDessert = true } });
                // Làm nóng cả bước tuần tự hóa JSON của phản hồi.
                _ = JsonSerializer.SerializeToUtf8Bytes(plan, JsonOptions.Default);
                plans++;
            }
            readiness.MarkReady(sw.Elapsed.TotalSeconds, plans);
            log.LogInformation("Làm nóng xong: {Plans} tuần mẫu trong {Seconds:F1} s", plans, sw.Elapsed.TotalSeconds);
        }
        catch (OperationCanceledException) { }
        catch (Exception e)
        {
            log.LogError(e, "Làm nóng lỗi; vẫn báo sẵn sàng");
            readiness.MarkFailed(e.Message, sw.Elapsed.TotalSeconds);
        }
    }
}
