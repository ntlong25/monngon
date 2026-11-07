using System.Globalization;
using System.Text.Json.Serialization;
using MonNgon.Engine.Data;
using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed record PlanOptions
{
    public int MaxIterations { get; init; } = 12;
    /// <summary>Số món chính (trưa+tối) khác nhau mong muốn; ~10–12 cho 14 bữa (US-2.3).</summary>
    public int DistinctMain { get; init; } = 11;
    public int DistinctBreakfast { get; init; } = 3;
    public int DistinctSnack { get; init; } = 3;
    /// <summary>Nhắm protein cao hơn sàn một chút để bù làm tròn 5 g.</summary>
    public double ProteinMargin { get; init; } = 1.02;
    public int RefinePasses { get; init; } = 5;
    public ScoreWeights ScoreWeights { get; init; } = new();
    public int Days { get; init; } = 7;
    /// <summary>Dung sai khi xếp hạng món vào nhóm (chỉ để chọn).</summary>
    public double PoolProteinTolG { get; init; } = 8;
    public double PoolKcalTolPct { get; init; } = 0.12;
    /// <summary>Món phụ (cơm/đạm) ghép vào bữa chính khi cả ngày thiếu calo/protein sau khi scale.</summary>
    public bool Extras { get; init; } = true;
    public double ExtraCarbMaxG { get; init; } = 300;
    public double ExtraProteinMaxG { get; init; } = 150;
    /// <summary>Sửa ngân sách bằng đổi món/nguyên liệu rẻ hơn.</summary>
    public bool BudgetRepair { get; init; } = true;
    public int RepairIterations { get; init; } = 30;
    public int RepairMealsPerIter { get; init; } = 10;
    public int RepairRecipeAlts { get; init; } = 8;
    /// <summary>T-066. Mặc định auto: trưa/tối là trọn suất hoặc mâm ghép. full_meal_only = hành vi parity T-064.</summary>
    public MealStyle MealStyle { get; init; } = MealStyle.Auto;
    /// <summary>Số biến thể (canh/rau/cơm khác nhau) tạo cho mỗi món chính.</summary>
    public int MamVariants { get; init; } = 5;
    /// <summary>Tỉ lệ ô trong nhóm món trưa/tối dành cho mâm (chế độ auto).</summary>
    public double MamPoolRatio { get; init; } = 0.95;
    /// <summary>Mỗi món chính tối đa bao nhiêu biến thể cùng vào nhóm món của tuần.</summary>
    public int MamPerMainInPool { get; init; } = 3;
    /// <summary>Một món canh tối đa bao nhiêu lần/tuần.</summary>
    public int MaxSoupUses { get; init; } = 2;
    /// <summary>D-DES-01: thêm món tráng miệng vào bữa trưa/tối (chỉ có tác dụng khi meal_style ≠ full_meal_only).</summary>
    public bool IncludeDessert { get; init; } = true;
    /// <summary>
    /// L-11 / TC-2-09: điểm cộng cho món (mâm) trưa/tối chưa dùng lần nào trong tuần, để 14 bữa ra ~10–12 món khác nhau thay vì dồn vào 7 món × 2 lần.
    /// Không áp dụng ở chế độ parity (full_meal_only).
    /// </summary>
    public double NoveltyBonus { get; init; } = 3;
    /// <summary>Điểm cộng cho mâm so với trọn suất khi chọn món (ưu tiên bữa ăn "đủ mâm" nhưng không bắt buộc).</summary>
    public double MamBonus { get; init; } = 2.5;
    /// <summary>
    /// D-COM-01: từ vòng lập này mới được giảm cơm (từng bước 25 g, đến sàn) để cứu ngày không đạt; các vòng trước chỉ đổi tổ hợp mâm
    /// (cơm ghim đúng mức người dùng chọn). Chế độ parity không có cơm theo mức.
    /// </summary>
    public int RiceRescueFromIteration { get; init; } = 2;
    /// <summary>D-COM-01: bữa mâm lệch kcal (vượt) quá ngưỡng này ở mức cơm đã chọn thì giảm cơm bước 25 g trước khi chấp nhận.</summary>
    public double RiceSlotKcalTolPct { get; init; } = 0.30;
    /// <summary>Điểm trừ cho mâm phải giảm cơm (tỉ lệ cơm bị giảm × hệ số) khi chọn nhóm món — ưu tiên mâm giữ đủ cơm.</summary>
    public double RiceReducePenalty { get; init; } = 1.0;
    /// <summary>D-COM-02: ứng viên mâm phải giảm cơm bị trừ điểm lớn hơn mọi điểm cộng mềm (khẩu vị, xu hướng, chống lặp) — thứ tự từ điển.</summary>
    public double RiceKeepPenalty { get; init; } = 1000;
    /// <summary>D-COM-02: xếp hạng từ điển "giữ được cơm" trước điểm mềm. Tắt (false) chỉ để so sánh trước/sau trong engine-report (--rice-keep-first false).</summary>
    public bool RiceKeepFirst { get; init; } = true;
    /// <summary>D-COM-02: ước lượng kcal/đạm tráng miệng của bữa trưa/tối khi chấm "giữ được cơm" (tráng miệng được chọn sau).</summary>
    public double RiceDessertEstKcal { get; init; } = 50;
    public double RiceDessertEstProteinG { get; init; } = 2;
    /// <summary>T-096: bữa phụ được lên món phải có ≥ ngần này kcal (chặn món gần như 0 g do bước tinh chỉnh ngày kéo xuống); 0 = tắt. Chế độ parity (full_meal_only) không áp dụng.</summary>
    public double SnackMinKcal { get; init; } = 40;
}

public sealed class PlanWeekInput
{
    public required Targets Targets { get; init; }
    public required Preferences Prefs { get; init; }
    public required Dataset Data { get; init; }
    /// <summary>Ngày đầu tuần, dạng YYYY-MM-DD.</summary>
    public required string StartDate { get; init; }
    public long Seed { get; init; }
    public PlanOptions? Options { get; init; }
}

public sealed record Substitution(string From, string To);

public sealed class PlanMeal
{
    public string Date { get; set; } = "";
    public string Slot { get; set; } = "";
    /// <summary>planned | self | unfilled</summary>
    public string Status { get; set; } = "planned";
    public string? RecipeId { get; set; }
    /// <summary>Gram của "bạn" sau scale (cùng thứ tự với nguyên liệu của công thức).</summary>
    public List<GramLine> Grams { get; set; } = [];
    /// <summary>Khẩu phần chuẩn gốc của công thức (cho người ăn cùng).</summary>
    public List<GramLine> StandardGrams { get; set; } = [];
    /// <summary>Món phụ (cơm/đạm); đã nằm trong Macros, KHÔNG nằm trong Grams.</summary>
    public List<GramLine> Extras { get; set; } = [];
    public List<Substitution> Substitutions { get; set; } = [];
    public Macros Macros { get; set; } = Macros.Zero;
    public string? BatchGroupId { get; set; }
    public bool ForcedZeroCarb { get; set; }
    public bool ScaleInfeasible { get; set; }
    /// <summary>Từng món trong bữa (T-066). null ở chế độ full_meal_only để giữ nguyên định dạng golden.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<Dish>? Dishes { get; set; }
    /// <summary>Món tráng miệng (D-DES-01): công thức + gram (đã nằm trong Macros, KHÔNG nằm trong Grams). null = không có.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? DessertId { get; set; }
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<GramLine>? Dessert { get; set; }
    /// <summary>Cảnh báo mềm trên bữa, ví dụ "dessert_missing".</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<string>? Warnings { get; set; }
    /// <summary>D-COM-01: lượng cơm của bữa mâm có cơm (mức người dùng chọn / lượng thực). null = bữa không phải mâm có cơm.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public RiceInfo? Rice { get; set; }
    /// <summary>D-COM-01: ghi chú hiển thị cho người dùng (hiện chỉ có "rice_reduced").</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<MealNote>? Notes { get; set; }
    /// <summary>Lý do giảm cơm do bước cứu ngày đặt (kcal | protein); không đưa vào JSON, ghi chú giữ lại lý do.</summary>
    [JsonIgnore]
    public string? RiceReason { get; set; }

    public PlanMeal Clone() => new()
    {
        Date = Date, Slot = Slot, Status = Status, RecipeId = RecipeId,
        Grams = Grams.Select(g => g.Clone()).ToList(), StandardGrams = StandardGrams.Select(g => g.Clone()).ToList(),
        Extras = Extras.Select(g => g.Clone()).ToList(), Substitutions = [.. Substitutions], Macros = Macros,
        BatchGroupId = BatchGroupId, ForcedZeroCarb = ForcedZeroCarb, ScaleInfeasible = ScaleInfeasible, Dishes = Dishes,
        DessertId = DessertId, Dessert = Dessert?.Select(g => g.Clone()).ToList(), Warnings = Warnings,
        Rice = Rice, Notes = Notes, RiceReason = RiceReason,
    };

    public void CopyFrom(PlanMeal o)
    {
        Date = o.Date; Slot = o.Slot; Status = o.Status; RecipeId = o.RecipeId; Grams = o.Grams; StandardGrams = o.StandardGrams;
        Extras = o.Extras; Substitutions = o.Substitutions; Macros = o.Macros; BatchGroupId = o.BatchGroupId;
        ForcedZeroCarb = o.ForcedZeroCarb; ScaleInfeasible = o.ScaleInfeasible; Dishes = o.Dishes; DessertId = o.DessertId; Dessert = o.Dessert; Warnings = o.Warnings;
        Rice = o.Rice; Notes = o.Notes; RiceReason = o.RiceReason;
    }

    public PlanMeal ShallowCopy() { var c = new PlanMeal(); c.CopyFrom(this); return c; }
}

/// <summary>D-COM-01: lượng cơm của một bữa mâm. <c>TargetG</c> = mức người dùng chọn, <c>ActualG</c> = gram thực trong bữa (cơm chín hoặc tinh bột quy tương đương).</summary>
public sealed class RiceInfo
{
    public string Habit { get; set; } = "";
    public double TargetG { get; set; }
    public double ActualG { get; set; }
}

/// <summary>Ghi chú trên bữa. code = "rice_reduced": cơm thực thấp hơn mức chọn (reason = kcal | protein).</summary>
public sealed class MealNote
{
    public string Code { get; set; } = "";
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public double? TargetG { get; set; }
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public double? ActualG { get; set; }
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Reason { get; set; }
}

public sealed class DayTotals
{
    public double Kcal { get; set; }
    public double ProteinG { get; set; }
    public double CarbG { get; set; }
    public double FatG { get; set; }
}

public sealed class PlanDay
{
    public string Date { get; init; } = "";
    public List<PlanMeal> Meals { get; init; } = [];
    public DayTotals Totals { get; init; } = new();
}

