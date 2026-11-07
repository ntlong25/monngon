using System.Globalization;
using System.Text.Json;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

// T-067 — Thay đổi tuần đã lập (US-5.1…5.5). Mọi thao tác là hàm thuần: nhận tuần hiện tại, trả tuần mới (validator + đi chợ chạy lại).

/// <summary>Lỗi nghiệp vụ khi chỉnh tuần (đầu vào không hợp lệ, thay thế không được phép…). <see cref="Field"/> là đường dẫn trường để API trả 400.</summary>
public sealed class EditException(string field, string message) : Exception(message)
{
    public string Field { get; } = field;
}

public sealed class EditInput
{
    public required Targets Targets { get; init; }
    public required Preferences Prefs { get; init; }
    public required Dataset Data { get; init; }
    /// <summary>Tuần hiện tại do máy khách gửi lên (stateless).</summary>
    public required WeekPlan Plan { get; init; }
    public bool IncludeDessert { get; init; } = true;
}

public sealed record SwapDish(string Role, string RecipeId, string Name);

public sealed class SwapSuggestion
{
    public required string RecipeId { get; init; }
    public required string Name { get; init; }
    public required List<SwapDish> Dishes { get; init; }
    /// <summary>Macro cả bữa sau khi đổi (đã gồm tráng miệng/món thêm), chưa làm tròn.</summary>
    public required Macros Macros { get; init; }
    public required double DeltaProteinG { get; init; }
    public required double DeltaKcal { get; init; }
    /// <summary>Chênh lệch chi phí món ăn (cả nhà, theo gram dùng).</summary>
    public required double DeltaCostVnd { get; init; }
    /// <summary>Ngày đó vẫn đạt (hoặc được miễn vì có bữa ngoài) sau khi đổi.</summary>
    public required bool KeepsDayOk { get; init; }
    public required double DayProteinG { get; init; }
    public required double DayKcal { get; init; }
}

public sealed class SwapSuggestions
{
    public required string Date { get; init; }
    public required string Slot { get; init; }
    public required string CurrentRecipeId { get; init; }
    /// <summary>true = mọi gợi ý đều giữ ngày đạt. false = không món nào giữ được; các gợi ý là món "gần đạt nhất" và cần cảnh báo.</summary>
    public required bool AnyKeepsDay { get; init; }
    public required List<SwapSuggestion> Items { get; init; }
    public required Dictionary<string, Recipe> Recipes { get; init; }
}

public sealed class IngredientOption
{
    public required string IngredientId { get; init; }
    public required string Name { get; init; }
    /// <summary>Gram của nguyên liệu này trong bữa sau khi tính lại.</summary>
    public required double Grams { get; init; }
    public required double DeltaProteinG { get; init; }
    public required double DeltaKcal { get; init; }
    public required double DeltaCostVnd { get; init; }
    public required bool KeepsDayOk { get; init; }
}

public sealed class IngredientOptions
{
    public required string Date { get; init; }
    public required string Slot { get; init; }
    public required string IngredientId { get; init; }
    public required string SwapGroup { get; init; }
    public required List<IngredientOption> Options { get; init; }
}

public static partial class WeekPlanner
{
    /// <summary>US-5.2 AC2: protein cả bữa sau khi đổi nguyên liệu phải nằm trong ±5% so với trước.</summary>
    public const double IngredientSwapProteinTol = 0.05;

    private static Planner ForEdit(EditInput inp)
    {
        var plan = inp.Plan ?? throw new EditException("plan", "bắt buộc");
        if (plan.Days.Count == 0) throw new EditException("plan.days", "tuần phải có ít nhất 1 ngày");
        if (!DateOnly.TryParseExact(plan.StartDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _))
            throw new EditException("plan.start_date", "phải có dạng YYYY-MM-DD");
        MealStyle style;
        if (plan.MealStyle is null) style = MealStyle.FullMealOnly;
        else if (!MealStyles.TryParse(plan.MealStyle, out style)) throw new EditException("plan.meal_style", $"giá trị \"{plan.MealStyle}\" không hợp lệ");
        var legacy = plan.Days.SelectMany(d => d.Meals).Select(m => m.RecipeId).OfType<string>().Where(id => id.StartsWith(MamBuilder.IdPrefix, StringComparison.Ordinal));
        return new Planner(new PlanWeekInput
        {
            Targets = inp.Targets, Prefs = inp.Prefs, Data = inp.Data, StartDate = plan.StartDate, Seed = plan.Seed,
            Options = new PlanOptions { MealStyle = style, IncludeDessert = inp.IncludeDessert, Days = plan.Days.Count },
        }, legacy);
    }

