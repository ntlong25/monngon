using System.ComponentModel;
using MonNgon.Engine;
using MonNgon.Engine.Types;

namespace MonNgon.Api;

public sealed class TargetsRequest
{
    public Profile Profile { get; set; } = new();
}

public sealed class SlotsPreviewRequest
{
    public Profile Profile { get; set; } = new();
    public SlotsConfig Slots { get; set; } = new();
}

public sealed class SlotsPreviewResponse
{
    public required Targets Targets { get; init; }
    public required List<SlotTarget> Slots { get; init; }
}

public sealed class RiceFeasibilityResponse
{
    public required Targets Targets { get; init; }
    /// <summary>Mỗi mức cơm (it, vua, nhieu, rat_nhieu): mức chọn, mức khả thi theo chỉ tiêu bữa, có cần cảnh báo ở bước chọn thói quen ăn cơm không.</summary>
    public required List<RiceFeasibilityItem> Habits { get; init; }
}

public sealed class BudgetTargetsDto
{
    public double? KcalTarget { get; set; }
    public double? ProteinG { get; set; }
}

public sealed class BudgetRangeRequest
{
    [Description("Bắt buộc: chỉ tiêu đã tính ở bước \"chỉ tiêu\" (kcal_target, protein_g).")]
    public BudgetTargetsDto? Targets { get; set; }

    [Description("Nguồn đầy đủ (khuyến nghị): có thì lọc món theo kiêng/ghét/dụng cụ trước khi tính, và store/adults/children/slots lấy từ đây; "
        + "các trường cùng tên ở cấp ngoài (store_id, adults, children, slots) bị bỏ qua. "
        + "Không có thì phải gửi ít nhất một trong các trường cấp ngoài, nếu không → 400.")]
    public Preferences? Preferences { get; set; }

    [Description("Chỉ dùng khi KHÔNG có preferences. Mặc định \"cho_khac\".")]
    public string? StoreId { get; set; }

    [Description("Chỉ dùng khi KHÔNG có preferences. 1–6, mặc định 1.")]
    public int? Adults { get; set; }

    [Description("Chỉ dùng khi KHÔNG có preferences. 0–4, mặc định 0.")]
    public int? Children { get; set; }

    [Description("Chỉ dùng khi KHÔNG có preferences. Mặc định: ăn sáng/trưa/tối, bỏ bữa phụ.")]
    public SlotsConfig? Slots { get; set; }
}

public sealed class BudgetTierDto
{
    /// <summary>economy | moderate | comfortable — nhãn hiển thị lấy từ content/i18n.</summary>
    public required string Key { get; init; }
    public required double FromVnd { get; init; }
    public required double ToVnd { get; init; }
}

public sealed class BudgetRangeResponse
{
    public required double MinVnd { get; init; }
    public required double MaxVnd { get; init; }
    public required double StepVnd { get; init; }
    public required double EstimateVnd { get; init; }
    public required List<BudgetTierDto> Tiers { get; init; }
    /// <summary>"week_food_cost": chi phí món ăn theo gram dùng, không phải tiền trả tại quầy.</summary>
    public required string Basis { get; init; }
}

public sealed class PlanRequest
{
    public Profile Profile { get; set; } = new();
    public Preferences Preferences { get; set; } = new();
    /// <summary>YYYY-MM-DD; người gọi quyết định "ngày mai".</summary>
    public string StartDate { get; set; } = "";
    /// <summary>Mặc định 1. Đổi seed để "tạo lại" một tuần khác.</summary>
    public long? Seed { get; set; }
    /// <summary>auto (mặc định: trọn suất hoặc mâm) | full_meal_only (hành vi cũ, không ghép mâm) | mam_only.</summary>
    public string MealStyle { get; set; } = "auto";
    /// <summary>Thêm 1 món tráng miệng vào mỗi bữa trưa/tối (D-DES-01). Bỏ qua khi meal_style = full_meal_only.</summary>
    public bool IncludeDessert { get; set; } = true;
}

/// <summary>Trạng thái tuần máy khách gửi lên cho các thao tác chỉnh tuần (stateless): hồ sơ, lựa chọn và đúng WeekPlan đã nhận.</summary>
public sealed class PlanStateDto
{
    public Profile Profile { get; set; } = new();
    public Preferences Preferences { get; set; } = new();
    public WeekPlan Plan { get; set; } = new();
    /// <summary>Như lúc lập tuần (mặc định true). Chỉ có tác dụng khi meal_style ≠ full_meal_only.</summary>
    public bool IncludeDessert { get; set; } = true;
}

