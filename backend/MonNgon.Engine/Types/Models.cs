using System.Text.Json.Serialization;

namespace MonNgon.Engine.Types;

// Hợp đồng dữ liệu v0.2 (xem docs/pm/backlog.md). Giá trị liệt kê dùng chuỗi snake_case giống JSON.

public static class Enums
{
    public static readonly string[] Aisles = ["thit", "ca_hai_san", "trung_dau_phu", "rau_cu", "trai_cay", "gao_do_kho", "gia_vi_dau", "sua"];
    public static readonly string[] AllergenTags = ["peanut", "tree_nut", "seed", "sesame", "gluten", "dairy", "egg", "soy", "fish", "crustacean", "mollusc"];
    public static readonly string[] DietTags = ["meat", "poultry", "pork", "red_meat", "fish", "seafood", "egg", "dairy", "plant"];
    public static readonly string[] MealTypes = ["breakfast", "lunch", "dinner", "snack_am", "snack_pm"];
    public static readonly string[] Roles = ["protein", "carb", "veg", "fat", "seasoning"];
    public static readonly string[] Equipment = ["bep", "noi_com_dien", "lo_vi_song", "noi_chien_khong_dau", "lo_nuong", "noi_ap_suat", "may_xay"];
    public static readonly string[] DishRoles = ["full_meal", "main", "soup", "side_veg", "carb_base", "dessert"];
    public static readonly string[] Slots = ["breakfast", "lunch", "dinner", "snack_am", "snack_pm"];
    public static readonly string[] SlotModes = ["on", "self", "skip"];
    public static readonly string[] Goals = ["lose", "hold", "build"];
    public static readonly string[] Sexes = ["male", "female"];
    public static readonly string[] Activities = ["sedentary", "light", "moderate", "high", "athlete"];
    public static readonly string[] Diets = ["none", "vegetarian", "vegan", "pescatarian"];
    public static readonly string[] RiceHabits = ["it", "vua", "nhieu", "rat_nhieu"];
    public static readonly string[] Exclusions =
        ["no_pork", "no_red_meat", "no_gluten", "no_dairy", "no_egg", "no_peanut", "no_tree_nut", "no_seed", "no_sesame", "no_soy", "no_fish", "no_shellfish"];
}

public sealed class MacrosPer100g
{
    public double Kcal { get; set; }
    public double ProteinG { get; set; }
    public double CarbG { get; set; }
    public double FatG { get; set; }
    public double FiberG { get; set; }
}

public sealed class Source
{
    public string Db { get; set; } = "";
    public string Code { get; set; } = "";
    public string Note { get; set; } = "";
}

public sealed class HouseholdUnit
{
    public string Unit { get; set; } = "";
    public double Grams { get; set; }
}

/// <summary>D-SHP-02: nguyên liệu này được mua dưới dạng nguyên liệu khác (cơm chín → gạo sống): 1 g nguyên liệu = `factor` g của `ingredient_id`.</summary>
public sealed class PurchaseAs
{
    public string IngredientId { get; set; } = "";
    public double Factor { get; set; }
}

public sealed class Ingredient
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public List<string> Aliases { get; set; } = [];
    public string Aisle { get; set; } = "";
    [JsonPropertyName("per_100g")] public MacrosPer100g Per100g { get; set; } = new();
    public Source Source { get; set; } = new();
    public List<string> AllergenTags { get; set; } = [];
    public List<string> DietTags { get; set; } = [];
    public List<HouseholdUnit> HouseholdUnits { get; set; } = [];
    public double EdiblePortion { get; set; } = 1;
    public bool DefaultPantry { get; set; }
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public PurchaseAs? PurchaseAs { get; set; }
}

public sealed class RecipeIngredient
{
    public string IngredientId { get; set; } = "";
    public double Grams { get; set; }
    public string Role { get; set; } = "";
    public double MinG { get; set; }
    public double MaxG { get; set; }
    public string? SwapGroup { get; set; }
    /// <summary>D-COM-01: chỉ có ở dòng cơm/tinh bột của mâm — lượng người dùng chọn (gram của chính nguyên liệu này); Scale ghim dòng này, không co giãn tự do.</summary>
    [JsonIgnore]
    public double? RiceTargetG { get; set; }
    /// <summary>D-COM-01: sàn khi buộc phải giảm cơm.</summary>
    [JsonIgnore]
    public double? RiceFloorG { get; set; }
}