    /// <summary>US-5.1 AC1: 2–3 món cùng loại bữa, kèm chênh lệch protein/kcal/chi phí; chỉ món giữ ngày đạt (nếu không có thì món gần đạt nhất, đánh dấu).</summary>
    public static SwapSuggestions SuggestSwaps(EditInput inp, string date, string slot, int limit = 3)
    {
        var p = ForEdit(inp);
        return p.SuggestSwaps(p.Load(inp.Plan), date, slot, Math.Clamp(limit, 1, 5));
    }

    /// <summary>Đổi bữa sang <paramref name="recipeId"/> (công thức trọn suất hoặc mâm "mam:…" hợp lệ cho bữa đó), tính lại gram để ngày đạt chỉ tiêu.</summary>
    public static WeekPlan ApplySwap(EditInput inp, string date, string slot, string recipeId)
    {
        var p = ForEdit(inp);
        return p.ApplySwap(inp.Plan, p.Load(inp.Plan), date, slot, recipeId);
    }

    /// <summary>US-5.2 AC1: nguyên liệu cùng swap_group (không bị cấm) có thể thay cho <paramref name="ingredientId"/>, chỉ những lựa chọn giữ protein bữa trong ±5%.</summary>
    public static IngredientOptions GetIngredientOptions(EditInput inp, string date, string slot, string ingredientId)
    {
        var p = ForEdit(inp);
        return p.ListIngredientOptions(p.Load(inp.Plan), date, slot, ingredientId);
    }

    public static WeekPlan SwapIngredient(EditInput inp, string date, string slot, string fromId, string toId)
    {
        var p = ForEdit(inp);
        return p.SwapIngredient(inp.Plan, p.Load(inp.Plan), date, slot, fromId, toId);
    }

    /// <summary>US-5.3: mode = eat_out | skip | undo. Bữa được đánh dấu rút khỏi đi chợ, ngày đó được miễn kiểm; các bữa khác giữ nguyên.</summary>
    public static WeekPlan MarkOut(EditInput inp, string date, string slot, string mode)
    {
        var p = ForEdit(inp);
        return p.MarkOut(inp.Plan, p.Load(inp.Plan), date, slot, mode);
    }

    /// <summary>US-5.5: giữ nguyên các ngày ≤ <paramref name="today"/>, lập lại các ngày sau (ngân sách còn lại = ngân sách tuần trừ chi phí các ngày giữ).</summary>
    public static WeekPlan RegenerateRest(EditInput inp, string today, long? seed = null)
    {
        if (!DateOnly.TryParseExact(today ?? "", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _))
            throw new EditException("today", "phải có dạng YYYY-MM-DD");
        var p = ForEdit(inp);
        return p.RegenerateRest(inp.Plan, p.Load(inp.Plan), today!, seed);
    }

    internal sealed class EditSpec
    {
        public HashSet<string> BatchRecipeIds { get; init; } = [];
        public List<PlanMeal> Changed { get; init; } = [];
        public List<string> UnfilledSlots { get; init; } = [];
        public List<string>? Relaxed { get; init; }
    }

    private sealed partial class Planner
    {
        private static readonly string[] Statuses = ["planned", "self", "unfilled", "eaten_out", "skipped"];

