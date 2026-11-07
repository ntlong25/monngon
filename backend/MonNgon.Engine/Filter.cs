using MonNgon.Engine.Types;

namespace MonNgon.Engine;

public sealed record Ban(string[] Allergens, string[] Diet);

public sealed record ValidRecipe(Recipe Recipe, bool ForceZeroCarb);

public sealed class FilterResult
{
    public List<ValidRecipe> Valid { get; init; } = [];
    /// <summary>recipe_id → lý do loại (để debug).</summary>
    public Dictionary<string, List<string>> Excluded { get; init; } = [];
}

/// <summary>Bộ lọc cứng (port filter.ts): Preferences → nguyên liệu bị cấm → công thức hợp lệ.</summary>
public static class Filter
{
    private static readonly string[] None = [];

    public static readonly IReadOnlyDictionary<string, Ban> ExclusionBans = new Dictionary<string, Ban>
    {
        ["no_pork"] = new(None, ["pork"]),
        ["no_red_meat"] = new(None, ["red_meat"]),
        ["no_gluten"] = new(["gluten"], None),
        ["no_dairy"] = new(["dairy"], ["dairy"]),
        ["no_egg"] = new(["egg"], ["egg"]),
        ["no_peanut"] = new(["peanut"], None),
        ["no_tree_nut"] = new(["tree_nut"], None),
        // D-QA-01 / L-03: "Không hạt giống & vừng" cấm cả tag seed và sesame (docs/research/allergen-rules.md); no_sesame chỉ cấm vừng.
        ["no_seed"] = new(["seed", "sesame"], None),
        ["no_sesame"] = new(["sesame"], None),
        ["no_soy"] = new(["soy"], None),
        ["no_fish"] = new(["fish"], ["fish"]),
        ["no_shellfish"] = new(["crustacean", "mollusc"], ["seafood"]),
    };

    public static string[] DietBans(string diet) => diet switch
    {
        "none" => [],
        "vegetarian" => ["meat", "poultry", "pork", "red_meat", "fish", "seafood"],
        "vegan" => ["meat", "poultry", "pork", "red_meat", "fish", "seafood", "egg", "dairy"],
        "pescatarian" => ["meat", "poultry", "pork", "red_meat"],
        _ => throw new ArgumentOutOfRangeException(nameof(diet), diet, null),
    };

    /// <summary>Tập nguyên liệu bị cấm → các lý do (vd "no_peanut", "diet:vegan", "disliked").</summary>
    public static Dictionary<string, List<string>> BannedIngredients(IEnumerable<Ingredient> ingredients, Preferences prefs)
    {
        var dietBan = DietBans(prefs.Diet).ToHashSet();
        var disliked = prefs.DislikedIngredientIds.ToHashSet();
        var res = new Dictionary<string, List<string>>();
        foreach (var ing in ingredients)
        {
            var reasons = new List<string>();
            foreach (var ex in prefs.Exclusions)
            {
                var ban = ExclusionBans[ex];
                if (ban.Allergens.Any(a => ing.AllergenTags.Contains(a)) || ban.Diet.Any(d => ing.DietTags.Contains(d))) reasons.Add(ex);
            }
            if (ing.DietTags.Any(dietBan.Contains)) reasons.Add($"diet:{prefs.Diet}");
            if (disliked.Contains(ing.Id)) reasons.Add("disliked");
            if (reasons.Count > 0) res[ing.Id] = reasons;
        }
        return res;
    }

    public static FilterResult FilterRecipes(IEnumerable<Recipe> recipes, IReadOnlyDictionary<string, Ingredient> ingredientsById, IEnumerable<Ingredient> ingredientsInOrder, Preferences prefs)
    {
        var banned = BannedIngredients(ingredientsInOrder, prefs);
        var blocked = prefs.BlockedRecipeIds.ToHashSet();
        var have = prefs.Equipment.ToHashSet();
        var res = new FilterResult();
        foreach (var recipe in recipes)
        {
            var why = new List<string>();
            if (blocked.Contains(recipe.Id)) why.Add("blocked");
            foreach (var li in recipe.Ingredients)
            {
                if (!ingredientsById.ContainsKey(li.IngredientId)) why.Add($"unknown_ingredient:{li.IngredientId}");
                if (banned.TryGetValue(li.IngredientId, out var b)) why.Add($"ingredient:{li.IngredientId}({string.Join("+", b)})");
            }
            var missing = recipe.Equipment.Where(e => !have.Contains(e)).ToList();
            if (missing.Count > 0) why.Add($"equipment:{string.Join(",", missing)}");

            if (why.Count > 0) res.Excluded[recipe.Id] = why;
            else res.Valid.Add(new ValidRecipe(recipe, false));
        }
        return res;
    }

    /// <summary>
    /// Công thức dùng được cho 1 slot: đúng meal_type; trưa khớp hot/packed; phụ chiều khớp ngọt/mặn;
    /// Ít tinh bột → trưa/tối chỉ nhận is_low_carb và ép carb = 0.
    /// </summary>
    public static List<ValidRecipe> RecipesForSlot(IEnumerable<ValidRecipe> valid, string slot, SlotsConfig cfg, bool lowCarb)
    {
        var res = new List<ValidRecipe>();
        foreach (var v in valid)
        {
            var r = v.Recipe;
            if (!r.MealTypes.Contains(slot)) continue;
            if (slot == "lunch" && r.LunchStyle.Count > 0 && !r.LunchStyle.Contains(cfg.LunchStyle)) continue;
            if (slot == "snack_pm" && r.SnackStyle is not null && r.SnackStyle != cfg.SnackPmStyle) continue;
            if (lowCarb && slot is "lunch" or "dinner")
            {
                if (!r.IsLowCarb) continue;
                res.Add(new ValidRecipe(r, true));
            }
            else res.Add(new ValidRecipe(r, false));
        }
        return res;
    }
}
