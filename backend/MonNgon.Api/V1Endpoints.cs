using System.Text.Json;
using Microsoft.AspNetCore.Http.HttpResults;
using MonNgon.Engine;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Api;

public sealed record DataInfo(string Dir, string Version, string? ContentDir);

public static class V1Endpoints
{
    private static readonly Dictionary<string, string> EquipmentNames = new()
    {
        ["bep"] = "Bếp", ["noi_com_dien"] = "Nồi cơm điện", ["lo_vi_song"] = "Lò vi sóng", ["noi_chien_khong_dau"] = "Nồi chiên không dầu",
        ["lo_nuong"] = "Lò nướng", ["noi_ap_suat"] = "Nồi áp suất", ["may_xay"] = "Máy xay",
    };

    private static readonly Dictionary<string, string> ExclusionNames = new()
    {
        ["no_pork"] = "Không thịt lợn", ["no_red_meat"] = "Không thịt đỏ", ["no_gluten"] = "Không gluten", ["no_dairy"] = "Không sữa",
        ["no_egg"] = "Không trứng", ["no_peanut"] = "Không lạc", ["no_tree_nut"] = "Không hạt cây", ["no_seed"] = "Không hạt giống & vừng",
        ["no_sesame"] = "Không vừng", ["no_soy"] = "Không đậu nành", ["no_fish"] = "Không cá", ["no_shellfish"] = "Không hải sản có vỏ",
    };

    private static readonly Dictionary<string, string> DietNames = new()
    {
        ["none"] = "Không kiêng", ["vegetarian"] = "Chay", ["vegan"] = "Thuần chay", ["pescatarian"] = "Chay có cá",
    };