        /// <summary>Sao chép sâu tuần cũ thành danh sách bữa theo ngày, kiểm cấu trúc (ngày liên tiếp, số dòng gram khớp công thức…).</summary>
        internal List<List<PlanMeal>> Load(WeekPlan plan)
        {
            if (plan.Days.Count != _dates.Count) throw new EditException("plan.days", $"cần {_dates.Count} ngày");
            var res = new List<List<PlanMeal>>();
            for (var di = 0; di < plan.Days.Count; di++)
            {
                var day = plan.Days[di];
                if (day.Date != _dates[di]) throw new EditException($"plan.days[{di}].date", $"phải là {_dates[di]}");
                var dm = new List<PlanMeal>();
                for (var mi = 0; mi < day.Meals.Count; mi++)
                {
                    var m = day.Meals[mi].Clone();
                    var path = $"plan.days[{di}].meals[{mi}]";
                    if (m.Date != day.Date) throw new EditException($"{path}.date", $"phải là {day.Date}");
                    if (!Enums.Slots.Contains(m.Slot)) throw new EditException($"{path}.slot", $"bữa \"{m.Slot}\" không hợp lệ");
                    if (!Statuses.Contains(m.Status)) throw new EditException($"{path}.status", $"trạng thái \"{m.Status}\" không hợp lệ");
                    if (m.Status == "planned" && m.RecipeId is null) throw new EditException($"{path}.recipe_id", "bữa đã lên thực đơn cần có công thức");
                    if (m.RecipeId is not null) CheckLines(m, path);
                    dm.Add(m);
                }
                res.Add(dm);
            }
            return res;
        }

        private void CheckLines(PlanMeal m, string path)
        {
            if (!_data.RecipesById.TryGetValue(m.RecipeId!, out var r))
                throw new EditException($"{path}.recipe_id", $"công thức \"{m.RecipeId}\" không còn trong dữ liệu hiện tại");
            if (m.Grams.Count != r.Ingredients.Count || m.StandardGrams.Count != r.Ingredients.Count)
                throw new EditException($"{path}.grams", $"số dòng nguyên liệu không khớp công thức \"{r.Id}\" ({r.Ingredients.Count})");
            foreach (var g in m.Grams.Concat(m.StandardGrams).Concat(m.Extras).Concat(m.Dessert ?? []))
            {
                if (!_data.IngredientsById.ContainsKey(g.IngredientId)) throw new EditException($"{path}.grams", $"nguyên liệu \"{g.IngredientId}\" không tồn tại");
                if (!double.IsFinite(g.Grams) || g.Grams < 0) throw new EditException($"{path}.grams", "gram không được âm");
            }
            if (m.DessertId is not null)
            {
                if (!_data.RecipesById.TryGetValue(m.DessertId, out var dr)) throw new EditException($"{path}.dessert_id", $"công thức \"{m.DessertId}\" không tồn tại");
                if (m.Dessert is null || m.Dessert.Count != dr.Ingredients.Count) throw new EditException($"{path}.dessert", "số dòng nguyên liệu không khớp món tráng miệng");
            }
        }

        private (int Day, PlanMeal Meal) Find(List<List<PlanMeal>> meals, string date, string slot)
        {
            var di = _dates.IndexOf(date);
            if (di < 0) throw new EditException("date", $"ngày \"{date}\" không nằm trong tuần");
            if (!Enums.Slots.Contains(slot)) throw new EditException("slot", $"bữa \"{slot}\" không hợp lệ");
            var m = meals[di].FirstOrDefault(x => x.Slot == slot) ?? throw new EditException("slot", $"ngày {date} không có bữa \"{slot}\"");
            return (di, m);
        }

        private (int Day, PlanMeal Meal) FindPlanned(List<List<PlanMeal>> meals, string date, string slot)
        {
            var (di, m) = Find(meals, date, slot);
            if (m.Status != "planned") throw new EditException("slot", m.Status is "eaten_out" or "skipped" ? "bữa này đang đánh dấu ăn ngoài/bỏ bữa, hãy hoàn tác trước" : "bữa này không có món do app lên thực đơn");
            return (di, m);
        }

        private bool IsMam(PlanMeal m) => m.RecipeId is not null && _mam.ContainsKey(m.RecipeId);

        private double Viol(DayTotals t) =>
            Math.Max(0, _targets.ProteinG - t.ProteinG) * 4 + Math.Max(0, _targets.KcalMin - t.Kcal) + Math.Max(0, t.Kcal - _targets.KcalMax);