public sealed class WeekPlan
{
    /// <summary>ready | partial</summary>
    public string Status { get; set; } = "partial";
    public string StartDate { get; set; } = "";
    public long Seed { get; set; }
    public List<PlanDay> Days { get; set; } = [];
    public WeekValidation Validation { get; set; } = new();
    public ShoppingList Shopping { get; set; } = new();
    public double BudgetVnd { get; set; }
    public int Iterations { get; set; }
    /// <summary>Số công thức khác nhau dùng trong tuần.</summary>
    public int DistinctRecipes { get; set; }
    /// <summary>Số lần đổi món/nguyên liệu ở bước sửa ngân sách.</summary>
    public int Repairs { get; set; }
    /// <summary>Các bữa không có công thức hợp lệ; tuần vẫn được trả về với trạng thái partial.</summary>
    public List<string> UnfilledSlots { get; set; } = [];
    /// <summary>auto | mam_only; null khi full_meal_only.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? MealStyle { get; set; }
    /// <summary>Ưu tiên mềm đã bị bỏ qua để tuần đạt chỉ tiêu cứng (D-HLT-02): health_leanings | cuisine. null khi không phải nới gì.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<string>? RelaxedPreferences { get; set; }
    /// <summary>Công thức tổng hợp của các mâm có trong tuần (id "mam:..."); không đưa vào JSON của WeekPlan — API trả riêng trong map recipes.</summary>
    [JsonIgnore]
    public List<Recipe> MamRecipes { get; set; } = [];
}

/// <summary>
/// T-010 — Bộ máy lập tuần (port 1-1 từ planWeek.ts): lọc → phân slot → chọn món → scale → tinh chỉnh theo ngày → món phụ
/// → validator → thử lại → sửa ngân sách. Tất định theo seed, không I/O, không đọc đồng hồ.
/// </summary>
public static partial class WeekPlanner
{
    /// <summary>
    /// Xu hướng sức khỏe và khẩu vị chỉ là ưu tiên mềm (D-HLT-02): nếu tuần chưa đạt chỉ tiêu cứng mà người dùng có ưu tiên mềm,
    /// thử lại với ít ưu tiên mềm hơn (bỏ xu hướng → bỏ khẩu vị → bỏ cả hai) và giữ phương án tốt nhất.
    /// Phương án có nhiều ưu tiên hơn thắng khi hòa, nên tuần đã đạt thì không bị đổi.
    /// </summary>
    public static WeekPlan Plan(PlanWeekInput input)
    {
        var plan = new Planner(input).Run();
        var p = input.Prefs;
        var hasHealth = p.HealthLeanings.Count > 0;
        var hasCuisine = p.CuisineLikes.Count > 0 || p.CuisineLess.Count > 0;
        if (plan.Status == "ready" || !(hasHealth || hasCuisine)) return plan;

        var tries = new List<(bool Health, bool Cuisine)>();
        if (hasHealth) tries.Add((true, false));
        if (hasCuisine) tries.Add((false, true));
        if (hasHealth && hasCuisine) tries.Add((true, true));
        foreach (var (dropHealth, dropCuisine) in tries)
        {
            var prefs = System.Text.Json.JsonSerializer.Deserialize<Preferences>(System.Text.Json.JsonSerializer.Serialize(p, JsonOptions.Default), JsonOptions.Default)!;
            var relaxed = new List<string>();
            if (dropHealth) { prefs.HealthLeanings = []; relaxed.Add("health_leanings"); }
            if (dropCuisine) { prefs.CuisineLikes = []; prefs.CuisineLess = []; relaxed.Add("cuisine"); }
            var alt = new Planner(new PlanWeekInput { Targets = input.Targets, Prefs = prefs, Data = input.Data, StartDate = input.StartDate, Seed = input.Seed, Options = input.Options }).Run();
            if (Rank(alt) < Rank(plan) - 1e-9) { alt.RelaxedPreferences = relaxed; plan = alt; }
            if (plan.Status == "ready") break;
        }
        return plan;

        double Rank(WeekPlan w) => w.Validation.DaysMissing * 1000 + (w.Validation.BudgetOverVnd > 0 ? 100 : 0) + w.UnfilledSlots.Count * 500
            + w.Validation.Shortfalls.Sum(f => f.Kind == "protein_low" ? f.Amount / Math.Max(1, input.Targets.ProteinG) : f.Amount / Math.Max(1, input.Targets.KcalTarget));
    }

    public static string AddDays(string iso, int n) =>
        DateOnly.ParseExact(iso, "yyyy-MM-dd", CultureInfo.InvariantCulture).AddDays(n).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    private static readonly string[] DayOrder = ["breakfast", "snack_am", "lunch", "snack_pm", "dinner"];
    private static readonly string[] ExtraSlots = ["breakfast", "lunch", "dinner"];
    private static readonly string[] Groups = ["main", "breakfast", "snack_am", "snack_pm"];
    private static string GroupOf(string s) => s is "lunch" or "dinner" ? "main" : s;
    private static double Round5(double x) => Js.Round(x / 5) * 5;

    private sealed class SlotCtx(SlotTarget target, List<ValidRecipe> cands)
    {
        public SlotTarget Target { get; } = target;
        public List<ValidRecipe> Cands { get; } = cands;
    }

    private sealed partial class Planner
    {
        private readonly PlanOptions _opt;
        private readonly Targets _targets;
        private readonly Preferences _prefs;
        private readonly Dataset _data;
        private readonly PlanWeekInput _input;
        private readonly MealStyle _style;
        private readonly Dictionary<string, MamInfo> _mam = [];
        private readonly List<Recipe> _desserts = [];
        private readonly Dictionary<string, SlotCtx> _slotCtx = [];
        private readonly List<string> _unfilled = [];
        private readonly List<SlotTarget> _planned = [];
        private readonly List<SlotTarget> _selfSlots;
        private readonly Dictionary<string, List<string>> _banned;
        private readonly double _plannedShare, _kMid, _pGoal, _costRef, _others;
        private readonly double _selfKcal, _selfProtein;
        private readonly Dictionary<string, double> _servingCost = [];
        private readonly List<string> _dates;
        private readonly (string? Carb, string? Protein) _extrasPick;

        public Planner(PlanWeekInput input, IEnumerable<string>? legacyMamIds = null)
        {
            _input = input;
            _opt = input.Options ?? new PlanOptions();
            _style = _opt.MealStyle;
            _targets = input.Targets;
            _prefs = input.Prefs;
            _data = input.Data;

            var slotTargets = MealSlots.Allocate(_targets, _prefs.Slots);
            var filtered = Filter.FilterRecipes(_data.Recipes, _data.IngredientsById, _data.Ingredients, _prefs);
            _banned = Filter.BannedIngredients(_data.Ingredients, _prefs);

            IReadOnlyList<ValidRecipe> source = filtered.Valid;
            if (_style != MealStyle.FullMealOnly)
            {
                var infos = MamBuilder.Build(filtered.Valid.Select(v => v.Recipe).ToList(), r => Shopping.RecipeServingCostVnd(r, input.Data, _prefs.StoreId, _style != MealStyle.FullMealOnly),
                    input.Data.IngredientsById, _prefs, _opt.MamVariants);
                foreach (var i in infos) _mam[i.Composite.Id] = i;
                // Chỉnh tuần đã có: mâm cũ không còn trong kho mâm hiện tại (vd món bị chặn) vẫn phải tra được để giữ nguyên các bữa đó.
                var legacy = (legacyMamIds ?? []).Distinct().Where(id => !_mam.ContainsKey(id)).Select(id => MamBuilder.Rebuild(id, input.Data, input.Prefs.RiceHabit)).OfType<MamInfo>().ToList();
                foreach (var i in legacy) _mam[i.Composite.Id] = i;
                if (infos.Count + legacy.Count > 0)
                    _data = new Dataset(input.Data.Ingredients, input.Data.Recipes.Concat(infos.Concat(legacy).Select(i => i.Composite)), input.Data.Stores, input.Data.Prices);
                if (_opt.IncludeDessert) _desserts = filtered.Valid.Select(v => v.Recipe).Where(r => r.DishRole == "dessert").ToList();
                source = filtered.Valid.Where(v => v.Recipe.DishRole == "full_meal").Concat(infos.Select(i => new ValidRecipe(i.Composite, false))).ToList();
            }

            foreach (var st in slotTargets.Where(s => s.Planned))
            {
                var cands = Filter.RecipesForSlot(source, st.Slot, _prefs.Slots, _prefs.LowCarb);
                if (_style == MealStyle.MamOnly && st.Slot is "lunch" or "dinner")
                {
                    var onlyMam = cands.Where(c => _mam.ContainsKey(c.Recipe.Id)).ToList();
                    if (onlyMam.Count > 0) cands = onlyMam;
                }
                if (cands.Count == 0) { _unfilled.Add(st.Slot); continue; }
                _planned.Add(st);
                _slotCtx[st.Slot] = new SlotCtx(st, cands);
            }
            _selfSlots = slotTargets.Where(s => s.Mode == "self").ToList();
            _selfKcal = _selfSlots.Aggregate(0.0, (a, s) => a + s.Kcal);
            _selfProtein = _selfSlots.Aggregate(0.0, (a, s) => a + s.ProteinG);
            var ps = _planned.Aggregate(0.0, (a, s) => a + s.Share);
            _plannedShare = ps == 0 ? 1 : ps;

            _kMid = (_targets.KcalMin + _targets.KcalMax) / 2;
            _pGoal = _targets.ProteinG * _opt.ProteinMargin;

            var nMeals = _planned.Count * _opt.Days;
            _others = Shopping.OtherEatersFactor(new Household(_prefs.Adults, _prefs.Children));
            _costRef = _prefs.WeeklyBudgetVnd / Math.Max(1, nMeals) / (1 + _others);
            _dates = Enumerable.Range(0, _opt.Days).Select(i => AddDays(input.StartDate, i)).ToList();
            _extrasPick = _opt.Extras ? PickExtras(_data, _banned, _prefs.StoreId) : (null, null);
        }

        private (double Kcal, double ProteinG) SlotGoal(SlotTarget st) =>
            (Math.Max(0, _kMid - _selfKcal) * (st.Share / _plannedShare), Math.Max(0, _pGoal - _selfProtein) * (st.Share / _plannedShare));

        /// <summary>D-SHP-02: quy cơm ra gạo khi tính chi phí/đi chợ; chế độ parity (full_meal_only) giữ nguyên bản TS.</summary>
        private bool Pa => _style != MealStyle.FullMealOnly;

        private double CostOf(Recipe r)
        {
            if (!_servingCost.TryGetValue(r.Id, out var c)) _servingCost[r.Id] = c = Shopping.RecipeServingCostVnd(r, _data, _prefs.StoreId, Pa);
            return c;
        }

        /// <summary>Bữa ăn ngoài / bỏ bữa (US-5.3): không tính vào tổng ngày, danh sách đi chợ; ngày đó được miễn kiểm.</summary>
        internal static bool IsOut(PlanMeal m) => m.Status is "eaten_out" or "skipped";

        private static DayTotals DayTot(IEnumerable<PlanMeal> dayMeals)
        {
            var t = new DayTotals();
            foreach (var m in dayMeals.Where(m => !IsOut(m)))
            {
                t.Kcal += m.Macros.Kcal;
                t.ProteinG += m.Macros.ProteinG;
                t.CarbG += m.Macros.CarbG;
                t.FatG += m.Macros.FatG;
            }
            return t;
        }