    public static IEndpointRouteBuilder MapV1(this IEndpointRouteBuilder app)
    {
        var g = app.MapGroup("/v1");

        g.MapGet("/reference", (Dataset data, DataInfo info) =>
        {
            var swipe = LoadSwipeCards(info.ContentDir);
            return TypedResults.Ok(new ReferenceResponse
            {
                DataVersion = info.Version,
                Stores = data.Stores.Select(s => new StoreDto { Id = s.Id, Name = s.Name, PriceSurveyDate = s.PriceSurveyDate }).ToList(),
                Equipment = Enums.Equipment.Select(id => new OptionDto { Id = id, Name = EquipmentNames.GetValueOrDefault(id, id), Group = "equipment" }).ToList(),
                Exclusions = Enums.Exclusions.Select(id => new OptionDto
                {
                    Id = id, Name = ExclusionNames.GetValueOrDefault(id, id), Group = "exclusion",
                    Bans = Filter.ExclusionBans[id].Allergens.Concat(Filter.ExclusionBans[id].Diet).Distinct().ToList(),
                    Description = BanDescription(data, new Preferences { Exclusions = [id] }),
                }).ToList(),
                Diets = Enums.Diets.Select(id => new OptionDto
                {
                    Id = id, Name = DietNames.GetValueOrDefault(id, id), Group = "diet", Bans = Filter.DietBans(id).ToList(),
                    Description = id == "none" ? "Ăn mọi thứ" : BanDescription(data, new Preferences { Diet = id }),
                }).ToList(),
                HealthLeanings = HealthLeanings(data),
                DislikeSuggestions = DislikeSuggestionIds.Where(data.IngredientsById.ContainsKey).Select(id => ToDto(data.IngredientsById[id])).ToList(),
                Aisles = AisleNames,
                SwipeCards = swipe,
                RecipeCount = data.Recipes.Count,
                IngredientCount = data.Ingredients.Count,
            });
        }).WithName("GetReference").WithSummary("Cửa hàng, dụng cụ, lựa chọn kiêng/loại trừ, thẻ vuốt, phiên bản dữ liệu");

        g.MapGet("/ingredients", (Dataset data, string? q, int? limit) =>
        {
            var take = Math.Clamp(limit ?? 20, 1, 100);
            var key = TextFold.Fold((q ?? "").Trim());
            IEnumerable<Ingredient> src = data.Ingredients;
            if (key.Length > 0)
            {
                src = src
                    .Select(i => (i, rank: Rank(i, key)))
                    .Where(x => x.rank < int.MaxValue)
                    .OrderBy(x => x.rank).ThenBy(x => x.i.Name, ViCollator.Instance)
                    .Select(x => x.i);
            }
            else src = src.OrderBy(i => i.Name, ViCollator.Instance);
            return TypedResults.Ok(src.Take(take).Select(ToDto).ToList());
        }).WithName("SearchIngredients").WithSummary("Tìm nguyên liệu không dấu (ô 'không muốn thấy')");

        g.MapPost("/targets", Results<Ok<Targets>, ValidationProblem> (TargetsRequest req) =>
        {
            var e = new Errors();
            Validation.Profile(e, req.Profile);
            if (e.Any) return TypedResults.ValidationProblem(e.ToDictionary());
            return TypedResults.Ok(TargetCalc.Compute(req.Profile));
        }).WithName("ComputeTargets").WithSummary("Chỉ tiêu calo/protein kèm các bước trung gian");

        g.MapPost("/slots/preview", Results<Ok<SlotsPreviewResponse>, ValidationProblem> (SlotsPreviewRequest req) =>
        {
            var e = new Errors();
            Validation.Profile(e, req.Profile);
            Validation.Slots(e, req.Slots);
            if (e.Any) return TypedResults.ValidationProblem(e.ToDictionary());
            var t = TargetCalc.Compute(req.Profile);
            return TypedResults.Ok(new SlotsPreviewResponse { Targets = t, Slots = MealSlots.Allocate(t, req.Slots) });
        }).WithName("PreviewSlots").WithSummary("Phân bổ chỉ tiêu theo bữa");

        g.MapPost("/rice/feasibility", Results<Ok<RiceFeasibilityResponse>, ValidationProblem> (SlotsPreviewRequest req) =>
        {
            var e = new Errors();
            Validation.Profile(e, req.Profile);
            Validation.Slots(e, req.Slots);
            if (e.Any) return TypedResults.ValidationProblem(e.ToDictionary());
            var t = TargetCalc.Compute(req.Profile);
            return TypedResults.Ok(new RiceFeasibilityResponse { Targets = t, Habits = RiceFeasibility.Compute(t, req.Slots) });
        }).WithName("RiceFeasibility").WithSummary("Mức cơm khả thi mỗi bữa trưa/tối theo chỉ tiêu (cảnh báo ở bước chọn thói quen ăn cơm)");

        g.MapPost("/budget-range", Results<Ok<BudgetRangeResponse>, ValidationProblem> (BudgetRangeRequest req, Dataset data) =>
        {
            var e = new Errors();
            if (req.Targets is null) e.Add("targets", "bắt buộc (kcal_target, protein_g)");
            else
            {
                if (req.Targets.KcalTarget is not > 0) e.Add("targets.kcal_target", "bắt buộc và phải > 0");
                if (req.Targets.ProteinG is not > 0) e.Add("targets.protein_g", "bắt buộc và phải > 0");
            }
            Preferences prefs;
            if (req.Preferences is not null)
            {
                prefs = req.Preferences;
                Validation.Preferences(e, prefs, data);
            }
            else
            {
                // Không có preferences: phải có ít nhất một trường cấp ngoài, trường vắng dùng mặc định.
                if (req.StoreId is null && req.Adults is null && req.Children is null && req.Slots is null)
                    e.Add("preferences", "bắt buộc, hoặc gửi ít nhất một trong store_id, adults, children, slots");
                var storeId = req.StoreId ?? "cho_khac";
                var adults = req.Adults ?? 1;
                var children = req.Children ?? 0;
                var slots = req.Slots ?? new SlotsConfig();
                if (!data.StoresById.ContainsKey(storeId)) e.Add("store_id", $"cửa hàng \"{storeId}\" không tồn tại");
                if (adults is < 1 or > 6) e.Add("adults", "phải trong khoảng 1–6");
                if (children is < 0 or > 4) e.Add("children", "phải trong khoảng 0–4");
                Validation.Slots(e, slots);
                // Không có preferences: không lọc theo dụng cụ/kiêng (mọi dụng cụ được coi là có).
                prefs = new Preferences { StoreId = storeId, Adults = adults, Children = children, Slots = slots, Equipment = [.. Enums.Equipment] };
            }
            if (e.Any) return TypedResults.ValidationProblem(e.ToDictionary());
            var kcal = req.Targets!.KcalTarget!.Value;
            var targets = new Targets { Mode = "manual", KcalTarget = kcal, KcalMin = kcal * 0.95, KcalMax = kcal * 1.05, ProteinG = req.Targets.ProteinG!.Value };
            var r = BudgetEstimator.Compute(data, targets, prefs);
            return TypedResults.Ok(new BudgetRangeResponse
            {
                MinVnd = r.MinVnd, MaxVnd = r.MaxVnd, StepVnd = r.StepVnd, EstimateVnd = r.EstimateVnd, Basis = r.Basis,
                Tiers = r.Tiers.Select(t => new BudgetTierDto { Key = t.Key, FromVnd = t.FromVnd, ToVnd = t.ToVnd }).ToList(),
            });
        }).WithName("BudgetRange").WithSummary("Khoảng ngân sách tuần gợi ý theo chỉ tiêu, số người, số bữa và (tùy chọn) kiêng/ghét/dụng cụ")
        .WithDescription("`targets` bắt buộc. Nguồn cấu hình có hai dạng: (1) `preferences` đầy đủ (khuyến nghị; lọc món theo kiêng/ghét/dụng cụ; các trường cấp ngoài `store_id`, `adults`, `children`, `slots` bị bỏ qua) "
            + "hoặc (2) không có `preferences`, khi đó gửi ít nhất một trong `store_id` (mặc định cho_khac), `adults` (1–6, mặc định 1), `children` (0–4, mặc định 0), `slots` (mặc định ăn sáng/trưa/tối); trường vắng dùng mặc định. "
            + "Không có nguồn nào → 400 (lỗi ở `preferences`).");

        g.MapPost("/plans", Results<Ok<PlanResponse>, ValidationProblem> (PlanRequest req, Dataset data, DataInfo info) =>
        {
            var e = new Errors();
            Validation.Profile(e, req.Profile);
            Validation.Preferences(e, req.Preferences, data);
            Validation.StartDate(e, req.StartDate);
            Validation.MealStyle(e, req.MealStyle);
            if (e.Any) return TypedResults.ValidationProblem(e.ToDictionary());
            MealStyles.TryParse(req.MealStyle, out var style);
            var targets = TargetCalc.Compute(req.Profile);
            var plan = WeekPlanner.Plan(new PlanWeekInput
            {
                Targets = targets, Prefs = req.Preferences, Data = data, StartDate = req.StartDate, Seed = req.Seed ?? 1,
                Options = new PlanOptions { MealStyle = style, IncludeDessert = req.IncludeDessert },
            });
            var (recipes, ingredients) = BuildOfflineMaps(plan, data);
            return TypedResults.Ok(new PlanResponse { Targets = targets, Plan = plan, Trace = BuildTrace(plan, data), DataVersion = info.Version, Recipes = recipes, Ingredients = ingredients });
        }).WithName("CreatePlan").WithSummary("Tạo tuần: WeekPlan + danh sách đi chợ + trace 'Cách chúng mình tính'");

        // ----- T-067: thay đổi tuần (stateless: máy khách gửi kèm tuần hiện tại) -----

        g.MapPost("/plans/swap-suggestions", Results<Ok<SwapSuggestions>, ValidationProblem> (SwapSuggestionsRequest req, Dataset data) =>
            Edit(req.State, data, inp => TypedResults.Ok(WeekPlanner.SuggestSwaps(inp, req.Date, req.Slot, req.Limit ?? 3))))
            .WithName("SwapSuggestions").WithSummary("US-5.1: 2–3 món thay thế cùng loại bữa, kèm chênh lệch protein/kcal/chi phí; chỉ món giữ ngày đạt (hoặc món gần đạt nhất, any_keeps_day = false)");

        g.MapPost("/plans/apply-swap", Results<Ok<PlanResponse>, ValidationProblem> (ApplySwapRequest req, Dataset data, DataInfo info) =>
            EditPlan(req.State, data, info, inp => WeekPlanner.ApplySwap(inp, req.Date, req.Slot, req.RecipeId)))
            .WithName("ApplySwap").WithSummary("US-5.1: đổi bữa sang món đã chọn; validator và danh sách đi chợ chạy lại");

        g.MapPost("/plans/ingredient-options", Results<Ok<IngredientOptions>, ValidationProblem> (IngredientOptionsRequest req, Dataset data) =>
            Edit(req.State, data, inp => TypedResults.Ok(WeekPlanner.GetIngredientOptions(inp, req.Date, req.Slot, req.IngredientId))))
            .WithName("IngredientOptions").WithSummary("US-5.2: nguyên liệu cùng swap_group thay được (không vi phạm ràng buộc cứng, giữ protein bữa ±5%)");

        g.MapPost("/plans/swap-ingredient", Results<Ok<PlanResponse>, ValidationProblem> (SwapIngredientRequest req, Dataset data, DataInfo info) =>
            EditPlan(req.State, data, info, inp => WeekPlanner.SwapIngredient(inp, req.Date, req.Slot, req.FromIngredientId, req.ToIngredientId)))
            .WithName("SwapIngredient").WithSummary("US-5.2: đổi một nguyên liệu trong bữa, gram tính lại để giữ protein bữa trong ±5%");

        g.MapPost("/plans/eat-out", Results<Ok<PlanResponse>, ValidationProblem> (EatOutRequest req, Dataset data, DataInfo info) =>
            EditPlan(req.State, data, info, inp => WeekPlanner.MarkOut(inp, req.Date, req.Slot, req.Mode)))
            .WithName("EatOut").WithSummary("US-5.3: ăn ngoài / bỏ bữa / hoàn tác — ngày đó được miễn kiểm, bữa rút khỏi danh sách đi chợ");

        g.MapPost("/plans/regenerate-rest", Results<Ok<PlanResponse>, ValidationProblem> (RegenerateRestRequest req, Dataset data, DataInfo info) =>
            EditPlan(req.State, data, info, inp => WeekPlanner.RegenerateRest(inp, req.Today, req.Seed)))
            .WithName("RegenerateRest").WithSummary("US-5.5: giữ các ngày đã qua và hôm nay, lập lại các ngày sau (tôn trọng món bị chặn)");

        g.MapPost("/shopping-list", Results<Ok<ShoppingList>, ValidationProblem> (ShoppingListRequest req, Dataset data) =>
        {
            var e = new Errors();
            if (!data.StoresById.ContainsKey(req.StoreId)) e.Add("store_id", $"cửa hàng \"{req.StoreId}\" không tồn tại");
            if (req.Adults is < 1 or > 6) e.Add("adults", "phải trong khoảng 1–6");
            if (req.Children is < 0 or > 4) e.Add("children", "phải trong khoảng 0–4");
            for (var i = 0; i < req.Meals.Count; i++)
                for (var j = 0; j < req.Meals[i].Ingredients.Count; j++)
                {
                    var l = req.Meals[i].Ingredients[j];
                    var path = $"meals[{i}].ingredients[{j}]";
                    if (!data.IngredientsById.ContainsKey(l.IngredientId)) e.Add($"{path}.ingredient_id", $"nguyên liệu \"{l.IngredientId}\" không tồn tại");
                    if (!double.IsFinite(l.Grams) || l.Grams < 0) e.Add($"{path}.grams", "không được âm");
                    if (!double.IsFinite(l.StandardGrams) || l.StandardGrams < 0) e.Add($"{path}.standard_grams", "không được âm");
                }
            for (var i = 0; i < (req.PantryIds?.Count ?? 0); i++)
                if (!data.IngredientsById.ContainsKey(req.PantryIds![i])) e.Add($"pantry_ids[{i}]", $"nguyên liệu \"{req.PantryIds[i]}\" không tồn tại");
            if (e.Any) return TypedResults.ValidationProblem(e.ToDictionary());
            var meals = req.Meals.Where(m => !m.EatenOut)
                .Select(m => new ShoppingMeal { Ingredients = m.Ingredients.Select(l => new ShoppingIngredient(l.IngredientId, l.Grams, l.StandardGrams)).ToList() }).ToList();
            return TypedResults.Ok(Shopping.BuildShoppingList(meals, new Household(req.Adults, req.Children), data, req.StoreId, req.PantryIds, displayQty: true));
        }).WithName("BuildShoppingList").WithSummary("Tính lại danh sách đi chợ (stateless): nhà có sẵn, ăn ngoài");

        g.MapGet("/recipes/{id}", Results<Ok<RecipeDetailResponse>, NotFound<Microsoft.AspNetCore.Mvc.ProblemDetails>> (string id, Dataset data) =>
        {
            if (!data.RecipesById.TryGetValue(id, out var r))
                return TypedResults.NotFound(new Microsoft.AspNetCore.Mvc.ProblemDetails { Status = 404, Title = "Không tìm thấy công thức", Detail = $"Không có công thức \"{id}\"" });
            return TypedResults.Ok(new RecipeDetailResponse { Recipe = r, Macros = Nutrition.Compute(Nutrition.RecipeBaseLines(r), data.IngredientsById) });
        }).WithName("GetRecipe").WithSummary("Chi tiết công thức + macro khẩu phần chuẩn kèm nguồn");

        return app;
    }

