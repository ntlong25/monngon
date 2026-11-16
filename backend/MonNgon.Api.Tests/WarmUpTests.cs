using System.Net;
using System.Net.Http.Json;
using System.Runtime.CompilerServices;
using System.Text.Json.Nodes;
using Microsoft.AspNetCore.Mvc.Testing;

namespace MonNgon.Api.Tests;

/// <summary>Các test khác không cần làm nóng (chậm, tranh CPU với test hiệu năng): tắt mặc định cho cả assembly test.</summary>
internal static class DisableWarmUp
{
    [ModuleInitializer]
    internal static void Init() => Environment.SetEnvironmentVariable("WarmUp__Enabled", "false");
}

/// <summary>T-117: readiness chỉ OK sau khi làm nóng; liveness luôn OK; làm nóng không đổi kết quả lập tuần.</summary>
public class WarmUpTests(WebApplicationFactory<Program> factory) : IClassFixture<WebApplicationFactory<Program>>
{
    private static JsonObject Body() => new()
    {
        ["profile"] = JsonNode.Parse("""{"goal":"lose","sex":"female","age":32,"height_cm":162,"weight_kg":60,"activity":"light","target_mode":"formula"}"""),
        ["preferences"] = JsonNode.Parse("""{"store_id":"bach_hoa_xanh","weekly_budget_vnd":650000,"adults":1,"children":0,"slots":{"breakfast":"on","lunch":"on","dinner":"on","snack_am":"skip","snack_pm":"on","lunch_style":"hot","snack_pm_style":"savory"},"diet":"none","low_carb":false,"exclusions":[],"disliked_ingredient_ids":[],"health_leanings":["nhieu_xo"],"cuisine_likes":["xao","canh"],"cuisine_less":[],"equipment":["bep","noi_com_dien"],"blocked_recipe_ids":[],"rice_habit":"it"}"""),
        ["start_date"] = "2026-11-17",
    };

    private static async Task<string> PlanJson(HttpClient c)
    {
        var r = await c.PostAsJsonAsync("/v1/plans", Body());
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        return await r.Content.ReadAsStringAsync();
    }

    [Fact]
    public async Task Tat_lam_nong_thi_readiness_OK_ngay()
    {
        var c = factory.CreateClient();
        var r = await c.GetAsync("/health/ready");
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        Assert.Equal(0, (await r.Content.ReadFromJsonAsync<JsonNode>())!["warm_up_plans"]!.GetValue<int>());
    }

    [Fact]
    public async Task Co_lam_nong_thi_readiness_503_cho_den_khi_xong_con_liveness_OK_ngay_va_ket_qua_lap_tuan_khong_doi()
    {
        var baseline = await PlanJson(factory.CreateClient());

        // Giữ cho làm nóng chưa xong khi kiểm tra bằng Readiness giả: dựng host riêng với làm nóng bật, mức "it" cho nhanh.
        using var warm = factory.WithWebHostBuilder(b => b.UseSetting("WarmUp:Enabled", "true").UseSetting("WarmUp:Levels", "it,vua"));
        var c = warm.CreateClient();
        Assert.Equal(HttpStatusCode.OK, (await c.GetAsync("/health")).StatusCode); // liveness không chờ
        var deadline = DateTime.UtcNow.AddSeconds(120);
        JsonNode? ready = null;
        while (DateTime.UtcNow < deadline)
        {
            var r = await c.GetAsync("/health/ready");
            if (r.StatusCode == HttpStatusCode.OK) { ready = await r.Content.ReadFromJsonAsync<JsonNode>(); break; }
            Assert.Equal(HttpStatusCode.ServiceUnavailable, r.StatusCode);
            await Task.Delay(100);
        }
        Assert.NotNull(ready);
        Assert.Equal(2, ready!["warm_up_plans"]!.GetValue<int>());
        Assert.Null(ready["warm_up_error"]);
        // làm nóng không ảnh hưởng kết quả: cùng yêu cầu → cùng byte
        Assert.Equal(baseline, await PlanJson(c));
    }
}