        private bool DayOk(double kcal, double protein) => protein >= _targets.ProteinG && kcal >= _targets.KcalMin && kcal <= _targets.KcalMax;

        private ShoppingList ShoppingOf(List<List<PlanMeal>> meals)
        {
            var sm = new List<ShoppingMeal>();
            foreach (var m in meals.SelectMany(d => d).Where(m => m.Status == "planned"))
            {
                var ing = new List<ShoppingIngredient>();
                for (var i = 0; i < m.Grams.Count; i++) ing.Add(new ShoppingIngredient(m.Grams[i].IngredientId, m.Grams[i].Grams, m.StandardGrams[i].Grams));
                foreach (var e in m.Extras) ing.Add(new ShoppingIngredient(e.IngredientId, e.Grams, 0));
                if (m.DessertId is not null && m.Dessert is not null)
                {
                    // Cả nhà cùng ăn tráng miệng: người khác dùng khẩu phần chuẩn của món.
                    var dr = _data.RecipesById[m.DessertId];
                    for (var i = 0; i < m.Dessert.Count; i++) ing.Add(new ShoppingIngredient(m.Dessert[i].IngredientId, m.Dessert[i].Grams, dr.Ingredients[i].Grams));
                }
                sm.Add(new ShoppingMeal { Ingredients = ing });
            }
            return Shopping.BuildShoppingList(sm, new Household(_prefs.Adults, _prefs.Children), _data, _prefs.StoreId, null, _style != MealStyle.FullMealOnly);
        }

        private WeekPlan Finalize(List<List<PlanMeal>> meals, int iterations, int repairs, EditSpec? edit = null)
        {
            if (edit is null)
            {
                AssignBatchGroups(meals.SelectMany(d => d).ToList(), _data);
                FillDishes(meals);
            }
            else
            {
                // Chỉnh tuần: chỉ nhóm lại nấu-1-ăn-2 cho công thức bị đụng tới và tách món cho bữa đã đổi; các bữa khác giữ nguyên từng chữ số.
                if (edit.BatchRecipeIds.Count > 0) AssignBatchGroups(meals.SelectMany(d => d).Where(m => m.RecipeId is not null && edit.BatchRecipeIds.Contains(m.RecipeId)).ToList(), _data);
                FillDishesFor(edit.Changed);
            }
            FillRice(edit is null ? meals.SelectMany(d => d) : edit.Changed);
            var days = meals.Select((dm, i) => new PlanDay { Date = _dates[i], Meals = dm, Totals = DayTot(dm) }).ToList();
            var shopping = ShoppingOf(meals);
            var validation = WeekValidator.Validate(
                days.Select(d => new DayTotal { Date = d.Date, ProteinG = d.Totals.ProteinG, Kcal = d.Totals.Kcal, Exempt = d.Meals.Any(IsOut) }).ToList(),
                _targets, _prefs.WeeklyBudgetVnd, shopping.WeekFoodCost);
            var distinct = meals.SelectMany(d => d).Select(m => m.RecipeId).Where(x => !string.IsNullOrEmpty(x)).Distinct().Count();
            return new WeekPlan
            {
                Status = validation.Ok && _unfilled.Count == 0 ? "ready" : "partial", StartDate = _input.StartDate, Seed = _input.Seed,
                Days = days, Validation = validation, Shopping = shopping, BudgetVnd = _prefs.WeeklyBudgetVnd, Iterations = iterations,
                DistinctRecipes = distinct, Repairs = repairs, UnfilledSlots = edit?.UnfilledSlots ?? _unfilled,
                RelaxedPreferences = edit?.Relaxed,
                MealStyle = _style == MealStyle.FullMealOnly ? null : MealStyles.ToWire(_style),
                MamRecipes = meals.SelectMany(d => d).Where(m => m.RecipeId is not null && _mam.ContainsKey(m.RecipeId))
                    .Select(m => _mam[m.RecipeId!].Composite).DistinctBy(r => r.Id).ToList(),
            };
        }

        /// <summary>
        /// D-COM-01: mỗi bữa mâm có cơm trả <c>rice</c> (mức chọn / thực tế); thực tế thấp hơn mức chọn quá sai số làm tròn thì thêm ghi chú <c>rice_reduced</c>.
        /// Khi chỉnh tuần chỉ tính lại cho bữa đã đổi (các bữa khác, kể cả ngày đã qua với mức cơm cũ, giữ nguyên).
        /// </summary>
        private void FillRice(IEnumerable<PlanMeal> meals)
        {
            if (_style == MealStyle.FullMealOnly) return;
            foreach (var m in meals.Where(m => m.Status == "planned"))
            {
                if (m.RecipeId is null || !_mam.TryGetValue(m.RecipeId, out var info) || info.RiceIdx < 0 || m.Grams.Count <= info.RiceIdx)
                {
                    m.Rice = null;
                    m.Notes = null;
                    continue;
                }
                var actual = m.Grams[info.RiceIdx].Grams;
                m.Rice = new RiceInfo { Habit = _prefs.RiceHabit, TargetG = info.RiceTargetG, ActualG = actual };
                if (actual < info.RiceTargetG - RiceHabits.ToleranceG)
                {
                    var reason = m.RiceReason ?? m.Notes?.FirstOrDefault(n => n.Code == "rice_reduced")?.Reason ?? "kcal";
                    m.Notes = [new MealNote { Code = "rice_reduced", TargetG = info.RiceTargetG, ActualG = actual, Reason = reason }];
                }
                else m.Notes = null;
            }
        }

        /// <summary>Gram cơm hiện tại của bữa mâm có cơm (null nếu bữa không có dòng cơm theo mức).</summary>
        private double? RiceNow(PlanMeal m) =>
            m.RecipeId is not null && _mam.TryGetValue(m.RecipeId, out var i) && i.RiceIdx >= 0 && m.Grams.Count > i.RiceIdx ? m.Grams[i.RiceIdx].Grams : null;

        /// <summary>
        /// D-COM-01: scale một công thức vào mục tiêu bữa. Mâm có cơm ghim cơm ở mức người dùng chọn; nếu ở mức đó bữa vẫn lệch (vượt kcal quá dải
        /// hoặc không khả thi) thì giảm cơm từng bước 25 g đến sàn — chỉ dừng ở mức đầu tiên vừa. <paramref name="reason"/> != null khi đã giảm cơm.
        /// </summary>
        private ScaleResult ScaleMeal(Recipe r, ScaleTarget t, bool zeroCarb, out string? reason, out double riceShort, bool strict = false)
        {
            reason = null;
            riceShort = 0;
            var res = Scaler.Scale(r, _data.IngredientsById, t, new ScaleOptions { ForceZeroCarb = zeroCarb });
            if (_style == MealStyle.FullMealOnly || zeroCarb || !_mam.TryGetValue(r.Id, out var info) || info.RiceIdx < 0) return res;
            // strict (xếp hạng ứng viên, D-COM-02): "giữ được cơm" = Scaler coi bữa khả thi (đạm không thiếu quá 3 g, |kcal| ≤ 5%) khi cơm ghim đúng mức.
            bool Bad(ScaleResult x) => strict
                ? x.Infeasible
                : x.Deviation.KcalPct > _opt.RiceSlotKcalTolPct || (x.Infeasible && x.Deviation.ProteinG < -_opt.PoolProteinTolG);
            if (!Bad(res)) return res;
            var why = res.Deviation.KcalPct > (strict ? 0.0 : _opt.RiceSlotKcalTolPct) ? "kcal" : "protein";
            var cur = info.RiceTargetG;
            var best = res;
            while (cur > info.RiceFloorG + 1e-9)
            {
                cur = Math.Max(info.RiceFloorG, cur - RiceHabits.StepG);
                var r2 = Scaler.Scale(r, _data.IngredientsById, t, new ScaleOptions { ForceZeroCarb = zeroCarb, RiceOverrideG = cur });
                best = r2;
                if (!Bad(r2)) break;
            }
            reason = why;
            riceShort = (info.RiceTargetG - cur) / info.RiceTargetG;
            return best;
        }

        /// <summary>Ước lượng kcal/đạm tráng miệng của bữa (0 khi bữa không có tráng miệng) để chấm "giữ được cơm".</summary>
        private (double Kcal, double ProteinG) DessertEstimate(string slot) =>
            _style != MealStyle.FullMealOnly && _opt.IncludeDessert && slot is "lunch" or "dinner" ? (_opt.RiceDessertEstKcal, _opt.RiceDessertEstProteinG) : (0, 0);

        private ScaleOptions ScaleOpts(PlanMeal m) => new() { ForceZeroCarb = m.ForcedZeroCarb, RiceOverrideG = RiceNow(m) };

        /// <summary>Tách mỗi bữa thành các món (dishes[]) với gram và macro riêng; món thêm do engine bù là dòng "extra".</summary>
        private void FillDishes(List<List<PlanMeal>> meals) => FillDishesFor(meals.SelectMany(d => d));

        private void FillDishesFor(IEnumerable<PlanMeal> changed)
        {
            if (_style == MealStyle.FullMealOnly) return;
            foreach (var m in changed.Where(m => m.Status == "planned"))
            {
                var dishes = new List<Dish>();
                if (_mam.TryGetValue(m.RecipeId!, out var info))
                {
                    foreach (var part in info.Parts)
                    {
                        var lines = m.Grams.Skip(part.Start).Take(part.Count).Select(g => g.Clone()).ToList();
                        dishes.Add(new Dish { Role = part.Role, RecipeId = part.Recipe.Id, Name = part.Recipe.Name, Grams = lines, Macros = Nutrition.Compute(lines, _data.IngredientsById).Total });
                    }
                }
                else
                {
                    var lines = m.Grams.Select(g => g.Clone()).ToList();
                    dishes.Add(new Dish { Role = "full_meal", RecipeId = m.RecipeId, Name = _data.RecipesById[m.RecipeId!].Name, Grams = lines, Macros = Nutrition.Compute(lines, _data.IngredientsById).Total });
                }
                if (m.DessertId is not null && m.Dessert is not null)
                {
                    var lines = m.Dessert.Select(g => g.Clone()).ToList();
                    dishes.Add(new Dish { Role = "dessert", RecipeId = m.DessertId, Name = _data.RecipesById[m.DessertId].Name, Grams = lines, Macros = Nutrition.Compute(lines, _data.IngredientsById).Total });
                }
                if (m.Extras.Count > 0)
                {
                    var lines = m.Extras.Select(g => g.Clone()).ToList();
                    dishes.Add(new Dish { Role = "extra", RecipeId = null, Name = "Món thêm", Grams = lines, Macros = Nutrition.Compute(lines, _data.IngredientsById).Total });
                }
                // Món bị scale về 0 g (vd cơm khi ngày chật calo) không còn là một món của bữa: bỏ khỏi danh sách để UI không hiện món 0 g.
                dishes.RemoveAll(d => d.Role != "full_meal" && d.Grams.Sum(g => g.Grams) < 1);
                m.Dishes = dishes;
            }
        }