    /// <summary>Chạy một thao tác chỉnh tuần: kiểm trạng thái gửi lên, dựng EditInput, đổi EditException thành 400 theo trường.</summary>
    private static Results<Ok<T>, ValidationProblem> Edit<T>(PlanStateDto? st, Dataset data, Func<EditInput, Ok<T>> run)
    {
        var e = new Errors();
        Validation.State(e, st, data);
        if (e.Any) return TypedResults.ValidationProblem(e.ToDictionary());
        var inp = new EditInput { Targets = TargetCalc.Compute(st!.Profile), Prefs = st.Preferences, Data = data, Plan = st.Plan, IncludeDessert = st.IncludeDessert };
        try { return run(inp); }
        catch (EditException x) { return TypedResults.ValidationProblem(new Dictionary<string, string[]> { [x.Field] = [x.Message] }); }
    }

    private static Results<Ok<PlanResponse>, ValidationProblem> EditPlan(PlanStateDto? st, Dataset data, DataInfo info, Func<EditInput, WeekPlan> run) =>
        Edit(st, data, inp =>
        {
            var plan = run(inp);
            var (recipes, ingredients) = BuildOfflineMaps(plan, data);
            return TypedResults.Ok(new PlanResponse { Targets = inp.Targets, Plan = plan, Trace = BuildTrace(plan, data), DataVersion = info.Version, Recipes = recipes, Ingredients = ingredients });
        });

