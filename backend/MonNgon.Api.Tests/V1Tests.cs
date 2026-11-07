using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.AspNetCore.Mvc.Testing;
using MonNgon.Api;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Api.Tests;

public class V1Tests(WebApplicationFactory<Program> factory) : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _c = factory.CreateClient();

    private static string FindUp(string rel)
    {
        for (var d = new DirectoryInfo(AppContext.BaseDirectory); d is not null; d = d.Parent)
        {
            var p = Path.Combine(d.FullName, rel);
            if (File.Exists(p)) return p;
        }
        throw new FileNotFoundException(rel);
    }

    private static JsonNode Golden(string name) => JsonNode.Parse(File.ReadAllText(FindUp(Path.Combine("golden", "cases", name))))!;

    private static async Task<JsonNode> Json(HttpResponseMessage r) => JsonNode.Parse(await r.Content.ReadAsStringAsync())!;

    [Fact]
    public async Task Reference_co_cua_hang_dung_cu_va_phien_ban_du_lieu()
    {
        var r = await _c.GetAsync("/v1/reference");
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        var j = await Json(r);
        Assert.Equal(64, j["data_version"]!.GetValue<string>().Length);
        Assert.True(j["stores"]!.AsArray().Count >= 3);
        Assert.Contains(j["exclusions"]!.AsArray(), x => x!["id"]!.GetValue<string>() == "no_pork");
        Assert.Contains(j["diets"]!.AsArray(), x => x!["id"]!.GetValue<string>() == "vegan");
        Assert.True(j["recipe_count"]!.GetValue<int>() > 100);
    }

    [Fact]
    public async Task Ingredients_tim_khong_dau()
    {
        var j = await Json(await _c.GetAsync("/v1/ingredients?q=rau%20den"));
        Assert.Contains(j.AsArray(), x => x!["name"]!.GetValue<string>().Contains("dền", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task Ingredients_limit_duoc_ton_trong()
    {
        var j = await Json(await _c.GetAsync("/v1/ingredients?limit=3"));
        Assert.Equal(3, j.AsArray().Count);
    }

    [Fact]
    public async Task Targets_khop_golden_p01()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var r = await _c.PostAsJsonAsync("/v1/targets", new { profile = JsonSerializer.Deserialize<JsonElement>(g["input"]!["profile"]!.ToJsonString()) });
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        Assert.True(JsonNode.DeepEquals(g["input"]!["targets"], await Json(r)));
    }

    [Fact]
    public async Task Targets_sai_dau_vao_tra_400_kem_duong_dan_truong()
    {
        var r = await _c.PostAsJsonAsync("/v1/targets", new { profile = new { goal = "bay", sex = "female", age = 5, height_cm = 160, weight_kg = 60, activity = "light", target_mode = "formula" } });
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        var j = await Json(r);
        Assert.NotNull(j["errors"]!["profile.goal"]);
        Assert.NotNull(j["errors"]!["profile.age"]);
    }

    [Fact]
    public async Task Slots_preview_phan_bo_theo_bua()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var body = new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["slots"] = g["input"]!["preferences"]!["slots"]!.DeepClone() };
        var r = await _c.PostAsync("/v1/slots/preview", JsonContent.Create(body));
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        var j = await Json(r);
        Assert.Equal(5, j["slots"]!.AsArray().Count);
    }

    [Fact]
    public async Task Slots_preview_khong_bua_chinh_nao_tra_400()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var slots = g["input"]!["preferences"]!["slots"]!.DeepClone();
        slots["breakfast"] = "skip"; slots["lunch"] = "skip"; slots["dinner"] = "skip";
        var r = await _c.PostAsync("/v1/slots/preview", JsonContent.Create(new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["slots"] = slots }));
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
    }

    [Fact]
    public async Task BudgetRange_tra_khoang_hop_ly_va_bac_theo_key()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var body = new JsonObject
        {
            ["targets"] = new JsonObject { ["kcal_target"] = 1400, ["protein_g"] = 120 },
            ["store_id"] = "bach_hoa_xanh", ["adults"] = 1, ["children"] = 0, ["slots"] = g["input"]!["preferences"]!["slots"]!.DeepClone(),
        };
        var r = await _c.PostAsync("/v1/budget-range", JsonContent.Create(body));
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        var j = await Json(r);
        Assert.Equal("week_food_cost", j["basis"]!.GetValue<string>());
        Assert.True(j["min_vnd"]!.GetValue<double>() <= j["estimate_vnd"]!.GetValue<double>() * 1.5);
        Assert.True(j["max_vnd"]!.GetValue<double>() >= j["min_vnd"]!.GetValue<double>() + 500_000);
        Assert.Equal(new[] { "economy", "moderate", "comfortable" }, j["tiers"]!.AsArray().Select(t => t!["key"]!.GetValue<string>()));
        Assert.All(j["tiers"]!.AsArray(), t => Assert.Null(t!["label"]));
    }

    [Fact]
    public async Task BudgetRange_voi_preferences_loc_mon_theo_kieng()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        async Task<double> Est(string diet)
        {
            var prefs = g["input"]!["preferences"]!.DeepClone();
            prefs["diet"] = diet;
            var r = await _c.PostAsync("/v1/budget-range", JsonContent.Create(new JsonObject { ["targets"] = new JsonObject { ["kcal_target"] = 1400, ["protein_g"] = 120 }, ["preferences"] = prefs }));
            Assert.Equal(HttpStatusCode.OK, r.StatusCode);
            return (await Json(r))["estimate_vnd"]!.GetValue<double>();
        }
        Assert.NotEqual(await Est("none"), await Est("vegan"));
    }

    /// <summary>L-03 / D-QA-01: "Không hạt giống & vừng" — 5 seed, không tuần nào có vừng.</summary>
    [Fact]
    public async Task Plans_no_seed_khong_bao_gio_co_vung()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        for (var seed = 1; seed <= 5; seed++)
        {
            var prefs = g["input"]!["preferences"]!.DeepClone();
            prefs["exclusions"] = new JsonArray("no_seed");
            var body = new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = prefs, ["start_date"] = g["input"]!["start_date"]!.DeepClone(), ["seed"] = seed };
            var r = await _c.PostAsync("/v1/plans", JsonContent.Create(body));
            Assert.Equal(HttpStatusCode.OK, r.StatusCode);
            var text = await r.Content.ReadAsStringAsync();
            Assert.DoesNotContain("\"vung\"", text);
        }
    }

    [Fact]
    public async Task BudgetRange_khong_co_nguon_nao_tra_400()
    {
        var r = await _c.PostAsJsonAsync("/v1/budget-range", new { targets = new { kcal_target = 1400, protein_g = 120 } });
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        Assert.NotNull((await Json(r))["errors"]!["preferences"]);
    }

    [Fact]
    public async Task BudgetRange_chi_can_mot_truong_cap_ngoai_la_du_va_dung_mac_dinh()
    {
        async Task<double> Est(object body)
        {
            var r = await _c.PostAsJsonAsync("/v1/budget-range", body);
            Assert.Equal(HttpStatusCode.OK, r.StatusCode);
            return (await Json(r))["estimate_vnd"]!.GetValue<double>();
        }
        var targets = new { kcal_target = 1400, protein_g = 120 };
        var onlyStore = await Est(new { targets, store_id = "cho_khac" });
        var explicitDefaults = await Est(new { targets, store_id = "cho_khac", adults = 1, children = 0 });
        Assert.Equal(explicitDefaults, onlyStore);
        Assert.True(await Est(new { targets, adults = 2 }) > onlyStore); // 2 người ăn tốn hơn 1
    }

    /// <summary>L-12 / D-QA-08: cùng lựa chọn thì bước ngân sách (dạng rút gọn) và màn tổng kết (đầy đủ preferences) phải cho cùng mức tối thiểu và cùng mốc.</summary>
    [Fact]
    public async Task BudgetRange_dang_rut_gon_va_day_du_cung_lua_chon_thi_cung_muc_toi_thieu()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var targets = new JsonObject { ["kcal_target"] = 1400, ["protein_g"] = 120 };
        var slots = g["input"]!["preferences"]!["slots"]!;
        foreach (var (store, adults, children) in new[] { ("bach_hoa_xanh", 1, 0), ("cho_khac", 2, 1), ("bach_hoa_xanh", 3, 2) })
        {
            var partial = new JsonObject { ["targets"] = targets.DeepClone(), ["store_id"] = store, ["adults"] = adults, ["children"] = children, ["slots"] = slots.DeepClone() };
            // Lựa chọn đầy đủ nhưng không đổi gì so với mặc định của dạng rút gọn: không kiêng, không ghét, đủ dụng cụ, mức cơm vừa.
            var prefs = new JsonObject
            {
                ["store_id"] = store, ["adults"] = adults, ["children"] = children, ["slots"] = slots.DeepClone(), ["diet"] = "none",
                ["exclusions"] = new JsonArray(), ["equipment"] = new JsonArray(Enums.Equipment.Select(e => (JsonNode?)e).ToArray()), ["rice_habit"] = "vua",
            };
            var full = new JsonObject { ["targets"] = targets.DeepClone(), ["preferences"] = prefs };
            var a = await Json(await _c.PostAsync("/v1/budget-range", JsonContent.Create(partial)));
            var b = await Json(await _c.PostAsync("/v1/budget-range", JsonContent.Create(full)));
            foreach (var k in new[] { "min_vnd", "max_vnd", "estimate_vnd" })
                Assert.True(a[k]!.GetValue<double>() == b[k]!.GetValue<double>(), $"{store} {adults}+{children}: {k} rút gọn {a[k]} ≠ đầy đủ {b[k]}");
        }
    }

    [Fact]
    public async Task BudgetRange_co_preferences_thi_bo_qua_truong_cap_ngoai()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        async Task<HttpResponseMessage> Post(JsonObject extra)
        {
            var body = new JsonObject { ["targets"] = new JsonObject { ["kcal_target"] = 1400, ["protein_g"] = 120 }, ["preferences"] = g["input"]!["preferences"]!.DeepClone() };
            foreach (var (k, v) in extra) body[k] = v!.DeepClone();
            return await _c.PostAsync("/v1/budget-range", JsonContent.Create(body));
        }
        var plain = await Post([]);
        // Trường cấp ngoài (kể cả giá trị sai) không ảnh hưởng và không gây lỗi.
        var withOuter = await Post(new JsonObject { ["store_id"] = "khong_co", ["adults"] = 99, ["children"] = 9 });
        Assert.Equal(HttpStatusCode.OK, plain.StatusCode);
        Assert.Equal(HttpStatusCode.OK, withOuter.StatusCode);
        Assert.Equal((await Json(plain))["estimate_vnd"]!.GetValue<double>(), (await Json(withOuter))["estimate_vnd"]!.GetValue<double>());
    }

    [Fact]
    public async Task BudgetRange_thieu_targets_tra_400()
    {
        var r = await _c.PostAsJsonAsync("/v1/budget-range", new { store_id = "cho_khac", adults = 1, children = 0, slots = new { } });
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        Assert.NotNull((await Json(r))["errors"]!["targets"]);
    }

    [Fact]
    public async Task BudgetRange_cua_hang_la_tra_400()
    {
        var r = await _c.PostAsJsonAsync("/v1/budget-range", new { targets = new { kcal_target = 1400, protein_g = 120 }, store_id = "khong_co", adults = 1, children = 0, slots = new { } });
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        Assert.NotNull((await Json(r))["errors"]!["store_id"]);
    }

    [Fact]
    public async Task Plans_p01_khop_golden_seed1()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var body = new JsonObject
        {
            ["profile"] = g["input"]!["profile"]!.DeepClone(),
            ["preferences"] = g["input"]!["preferences"]!.DeepClone(),
            ["start_date"] = g["input"]!["start_date"]!.DeepClone(),
            ["seed"] = 1,
            ["meal_style"] = "full_meal_only", // golden được xuất từ engine chưa ghép mâm
        };
        var r = await _c.PostAsync("/v1/plans", JsonContent.Create(body));
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        var j = await Json(r);
        Assert.Equal(g["plan"]!["status"]!.GetValue<string>(), j["plan"]!["status"]!.GetValue<string>());
        Assert.True(JsonNode.DeepEquals(g["plan"]!["days"], j["plan"]!["days"]), "days lệch golden");
        Assert.True(JsonNode.DeepEquals(g["input"]!["targets"], j["targets"]));
        Assert.True(j["trace"]!.AsArray().Count > 0);
        Assert.Equal(64, j["data_version"]!.GetValue<string>().Length);
    }

    [Fact]
    public async Task Plans_auto_tra_dishes_cho_bua_trua_toi_va_meal_style_sai_tra_400()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        JsonObject Body(string style) => new()
        {
            ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = g["input"]!["preferences"]!.DeepClone(),
            ["start_date"] = "2026-11-09", ["meal_style"] = style,
        };
        var ok = await _c.PostAsync("/v1/plans", JsonContent.Create(Body("auto")));
        Assert.Equal(HttpStatusCode.OK, ok.StatusCode);
        var j = await Json(ok);
        Assert.Equal("auto", j["plan"]!["meal_style"]!.GetValue<string>());
        var lunch = j["plan"]!["days"]![0]!["meals"]!.AsArray().First(m => m!["slot"]!.GetValue<string>() == "lunch")!;
        Assert.True(lunch["dishes"]!.AsArray().Count >= 1);
        Assert.NotNull(lunch["dishes"]![0]!["macros"]);

        // Trace "Cách chúng mình tính" gồm cả tráng miệng: tổng mỗi bữa khớp macros của bữa trong plan.
        var trace = j["trace"]!.AsArray();
        var withDessert = 0;
        foreach (var day in j["plan"]!["days"]!.AsArray())
            foreach (var m in day!["meals"]!.AsArray().Where(m => m!["status"]!.GetValue<string>() == "planned"))
            {
                var t = trace.Single(x => x!["date"]!.GetValue<string>() == m!["date"]!.GetValue<string>() && x!["slot"]!.GetValue<string>() == m!["slot"]!.GetValue<string>())!;
                Assert.True(Math.Abs(m!["macros"]!["kcal"]!.GetValue<double>() - t["total"]!["kcal"]!.GetValue<double>()) < 0.01, "kcal trace lệch macros bữa");
                Assert.True(Math.Abs(m!["macros"]!["protein_g"]!.GetValue<double>() - t["total"]!["protein_g"]!.GetValue<double>()) < 0.01, "protein_g trace lệch macros bữa");
                if (m!["dessert_id"] is not null) { withDessert++; Assert.True(t["dessert"]!.AsArray().Count > 0); }
                else Assert.Empty(t["dessert"]!.AsArray());
            }
        Assert.True(withDessert > 0);

        var bad = await _c.PostAsync("/v1/plans", JsonContent.Create(Body("khac")));
        Assert.Equal(HttpStatusCode.BadRequest, bad.StatusCode);
        Assert.NotNull((await Json(bad))["errors"]!["meal_style"]);
    }

    /// <summary>T-094 / D-COM-01: preferences.rice_habit — thiếu = vừa; sai giá trị → 400; mỗi bữa mâm có rice{habit,target_g,actual_g}, giảm cơm thì có notes[rice_reduced].</summary>
    [Fact]
    public async Task Plans_rice_habit_tra_rice_va_ghi_chu_giam_com_va_gia_tri_sai_tra_400()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        JsonObject Body(string? habit)
        {
            var prefs = g["input"]!["preferences"]!.DeepClone().AsObject();
            if (habit is not null) prefs["rice_habit"] = habit;
            return new() { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = prefs, ["start_date"] = "2026-11-09", ["meal_style"] = "auto" };
        }
        static IEnumerable<JsonNode> Planned(JsonNode j) => j["plan"]!["days"]!.AsArray().SelectMany(d => d!["meals"]!.AsArray()).Where(m => m!["status"]!.GetValue<string>() == "planned")!.Select(m => m!);

        var def = await Json(await _c.PostAsync("/v1/plans", JsonContent.Create(Body(null))));
        var withRice = Planned(def).Where(m => m["rice"] is not null).ToList();
        Assert.NotEmpty(withRice);
        Assert.All(withRice, m => Assert.Equal("vua", m["rice"]!["habit"]!.GetValue<string>()));
        Assert.All(withRice, m => Assert.True(m["rice"]!["target_g"]!.GetValue<double>() > 0 && m["rice"]!["actual_g"]!.GetValue<double>() > 0));
        Assert.Contains(withRice, m => m["rice"]!["target_g"]!.GetValue<double>() == 150);

        var lots = await Json(await _c.PostAsync("/v1/plans", JsonContent.Create(Body("rat_nhieu"))));
        var notes = Planned(lots).Where(m => m["notes"] is not null).ToList();
        Assert.NotEmpty(notes);
        foreach (var m in notes)
        {
            var n = m["notes"]![0]!;
            Assert.Equal("rice_reduced", n["code"]!.GetValue<string>());
            Assert.True(n["actual_g"]!.GetValue<double>() < n["target_g"]!.GetValue<double>() - 10);
            Assert.Contains(n["reason"]!.GetValue<string>(), new[] { "kcal", "protein" });
            Assert.Equal(m["rice"]!["actual_g"]!.GetValue<double>(), n["actual_g"]!.GetValue<double>());
        }

        var parity = Body(null);
        parity["meal_style"] = "full_meal_only";
        Assert.All(Planned(await Json(await _c.PostAsync("/v1/plans", JsonContent.Create(parity)))), m => { Assert.Null(m["rice"]); Assert.Null(m["notes"]); });

        var bad = await _c.PostAsync("/v1/plans", JsonContent.Create(Body("khong_biet")));
        Assert.Equal(HttpStatusCode.BadRequest, bad.StatusCode);
        Assert.NotNull((await Json(bad))["errors"]!["preferences.rice_habit"]);
    }

    [Fact]
    public async Task Plans_sai_dau_vao_tra_400_va_khong_nem_500()
    {
        var r = await _c.PostAsJsonAsync("/v1/plans", new { profile = new { goal = "lose" }, start_date = "11/09/2026" });
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        var j = await Json(r);
        Assert.NotNull(j["errors"]!["start_date"]);
    }

    private async Task<(HttpResponseMessage R, JsonNode J)> PlanWith(Action<JsonNode> edit)
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var prefs = g["input"]!["preferences"]!.DeepClone();
        edit(prefs);
        var body = new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = prefs, ["start_date"] = "2026-11-09" };
        var r = await _c.PostAsync("/v1/plans", JsonContent.Create(body));
        return (r, await Json(r));
    }

    [Fact]
    public async Task Plans_khong_con_bua_chinh_nao_tra_400_kem_truong_loi_D_QA_05()
    {
        var (r, j) = await PlanWith(p => { p["slots"]!["breakfast"] = "skip"; p["slots"]!["lunch"] = "self"; p["slots"]!["dinner"] = "skip"; });
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        Assert.NotNull(j["errors"]!["preferences.slots.breakfast"]);
        // còn đúng 1 bữa chính lên thực đơn thì hợp lệ — kể cả "chỉ còn sáng" (TC-1-17 ghi 400 cho trường hợp này là sai: US-1.3 AC4 và D-QA-05 coi sáng là bữa chính)
        var (ok, _) = await PlanWith(p => { p["slots"]!["breakfast"] = "skip"; p["slots"]!["lunch"] = "skip"; p["slots"]!["dinner"] = "on"; });
        Assert.Equal(HttpStatusCode.OK, ok.StatusCode);
        var (onlyBreakfast, _) = await PlanWith(p => { p["slots"]!["breakfast"] = "on"; p["slots"]!["lunch"] = "skip"; p["slots"]!["dinner"] = "skip"; });
        Assert.Equal(HttpStatusCode.OK, onlyBreakfast.StatusCode);
        // tắt cả ba bữa chính (kể cả khi bữa phụ vẫn bật) → 400
        var (allOff, jOff) = await PlanWith(p => { p["slots"]!["breakfast"] = "skip"; p["slots"]!["lunch"] = "skip"; p["slots"]!["dinner"] = "skip"; p["slots"]!["snack_am"] = "on"; });
        Assert.Equal(HttpStatusCode.BadRequest, allOff.StatusCode);
        Assert.NotNull(jOff["errors"]!["preferences.slots.breakfast"]);
    }

    [Fact]
    public async Task Plans_equipment_rong_hoac_chi_may_xay_tra_400_D_QA_05()
    {
        var (r1, j1) = await PlanWith(p => p["equipment"] = new JsonArray());
        Assert.Equal(HttpStatusCode.BadRequest, r1.StatusCode);
        Assert.NotNull(j1["errors"]!["preferences.equipment"]);
        var (r2, j2) = await PlanWith(p => p["equipment"] = new JsonArray("may_xay"));
        Assert.Equal(HttpStatusCode.BadRequest, r2.StatusCode);
        Assert.NotNull(j2["errors"]!["preferences.equipment"]);
        var (ok, _) = await PlanWith(p => p["equipment"] = new JsonArray("lo_vi_song"));
        Assert.Equal(HttpStatusCode.OK, ok.StatusCode);
    }

    [Fact]
    public async Task Plans_cua_hang_khong_ton_tai_tra_400()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var prefs = g["input"]!["preferences"]!.DeepClone();
        prefs["store_id"] = "xyz";
        var body = new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = prefs, ["start_date"] = "2026-11-09" };
        var r = await _c.PostAsync("/v1/plans", JsonContent.Create(body));
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        Assert.NotNull((await Json(r))["errors"]!["preferences.store_id"]);
    }

    [Fact]
    public async Task Reference_xu_huong_chi_gom_danh_sach_trang_va_du_10_mon()
    {
        var j = await Json(await _c.GetAsync("/v1/reference"));
        var ids = j["health_leanings"]!.AsArray().Select(x => x!["id"]!.GetValue<string>()).ToList();
        Assert.NotEmpty(ids);
        Assert.All(ids, id => Assert.Contains(id, new[] { "nhieu_xo", "it_duong", "tot_cho_tim", "it_beo" }));
        foreach (var internalTag in new[] { "giau_dam", "omega3", "chay", "low_carb" }) Assert.DoesNotContain(internalTag, ids);

        // Ngưỡng 10 món: 9 món mang thẻ → ẩn; 10 món → hiện.
        var data = Dataset.LoadDirectory(Path.GetDirectoryName(FindUp(Path.Combine("data", "recipes.json")))!);
        List<Recipe> With(int n) => data.Recipes.Where(r => !r.HealthTags.Contains("it_duong")).Concat(data.Recipes.Where(r => r.HealthTags.Contains("it_duong")).Take(n)).ToList();
        Assert.DoesNotContain(V1Endpoints.HealthLeanings(new Dataset(data.Ingredients, With(9), data.Stores, data.Prices)), o => o.Id == "it_duong");
        Assert.Contains(V1Endpoints.HealthLeanings(new Dataset(data.Ingredients, With(10), data.Stores, data.Prices)), o => o.Id == "it_duong");
    }

    [Theory]
    [InlineData("giau_dam")]
    [InlineData("omega3")]
    [InlineData("chay")]
    [InlineData("low_carb")]
    [InlineData("khong_co")]
    public async Task Plans_xu_huong_noi_bo_hoac_la_tra_400(string tag)
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var prefs = g["input"]!["preferences"]!.DeepClone();
        prefs["health_leanings"] = new JsonArray(tag);
        var body = new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = prefs, ["start_date"] = "2026-11-09" };
        var r = await _c.PostAsync("/v1/plans", JsonContent.Create(body));
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        Assert.NotNull((await Json(r))["errors"]!["preferences.health_leanings[0]"]);
    }

    [Fact]
    public async Task Recipe_chi_tiet_va_404()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var id = g["plan"]!["days"]![0]!["meals"]![0]!["recipe_id"]!.GetValue<string>();
        var ok = await _c.GetAsync($"/v1/recipes/{id}");
        Assert.Equal(HttpStatusCode.OK, ok.StatusCode);
        Assert.Equal(id, (await Json(ok))["recipe"]!["id"]!.GetValue<string>());
        Assert.Equal(HttpStatusCode.NotFound, (await _c.GetAsync("/v1/recipes/khong_co")).StatusCode);
    }

    [Fact]
    public async Task Cors_dev_cho_phep_moi_origin()
    {
        var req = new HttpRequestMessage(HttpMethod.Get, "/v1/reference");
        req.Headers.Add("Origin", "http://localhost:5173");
        var r = await _c.SendAsync(req);
        Assert.True(r.Headers.Contains("Access-Control-Allow-Origin"));
    }

    [Fact]
    public async Task OpenApi_co_du_endpoint_v1()
    {
        var j = await Json(await _c.GetAsync("/openapi/v1.json"));
        // Ghi lại hợp đồng cho client Dart/OpenAPI generator.
        var dir = Path.Combine(Path.GetDirectoryName(FindUp(Path.Combine("backend", "MonNgon.sln")))!, "openapi");
        Directory.CreateDirectory(dir);
        File.WriteAllText(Path.Combine(dir, "openapi.json"), j.ToJsonString(new JsonSerializerOptions { WriteIndented = true, Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping }));
        var paths = j["paths"]!.AsObject().Select(p => p.Key).ToList();
        foreach (var p in new[] { "/v1/reference", "/v1/ingredients", "/v1/targets", "/v1/slots/preview", "/v1/budget-range", "/v1/plans", "/v1/recipes/{id}", "/v1/plans/swap-suggestions", "/v1/plans/apply-swap", "/v1/plans/ingredient-options", "/v1/plans/swap-ingredient", "/v1/plans/eat-out", "/v1/plans/regenerate-rest" })
            Assert.Contains(p, paths);
    }

    // ---- T-070 ----

    private static IEnumerable<JsonNode> Walk(JsonNode? n)
    {
        if (n is null) yield break;
        yield return n;
        if (n is JsonObject o) foreach (var kv in o) foreach (var c in Walk(kv.Value)) yield return c;
        if (n is JsonArray a) foreach (var x in a) foreach (var c in Walk(x)) yield return c;
    }

    [Fact]
    public async Task OpenApi_khong_con_kieu_so_dang_union_voi_string()
    {
        var j = await Json(await _c.GetAsync("/openapi/v1.json"));
        foreach (var n in Walk(j["components"]))
        {
            if (n is not JsonObject o || o["type"] is not JsonArray t) continue;
            var names = t.Select(x => x!.GetValue<string>()).ToList();
            Assert.False(names.Contains("string") && (names.Contains("number") || names.Contains("integer")), o.ToJsonString());
        }
        Assert.DoesNotContain("\"pattern\"", j["components"]!["schemas"]!["Macros"]!.ToJsonString());
    }

    private async Task<JsonNode> PlanAuto()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var body = new JsonObject
        {
            ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = g["input"]!["preferences"]!.DeepClone(),
            ["start_date"] = "2026-11-09", ["meal_style"] = "auto",
        };
        var r = await _c.PostAsync("/v1/plans", JsonContent.Create(body));
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        return await Json(r);
    }

    [Fact]
    public async Task Plans_tra_du_recipes_va_ingredients_de_xem_offline()
    {
        var j = await PlanAuto();
        var recipes = j["recipes"]!.AsObject();
        var ingredients = j["ingredients"]!.AsObject();
        var meals = j["plan"]!["days"]!.AsArray().SelectMany(d => d!["meals"]!.AsArray()).Where(m => m!["status"]!.GetValue<string>() == "planned").ToList();
        Assert.NotEmpty(meals);
        foreach (var m in meals)
        {
            Assert.True(recipes.ContainsKey(m!["recipe_id"]!.GetValue<string>()), m["recipe_id"]!.ToJsonString());
            if (m["dessert_id"] is { } d) Assert.True(recipes.ContainsKey(d.GetValue<string>()));
            foreach (var dish in m["dishes"]!.AsArray().Where(x => x!["recipe_id"] is not null)) Assert.True(recipes.ContainsKey(dish!["recipe_id"]!.GetValue<string>()));
        }
        // mọi ingredient_id trong plan đều có trong map
        foreach (var n in Walk(j["plan"]).OfType<JsonObject>().Where(o => o["ingredient_id"] is not null))
            Assert.True(ingredients.ContainsKey(n["ingredient_id"]!.GetValue<string>()), n["ingredient_id"]!.ToJsonString());
        foreach (var sub in Walk(j["plan"]).OfType<JsonObject>().Where(o => o["from"] is not null && o["to"] is not null))
        {
            Assert.True(ingredients.ContainsKey(sub["from"]!.GetValue<string>()));
            Assert.True(ingredients.ContainsKey(sub["to"]!.GetValue<string>()));
        }
        // công thức đầy đủ + image_group
        var any = recipes.First().Value!;
        Assert.NotNull(any["steps"]);
        Assert.NotNull(any["cook_minutes"]);
        Assert.NotNull(any["dish_role"]);
        Assert.Contains(any["image_group"]!.GetValue<string>(), new[] { "kho", "xao", "canh", "luoc_hap", "com", "sang", "phu" });
        Assert.NotNull(ingredients.First().Value!["household_units"]);
        Assert.NotNull(ingredients.First().Value!["default_pantry"]);
        // đi chợ có đơn vị mua
        Assert.All(j["plan"]!["shopping"]!["items"]!.AsArray(), i => Assert.False(string.IsNullOrEmpty(i!["display_qty"]!.GetValue<string>())));
    }

    [Fact]
    public async Task Reference_co_xu_huong_goi_y_ghet_quay_va_mo_ta()
    {
        var j = await Json(await _c.GetAsync("/v1/reference"));
        Assert.True(j["health_leanings"]!.AsArray().Count >= 3);
        Assert.All(j["health_leanings"]!.AsArray(), x => Assert.Equal("health", x!["group"]!.GetValue<string>()));
        Assert.True(j["dislike_suggestions"]!.AsArray().Count >= 6);
        Assert.NotNull(j["dislike_suggestions"]![0]!["household_units"]);
        Assert.Equal("Thịt", j["aisles"]!["thit"]!.GetValue<string>());
        foreach (var o in j["exclusions"]!.AsArray().Concat(j["diets"]!.AsArray()).Concat(j["equipment"]!.AsArray()))
            Assert.False(string.IsNullOrEmpty(o!["group"]!.GetValue<string>()));
        Assert.All(j["exclusions"]!.AsArray(), x => { Assert.Equal("exclusion", x!["group"]!.GetValue<string>()); Assert.False(string.IsNullOrEmpty(x["description"]!.GetValue<string>())); });
        Assert.All(j["diets"]!.AsArray(), x => Assert.Equal("diet", x!["group"]!.GetValue<string>()));
    }

    [Fact]
    public async Task ShoppingList_bo_bua_an_ngoai_va_nha_co_san()
    {
        object Meal(bool eatenOut) => new { eaten_out = eatenOut, ingredients = new[] { new { ingredient_id = "uc_ga_khong_da", grams = 150, standard_grams = 150 }, new { ingredient_id = "muoi", grams = 2, standard_grams = 2 } } };
        async Task<JsonNode> Call(object[] meals, string[] pantry)
        {
            var r = await _c.PostAsJsonAsync("/v1/shopping-list", new { meals, store_id = "cho_khac", adults = 1, children = 0, pantry_ids = pantry });
            Assert.Equal(HttpStatusCode.OK, r.StatusCode);
            return await Json(r);
        }
        var all = await Call([Meal(false), Meal(false)], []);
        var oneOut = await Call([Meal(false), Meal(true)], []);
        Assert.True(all["items"]!.AsArray().First(i => i!["ingredient_id"]!.GetValue<string>() == "uc_ga_khong_da")!["need_g"]!.GetValue<double>()
            > oneOut["items"]!.AsArray().First(i => i!["ingredient_id"]!.GetValue<string>() == "uc_ga_khong_da")!["need_g"]!.GetValue<double>());
        var pantry = await Call([Meal(false)], ["uc_ga_khong_da"]);
        // D-SHP-01: dòng nhà có sẵn vẫn nằm trong danh sách (để bỏ đánh dấu được), có cờ is_pantry, nhưng không tính vào till_cost.
        var chicken = pantry["items"]!.AsArray().First(i => i!["ingredient_id"]!.GetValue<string>() == "uc_ga_khong_da")!;
        Assert.True(chicken["is_pantry"]!.GetValue<bool>());
        Assert.Contains("uc_ga_khong_da", pantry["skipped_pantry"]!.AsArray().Select(x => x!.GetValue<string>()));
        Assert.True(all["items"]!.AsArray().First(i => i!["ingredient_id"]!.GetValue<string>() == "muoi")!["is_default_pantry"]!.GetValue<bool>());
    }

    [Fact]
    public async Task ShoppingList_pantry_ids_khong_gui_dung_default_pantry_gui_rong_khong_coi_gi_la_co_san_D_SHP_01()
    {
        var meals = new[] { new { eaten_out = false, ingredients = new[] {
            new { ingredient_id = "uc_ga_khong_da", grams = 150, standard_grams = 150 }, new { ingredient_id = "muoi", grams = 2, standard_grams = 2 }, new { ingredient_id = "dau_an", grams = 10, standard_grams = 10 } } } };
        async Task<JsonNode> Call(object body)
        {
            var r = await _c.PostAsJsonAsync("/v1/shopping-list", body);
            Assert.Equal(HttpStatusCode.OK, r.StatusCode);
            return await Json(r);
        }
        var none = await Call(new { meals, store_id = "cho_khac", adults = 1, children = 0, pantry_ids = Array.Empty<string>() });
        var dflt = await Call(new { meals, store_id = "cho_khac", adults = 1, children = 0 });
        JsonNode Item(JsonNode l, string id) => l["items"]!.AsArray().First(i => i!["ingredient_id"]!.GetValue<string>() == id)!;
        // [] → không dòng nào có sẵn, không có tiền "nếu phải mua"
        Assert.All(none["items"]!.AsArray(), i => Assert.False(i!["is_pantry"]!.GetValue<bool>()));
        Assert.Equal(0, none["pantry_cost_if_buy_vnd"]!.GetValue<double>());
        // không gửi → theo default_pantry của nguyên liệu
        foreach (var it in dflt["items"]!.AsArray()) Assert.Equal(it!["is_default_pantry"]!.GetValue<bool>(), it["is_pantry"]!.GetValue<bool>());
        Assert.True(Item(dflt, "muoi")["is_pantry"]!.GetValue<bool>());
        Assert.False(Item(dflt, "uc_ga_khong_da")["is_pantry"]!.GetValue<bool>());
        // chi phí món ăn không đổi khi bật/tắt pantry; tiền tại quầy giảm đúng phần "nếu phải mua"
        Assert.Equal(none["week_food_cost"]!.GetValue<double>(), dflt["week_food_cost"]!.GetValue<double>());
        Assert.True(dflt["till_cost"]!.GetValue<double>() < none["till_cost"]!.GetValue<double>());
        Assert.InRange(dflt["till_cost"]!.GetValue<double>() + dflt["pantry_cost_if_buy_vnd"]!.GetValue<double>() - none["till_cost"]!.GetValue<double>(), -1000, 1000);
    }

    [Fact]
    public async Task Plans_auto_quy_com_ra_gao_o_danh_sach_di_cho_va_ghi_purchase_as_trong_ingredients_D_SHP_02()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var body = new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = g["input"]!["preferences"]!.DeepClone(), ["start_date"] = "2026-11-09" };
        var j = await Json(await _c.PostAsync("/v1/plans", JsonContent.Create(body)));
        var ids = j["plan"]!["shopping"]!["items"]!.AsArray().Select(i => i!["ingredient_id"]!.GetValue<string>()).ToList();
        Assert.Contains("gao_te", ids);
        Assert.DoesNotContain("com_trang", ids);
        var ing = j["ingredients"]!;
        Assert.Equal("gao_te", ing["com_trang"]!["purchase_as"]!["ingredient_id"]!.GetValue<string>());
        Assert.Equal(0.36, ing["com_trang"]!["purchase_as"]!["factor"]!.GetValue<double>(), 6);
        Assert.NotNull(ing["gao_te"]); // nguyên liệu đích luôn có trong map để app ghi "≈ X g gạo tẻ"
        Assert.Null(ing["gao_te"]!["purchase_as"]);
    }

    [Fact]
    public async Task Plans_auto_till_cost_khong_gom_do_nha_co_san_nhung_week_food_cost_van_tinh_D_SHP_01()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var body = new JsonObject { ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = g["input"]!["preferences"]!.DeepClone(), ["start_date"] = "2026-11-09" };
        var j = await Json(await _c.PostAsync("/v1/plans", JsonContent.Create(body)));
        var shop = j["plan"]!["shopping"]!;
        var items = shop["items"]!.AsArray();
        Assert.Contains(items, i => i!["is_pantry"]!.GetValue<bool>());
        Assert.All(items, i => Assert.Equal(i!["is_default_pantry"]!.GetValue<bool>(), i["is_pantry"]!.GetValue<bool>()));
        var till = items.Where(i => !i!["is_pantry"]!.GetValue<bool>()).Sum(i => i!["till_cost_vnd"]!.GetValue<double>());
        Assert.InRange(shop["till_cost"]!.GetValue<double>() - till, -500, 500);
        var used = items.Sum(i => i!["used_cost_vnd"]!.GetValue<double>());
        Assert.InRange(shop["week_food_cost"]!.GetValue<double>() - used, -500, 500);
        Assert.True(shop["pantry_cost_if_buy_vnd"]!.GetValue<double>() > 0);
    }

    [Fact]
    public async Task ShoppingList_dau_vao_sai_tra_400_kem_duong_dan()
    {
        var r = await _c.PostAsJsonAsync("/v1/shopping-list", new
        {
            meals = new[] { new { eaten_out = false, ingredients = new[] { new { ingredient_id = "khong_co", grams = -1, standard_grams = 0 } } } },
            store_id = "xyz", adults = 0, children = 0, pantry_ids = new[] { "la" },
        });
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        var e = (await Json(r))["errors"]!.AsObject();
        foreach (var k in new[] { "store_id", "adults", "meals[0].ingredients[0].ingredient_id", "meals[0].ingredients[0].grams", "pantry_ids[0]" }) Assert.True(e.ContainsKey(k), k);
    }

    [Fact]
    public async Task Ingredients_tra_household_units()
    {
        var j = await Json(await _c.GetAsync("/v1/ingredients?q=dau%20an"));
        Assert.NotNull(j[0]!["household_units"]);
    }

    // ---- T-067: thay đổi tuần ----

    private async Task<(JsonObject State, JsonNode Plan)> WeekState()
    {
        var g = Golden("p01_nu_giam_mo_vua.seed1.json");
        var body = new JsonObject
        {
            ["profile"] = g["input"]!["profile"]!.DeepClone(), ["preferences"] = g["input"]!["preferences"]!.DeepClone(),
            ["start_date"] = g["input"]!["start_date"]!.DeepClone(), ["seed"] = 1,
        };
        var j = await Json(await _c.PostAsync("/v1/plans", JsonContent.Create(body)));
        var state = new JsonObject { ["profile"] = body["profile"]!.DeepClone(), ["preferences"] = body["preferences"]!.DeepClone(), ["plan"] = j["plan"]!.DeepClone(), ["include_dessert"] = true };
        return (state, j);
    }

    private Task<HttpResponseMessage> Post(string path, JsonObject state, params (string K, JsonNode? V)[] extra)
    {
        var body = new JsonObject { ["state"] = state.DeepClone() };
        foreach (var (k, v) in extra) body[k] = v;
        return _c.PostAsync(path, JsonContent.Create(body));
    }

    private static JsonNode MealOf(JsonNode plan, string date, string slot) =>
        plan["days"]!.AsArray().First(d => d!["date"]!.GetValue<string>() == date)!["meals"]!.AsArray().First(m => m!["slot"]!.GetValue<string>() == slot)!;

    [Fact]
    public async Task Doi_mon_qua_API_goi_y_roi_ap_dung_va_tra_ve_tuan_day_du()
    {
        var (state, _) = await WeekState();
        var sug = await Post("/v1/plans/swap-suggestions", state, ("date", "2026-11-10"), ("slot", "dinner"));
        Assert.Equal(HttpStatusCode.OK, sug.StatusCode);
        var sj = await Json(sug);
        var items = sj["items"]!.AsArray();
        Assert.InRange(items.Count, 2, 3);
        Assert.True(sj["any_keeps_day"]!.GetValue<bool>());
        Assert.All(items, i => Assert.NotNull(i!["delta_cost_vnd"]));
        var pick = items[0]!["recipe_id"]!.GetValue<string>();

        var ap = await Post("/v1/plans/apply-swap", state, ("date", "2026-11-10"), ("slot", "dinner"), ("recipe_id", pick));
        Assert.Equal(HttpStatusCode.OK, ap.StatusCode);
        var aj = await Json(ap);
        Assert.Equal(pick, MealOf(aj["plan"]!, "2026-11-10", "dinner")["recipe_id"]!.GetValue<string>());
        Assert.True(aj["plan"]!["validation"]!["days"]!.AsArray().First(d => d!["date"]!.GetValue<string>() == "2026-11-10")!["ok"]!.GetValue<bool>());
        Assert.True(aj["recipes"]!.AsObject().ContainsKey(pick));
        Assert.Equal(64, aj["data_version"]!.GetValue<string>().Length);
        Assert.Contains(aj["trace"]!.AsArray(), t => t!["date"]!.GetValue<string>() == "2026-11-10" && t["slot"]!.GetValue<string>() == "dinner" && t["recipe_id"]!.GetValue<string>() == pick);
        // kết quả của apply gửi lại làm trạng thái mới được (chuỗi thao tác liên tiếp)
        state["plan"] = aj["plan"]!.DeepClone();
        var again = await Post("/v1/plans/eat-out", state, ("date", "2026-11-11"), ("slot", "lunch"), ("mode", "eat_out"));
        Assert.Equal(HttpStatusCode.OK, again.StatusCode);
    }

    [Fact]
    public async Task Doi_mon_sai_dau_vao_tra_400_theo_truong()
    {
        var (state, _) = await WeekState();
        var r = await Post("/v1/plans/apply-swap", state, ("date", "2026-11-10"), ("slot", "dinner"), ("recipe_id", "khong_co"));
        Assert.Equal(HttpStatusCode.BadRequest, r.StatusCode);
        Assert.NotNull((await Json(r))["errors"]!["recipe_id"]);
        var r2 = await Post("/v1/plans/swap-suggestions", state, ("date", "2026-12-01"), ("slot", "dinner"));
        Assert.Equal(HttpStatusCode.BadRequest, r2.StatusCode);
        Assert.NotNull((await Json(r2))["errors"]!["date"]);
        // state có hồ sơ không hợp lệ
        var bad = state.DeepClone().AsObject();
        bad["profile"]!["goal"] = "bay";
        var r3 = await Post("/v1/plans/swap-suggestions", bad, ("date", "2026-11-10"), ("slot", "dinner"));
        Assert.Equal(HttpStatusCode.BadRequest, r3.StatusCode);
        Assert.NotNull((await Json(r3))["errors"]!["state.profile.goal"]);
        var empty = await _c.PostAsJsonAsync("/v1/plans/eat-out", new { });
        Assert.Equal(HttpStatusCode.BadRequest, empty.StatusCode);
    }

    [Fact]
    public async Task An_ngoai_qua_API_mien_kiem_ngay_rut_di_cho_va_hoan_tac_ve_dung_ban_dau()
    {
        var (state, orig) = await WeekState();
        var r = await Post("/v1/plans/eat-out", state, ("date", "2026-11-12"), ("slot", "dinner"), ("mode", "eat_out"));
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        var j = await Json(r);
        Assert.Equal("eaten_out", MealOf(j["plan"]!, "2026-11-12", "dinner")["status"]!.GetValue<string>());
        var v = j["plan"]!["validation"]!["days"]!.AsArray().First(d => d!["date"]!.GetValue<string>() == "2026-11-12")!;
        Assert.True(v["exempt"]!.GetValue<bool>());
        Assert.True(v["ok"]!.GetValue<bool>());
        Assert.True(j["plan"]!["shopping"]!["week_food_cost"]!.GetValue<double>() < orig["plan"]!["shopping"]!["week_food_cost"]!.GetValue<double>());
        Assert.DoesNotContain(j["trace"]!.AsArray(), t => t!["date"]!.GetValue<string>() == "2026-11-12" && t["slot"]!.GetValue<string>() == "dinner");

        state["plan"] = j["plan"]!.DeepClone();
        var undo = await Json(await Post("/v1/plans/eat-out", state, ("date", "2026-11-12"), ("slot", "dinner"), ("mode", "undo")));
        Assert.True(JsonNode.DeepEquals(orig["plan"], undo["plan"]), "hoàn tác phải ra đúng tuần ban đầu");

        var bad = await Post("/v1/plans/eat-out", state, ("date", "2026-11-12"), ("slot", "dinner"), ("mode", "abc"));
        Assert.Equal(HttpStatusCode.BadRequest, bad.StatusCode);
        Assert.NotNull((await Json(bad))["errors"]!["mode"]);
    }

    [Fact]
    public async Task Doi_nguyen_lieu_qua_API_tuy_chon_roi_ap_dung()
    {
        var (state, orig) = await WeekState();
        // tìm một bữa có nguyên liệu đạm thay được
        foreach (var d in orig["plan"]!["days"]!.AsArray())
            foreach (var m in d!["meals"]!.AsArray().Where(m => m!["status"]!.GetValue<string>() == "planned" && m["slot"]!.GetValue<string>() != "snack_am"))
            {
                var recipe = orig["recipes"]!.AsObject()[m!["recipe_id"]!.GetValue<string>()]!;
                var lines = recipe["ingredients"]!.AsArray();
                for (var i = 0; i < lines.Count; i++)
                {
                    if (lines[i]!["swap_group"] is null || lines[i]!["role"]!.GetValue<string>() != "protein") continue;
                    var ing = m["grams"]![i]!["ingredient_id"]!.GetValue<string>();
                    var date = d["date"]!.GetValue<string>();
                    var slot = m["slot"]!.GetValue<string>();
                    var opts = await Json(await Post("/v1/plans/ingredient-options", state, ("date", date), ("slot", slot), ("ingredient_id", ing)));
                    var list = opts["options"]!.AsArray();
                    if (list.Count == 0) continue;
                    var to = list[0]!["ingredient_id"]!.GetValue<string>();
                    var r = await Post("/v1/plans/swap-ingredient", state, ("date", date), ("slot", slot), ("from_ingredient_id", ing), ("to_ingredient_id", to));
                    Assert.Equal(HttpStatusCode.OK, r.StatusCode);
                    var j = await Json(r);
                    var nm = MealOf(j["plan"]!, date, slot);
                    Assert.Contains(nm["substitutions"]!.AsArray(), s => s!["to"]!.GetValue<string>() == to);
                    Assert.True(j["ingredients"]!.AsObject().ContainsKey(to));
                    var bad = await Post("/v1/plans/swap-ingredient", state, ("date", date), ("slot", slot), ("from_ingredient_id", ing), ("to_ingredient_id", "dau_an"));
                    Assert.Equal(HttpStatusCode.BadRequest, bad.StatusCode);
                    return;
                }
            }
        Assert.Fail("không tìm thấy bữa có nguyên liệu đạm thay được");
    }

    [Fact]
    public async Task Len_lai_phan_con_lai_qua_API_giu_ngay_qua_va_hom_nay()
    {
        var (state, orig) = await WeekState();
        var r = await Post("/v1/plans/regenerate-rest", state, ("today", "2026-11-11"), ("seed", 9));
        Assert.Equal(HttpStatusCode.OK, r.StatusCode);
        var j = await Json(r);
        var o = orig["plan"]!["days"]!.AsArray();
        var n = j["plan"]!["days"]!.AsArray();
        for (var i = 0; i < 3; i++) Assert.True(JsonNode.DeepEquals(o[i], n[i]), $"ngày {i} phải giữ nguyên");
        Assert.False(JsonNode.DeepEquals(o[5], n[5]));
        Assert.Equal(7, j["plan"]!["validation"]!["days"]!.AsArray().Count);
        var bad = await Post("/v1/plans/regenerate-rest", state, ("today", "2026-11-15"));
        Assert.Equal(HttpStatusCode.BadRequest, bad.StatusCode);
        Assert.NotNull((await Json(bad))["errors"]!["today"]);
    }
}