        private PlanMeal MakeMeal(string date, string slot, Recipe recipe, bool forceZeroCarb, ScaleResult sc) => new()
        {
            Date = date, Slot = slot, Status = "planned", RecipeId = recipe.Id, Grams = sc.Grams,
            StandardGrams = recipe.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList(),
            Extras = [], Substitutions = [], Macros = sc.Macros, BatchGroupId = null, ForcedZeroCarb = forceZeroCarb,
            ScaleInfeasible = sc.Infeasible,
        };

        private static ScoreContext NeutralCtx(Preferences prefs, double cost, double costRef) => new()
        {
            CuisineLikes = prefs.CuisineLikes, CuisineLess = prefs.CuisineLess, HealthLeanings = prefs.HealthLeanings,
            CostVnd = cost, CostReferenceVnd = costRef, UsesThisWeek = 0, SameDayRecipeIds = [], RecentMainProteins = [],
        };

        public WeekPlan Run()
        {
            (WeekPlan Plan, List<List<PlanMeal>> Meals, double Badness)? best = null;
            var iterations = 0;

            for (var it = 0; it < _opt.MaxIterations; it++)
            {
                iterations = it + 1;
                var rng = new Rng(Rng.DeriveSeed(_input.Seed, it));
                // Ưu tiên mềm (xu hướng sức khỏe, khẩu vị) giảm dần ở các vòng sau để món đạt chỉ tiêu có cơ hội thắng.
                var softF = it < 3 ? 1.0 : it < 6 ? 0.5 : 0.0;
                var weights = _opt.ScoreWeights with
                {
                    Cost = _opt.ScoreWeights.Cost * (1 + it * 1.5),
                    HealthLeaning = _opt.ScoreWeights.HealthLeaning * softF,
                    CuisineLike = _opt.ScoreWeights.CuisineLike * softF,
                    CuisineLess = _opt.ScoreWeights.CuisineLess * softF,
                };
                var noise = it == 0 ? 0.0 : 1.5;
                // Nếu mâm không đạt chỉ tiêu (vd thuần chay + ít tinh bột, món chính ít calo), các vòng sau giảm dần ưu tiên mâm để trọn suất calo cao có cơ hội.
                var mamF = _style == MealStyle.MamOnly ? 1.0 : it < 3 ? 1.0 : it < 6 ? 0.4 : 0.0;
                var mamBonusNow = _opt.MamBonus * mamF;

                // 1. Chọn nhóm món (pool) cho từng nhóm bữa.
                var pools = new Dictionary<string, HashSet<string>>();
                foreach (var g in Groups)
                {
                    var slotsOfGroup = _planned.Where(s => GroupOf(s.Slot) == g).ToList();
                    if (slotsOfGroup.Count == 0) continue;
                    var unionOrder = new List<(ValidRecipe Vr, SlotTarget Slot)>();
                    var inUnion = new HashSet<string>();
                    foreach (var st in slotsOfGroup)
                        foreach (var vr in _slotCtx[st.Slot].Cands)
                            if (inUnion.Add(vr.Recipe.Id)) unionOrder.Add((vr, st));
                    var scored = new List<(string Id, double S)>();
                    foreach (var (vr, slot) in unionOrder)
                    {
                        var goal = SlotGoal(slot);
                        var (dK, dP) = DessertEstimate(slot.Slot);
                        var sc = ScaleMeal(vr.Recipe, new ScaleTarget(Math.Max(0, goal.Kcal - dK), Math.Max(0, goal.ProteinG - dP)), vr.ForceZeroCarb, out _, out var riceShort, strict: true);
                        var baseScore = Score.Total(vr.Recipe, NeutralCtx(_prefs, CostOf(vr.Recipe), _costRef), weights);
                        var fit =
                            (sc.Infeasible ? -2 : 0) - (riceShort > 0 && _opt.RiceKeepFirst ? _opt.RiceKeepPenalty : 0) - _opt.RiceReducePenalty * riceShort - 0.5 * (Math.Abs(sc.Deviation.ProteinG) / _opt.PoolProteinTolG) -
                            0.5 * (Math.Abs(sc.Deviation.KcalPct) / _opt.PoolKcalTolPct);
                        var mamBonus = _mam.ContainsKey(vr.Recipe.Id) ? mamBonusNow : 0;
                        scored.Add((vr.Recipe.Id, baseScore + fit + mamBonus + noise * rng.Next()));
                    }
                    var size = g switch { "main" => _opt.DistinctMain, "breakfast" => _opt.DistinctBreakfast, _ => _opt.DistinctSnack };
                    var ordered = scored.OrderByDescending(x => x.S).ThenBy(x => x.Id, ViCollator.Instance).ToList();
                    IEnumerable<string> top;
                    if (g == "main" && _mam.Count > 0)
                    {
                        // Dành phần lớn nhóm món cho mâm (mỗi món chính tối đa vài biến thể), phần còn lại cho trọn suất.
                        var quota = _style == MealStyle.MamOnly ? size : (int)Math.Ceiling(size * _opt.MamPoolRatio * mamF);
                        var perMain = new Dictionary<string, int>();
                        var comps = new List<string>();
                        var poolSoups = new HashSet<string>();
                        foreach (var x in ordered)
                        {
                            if (comps.Count >= quota) break;
                            if (!_mam.TryGetValue(x.Id, out var mi)) continue;
                            perMain.TryGetValue(mi.MainId, out var n);
                            if (n >= _opt.MamPerMainInPool) continue;
                            // Mỗi canh chỉ vào nhóm món một lần để canh không bị lặp quá giới hạn trong tuần.
                            if (mi.SoupId is not null && !poolSoups.Add(mi.SoupId)) continue;
                            perMain[mi.MainId] = n + 1;
                            comps.Add(x.Id);
                        }
                        var rest = ordered.Where(x => !_mam.ContainsKey(x.Id)).Take(Math.Max(0, size - comps.Count)).Select(x => x.Id);
                        top = comps.Concat(rest);
                    }
                    else top = ordered.Take(size).Select(x => x.Id);
                    pools[g] = [.. top];
                }

                // 2. Gán món vào từng bữa theo thứ tự thời gian.
                var uses = new Dictionary<string, int>();
                var soupUses = new Dictionary<string, int>();
                var vegUses = new Dictionary<string, int>();
                var mainUses = new Dictionary<string, int>();
                var dessertUses = new Dictionary<string, int>();
                var equipUses = new Dictionary<string, int>();
                var recentMain = new List<string>();
                var meals = new List<List<PlanMeal>>();
                foreach (var date in _dates)
                {
                    var dayMeals = new List<PlanMeal>();
                    var sameDay = new List<string>();
                    var sameDayMains = new List<string>();
                    var sameDayDesserts = new List<string>();
                    foreach (var slot in DayOrder)
                    {
                        _slotCtx.TryGetValue(slot, out var sc);
                        var selfT = _selfSlots.FirstOrDefault(s => s.Slot == slot);
                        if (selfT is not null)
                        {
                            dayMeals.Add(new PlanMeal
                            {
                                Date = date, Slot = slot, Status = "self", RecipeId = null,
                                Macros = Macros.Zero with { Kcal = selfT.Kcal, ProteinG = selfT.ProteinG },
                            });
                            continue;
                        }
                        if (_unfilled.Contains(slot))
                        {
                            dayMeals.Add(new PlanMeal { Date = date, Slot = slot, Status = "unfilled", RecipeId = null, Macros = Macros.Zero });
                            continue;
                        }
                        if (sc is null) continue;
                        var grp = GroupOf(slot);
                        var pool = pools[grp];
                        var eligible = sc.Cands.Where(c => pool.Contains(c.Recipe.Id)).ToList();
                        if (eligible.Count == 0) eligible = sc.Cands;
                        if (grp == "main")
                        {
                            var fresh = eligible.Where(c => !sameDay.Contains(c.Recipe.Id)).ToList();
                            if (fresh.Count > 0) eligible = fresh;
                            if (_mam.Count > 0)
                            {
                                // Trưa và tối không cùng một món chính; một canh không quá MaxSoupUses lần/tuần.
                                var distinctMain = eligible.Where(c => !_mam.TryGetValue(c.Recipe.Id, out var mi) || !sameDayMains.Contains(mi.MainId)).ToList();
                                if (distinctMain.Count > 0) eligible = distinctMain;
                                var soupOk = eligible.Where(c => !_mam.TryGetValue(c.Recipe.Id, out var mi) || mi.SoupId is null ||
                                    soupUses.GetValueOrDefault(mi.SoupId) < _opt.MaxSoupUses).ToList();
                                if (soupOk.Count > 0) eligible = soupOk;
                                else
                                {
                                    // Hết lượt canh trong nhóm món: mở rộng ra mọi ứng viên của bữa trước khi chấp nhận lặp quá giới hạn.
                                    var wide = sc.Cands.Where(c => !sameDay.Contains(c.Recipe.Id) &&
                                        (!_mam.TryGetValue(c.Recipe.Id, out var mi) || ((mi.SoupId is null || soupUses.GetValueOrDefault(mi.SoupId) < _opt.MaxSoupUses) && !sameDayMains.Contains(mi.MainId)))).ToList();
                                    if (wide.Count > 0) eligible = wide;
                                }
                            }
                        }
                        ValidRecipe? pick = null;
                        var pickScore = double.NegativeInfinity;
                        var pickKeeps = false;
                        var (pdK, pdP) = DessertEstimate(slot);
                        var pgoal = SlotGoal(sc.Target);
                        foreach (var c in eligible)
                        {
                            uses.TryGetValue(c.Recipe.Id, out var u);
                            var ctx = new ScoreContext
                            {
                                CuisineLikes = _prefs.CuisineLikes, CuisineLess = _prefs.CuisineLess, HealthLeanings = _prefs.HealthLeanings,
                                CostVnd = CostOf(c.Recipe), CostReferenceVnd = _costRef, UsesThisWeek = u,
                                SameDayRecipeIds = sameDay, RecentMainProteins = grp == "main" ? recentMain : [],
                            };
                            var s = Score.Total(c.Recipe, ctx, weights);
                            if (_mam.TryGetValue(c.Recipe.Id, out var mamInfo))
                            {
                                // Đa dạng rau và món chính trong tuần.
                                s += mamBonusNow;
                                if (mamInfo.VegId is not null) s -= 0.75 * vegUses.GetValueOrDefault(mamInfo.VegId);
                                if (mamInfo.SoupId is not null) s -= 0.5 * soupUses.GetValueOrDefault(mamInfo.SoupId);
                                s -= weights.RepeatOverUse * Math.Max(0, mainUses.GetValueOrDefault(mamInfo.MainId) - weights.FreeUses);
                            }
                            if (_style != MealStyle.FullMealOnly && grp == "main" && u == 0) s += _opt.NoveltyBonus;
                            if (_style != MealStyle.FullMealOnly && c.Recipe.Equipment.Count > 0)
                            {
                                // Đa dạng dụng cụ: phạt nhẹ khi một bộ dụng cụ đã dùng nhiều lần trong tuần (nhiều thiết bị → thực đơn không dồn vào một thiết bị).
                                s -= 0.4 * Math.Max(0, equipUses.GetValueOrDefault(EquipKey(c.Recipe)) - 3);
                            }
                            // D-COM-02: ứng viên giữ được cơm theo mức luôn xếp trước ứng viên phải giảm cơm (thứ tự từ điển, không cộng dồn với điểm mềm).
                            var keeps = true;
                            if (!_opt.RiceKeepFirst) { }
                            else if (_style != MealStyle.FullMealOnly && _mam.TryGetValue(c.Recipe.Id, out var kmi) && kmi.RiceIdx >= 0 && !c.ForceZeroCarb)
                            {
                                ScaleMeal(c.Recipe, new ScaleTarget(Math.Max(0, pgoal.Kcal - pdK), Math.Max(0, pgoal.ProteinG - pdP)), c.ForceZeroCarb, out _, out var kShort, strict: true);
                                keeps = kShort <= 0;
                            }
                            // Bữa nguyên (không phải mâm) ở trưa/tối bỏ hẳn cơm theo mức → không tính là "giữ cơm" (tránh bỏ mâm chỉ để khỏi phải bớt cơm).
                            else if (_style != MealStyle.FullMealOnly && slot is "lunch" or "dinner" && !c.ForceZeroCarb && !_mam.ContainsKey(c.Recipe.Id))
                                keeps = false;
                            if (pick is null || (keeps && !pickKeeps) || (keeps == pickKeeps && (s > pickScore + 1e-9 || (Math.Abs(s - pickScore) <= 1e-9 && string.CompareOrdinal(c.Recipe.Id, pick.Recipe.Id) < 0))))
                            {
                                pick = c;
                                pickScore = s;
                                pickKeeps = keeps;
                            }
                        }
                        var chosen = pick!;
                        uses[chosen.Recipe.Id] = (uses.TryGetValue(chosen.Recipe.Id, out var uu) ? uu : 0) + 1;
                        sameDay.Add(chosen.Recipe.Id);
                        if (chosen.Recipe.Equipment.Count > 0) equipUses[EquipKey(chosen.Recipe)] = equipUses.GetValueOrDefault(EquipKey(chosen.Recipe)) + 1;
                        if (_mam.TryGetValue(chosen.Recipe.Id, out var chosenMam))
                        {
                            sameDayMains.Add(chosenMam.MainId);
                            mainUses[chosenMam.MainId] = mainUses.GetValueOrDefault(chosenMam.MainId) + 1;
                            if (chosenMam.SoupId is not null) soupUses[chosenMam.SoupId] = soupUses.GetValueOrDefault(chosenMam.SoupId) + 1;
                            if (chosenMam.VegId is not null) vegUses[chosenMam.VegId] = vegUses.GetValueOrDefault(chosenMam.VegId) + 1;
                        }
                        if (grp == "main") recentMain.Add(Score.MainProteinId(chosen.Recipe) ?? "");
                        var goal = SlotGoal(sc.Target);
                        // D-DES-01: chọn tráng miệng trước, trừ kcal/protein của nó khỏi chỉ tiêu bữa rồi mới scale món chính/cơm.
                        Recipe? dessert = null;
                        List<GramLine>? dessertLines = null;
                        var dm = Macros.Zero;
                        if (_style != MealStyle.FullMealOnly && _opt.IncludeDessert && slot is "lunch" or "dinner")
                        {
                            dessert = PickDessert(slot, sameDayDesserts, dessertUses, rng, goal);
                            if (dessert is not null)
                            {
                                dessertLines = DessertPortion(dessert, goal.Kcal);
                                dm = Nutrition.Compute(dessertLines, _data.IngredientsById).Total;
                                dessertUses[dessert.Id] = dessertUses.GetValueOrDefault(dessert.Id) + 1;
                                sameDayDesserts.Add(dessert.Id);
                            }
                        }
                        var meal = MakeMeal(date, slot, chosen.Recipe, chosen.ForceZeroCarb,
                            ScaleMeal(chosen.Recipe, new ScaleTarget(Math.Max(0, goal.Kcal - dm.Kcal), Math.Max(0, goal.ProteinG - dm.ProteinG)), chosen.ForceZeroCarb, out var riceWhy, out _));
                        meal.RiceReason = riceWhy;
                        if (dessert is not null)
                        {
                            meal.DessertId = dessert.Id;
                            meal.Dessert = dessertLines;
                            meal.Macros += dm;
                        }
                        else if (_style != MealStyle.FullMealOnly && _opt.IncludeDessert && slot is "lunch" or "dinner") meal.Warnings = ["dessert_missing"];
                        dayMeals.Add(meal);
                    }
                    meals.Add(dayMeals);
                }

                // 3. Tinh chỉnh theo ngày, ghép món phụ, chỉnh tinh.
                foreach (var dayMeals in meals)
                {
                    RefineDay(dayMeals);
                    if (_opt.Extras) AddExtras(dayMeals);
                    PolishDay(dayMeals);
                    RescueDayWithDessert(dayMeals);
                    if (it >= _opt.RiceRescueFromIteration) { RescueDayWithRice(dayMeals); RescueDayWithFullMeal(dayMeals); }
                }

                var plan = Finalize(meals, iterations, 0);
                // T-077: ở các vòng còn ưu tiên mâm (it < 3), vượt ngân sách thì sửa ngân sách ngay trên vòng này (đổi canh/rau rẻ hơn trước khi hạ xuống trọn suất)
                // thay vì bỏ vòng và sang vòng giảm ưu tiên mâm. Chỉ nhận khi sửa xong đạt 7/7; golden (full_meal_only) không đi nhánh này.
                if (plan.Status != "ready" && _style != MealStyle.FullMealOnly && _opt.BudgetRepair && it < 3 && plan.Validation.BudgetOverVnd > 0 && _unfilled.Count == 0)
                {
                    var work = meals.Select(d => d.Select(m => m.Clone()).ToList()).ToList();
                    var repairs = RepairDesserts(work) + RepairBudget(work);
                    if (repairs > 0)
                    {
                        var after = Finalize(work, iterations, repairs);
                        if (after.Status == "ready") { plan = after; meals = work; }
                    }
                }
                var badness = BadnessOf(plan.Validation, _targets);
                if (best is null || badness < best.Value.Badness) best = (plan, meals, badness);
                if (plan.Status == "ready") break;
            }

            var result = best!.Value.Plan;

            // 4. Sửa ngân sách.
            if (_opt.BudgetRepair && result.Validation.BudgetOverVnd > 0)
            {
                var work = best.Value.Meals.Select(d => d.Select(m => m.Clone()).ToList()).ToList();
                var repairs = RepairDesserts(work) + RepairBudget(work);
                if (repairs > 0)
                {
                    var after = Finalize(work, iterations, repairs);
                    if (BadnessOf(after.Validation, _targets) <= best.Value.Badness + 1e-9) result = after;
                }
            }
            result.Iterations = iterations;
            return result;
        }