    private static readonly string[] DislikeSuggestionIds = ["ca_tim", "dau_bap", "hanh_tay", "ca_thu", "muc_ong", "dau_phu", "nam_rom", "gia_do", "tom", "tempeh"];

    private static readonly Dictionary<string, string> AisleNames = new()
    {
        ["thit"] = "Thịt", ["ca_hai_san"] = "Cá & hải sản", ["trung_dau_phu"] = "Trứng & đậu phụ", ["rau_cu"] = "Rau củ",
        ["trai_cay"] = "Trái cây", ["gao_do_kho"] = "Gạo & đồ khô", ["gia_vi_dau"] = "Gia vị & dầu", ["sua"] = "Sữa",
    };

    /// <summary>D-ONB-03: chỉ 4 xu hướng sức khỏe chính thức hiện cho người dùng; thẻ nội bộ (giau_dam, omega3, chay, low_carb) không phải lựa chọn.</summary>
    private static readonly (string Id, string Name, string Description)[] HealthNames =
    [
        ("nhieu_xo", "Nhiều chất xơ", "Ưu tiên món có nhiều rau, đậu và ngũ cốc nguyên cám."),
        ("it_duong", "Ít đường", "Ưu tiên món không thêm đường và ít tinh bột."),
        ("tot_cho_tim", "Tốt cho tim mạch", "Ưu tiên món có cá béo, nhiều xơ và ít chiên ngập dầu."),
        ("it_beo", "Ít béo", "Ưu tiên món có ít chất béo trong tổng năng lượng."),
    ];