public sealed class SwapSuggestionsRequest
{
    public PlanStateDto State { get; set; } = new();
    /// <summary>YYYY-MM-DD của bữa cần đổi.</summary>
    public string Date { get; set; } = "";
    public string Slot { get; set; } = "";
    /// <summary>Số gợi ý tối đa (1–5, mặc định 3).</summary>
    public int? Limit { get; set; }
}

public sealed class ApplySwapRequest
{
    public PlanStateDto State { get; set; } = new();
    public string Date { get; set; } = "";
    public string Slot { get; set; } = "";
    /// <summary>recipe_id của một gợi ý (công thức trọn suất hoặc mâm "mam:…").</summary>
    public string RecipeId { get; set; } = "";
}

public sealed class IngredientOptionsRequest
{
    public PlanStateDto State { get; set; } = new();
    public string Date { get; set; } = "";
    public string Slot { get; set; } = "";
    /// <summary>Nguyên liệu đang có trong bữa muốn thay.</summary>
    public string IngredientId { get; set; } = "";
}

public sealed class SwapIngredientRequest
{
    public PlanStateDto State { get; set; } = new();
    public string Date { get; set; } = "";
    public string Slot { get; set; } = "";
    public string FromIngredientId { get; set; } = "";
    public string ToIngredientId { get; set; } = "";
}

public sealed class EatOutRequest
{
    public PlanStateDto State { get; set; } = new();
    public string Date { get; set; } = "";
    public string Slot { get; set; } = "";
    /// <summary>eat_out (ăn ngoài) | skip (bỏ bữa) | undo (hoàn tác).</summary>
    public string Mode { get; set; } = "";
}

public sealed class RegenerateRestRequest
{
    public PlanStateDto State { get; set; } = new();
    /// <summary>YYYY-MM-DD: các ngày ≤ today giữ nguyên, các ngày sau được lập lại.</summary>
    public string Today { get; set; } = "";
    /// <summary>Mặc định seed của tuần + 1 (ra kết quả khác lần trước).</summary>
    public long? Seed { get; set; }
}

public sealed class TraceLine
{
    public required string IngredientId { get; init; }
    public required string Name { get; init; }
    public required double Grams { get; init; }
    public required Macros Macros { get; init; }
    /// <summary>Nguồn dữ liệu dinh dưỡng, ví dụ "USDA FDC #171077".</summary>
    public required string Source { get; init; }
}

public sealed class MealTrace
{
    public required string Date { get; init; }
    public required string Slot { get; init; }
    public required string RecipeId { get; init; }
    public required List<TraceLine> Lines { get; init; }
    public required List<TraceLine> Extras { get; init; }
    /// <summary>Các dòng nguyên liệu của món tráng miệng (rỗng nếu bữa không có); đã nằm trong total.</summary>
    public required List<TraceLine> Dessert { get; init; }
    /// <summary>Tổng macro cả bữa (chưa làm tròn), cộng từ các dòng trên; khớp macros của bữa trong plan.</summary>
    public required Macros Total { get; init; }
}

public sealed class PlanResponse
{
    public required Targets Targets { get; init; }
    public required WeekPlan Plan { get; init; }
    /// <summary>"Cách chúng mình tính": từng dòng nguyên liệu của từng bữa kèm nguồn.</summary>
    public required List<MealTrace> Trace { get; init; }
    public required string DataVersion { get; init; }
    /// <summary>Mọi công thức xuất hiện trong tuần (kể cả món của mâm, tráng miệng, mâm "mam:...") — xem offline, không cần GET /v1/recipes/{id}.</summary>
    public required Dictionary<string, Recipe> Recipes { get; init; }
    /// <summary>Mọi nguyên liệu xuất hiện trong tuần (kể cả món thêm, tráng miệng, nguyên liệu thay thế).</summary>
    public required Dictionary<string, IngredientInfoDto> Ingredients { get; init; }
}

public sealed class StoreDto
{
    public required string Id { get; init; }
    public required string Name { get; init; }
    public string? PriceSurveyDate { get; init; }
}