        private double MealCostVnd(PlanMeal m)
        {
            double Cost(IEnumerable<GramLine> g) => Shopping.ServingCostVnd(g, _data, _prefs.StoreId, Pa);
            var c = Cost(m.Grams) + _others * Cost(m.StandardGrams) + Cost(m.Extras);
            if (m.DessertId is not null && m.Dessert is not null)
                c += Cost(m.Dessert) + _others * Cost(_data.RecipesById[m.DessertId].Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)));
            return c;
        }

        private WeekPlan FinalizeEdit(List<List<PlanMeal>> meals, WeekPlan old, IEnumerable<PlanMeal> changed, IEnumerable<string?> batchRecipeIds) =>
            Finalize(meals, old.Iterations, old.Repairs, new EditSpec
            {
                Changed = [.. changed], BatchRecipeIds = batchRecipeIds.OfType<string>().ToHashSet(),
                UnfilledSlots = [.. old.UnfilledSlots], Relaxed = old.RelaxedPreferences is null ? null : [.. old.RelaxedPreferences],
            });

        // ------------------------------------------------------------------------------------------------
        // US-5.1 — đổi món

        private sealed record SwapTrial(PlanMeal Meal, DayTotals Day, bool DayOk, double Viol);

        /// <summary>
        /// Thử đặt <paramref name="cand"/> vào bữa <paramref name="cur"/>: giữ tráng miệng, giữ món đạm phụ (bỏ cơm phụ nếu mâm đã có cơm / ít tinh bột),
        /// scale để lấp đúng khoảng thiếu của ngày (chỉ bữa này đổi; các bữa khác giữ nguyên), rồi chỉnh tinh ±5 g trên chính bữa này.
        /// </summary>
        private SwapTrial TrialSwap(List<PlanMeal> day, PlanMeal cur, ValidRecipe cand)
        {
            var ot = DayTot(day.Where(x => !ReferenceEquals(x, cur)));
            var dessertM = DessertMacros(cur);
            var carbBlocked = cand.ForceZeroCarb || (_mam.TryGetValue(cand.Recipe.Id, out var ci) && ci.HasCarbBase);
            var extras = cur.Extras.Where(e => !(carbBlocked && e.IngredientId == _extrasPick.Carb)).Select(e => e.Clone()).ToList();
            var exM = extras.Count > 0 ? Nutrition.Compute(extras, _data.IngredientsById).Total : Macros.Zero;
            var goalK = _kMid - ot.Kcal - dessertM.Kcal - exM.Kcal;
            var goalP = _pGoal - ot.ProteinG - dessertM.ProteinG - exM.ProteinG;
            var sc = ScaleMeal(cand.Recipe, new ScaleTarget(Math.Max(0, goalK), Math.Max(0, goalP)), cand.ForceZeroCarb, out var riceWhy, out _);
            var meal = MakeMeal(cur.Date, cur.Slot, cand.Recipe, cand.ForceZeroCarb, sc);
            meal.RiceReason = riceWhy;
            meal.Extras = extras;
            meal.DessertId = cur.DessertId;
            meal.Dessert = cur.Dessert?.Select(g => g.Clone()).ToList();
            meal.Warnings = cur.Warnings;
            meal.Macros = sc.Macros + exM + dessertM;
            var trialDay = day.Select(x => ReferenceEquals(x, cur) ? meal : x).ToList();
            PolishDay(trialDay, [meal]);
            // D-COM-01: đổi món giữ mức cơm người dùng chọn; chỉ khi ngày không đạt mới bớt cơm của chính bữa này (kèm ghi chú).
            if (!DayOk(DayTot(trialDay).Kcal, DayTot(trialDay).ProteinG)) RescueDayWithRice(trialDay, [meal]);
            var tot = DayTot(trialDay);
            return new SwapTrial(meal, tot, DayOk(tot.Kcal, tot.ProteinG), Viol(tot));
        }

        private List<SwapDish> DishesOf(Recipe r) =>
            _mam.TryGetValue(r.Id, out var info)
                ? info.Parts.Select(p => new SwapDish(p.Role, p.Recipe.Id, p.Recipe.Name)).ToList()
                : [new SwapDish("full_meal", r.Id, r.Name)];

        internal SwapSuggestions SuggestSwaps(List<List<PlanMeal>> meals, string date, string slot, int limit)
        {
            var (di, cur) = FindPlanned(meals, date, slot);
            if (!_slotCtx.TryGetValue(slot, out var sc)) throw new EditException("slot", $"bữa \"{slot}\" không được lên thực đơn");
            var day = meals[di];
            var exempt = day.Any(IsOut);

            var sameDay = day.Where(x => !ReferenceEquals(x, cur) && x.RecipeId is not null).Select(x => x.RecipeId!).ToHashSet();
            var otherMains = day.Where(x => !ReferenceEquals(x, cur) && IsMam(x)).Select(x => _mam[x.RecipeId!].MainId).ToHashSet();
            var curMain = IsMam(cur) ? _mam[cur.RecipeId!].MainId : null;
            var weekMeals = meals.SelectMany(d => d).Where(x => x.Status == "planned" && x.RecipeId is not null && !ReferenceEquals(x, cur)).ToList();
            var uses = weekMeals.GroupBy(x => x.RecipeId!).ToDictionary(g => g.Key, g => g.Count());
            var soupUses = new Dictionary<string, int>();
            foreach (var x in weekMeals)
                if (IsMam(x) && _mam[x.RecipeId!].SoupId is { } sid) soupUses[sid] = soupUses.GetValueOrDefault(sid) + 1;
            var recentMain = meals.SelectMany(d => d).TakeWhile(x => !ReferenceEquals(x, cur))
                .Where(x => GroupOf(x.Slot) == "main" && x.Status == "planned" && x.RecipeId is not null)
                .Select(x => Score.MainProteinId(_data.RecipesById[x.RecipeId!]) ?? "").ToList();

            var mainGroup = GroupOf(slot) == "main";
            var curIsMam = IsMam(cur);
            var pre = sc.Cands
                .Where(c => c.Recipe.Id != cur.RecipeId && !(mainGroup && sameDay.Contains(c.Recipe.Id)))
                .Where(c => !_mam.TryGetValue(c.Recipe.Id, out var ci) ||
                    (!otherMains.Contains(ci.MainId) && ci.MainId != curMain && (ci.SoupId is null || soupUses.GetValueOrDefault(ci.SoupId) < _opt.MaxSoupUses)))
                .Select(c =>
                {
                    var ctx = new ScoreContext
                    {
                        CuisineLikes = _prefs.CuisineLikes, CuisineLess = _prefs.CuisineLess, HealthLeanings = _prefs.HealthLeanings,
                        CostVnd = CostOf(c.Recipe), CostReferenceVnd = _costRef, UsesThisWeek = uses.GetValueOrDefault(c.Recipe.Id),
                        SameDayRecipeIds = [.. sameDay], RecentMainProteins = mainGroup ? recentMain : [],
                    };
                    // Ưu tiên cùng kiểu với bữa hiện tại (mâm ↔ mâm, trọn suất ↔ trọn suất) để gợi ý giống thứ người dùng đang có.
                    return (c, s: Score.Total(c.Recipe, ctx, _opt.ScoreWeights) + (_mam.ContainsKey(c.Recipe.Id) == curIsMam ? 1.0 : 0));
                })
                .OrderByDescending(x => x.s).ThenBy(x => x.c.Recipe.Id, StringComparer.Ordinal)
                .Take(36).ToList();

            var curCost = MealCostVnd(cur);
            var evaluated = pre.Select(x => (x.c, x.s, t: TrialSwap(day, cur, x.c))).ToList();
            var keep = evaluated.Where(e => e.t.DayOk || exempt).ToList();
            var any = keep.Count > 0;
            var pool = any
                ? keep.OrderByDescending(e => e.s).ThenBy(e => e.t.Viol).ThenBy(e => e.c.Recipe.Id, StringComparer.Ordinal).ToList()
                : evaluated.OrderBy(e => e.t.Viol).ThenByDescending(e => e.s).ThenBy(e => e.c.Recipe.Id, StringComparer.Ordinal).ToList();

            // Đa dạng: ưu tiên mỗi gợi ý một đạm chính khác nhau, thiếu thì bù theo thứ tự điểm.
            var picked = new List<(ValidRecipe c, double s, SwapTrial t)>();
            var proteins = new HashSet<string>();
            foreach (var e in pool)
            {
                if (picked.Count >= limit) break;
                if (proteins.Add(Score.MainProteinId(e.c.Recipe) ?? e.c.Recipe.Id)) picked.Add(e);
            }
            foreach (var e in pool)
            {
                if (picked.Count >= limit) break;
                if (!picked.Any(x => x.c.Recipe.Id == e.c.Recipe.Id)) picked.Add(e);
            }

            var recipes = new Dictionary<string, Recipe> { [cur.RecipeId!] = _data.RecipesById[cur.RecipeId!] };
            var items = new List<SwapSuggestion>();
            foreach (var (c, _, t) in picked)
            {
                recipes[c.Recipe.Id] = c.Recipe;
                if (_mam.TryGetValue(c.Recipe.Id, out var info)) foreach (var part in info.Parts) recipes[part.Recipe.Id] = part.Recipe;
                items.Add(new SwapSuggestion
                {
                    RecipeId = c.Recipe.Id, Name = c.Recipe.Name, Dishes = DishesOf(c.Recipe), Macros = t.Meal.Macros,
                    DeltaProteinG = t.Meal.Macros.ProteinG - cur.Macros.ProteinG, DeltaKcal = t.Meal.Macros.Kcal - cur.Macros.Kcal,
                    DeltaCostVnd = MealCostVnd(t.Meal) - curCost, KeepsDayOk = t.DayOk || exempt,
                    DayProteinG = t.Day.ProteinG, DayKcal = t.Day.Kcal,
                });
            }
            return new SwapSuggestions { Date = date, Slot = slot, CurrentRecipeId = cur.RecipeId!, AnyKeepsDay = any, Items = items, Recipes = recipes };
        }

        internal WeekPlan ApplySwap(WeekPlan old, List<List<PlanMeal>> meals, string date, string slot, string recipeId)
        {
            var (di, cur) = FindPlanned(meals, date, slot);
            if (recipeId == cur.RecipeId) throw new EditException("recipe_id", "đang là món của bữa này");
            var cand = _slotCtx.TryGetValue(slot, out var sc) ? sc.Cands.FirstOrDefault(c => c.Recipe.Id == recipeId) : null;
            if (cand is null) throw new EditException("recipe_id", $"\"{recipeId}\" không hợp lệ cho bữa này (không đúng loại bữa hoặc vi phạm ràng buộc cứng)");
            var oldId = cur.RecipeId;
            var t = TrialSwap(meals[di], cur, cand);
            cur.CopyFrom(t.Meal);
            cur.Substitutions = [];
            return FinalizeEdit(meals, old, [cur], [oldId, recipeId]);
        }

        // ------------------------------------------------------------------------------------------------
        // US-5.2 — đổi một nguyên liệu

        private sealed record IngredientTrial(PlanMeal Meal, bool ProteinOk, double DayKcal, bool DayOk);

        private IngredientTrial TrialIngredient(List<PlanMeal> day, PlanMeal cur, int idx, string newId)
        {
            var baseRecipe = _data.RecipesById[cur.RecipeId!];
            double Round5(double x) => Math.Max(5, Math.Round(x / 5, MidpointRounding.AwayFromZero) * 5);
            // Đổi sang nguyên liệu khác mật độ đạm/calo thì khoảng gram của dòng đó co/giãn tương ứng (đạm theo protein/100 g, tinh bột theo kcal/100 g).
            double Ratio(RecipeIngredient li, string toId)
            {
                if (toId == li.IngredientId || li.Role is not ("protein" or "carb")) return 1;
                double Dens(Ingredient i) => li.Role == "protein" ? i.Per100g.ProteinG : i.Per100g.Kcal;
                var a = Dens(_data.IngredientsById[li.IngredientId]);
                var b = Dens(_data.IngredientsById[toId]);
                return a > 0 && b > 0 ? Math.Clamp(a / b, 0.25, 4) : 1;
            }
            var ings = new List<RecipeIngredient>();
            for (var j = 0; j < baseRecipe.Ingredients.Count; j++)
            {
                var x = baseRecipe.Ingredients[j];
                var id = j == idx ? newId : cur.Grams[j].IngredientId;
                var r = Ratio(x, id);
                if (r == 1) { ings.Add(new RecipeIngredient { IngredientId = id, Grams = x.Grams, Role = x.Role, MinG = x.MinG, MaxG = x.MaxG, SwapGroup = x.SwapGroup, RiceTargetG = x.RiceTargetG, RiceFloorG = x.RiceFloorG }); continue; }
                var g = Round5(x.Grams * r);
                var scalable = x.MinG < x.MaxG;
                ings.Add(new RecipeIngredient
                {
                    IngredientId = id, Grams = g, Role = x.Role, SwapGroup = x.SwapGroup,
                    MinG = scalable ? Math.Min(g, x.MinG == 0 ? 0 : Round5(x.MinG * r)) : g,
                    MaxG = scalable ? Math.Max(g, Round5(x.MaxG * r)) : g,
                    RiceTargetG = x.RiceTargetG, RiceFloorG = x.RiceFloorG,
                });
            }
            var alt = baseRecipe.WithIngredients(ings);
            var exM = ExtrasMacros(cur);
            var core = cur.Macros - exM;
            var res = Scaler.Scale(alt, _data.IngredientsById, new ScaleTarget(core.Kcal, core.ProteinG), ScaleOpts(cur));
            var meal = cur.Clone();
            meal.Grams = res.Grams;
            meal.StandardGrams = ings.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList();
            var origId = baseRecipe.Ingredients[idx].IngredientId;
            var curId = cur.Grams[idx].IngredientId;
            var subs = cur.Substitutions.Where(s => s.To != curId).ToList();
            if (newId != origId) subs.Add(new Substitution(origId, newId));
            meal.Substitutions = subs;
            meal.Macros = res.Macros + exM;
            meal.ScaleInfeasible = res.Infeasible;
            var tot = DayTot(day.Select(x => ReferenceEquals(x, cur) ? meal : x));
            var pOk = cur.Macros.ProteinG <= 0 || Math.Abs(meal.Macros.ProteinG - cur.Macros.ProteinG) <= IngredientSwapProteinTol * cur.Macros.ProteinG + 1e-9;
            return new IngredientTrial(meal, pOk, tot.Kcal, DayOk(tot.Kcal, tot.ProteinG) || day.Any(IsOut));
        }

        private (int Day, PlanMeal Meal, int Idx, RecipeIngredient Line) FindLine(List<List<PlanMeal>> meals, string date, string slot, string ingredientId)
        {
            var (di, cur) = FindPlanned(meals, date, slot);
            var lines = _data.RecipesById[cur.RecipeId!].Ingredients;
            var idxs = Enumerable.Range(0, cur.Grams.Count).Where(i => cur.Grams[i].IngredientId == ingredientId).ToList();
            if (idxs.Count == 0) throw new EditException("ingredient_id", $"bữa này không dùng nguyên liệu \"{ingredientId}\"");
            // Cùng một nguyên liệu có thể xuất hiện ở nhiều dòng (vd nhiều món trong mâm): lấy dòng đầu tiên có nhóm thay thế.
            var idx = idxs.FirstOrDefault(i => !string.IsNullOrEmpty(lines[i].SwapGroup), -1);
            if (idx < 0) throw new EditException("ingredient_id", "nguyên liệu này không có nhóm thay thế");
            return (di, cur, idx, lines[idx]);
        }

        internal IngredientOptions ListIngredientOptions(List<List<PlanMeal>> meals, string date, string slot, string ingredientId)
        {
            var (di, cur, idx, line) = FindLine(meals, date, slot, ingredientId);
            var pool = BuildSwapPool(_data, _banned).GetValueOrDefault($"{line.SwapGroup}|{line.Role}") ?? [];
            var curCost = MealCostVnd(cur);
            var options = new List<IngredientOption>();
            foreach (var id in pool)
            {
                if (id == ingredientId) continue;
                var t = TrialIngredient(meals[di], cur, idx, id);
                if (!t.ProteinOk) continue;
                options.Add(new IngredientOption
                {
                    IngredientId = id, Name = _data.IngredientsById[id].Name, Grams = t.Meal.Grams[idx].Grams,
                    DeltaProteinG = t.Meal.Macros.ProteinG - cur.Macros.ProteinG, DeltaKcal = t.Meal.Macros.Kcal - cur.Macros.Kcal,
                    DeltaCostVnd = MealCostVnd(t.Meal) - curCost, KeepsDayOk = t.DayOk,
                });
            }
            options = options.OrderBy(o => Math.Abs(o.DeltaProteinG)).ThenBy(o => o.DeltaCostVnd).ThenBy(o => o.IngredientId, StringComparer.Ordinal).Take(8).ToList();
            return new IngredientOptions { Date = date, Slot = slot, IngredientId = ingredientId, SwapGroup = line.SwapGroup!, Options = options };
        }

        internal WeekPlan SwapIngredient(WeekPlan old, List<List<PlanMeal>> meals, string date, string slot, string fromId, string toId)
        {
            var (di, cur, idx, line) = FindLine(meals, date, slot, fromId);
            if (toId == fromId) throw new EditException("to_ingredient_id", "trùng nguyên liệu hiện tại");
            var pool = BuildSwapPool(_data, _banned).GetValueOrDefault($"{line.SwapGroup}|{line.Role}") ?? [];
            if (!pool.Contains(toId)) throw new EditException("to_ingredient_id", $"\"{toId}\" không cùng nhóm thay thế \"{line.SwapGroup}\" hoặc vi phạm ràng buộc cứng");
            var t = TrialIngredient(meals[di], cur, idx, toId);
            if (!t.ProteinOk) throw new EditException("to_ingredient_id", $"đổi sang \"{toId}\" làm lệch protein của bữa quá ±{IngredientSwapProteinTol * 100:0}%");
            cur.CopyFrom(t.Meal);
            return FinalizeEdit(meals, old, [cur], []);
        }

        // ------------------------------------------------------------------------------------------------
        // US-5.3 — ăn ngoài / bỏ bữa

        internal WeekPlan MarkOut(WeekPlan old, List<List<PlanMeal>> meals, string date, string slot, string mode)
        {
            var (_, m) = Find(meals, date, slot);
            switch (mode)
            {
                case "eat_out" or "skip":
                    if (m.Status is not ("planned" or "eaten_out" or "skipped")) throw new EditException("slot", "chỉ đánh dấu được bữa do app lên thực đơn");
                    m.Status = mode == "eat_out" ? "eaten_out" : "skipped";
                    break;
                case "undo":
                    if (!IsOut(m)) throw new EditException("slot", "bữa này không đang đánh dấu ăn ngoài/bỏ bữa");
                    m.Status = "planned";
                    break;
                default:
                    throw new EditException("mode", $"giá trị \"{mode}\" không hợp lệ (một trong: eat_out, skip, undo)");
            }
            return FinalizeEdit(meals, old, [], []);
        }

        // ------------------------------------------------------------------------------------------------
        // US-5.5 — lên lại phần còn lại của tuần

        internal WeekPlan RegenerateRest(WeekPlan old, List<List<PlanMeal>> meals, string today, long? seed)
        {
            var n = _dates.Count;
            var keep = _dates.Count(d => string.CompareOrdinal(d, today) <= 0);
            if (keep >= n) throw new EditException("today", "không còn ngày nào sau hôm nay để lên lại");
            var remain = n - keep;
            var kept = meals.Take(keep).ToList();

            // Chi phí món ăn tính theo gram dùng nên cộng được theo ngày: ngân sách còn lại = ngân sách tuần − chi phí các ngày giữ (sàn 50% phần chia đều).
            var keptCost = ShoppingOf(kept).Items.Sum(i => i.UsedCostVnd);
            var budget = Math.Max(_prefs.WeeklyBudgetVnd * remain / n * 0.5, _prefs.WeeklyBudgetVnd - keptCost);
            var prefs = JsonSerializer.Deserialize<Preferences>(JsonSerializer.Serialize(_prefs, JsonOptions.Default), JsonOptions.Default)!;
            prefs.WeeklyBudgetVnd = budget;

            var sub = Plan(new PlanWeekInput
            {
                Targets = _targets, Prefs = prefs, Data = _input.Data, StartDate = _dates[keep], Seed = seed ?? old.Seed + 1,
                Options = new PlanOptions { MealStyle = _style, IncludeDessert = _opt.IncludeDessert, Days = remain },
            });

            var fresh = sub.Days.Select(d => d.Meals).ToList();
            for (var i = 0; i < fresh.Count; i++)
            {
                // Bữa ăn ngoài/bỏ bữa đã đánh dấu cho các ngày sau vẫn giữ nguyên ý định sau khi lên lại.
                foreach (var om in old.Days[keep + i].Meals.Where(IsOut))
                {
                    var nm = fresh[i].FirstOrDefault(x => x.Slot == om.Slot && x.Status == "planned");
                    if (nm is not null) nm.Status = om.Status;
                }
                // Mã nhóm nấu chung của phần mới không được trùng mã của các ngày giữ lại.
                foreach (var m in fresh[i].Where(x => x.BatchGroupId is not null)) m.BatchGroupId += $"@{_dates[keep]}";
            }

            var merged = kept.Concat(fresh).ToList();
            return Finalize(merged, sub.Iterations, 0, new EditSpec
            {
                UnfilledSlots = old.UnfilledSlots.Union(sub.UnfilledSlots).ToList(),
                Relaxed = sub.RelaxedPreferences,
            });
        }
    }
}