        // -----------------------------------------------------------------------------------------

        /// <summary>Mâm đã có carb_base → không bù thêm cơm (extras cơm chỉ còn cho trọn suất).</summary>
        private bool HasCarbBase(PlanMeal m) => m.RecipeId is not null && _mam.TryGetValue(m.RecipeId, out var i) && i.HasCarbBase;

        private static string EquipKey(Recipe r) => string.Join("+", r.Equipment.OrderBy(x => x, StringComparer.Ordinal));

        /// <summary>
        /// Tối đa 15% calo bữa dành cho tráng miệng: món nặng hơn thì giảm gram các dòng scale được (bước 5 g).
        /// D-QA-04 / L-01: dòng cố định (min_g = max_g, vd đường trong chè) giữ nguyên gram công thức, không làm tròn; mọi gram kẹp trong [min_g, max_g].
        /// </summary>
        private List<GramLine> DessertPortion(Recipe d, double slotKcal)
        {
            var std = d.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList();
            var kcal = Nutrition.Compute(std, _data.IngredientsById).Total.Kcal;
            var f = kcal <= 0 ? 1 : Math.Clamp(0.15 * slotKcal / kcal, 0, 1);
            if (f >= 0.999) return std;
            return d.Ingredients.Select(i => new GramLine(i.IngredientId,
                i.MinG >= i.MaxG ? i.Grams : Math.Clamp(Math.Round(i.Grams * f / 5) * 5, i.MinG, i.MaxG))).ToList();
        }

        private Macros DessertMacros(PlanMeal m) => m.Dessert is { Count: > 0 } ? Nutrition.Compute(m.Dessert, _data.IngredientsById).Total : Macros.Zero;

        /// <summary>Phần nằm ngoài Grams: món thêm + tráng miệng.</summary>
        private Macros ExtrasMacros(PlanMeal m) => (m.Extras.Count > 0 ? Nutrition.Compute(m.Extras, _data.IngredientsById).Total : Macros.Zero) + DessertMacros(m);

        /// <summary>Chọn tráng miệng: hợp lệ (Ít tinh bột → low_carb_ok; trưa mang đi → portable), không trùng trong ngày (nếu còn lựa chọn), ít dùng nhất tuần này.</summary>
        private Recipe? PickDessert(string slot, List<string> sameDay, Dictionary<string, int> uses, Rng rng, (double Kcal, double ProteinG) goal)
        {
            var ok = _desserts.Where(d => (!_prefs.LowCarb || d.LowCarbOk) && !(slot == "lunch" && _prefs.Slots.LunchStyle == "packed" && !d.Portable)).ToList();
            if (ok.Count == 0) return null;
            var fresh = ok.Where(d => !sameDay.Contains(d.Id)).ToList();
            if (fresh.Count > 0) ok = fresh;
            // Ưu tiên món ít dùng, rẻ (so với chi phí tham chiếu một suất) và có chút ngẫu nhiên theo seed.
            // Chỉ tiêu bữa thấp → ưu tiên tráng miệng ít kcal và giàu đạm trên kcal (không nới ràng buộc cứng; chỉ đổi thứ tự ưu tiên).
            double Fit(Recipe d)
            {
                var m = Nutrition.Compute(d.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList(), _data.IngredientsById).Total;
                var heavy = Math.Max(0, m.Kcal / Math.Max(1, goal.Kcal) - 0.15);
                var need = goal.ProteinG / Math.Max(1, goal.Kcal);
                var deficit = Math.Max(0, need - m.ProteinG / Math.Max(1, m.Kcal));
                return -4 * heavy - 60 * deficit;
            }
            return ok.Select(d => (d, s: -uses.GetValueOrDefault(d.Id) + 0.5 * rng.Next() - 5 * CostOf(d) / Math.Max(1, _costRef) + Fit(d)))
                .OrderByDescending(x => x.s).ThenBy(x => x.d.Id, StringComparer.Ordinal).First().d;
        }