public sealed class Recipe
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public List<string> MealTypes { get; set; } = [];
    public List<string> LunchStyle { get; set; } = [];
    public string? SnackStyle { get; set; }
    public List<string> CuisineTags { get; set; } = [];
    public List<string> HealthTags { get; set; } = [];
    public List<string> Equipment { get; set; } = [];
    public double CookMinutes { get; set; }
    public bool Batchable { get; set; }
    public bool IsLowCarb { get; set; }
    public List<RecipeIngredient> Ingredients { get; set; } = [];
    public List<string> Steps { get; set; } = [];
    public string? Image { get; set; }
    /// <summary>v0.2: mặc định full_meal. Engine bản parity (T-064) bỏ qua trường này.</summary>
    public string DishRole { get; set; } = "full_meal";
    public List<string> PairsWith { get; set; } = [];
    /// <summary>v0.3 (dessert): mang đi được (trái cây nguyên quả, sữa hộp, sữa chua) — dùng cho trưa mang đi.</summary>
    public bool Portable { get; set; }
    /// <summary>v0.3 (dessert): dùng được khi chế độ Ít tinh bột.</summary>
    public bool LowCarbOk { get; set; }

    /// <summary>
    /// Nhóm ảnh placeholder (Q5: ảnh thật do người dùng cung cấp sau): kho | xao | canh | luoc_hap | com | sang | phu.
    /// Suy ra từ dish_role / meal_types / cuisine_tags; chỉ để đọc (không nằm trong data/).
    /// </summary>
    public string ImageGroup => ComputeImageGroup();

    private string ComputeImageGroup()
    {
        if (DishRole == "dessert") return "phu";
        var main = MealTypes.Any(t => t is "lunch" or "dinner");
        if (!main && MealTypes.Contains("breakfast")) return "sang";
        if (!main && MealTypes.Any(t => t is "snack_am" or "snack_pm")) return "phu";
        if (DishRole == "soup") return "canh";
        if (DishRole == "carb_base") return "com";
        foreach (var (tag, group) in new[] { ("kho", "kho"), ("rim", "kho"), ("ham", "kho"), ("canh", "canh"), ("xao", "xao"), ("chao", "xao"), ("chien", "xao"), ("luoc", "luoc_hap"), ("hap", "luoc_hap"), ("com", "com"), ("bun", "com") })
            if (CuisineTags.Contains(tag)) return group;
        return DishRole == "side_veg" ? "luoc_hap" : "xao";
    }

    /// <summary>Bản sao nông với danh sách nguyên liệu khác (dùng khi đổi nguyên liệu ở bước sửa ngân sách).</summary>
    public Recipe WithIngredients(List<RecipeIngredient> ingredients)
    {
        var r = (Recipe)MemberwiseClone();
        r.Ingredients = ingredients;
        return r;
    }
}

public sealed class Store
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public string? PriceSurveyDate { get; set; }
}

public sealed class Price
{
    public string IngredientId { get; set; } = "";
    public string StoreId { get; set; } = "";
    public double PackG { get; set; }
    public string PackLabel { get; set; } = "";
    public double PriceVnd { get; set; }
    public int ShelfLifeDays { get; set; }
    public string? SourceUrl { get; set; }
    public string? SurveyedOn { get; set; }
}

// ----- Hồ sơ & lựa chọn người dùng -----

public sealed class Profile
{
    public string Goal { get; set; } = "";
    public string Sex { get; set; } = "";
    public double Age { get; set; }
    public double HeightCm { get; set; }
    public double WeightKg { get; set; }
    public string Activity { get; set; } = "";
    public string TargetMode { get; set; } = "formula";
    public double? ManualKcal { get; set; }
    public double? ManualProteinG { get; set; }
}

public sealed class SlotsConfig
{
    public string Breakfast { get; set; } = "on";
    public string Lunch { get; set; } = "on";
    public string Dinner { get; set; } = "on";
    public string SnackAm { get; set; } = "skip";
    public string SnackPm { get; set; } = "skip";
    public string LunchStyle { get; set; } = "hot";
    public string SnackPmStyle { get; set; } = "savory";

    public string Mode(string slot) => slot switch
    {
        "breakfast" => Breakfast, "lunch" => Lunch, "dinner" => Dinner, "snack_am" => SnackAm, "snack_pm" => SnackPm,
        _ => throw new ArgumentOutOfRangeException(nameof(slot), slot, null),
    };
}

public sealed class Preferences
{
    public string StoreId { get; set; } = "";
    public double WeeklyBudgetVnd { get; set; }
    public int Adults { get; set; } = 1;
    public int Children { get; set; }
    public SlotsConfig Slots { get; set; } = new();
    public string Diet { get; set; } = "none";
    public bool LowCarb { get; set; }
    public List<string> Exclusions { get; set; } = [];
    public List<string> DislikedIngredientIds { get; set; } = [];
    public List<string> HealthLeanings { get; set; } = [];
    public List<string> CuisineLikes { get; set; } = [];
    public List<string> CuisineLess { get; set; } = [];
    public List<string> Equipment { get; set; } = [];
    public List<string> BlockedRecipeIds { get; set; } = [];
    /// <summary>D-COM-01: thói quen ăn cơm của người dùng chính (it | vua | nhieu | rat_nhieu). Thiếu = vua.</summary>
    public string RiceHabit { get; set; } = "vua";
}