public sealed class OptionDto
{
    public required string Id { get; init; }
    public required string Name { get; init; }
    /// <summary>Phạm vi nguyên liệu bị loại (thẻ dị ứng/chế độ ăn) để UI nói rõ lựa chọn bao gồm gì.</summary>
    public List<string> Bans { get; init; } = [];
    /// <summary>Mô tả ngắn lấy từ dữ liệu thật (nguyên liệu nào bị loại / thẻ nào được ưu tiên).</summary>
    public string Description { get; init; } = "";
    /// <summary>diet | exclusion | health | equipment</summary>
    public string Group { get; init; } = "";
}

public sealed class SwipeCardDto
{
    public string Id { get; set; } = "";
    public string Tag { get; set; } = "";
    public string Title { get; set; } = "";
    public string Subtitle { get; set; } = "";
    public List<string> SampleRecipeIds { get; set; } = [];
}

public sealed class ReferenceResponse
{
    public required string DataVersion { get; init; }
    public required List<StoreDto> Stores { get; init; }
    public required List<OptionDto> Equipment { get; init; }
    public required List<OptionDto> Exclusions { get; init; }
    public required List<OptionDto> Diets { get; init; }
    public required List<SwipeCardDto> SwipeCards { get; init; }
    public required List<OptionDto> HealthLeanings { get; init; }
    /// <summary>Gợi ý chip "không muốn thấy" (nguyên liệu hay bị ghét có trong kho).</summary>
    public required List<IngredientDto> DislikeSuggestions { get; init; }
    /// <summary>aisle id → tên quầy.</summary>
    public required Dictionary<string, string> Aisles { get; init; }
    public required int RecipeCount { get; init; }
    public required int IngredientCount { get; init; }
}

public sealed class IngredientDto
{
    public required string Id { get; init; }
    public required string Name { get; init; }
    public required string Aisle { get; init; }
    /// <summary>Quy đổi đơn vị bếp, ví dụ { unit: "thìa canh", grams: 15 } → "≈ 1 thìa canh".</summary>
    public List<HouseholdUnit> HouseholdUnits { get; init; } = [];
    public bool DefaultPantry { get; init; }
}

public sealed class IngredientInfoDto
{
    public required string Name { get; init; }
    public required string Aisle { get; init; }
    public List<HouseholdUnit> HouseholdUnits { get; init; } = [];
    public bool DefaultPantry { get; init; }
    /// <summary>D-SHP-02: nguyên liệu này được mua dưới dạng nguyên liệu khác (cơm → gạo); dùng để ghi "≈ X g gạo" ở dòng nguyên liệu. Nguyên liệu đích luôn có trong `ingredients`.</summary>
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull)]
    public PurchaseAs? PurchaseAs { get; init; }
}

public sealed class ShoppingLineDto
{
    public string IngredientId { get; set; } = "";
    /// <summary>Gram của "bạn" sau scale.</summary>
    public double Grams { get; set; }
    /// <summary>Khẩu phần chuẩn của công thức (cho người ăn cùng); 0 với món thêm.</summary>
    public double StandardGrams { get; set; }
}

public sealed class ShoppingMealDto
{
    public List<ShoppingLineDto> Ingredients { get; set; } = [];
    /// <summary>true = bữa ăn ngoài: bỏ khỏi danh sách đi chợ.</summary>
    public bool EatenOut { get; set; }
}

public sealed class ShoppingListRequest
{
    public List<ShoppingMealDto> Meals { get; set; } = [];
    public string StoreId { get; set; } = "cho_khac";
    public int Adults { get; set; } = 1;
    public int Children { get; set; }
    /// <summary>
    /// Nguyên liệu "nhà có sẵn" (D-SHP-01). Không gửi trường này → dùng danh sách `default_pantry`; gửi `[]` → không coi gì là có sẵn.
    /// Dòng nhà có sẵn vẫn có trong `items` (cờ `is_pantry`) nhưng không tính vào `till_cost`; `week_food_cost` vẫn tính gram đã dùng của mọi dòng.
    /// </summary>
    public List<string>? PantryIds { get; set; }
}

public sealed class RecipeDetailResponse
{
    public required Recipe Recipe { get; init; }
    /// <summary>Macro khẩu phần chuẩn (chưa làm tròn) kèm nguồn từng dòng.</summary>
    public required MacroResult Macros { get; init; }
}