        private double SnackFloor(string slot) => _style != MealStyle.FullMealOnly && slot is "snack_am" or "snack_pm" ? _opt.SnackMinKcal : 0;

        private void RefineDay(List<PlanMeal> dayMeals)
        {
            var plannedMeals = dayMeals.Where(m => m.Status == "planned").ToList();
            for (var pass = 0; pass < _opt.RefinePasses; pass++)
            {
                var tot = DayTot(dayMeals);
                if (DayOk(tot.Kcal, tot.ProteinG)) return;
                var rp = _pGoal - tot.ProteinG;
                var rk = _kMid - tot.Kcal;
                foreach (var m in plannedMeals)
                {
                    var sc = _slotCtx[m.Slot];
                    var w = sc.Target.Share / _plannedShare;
                    var recipe = _data.RecipesById[m.RecipeId!];
                    // Phần ngoài công thức (tráng miệng + món thêm) giữ nguyên gram: RefineDay còn được gọi lại sau AddExtras (RepairDesserts), nên phải tính cả món thêm.
                    var dsM = ExtrasMacros(m);
                    var res = Scaler.Scale(recipe, _data.IngredientsById,
                        new ScaleTarget(Math.Max(Math.Max(0, (SnackFloor(m.Slot) > 0 ? SnackFloor(m.Slot) + 5 : 0) - dsM.Kcal), m.Macros.Kcal - dsM.Kcal + rk * w), Math.Max(0, m.Macros.ProteinG - dsM.ProteinG + rp * w)),
                        ScaleOpts(m));
                    m.Grams = res.Grams;
                    m.Macros = res.Macros + dsM;
                    m.ScaleInfeasible = res.Infeasible;
                }
            }
        }

        private void AddExtras(List<PlanMeal> dayMeals)
        {
            var eligible = dayMeals.Where(m => m.Status == "planned" && ExtraSlots.Contains(m.Slot)).ToList();
            if (eligible.Count == 0) return;
            MacrosPer100g Per(string id) => _data.IngredientsById[id].Per100g;
            void Put(PlanMeal m, string id, double g)
            {
                if (g < 5) return;
                var cur = m.Extras.FirstOrDefault(e => e.IngredientId == id);
                if (cur is not null) cur.Grams += g;
                else m.Extras.Add(new GramLine(id, g));
                m.Macros += Nutrition.Compute([new GramLine(id, g)], _data.IngredientsById).Total;
            }
            double ExtraG(PlanMeal m, string id) => m.Extras.FirstOrDefault(e => e.IngredientId == id)?.Grams ?? 0;
            var bySlotShare = eligible.OrderByDescending(m => _slotCtx[m.Slot].Target.Share).ToList();

            // Protein trước (thêm cả calo).
            if (_extrasPick.Protein is { } pid)
            {
                var p = Per(pid);
                var need = _pGoal - DayTot(dayMeals).ProteinG;
                foreach (var m in bySlotShare)
                {
                    if (need <= 0.5) break;
                    var kroom = _targets.KcalMax - DayTot(dayMeals).Kcal;
                    var gByKcal = Math.Floor(Math.Max(0, kroom) / (p.Kcal / 100) / 5) * 5;
                    var g = Math.Min(Math.Min(_opt.ExtraProteinMaxG - ExtraG(m, pid), Math.Ceiling(need / (p.ProteinG / 100) / 5) * 5), gByKcal);
                    Put(m, pid, g);
                    need = _pGoal - DayTot(dayMeals).ProteinG;
                }
            }
            // Calo: cơm/tinh bột; nếu bữa bị ép ít tinh bột hoặc không có tinh bột phụ thì dùng đạm phụ.
            var kneed = _kMid - DayTot(dayMeals).Kcal;
            if (kneed > 0 && DayTot(dayMeals).Kcal < _targets.KcalMin)
            {
                if (_extrasPick.Carb is { } carbId)
                {
                    var c = Per(carbId);
                    var slotsOk = bySlotShare.Where(m => !m.ForcedZeroCarb && !HasCarbBase(m)).ToList();
                    foreach (var m in slotsOk)
                    {
                        if (kneed <= 5) break;
                        var share = slotsOk.Count > 0 ? 1.0 / slotsOk.Count : 1.0;
                        var g = Math.Min(_opt.ExtraCarbMaxG - ExtraG(m, carbId), Math.Max(0, Round5(kneed * Math.Max(share, 0.5) / (c.Kcal / 100))));
                        Put(m, carbId, g);
                        kneed = _kMid - DayTot(dayMeals).Kcal;
                    }
                }
                kneed = _kMid - DayTot(dayMeals).Kcal;
                if (kneed > 20 && _extrasPick.Protein is { } pid2)
                {
                    var p = Per(pid2);
                    foreach (var m in bySlotShare)
                    {
                        if (kneed <= 5) break;
                        var g = Math.Min(_opt.ExtraProteinMaxG - ExtraG(m, pid2), Round5(kneed / (p.Kcal / 100)));
                        Put(m, pid2, g);
                        kneed = _kMid - DayTot(dayMeals).Kcal;
                    }
                }
            }
        }

        /// <summary>
        /// L-01: tráng miệng không còn được giảm dưới min_g nên ngày chật calo có thể thiếu vài gram đạm mà leo đồi cục bộ (±5 g) không thoát được.
        /// Ngày chưa đạt → thử đổi tráng miệng của từng bữa sang món hợp lệ khác (không trùng trong ngày), chỉnh tinh lại, giữ phương án đạt/ít vi phạm nhất.
        /// </summary>
        private void RescueDayWithDessert(List<PlanMeal> dayMeals)
        {
            if (_desserts.Count == 0) return;
            double Bad(List<PlanMeal> day) { var t = DayTot(day); return Math.Max(0, _targets.ProteinG - t.ProteinG) * 4 + Math.Max(0, _targets.KcalMin - t.Kcal) + Math.Max(0, t.Kcal - _targets.KcalMax); }
            var best = Bad(dayMeals);
            if (best <= 1e-9) return;
            List<PlanMeal>? bestDay = null;
            foreach (var m in dayMeals.Where(x => x.Status == "planned" && x.DessertId is not null))
                foreach (var alt in _desserts.Where(x => x.Id != m.DessertId &&
                    (!_prefs.LowCarb || x.LowCarbOk) && !(m.Slot == "lunch" && _prefs.Slots.LunchStyle == "packed" && !x.Portable) &&
                    !dayMeals.Any(o => !ReferenceEquals(o, m) && o.DessertId == x.Id)))
                {
                    var day = dayMeals.Select(x => x.Clone()).ToList();
                    var cm = day[dayMeals.IndexOf(m)];
                    var oldM = DessertMacros(cm);
                    cm.DessertId = alt.Id;
                    cm.Dessert = alt.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList();
                    cm.Macros = cm.Macros - oldM + DessertMacros(cm);
                    RefineDay(day);
                    PolishDay(day);
                    var b = Bad(day);
                    if (b < best - 1e-9) { best = b; bestDay = day; }
                    if (best <= 1e-9) break;
                }
            if (bestDay is null) return;
            for (var i = 0; i < dayMeals.Count; i++) dayMeals[i].CopyFrom(bestDay[i]);
        }

        /// <summary>
        /// D-COM-01: cơm được ghim đúng mức người dùng chọn. Ngày vẫn không đạt chỉ tiêu (kcal vượt trần hoặc thiếu đạm vì cơm chiếm chỗ)
        /// thì giảm cơm từng bước 25 g — bữa đang nhiều cơm nhất trước — đến sàn max(50% mức, 60 g), mỗi bước chỉnh lại các món còn lại;
        /// giữ phương án ít vi phạm nhất. Mọi bữa bị giảm cơm đều được ghi chú ở <see cref="FillRice"/>.
        /// <paramref name="mutable"/> (khi chỉnh tuần): chỉ được đụng các bữa này, các bữa khác giữ nguyên từng chữ số.
        /// </summary>
        private void RescueDayWithRice(List<PlanMeal> dayMeals, ICollection<PlanMeal>? mutable = null)
        {
            if (_style == MealStyle.FullMealOnly) return;
            double Bad(List<PlanMeal> day) { var t = DayTot(day); return Math.Max(0, _targets.ProteinG - t.ProteinG) * 4 + Math.Max(0, _targets.KcalMin - t.Kcal) + Math.Max(0, t.Kcal - _targets.KcalMax); }
            var best = Bad(dayMeals);
            if (best <= 1e-9) return;
            var reason = DayTot(dayMeals).Kcal > _targets.KcalMax ? "kcal" : "protein";
            var allowed = Enumerable.Range(0, dayMeals.Count).Where(i => mutable is null || mutable.Contains(dayMeals[i])).ToHashSet();
            var work = dayMeals.Select(x => x.Clone()).ToList();
            List<PlanMeal>? bestDay = null;
            for (var step = 0; step < 60; step++)
            {
                var pick = -1;
                double pickG = 0;
                for (var i = 0; i < work.Count; i++)
                {
                    var m = work[i];
                    if (!allowed.Contains(i) || m.Status != "planned" || m.RecipeId is null || !_mam.TryGetValue(m.RecipeId, out var info) || info.RiceIdx < 0) continue;
                    var cur = RiceNow(m)!.Value;
                    if (cur <= info.RiceFloorG + 1e-9) continue;
                    if (cur > pickG + 1e-9) { pick = i; pickG = cur; }
                }
                if (pick < 0) break;
                var pm = work[pick];
                var pinfo = _mam[pm.RecipeId!];
                var line = pm.Grams[pinfo.RiceIdx];
                var next = Math.Max(pinfo.RiceFloorG, line.Grams - RiceHabits.StepG);
                pm.Macros += Nutrition.MacrosOf(_data.IngredientsById[line.IngredientId], next - line.Grams);
                line.Grams = next;
                pm.RiceReason ??= reason;
                if (mutable is null) RefineDay(work);
                PolishDay(work, mutable is null ? null : work.Where((_, i) => allowed.Contains(i)).ToList());
                var b = Bad(work);
                if (b < best - 1e-9) { best = b; bestDay = work.Select(x => x.Clone()).ToList(); }
                if (best <= 1e-9) break;
            }
            if (bestDay is null) return;
            for (var i = 0; i < dayMeals.Count; i++) dayMeals[i].CopyFrom(bestDay[i]);
        }