    /// <summary>Mỗi xu hướng chỉ được liệt kê khi có đủ món mang thẻ (≥ 10) để chọn nó thật sự có tác dụng.</summary>
    public const int MinRecipesPerLeaning = 10;

    public static IReadOnlyList<string> HealthWhitelist => HealthNames.Select(h => h.Id).ToArray();

    public static List<OptionDto> HealthLeanings(Dataset data)
    {
        var counts = data.Recipes.SelectMany(r => r.HealthTags).GroupBy(t => t).ToDictionary(g => g.Key, g => g.Count());
        return HealthNames.Where(h => counts.GetValueOrDefault(h.Id) >= MinRecipesPerLeaning)
            .Select(h => new OptionDto { Id = h.Id, Name = h.Name, Description = h.Description, Group = "health" }).ToList();
    }

    private static string BanDescription(Dataset data, Preferences p)
    {
        var names = Filter.BannedIngredients(data.Ingredients, p).Keys.Select(id => data.IngredientsById[id].Name).ToList();
        if (names.Count == 0) return "Không loại nguyên liệu nào trong kho hiện tại";
        var shown = string.Join(", ", names.Take(6));
        return names.Count > 6 ? $"Loại {names.Count} nguyên liệu: {shown}…" : $"Loại: {shown}";
    }