        /// <summary>
        /// D-COM-01 bước 3: giảm cơm đến sàn mà ngày vẫn không đạt thì đổi một bữa mâm sang món trọn suất (tự có tinh bột, co giãn rộng hơn)
        /// — thử từng bữa mâm × từng món trọn suất hợp lệ, nhận phương án đưa ngày về đạt (ít vi phạm nhất).
        /// </summary>
        private void RescueDayWithFullMeal(List<PlanMeal> dayMeals)
        {
            if (_style == MealStyle.FullMealOnly) return;
            var t0 = DayTot(dayMeals);
            if (DayOk(t0.Kcal, t0.ProteinG)) return;
            var sameDay = dayMeals.Where(x => x.RecipeId is not null).Select(x => x.RecipeId!).ToHashSet();
            SwapTrial? best = null;
            var bestIdx = -1;
            for (var i = 0; i < dayMeals.Count; i++)
            {
                var cur = dayMeals[i];
                if (cur.Status != "planned" || cur.RecipeId is null || !_mam.ContainsKey(cur.RecipeId) || !_slotCtx.TryGetValue(cur.Slot, out var sc)) continue;
                foreach (var cand in sc.Cands)
                {
                    if (_mam.ContainsKey(cand.Recipe.Id) || sameDay.Contains(cand.Recipe.Id)) continue;
                    var trial = TrialSwap(dayMeals, cur, cand);
                    if (best is null || trial.Viol < best.Viol - 1e-9) { best = trial; bestIdx = i; }
                }
            }
            if (best is null || bestIdx < 0 || best.Viol >= Viol(t0) - 1e-9) return;
            dayMeals[bestIdx].CopyFrom(best.Meal);
        }

        private void PolishDay(List<PlanMeal> dayMeals, ICollection<PlanMeal>? mutable = null)
        {
            double Viol(double protein, double kcal) =>
                Math.Max(0, _targets.ProteinG - protein) * 4 + Math.Max(0, _targets.KcalMin - kcal) + Math.Max(0, kcal - _targets.KcalMax);
            var mealsP = dayMeals.Where(m => m.Status == "planned" && (mutable is null || mutable.Contains(m))).ToList();
            var extraIds = new[] { _extrasPick.Carb, _extrasPick.Protein }.Where(x => !string.IsNullOrEmpty(x)).Select(x => x!).ToList();
            for (var step = 0; step < 80; step++)
            {
                var tot = DayTot(dayMeals);
                var v0 = Viol(tot.ProteinG, tot.Kcal);
                if (v0 <= 1e-9) return;
                double bestV = 0;
                Action? bestApply = null;
                void Consider(string ingId, double d, Action apply)
                {
                    var dm = Nutrition.MacrosOf(_data.IngredientsById[ingId], d);
                    var v = Viol(tot.ProteinG + dm.ProteinG, tot.Kcal + dm.Kcal);
                    if (v < v0 - 1e-9 && (bestApply is null || v < bestV)) { bestV = v; bestApply = apply; }
                }
                foreach (var m in mealsP)
                {
                    var recipe = _data.RecipesById[m.RecipeId!];
                    for (var i = 0; i < recipe.Ingredients.Count; i++)
                    {
                        var li = recipe.Ingredients[i];
                        if ((li.Role != "protein" && li.Role != "carb") || li.MinG >= li.MaxG) continue;
                        if (li.Role == "carb" && m.ForcedZeroCarb) continue;
                        if (li.RiceTargetG is not null) continue; // cơm đã ghim theo mức người dùng chọn (D-COM-01); chỉ bước cứu ngày mới giảm
                        var gl = m.Grams[i];
                        foreach (var d in new[] { 5.0, -5.0 })
                        {
                            var g = gl.Grams + d;
                            if (g < li.MinG || g > li.MaxG) continue;
                            var dd = d;
                            var mm = m;
                            if (d < 0 && m.Macros.Kcal + Nutrition.MacrosOf(_data.IngredientsById[gl.IngredientId], d).Kcal < SnackFloor(m.Slot)) continue;
                            Consider(gl.IngredientId, d, () =>
                            {
                                gl.Grams = g;
                                mm.Macros += Nutrition.MacrosOf(_data.IngredientsById[gl.IngredientId], dd);
                            });
                        }
                    }
                    if (m.DessertId is not null && m.Dessert is not null)
                    {
                        // Khẩu phần tráng miệng là "núm" tinh chỉnh trong biên hẹp của công thức.
                        var dr = _data.RecipesById[m.DessertId];
                        for (var i = 0; i < dr.Ingredients.Count; i++)
                        {
                            var li = dr.Ingredients[i];
                            // Núm khẩu phần chỉ chạm dòng scale được và luôn trong [min_g, max_g] (D-QA-04); dòng cố định giữ nguyên.
                            if (li.MinG >= li.MaxG) continue;
                            var gl = m.Dessert[i];
                            foreach (var d in new[] { 5.0, -5.0 })
                            {
                                var g = gl.Grams + d;
                                if (g < li.MinG || g > li.MaxG) continue;
                                var dd = d;
                                var mm = m;
                                Consider(gl.IngredientId, d, () =>
                                {
                                    gl.Grams = g;
                                    mm.Macros += Nutrition.MacrosOf(_data.IngredientsById[gl.IngredientId], dd);
                                });
                            }
                        }
                    }
                    if (_opt.Extras && ExtraSlots.Contains(m.Slot))
                    {
                        foreach (var id in extraIds)
                        {
                            if (id == _extrasPick.Carb && (m.ForcedZeroCarb || HasCarbBase(m))) continue;
                            var cap = id == _extrasPick.Carb ? _opt.ExtraCarbMaxG : _opt.ExtraProteinMaxG;
                            var cur = m.Extras.FirstOrDefault(e => e.IngredientId == id);
                            foreach (var d in new[] { 5.0, -5.0 })
                            {
                                var g = (cur?.Grams ?? 0) + d;
                                if (g < 0 || g > cap) continue;
                                var dd = d;
                                var mm = m;
                                var idc = id;
                                Consider(id, d, () =>
                                {
                                    var e = mm.Extras.FirstOrDefault(x => x.IngredientId == idc);
                                    if (e is not null) e.Grams = g;
                                    else mm.Extras.Add(new GramLine(idc, g));
                                    mm.Extras = mm.Extras.Where(x => x.Grams > 0).ToList();
                                    mm.Macros += Nutrition.MacrosOf(_data.IngredientsById[idc], dd);
                                });
                            }
                        }
                    }
                }
                if (bestApply is null) return;
                bestApply();
            }
        }

        private sealed class Alt(Recipe recipe, bool zero, List<Substitution> subs, string key)
        {
            public Recipe Recipe { get; } = recipe;
            public bool Zero { get; } = zero;
            public List<Substitution> Subs { get; } = subs;
            public string Key { get; } = key;
        }

        private sealed class Cand
        {
            public int Day;
            public double Saving;
            public bool Downgrade;
            public PlanMeal Meal = null!;
            public Recipe VariantRecipe = null!;
            public ScaleResult Res = null!;
            public List<Substitution> Subs = [];
            public string Key = "";
        }

        private double UsedCost(List<List<PlanMeal>> mm) => ShoppingOf(mm).Items.Aggregate(0.0, (s, i) => s + i.UsedCostVnd);

        /// <summary>
        /// Vượt ngân sách: thử đổi tráng miệng sang món rẻ hơn (vẫn hợp lệ cho bữa, không trùng trong ngày), tính lại ngày, giữ nếu rẻ hơn và ngày không xấu đi.
        /// Tráng miệng không bị bỏ — chỉ đổi món (D-DES-01).
        /// </summary>
        private int RepairDesserts(List<List<PlanMeal>> meals)
        {
            if (_desserts.Count == 0) return 0;
            var budget = _prefs.WeeklyBudgetVnd;
            var applied = 0;
            var cost = UsedCost(meals);
            for (var iter = 0; iter < _opt.RepairIterations && cost > budget; iter++)
            {
                (int Day, List<PlanMeal> NewDay, double Cost)? best = null;
                for (var d = 0; d < meals.Count; d++)
                    foreach (var m in meals[d].Where(x => x.Status == "planned" && x.DessertId is not null))
                    {
                        var cur = _data.RecipesById[m.DessertId!];
                        foreach (var alt in _desserts.Where(x => x.Id != cur.Id && CostOf(x) < CostOf(cur) - 1e-9 &&
                            (!_prefs.LowCarb || x.LowCarbOk) && !(m.Slot == "lunch" && _prefs.Slots.LunchStyle == "packed" && !x.Portable) &&
                            !meals[d].Any(o => !ReferenceEquals(o, m) && o.DessertId == x.Id)))
                        {
                            var day = meals[d].Select(x => x.Clone()).ToList();
                            var cm = day[meals[d].IndexOf(m)];
                            var oldM = DessertMacros(cm);
                            cm.DessertId = alt.Id;
                            cm.Dessert = alt.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList();
                            cm.Macros = cm.Macros - oldM + DessertMacros(cm);
                            RefineDay(day);
                            PolishDay(day);
                            var before = DayTot(meals[d]);
                            var after = DayTot(day);
                            if (DayOk(before.Kcal, before.ProteinG) && !DayOk(after.Kcal, after.ProteinG)) continue;
                            var trial = meals.Select((dm, i) => i == d ? day : dm).ToList();
                            var c = UsedCost(trial);
                            if (c < cost - 1e-6 && (best is null || c < best.Value.Cost)) best = (d, day, c);
                        }
                    }
                if (best is null) break;
                meals[best.Value.Day] = best.Value.NewDay;
                cost = best.Value.Cost;
                applied++;
            }
            return applied;
        }

        private int RepairBudget(List<List<PlanMeal>> meals)
        {
            var budget = _prefs.WeeklyBudgetVnd;
            var cost = UsedCost(meals);
            if (cost <= budget) return 0;
            double MealCost(IEnumerable<GramLine> grams, IEnumerable<GramLine> std) =>
                Shopping.ServingCostVnd(grams, _data, _prefs.StoreId, Pa) + _others * Shopping.ServingCostVnd(std, _data, _prefs.StoreId, Pa);
            var swapPool = BuildSwapPool(_data, _banned);
            var tabu = new HashSet<string>();
            var applied = 0;

            for (var iter = 0; iter < _opt.RepairIterations; iter++)
            {
                if (ShoppingOf(meals).WeekFoodCost <= budget) break;
                Cand? bestC = null;

                var ranked = meals
                    .SelectMany((dm, day) => dm.Select((m, idx) => (m, day, idx)))
                    .Where(x => x.m.Status == "planned")
                    .Select(x => (x.m, x.day, x.idx, c: MealCost(x.m.Grams, x.m.StandardGrams)))
                    .OrderByDescending(x => x.c)
                    .Take(_opt.RepairMealsPerIter)
                    .ToList();

                foreach (var (m, day, _, curCost) in ranked)
                {
                    var sc = _slotCtx[m.Slot];
                    var baseRecipe = _data.RecipesById[m.RecipeId!];
                    var exM = ExtrasMacros(m);
                    var core = m.Macros - exM;
                    var target = new ScaleTarget(core.Kcal, core.ProteinG);
                    var dayTotNow = DayTot(meals[day]);
                    var wasOk = DayOk(dayTotNow.Kcal, dayTotNow.ProteinG);
                    var sameDay = meals[day].Where(x => !ReferenceEquals(x, m) && !string.IsNullOrEmpty(x.RecipeId)).Select(x => x.RecipeId!).ToHashSet();

                    // a) đổi sang công thức rẻ hơn cùng bữa
                    var sameDayMainIds = meals[day].Where(x => !ReferenceEquals(x, m) && x.RecipeId is not null && _mam.ContainsKey(x.RecipeId))
                        .Select(x => _mam[x.RecipeId!].MainId).ToHashSet();
                    var soupCount = new Dictionary<string, int>();
                    foreach (var o in meals.SelectMany(d => d))
                        if (!ReferenceEquals(o, m) && o.RecipeId is not null && _mam.TryGetValue(o.RecipeId, out var oi) && oi.SoupId is not null)
                            soupCount[oi.SoupId] = soupCount.GetValueOrDefault(oi.SoupId) + 1;
                    var altPool = sc.Cands
                        .Where(cd => cd.Recipe.Id != m.RecipeId && !(GroupOf(m.Slot) == "main" && sameDay.Contains(cd.Recipe.Id)))
                        .Where(cd => !_mam.TryGetValue(cd.Recipe.Id, out var ci) ||
                            (!sameDayMainIds.Contains(ci.MainId) && (ci.SoupId is null || soupCount.GetValueOrDefault(ci.SoupId) < _opt.MaxSoupUses)));
                    List<Alt> recipeAlts;
                    // T-077: bữa đang là mâm thì thử mâm rẻ hơn (đổi canh/rau/món chính) trước khi hạ cả mâm xuống trọn suất; lấy riêng N mâm rẻ nhất để trọn suất rẻ không chiếm hết chỗ.
                    var curIsMam = _style != MealStyle.FullMealOnly && _mam.ContainsKey(m.RecipeId!);
                    if (curIsMam)
                    {
                        var pool = altPool.ToList();
                        recipeAlts = pool.Where(cd => _mam.ContainsKey(cd.Recipe.Id)).OrderBy(cd => CostOf(cd.Recipe)).Take(_opt.RepairRecipeAlts)
                            .Concat(pool.Where(cd => !_mam.ContainsKey(cd.Recipe.Id)).OrderBy(cd => CostOf(cd.Recipe)).Take(_opt.RepairRecipeAlts))
                            .Select(cd => new Alt(cd.Recipe, cd.ForceZeroCarb, [], cd.Recipe.Id)).ToList();
                    }
                    else
                    {
                        recipeAlts = altPool.OrderBy(cd => CostOf(cd.Recipe)).Take(_opt.RepairRecipeAlts)
                            .Select(cd => new Alt(cd.Recipe, cd.ForceZeroCarb, [], cd.Recipe.Id)).ToList();
                    }

                    // b) đổi nguyên liệu (protein/carb) trong cùng swap_group sang loại rẻ hơn
                    var subAlts = new List<Alt>();
                    for (var i = 0; i < baseRecipe.Ingredients.Count; i++)
                    {
                        var li = baseRecipe.Ingredients[i];
                        if (string.IsNullOrEmpty(li.SwapGroup) || (li.Role != "protein" && li.Role != "carb")) continue;
                        var curIng = m.Grams[i].IngredientId;
                        if (!swapPool.TryGetValue($"{li.SwapGroup}|{li.Role}", out var poolIds)) continue;
                        foreach (var id in poolIds)
                        {
                            if (id == curIng) continue;
                            var ings = new List<RecipeIngredient>();
                            for (var j = 0; j < baseRecipe.Ingredients.Count; j++)
                            {
                                var x = baseRecipe.Ingredients[j];
                                ings.Add(new RecipeIngredient
                                {
                                    IngredientId = j == i ? id : m.Grams[j].IngredientId,
                                    Grams = x.Grams, Role = x.Role, MinG = x.MinG, MaxG = x.MaxG, SwapGroup = x.SwapGroup,
                                    RiceTargetG = x.RiceTargetG, RiceFloorG = x.RiceFloorG,
                                });
                            }
                            var subs = m.Substitutions.Where(s => s.To != curIng).ToList();
                            subs.Add(new Substitution(li.IngredientId, id));
                            subAlts.Add(new Alt(baseRecipe.WithIngredients(ings), m.ForcedZeroCarb, subs, $"{baseRecipe.Id}~{i}:{id}"));
                        }
                    }

                    foreach (var alt in recipeAlts.Concat(subAlts))
                    {
                        var key = $"{day}|{m.Slot}|{alt.Key}";
                        if (tabu.Contains(key)) continue;
                        var res = Scaler.Scale(alt.Recipe, _data.IngredientsById, target, new ScaleOptions { ForceZeroCarb = alt.Zero, RiceOverrideG = alt.Subs.Count > 0 ? RiceNow(m) : null });
                        var stdAlt = alt.Recipe.Ingredients.Select(x => new GramLine(x.IngredientId, x.Grams)).ToList();
                        var saving = curCost - MealCost(res.Grams, stdAlt);
                        var downgrade = curIsMam && !_mam.ContainsKey(alt.Recipe.Id);
                        if (saving <= 1) continue;
                        // Mâm rẻ hơn luôn được ưu tiên hơn việc hạ xuống trọn suất, dù trọn suất tiết kiệm nhiều hơn.
                        if (bestC is not null && (bestC.Downgrade == downgrade ? saving <= bestC.Saving : !bestC.Downgrade)) continue;
                        var newKcal = dayTotNow.Kcal - core.Kcal + res.Macros.Kcal;
                        var newProtein = dayTotNow.ProteinG - core.ProteinG + res.Macros.ProteinG;
                        if (wasOk && !DayOk(newKcal, newProtein)) continue;
                        if (!wasOk && (newProtein < dayTotNow.ProteinG - 1e-6 || Math.Abs(newKcal - _kMid) > Math.Abs(dayTotNow.Kcal - _kMid) + 1e-6)) continue;
                        bestC = new Cand { Day = day, Saving = saving, Meal = m, VariantRecipe = alt.Recipe, Res = res, Subs = alt.Subs, Key = key, Downgrade = downgrade };
                    }
                }
                if (bestC is null) break;

                var meal = bestC.Meal;
                var backup = meal.ShallowCopy();
                var isRecipeSwap = bestC.Subs.Count == 0; // (id mâm trưa mang đi cũng chứa '~' nên không dùng khoá để nhận biết)
                var exM2 = ExtrasMacros(meal);
                meal.RecipeId = isRecipeSwap ? bestC.VariantRecipe.Id : meal.RecipeId;
                meal.Grams = bestC.Res.Grams;
                meal.StandardGrams = bestC.VariantRecipe.Ingredients.Select(i => new GramLine(i.IngredientId, i.Grams)).ToList();
                meal.Substitutions = isRecipeSwap ? [] : bestC.Subs;
                meal.Macros = bestC.Res.Macros + exM2;
                meal.ScaleInfeasible = bestC.Res.Infeasible;
                if (isRecipeSwap) meal.ForcedZeroCarb = _slotCtx[meal.Slot].Cands.FirstOrDefault(c => c.Recipe.Id == bestC.VariantRecipe.Id)?.ForceZeroCarb ?? false;
                var newCost = UsedCost(meals);
                if (newCost < cost - 1e-6)
                {
                    cost = newCost;
                    applied++;
                }
                else
                {
                    meal.CopyFrom(backup);
                    // Giữ nguyên hành vi bản TS: khóa tabu có tiền tố lặp (nên thực tế không chặn được lần thử lại).
                    tabu.Add($"{bestC.Day}|{meal.Slot}|{bestC.Key}");
                }
            }
            return applied;
        }

        /// <summary>Chọn nguyên liệu phụ: tinh bột rẻ nhất theo kcal và đạm gọn/rẻ nhất theo gram protein (không bị cấm).</summary>
        private static (string? Carb, string? Protein) PickExtras(Dataset data, Dictionary<string, List<string>> banned, string storeId)
        {
            double Price(Ingredient i)
            {
                if (!data.PricesByIngredient.TryGetValue(i.Id, out var m)) return double.PositiveInfinity;
                if (m.TryGetValue(storeId, out var p) || m.TryGetValue("cho_khac", out p)) return p.PriceVnd / p.PackG;
                return double.PositiveInfinity;
            }
            (string Id, double V)? carb = null, protein = null;
            foreach (var i in data.Ingredients)
            {
                if (banned.ContainsKey(i.Id)) continue;
                var m = i.Per100g;
                var unit = Price(i);
                if (!double.IsFinite(unit)) continue;
                if (i.Aisle == "gao_do_kho" && m.CarbG >= 20 && m.ProteinG <= 10 && m.FatG <= 5 && m.Kcal >= 100)
                {
                    var v = unit / m.Kcal;
                    if (carb is null || v < carb.Value.V) carb = (i.Id, v);
                }
                if ((i.Aisle == "thit" || i.Aisle == "ca_hai_san") && m.ProteinG >= 15 && m.ProteinG / Math.Max(1, m.Kcal) >= 0.12)
                {
                    var v = unit / m.ProteinG;
                    if (protein is null || v < protein.Value.V) protein = (i.Id, v);
                }
            }
            return (carb?.Id, protein?.Id);
        }

        /// <summary>"{swap_group}|{role}" → nguyên liệu có thể thay (không bị cấm), lấy từ chính các công thức; sắp theo thứ tự ordinal.</summary>
        private static Dictionary<string, List<string>> BuildSwapPool(Dataset data, Dictionary<string, List<string>> banned)
        {
            var pool = new Dictionary<string, HashSet<string>>();
            foreach (var r in data.Recipes)
                foreach (var li in r.Ingredients)
                {
                    if (string.IsNullOrEmpty(li.SwapGroup) || banned.ContainsKey(li.IngredientId)) continue;
                    var key = $"{li.SwapGroup}|{li.Role}";
                    if (!pool.TryGetValue(key, out var set)) pool[key] = set = [];
                    set.Add(li.IngredientId);
                }
            return pool.ToDictionary(kv => kv.Key, kv => kv.Value.OrderBy(x => x, StringComparer.Ordinal).ToList());
        }

        /// <summary>Món batchable dùng nhiều lần: ghép từng 2 bữa liên tiếp thành "nấu 1 lần ăn 2 bữa".</summary>
        private static void AssignBatchGroups(List<PlanMeal> allMeals, Dataset data)
        {
            var byRecipe = new Dictionary<string, List<PlanMeal>>();
            foreach (var m in allMeals)
            {
                if (m.Status != "planned") continue;
                if (!byRecipe.TryGetValue(m.RecipeId!, out var list)) byRecipe[m.RecipeId!] = list = [];
                list.Add(m);
            }
            foreach (var (rid, list) in byRecipe)
            {
                var batchable = data.RecipesById[rid].Batchable;
                for (var i = 0; i < list.Count; i++)
                    list[i].BatchGroupId = batchable ? $"{rid}#{i / 2}" : $"{rid}#{list[i].Date}-{list[i].Slot}";
            }
        }

        private static double BadnessOf(WeekValidation v, Targets t)
        {
            var s = v.DaysMissing * 1000 + (v.BudgetOverVnd > 0 ? 100 + v.BudgetOverVnd / 1000 : 0);
            foreach (var f in v.Shortfalls) s += f.Kind == "protein_low" ? f.Amount / Math.Max(1, t.ProteinG) : f.Amount / Math.Max(1, t.KcalTarget);
            return s;
        }
    }
}