    private static IngredientDto ToDto(Ingredient i) => new() { Id = i.Id, Name = i.Name, Aisle = i.Aisle, HouseholdUnits = i.HouseholdUnits, DefaultPantry = i.DefaultPantry };

    /// <summary>Mọi công thức và nguyên liệu xuất hiện trong tuần để app xem offline.</summary>
    private static (Dictionary<string, Recipe>, Dictionary<string, IngredientInfoDto>) BuildOfflineMaps(WeekPlan plan, Dataset data)
    {
        var recipes = new Dictionary<string, Recipe>();
        var ingIds = new HashSet<string>();
        void AddRecipe(string? id)
        {
            if (id is null || recipes.ContainsKey(id) || !data.RecipesById.TryGetValue(id, out var r)) return;
            recipes[id] = r;
            foreach (var li in r.Ingredients) ingIds.Add(li.IngredientId);
        }
        foreach (var c in plan.MamRecipes) { recipes[c.Id] = c; foreach (var li in c.Ingredients) ingIds.Add(li.IngredientId); }
        foreach (var m in plan.Days.SelectMany(d => d.Meals).Where(m => m.Status == "planned"))
        {
            AddRecipe(m.RecipeId);
            AddRecipe(m.DessertId);
            foreach (var d in m.Dishes ?? []) { AddRecipe(d.RecipeId); foreach (var g in d.Grams) ingIds.Add(g.IngredientId); }
            foreach (var g in m.Grams.Concat(m.Extras).Concat(m.Dessert ?? [])) ingIds.Add(g.IngredientId);
            foreach (var s in m.Substitutions) { ingIds.Add(s.From); ingIds.Add(s.To); }
        }
        foreach (var i in plan.Shopping.Items) ingIds.Add(i.IngredientId);
        foreach (var id in ingIds.ToList())
            if (data.IngredientsById.TryGetValue(id, out var src) && src.PurchaseAs is { } pa) ingIds.Add(pa.IngredientId);
        var ingredients = ingIds.Where(data.IngredientsById.ContainsKey).OrderBy(x => x, StringComparer.Ordinal)
            .ToDictionary(id => id, id =>
            {
                var i = data.IngredientsById[id];
                return new IngredientInfoDto { Name = i.Name, Aisle = i.Aisle, HouseholdUnits = i.HouseholdUnits, DefaultPantry = i.DefaultPantry, PurchaseAs = i.PurchaseAs };
            });
        return (recipes, ingredients);
    }

    private static int Rank(Ingredient i, string key)
    {
        var name = TextFold.Fold(i.Name);
        if (name.StartsWith(key, StringComparison.Ordinal)) return 0;
        if (name.Split(' ').Any(w => w.StartsWith(key, StringComparison.Ordinal))) return 1;
        if (name.Contains(key, StringComparison.Ordinal)) return 2;
        if (i.Aliases.Any(a => TextFold.Fold(a).Contains(key, StringComparison.Ordinal))) return 3;
        return int.MaxValue;
    }

    private static List<MealTrace> BuildTrace(WeekPlan plan, Dataset data)
    {
        TraceLine Line(MacroLine l) => new() { IngredientId = l.IngredientId, Name = l.Name, Grams = l.Grams, Macros = l.Macros, Source = Nutrition.FormatSource(l.Source) };
        var res = new List<MealTrace>();
        foreach (var day in plan.Days)
            foreach (var m in day.Meals.Where(m => m.Status == "planned"))
            {
                var core = Nutrition.Compute(m.Grams, data.IngredientsById);
                var extras = Nutrition.Compute(m.Extras, data.IngredientsById);
                var dessert = Nutrition.Compute(m.Dessert ?? [], data.IngredientsById);
                res.Add(new MealTrace
                {
                    Date = m.Date, Slot = m.Slot, RecipeId = m.RecipeId!,
                    Lines = core.Lines.Select(Line).ToList(), Extras = extras.Lines.Select(Line).ToList(), Dessert = dessert.Lines.Select(Line).ToList(), Total = core.Total + extras.Total + dessert.Total,
                });
            }
        return res;
    }

    private static List<SwipeCardDto> LoadSwipeCards(string? contentDir)
    {
        if (contentDir is null) return [];
        var path = Path.Combine(contentDir, "swipe-cards.json");
        if (!File.Exists(path)) return [];
        try { return JsonSerializer.Deserialize<List<SwipeCardDto>>(File.ReadAllText(path), JsonOptions.Default) ?? []; }
        catch (JsonException) { return []; }
    }
}
