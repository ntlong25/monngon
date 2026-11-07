import '../api/generated/models.dart';
import '../l10n/gen/app_localizations.dart';

/// Nhãn hiển thị cho các mã (wire value) của API, lấy từ i18n. Mã lạ → dùng tên server gửi ([fallback]) hoặc chính mã.
abstract final class Labels {
  /// Vai trò món trong mâm.
  static String dishRole(AppL10n l, String role) => switch (role) {
    'main' => l.dishRoleMain,
    'soup' => l.dishRoleSoup,
    'side_veg' => l.dishRoleSideVeg,
    'carb_base' => l.dishRoleCarbBase,
    'dessert' => l.dishRoleDessert,
    'extra' => l.dishRoleExtra,
    _ => l.dishRoleFullMeal,
  };

  /// 1 = Thứ Hai … 7 = Chủ nhật (như `DateTime.weekday`).
  static String weekday(AppL10n l, int weekday) => switch (weekday) {
    1 => l.weekday1,
    2 => l.weekday2,
    3 => l.weekday3,
    4 => l.weekday4,
    5 => l.weekday5,
    6 => l.weekday6,
    _ => l.weekday7,
  };

  static String goal(AppL10n l, String id) => switch (id) {
    'lose' => l.onboardingGoalLose,
    'hold' => l.onboardingGoalHold,
    'build' => l.onboardingGoalBuild,
    _ => id,
  };

  static String sex(AppL10n l, String id) => switch (id) {
    'male' => l.onboardingBodySexMale,
    'female' => l.onboardingBodySexFemale,
    _ => id,
  };

  static String activity(AppL10n l, String id) => switch (id) {
    'sedentary' => l.onboardingBodyActivitySedentary,
    'light' => l.onboardingBodyActivityLight,
    'moderate' => l.onboardingBodyActivityModerate,
    'high' => l.onboardingBodyActivityHigh,
    'athlete' => l.onboardingBodyActivityAthlete,
    _ => id,
  };

  static String slot(AppL10n l, String id) => switch (id) {
    'breakfast' => l.onboardingMealsBreakfast,
    'lunch' => l.onboardingMealsLunch,
    'dinner' => l.onboardingMealsDinner,
    'snack_am' => l.onboardingMealsSnackAm,
    'snack_pm' => l.onboardingMealsSnackPm,
    _ => id,
  };

  static String slotMode(AppL10n l, String id) => switch (id) {
    'on' => l.onboardingMealsOn,
    'self' => l.onboardingMealsSelf,
    'skip' => l.onboardingMealsOff,
    _ => id,
  };

  static String equipment(AppL10n l, OptionDto o) => switch (o.id) {
    'bep' => l.onboardingEquipmentStove,
    'noi_com_dien' => l.onboardingEquipmentRiceCooker,
    'lo_vi_song' => l.onboardingEquipmentMicrowave,
    'noi_chien_khong_dau' => l.onboardingEquipmentAirFryer,
    'lo_nuong' => l.onboardingEquipmentOven,
    'noi_ap_suat' => l.onboardingEquipmentPressureCooker,
    'may_xay' => l.onboardingEquipmentBlender,
    _ => o.name,
  };

  static String exclusion(AppL10n l, OptionDto o) => switch (o.id) {
    'no_pork' => l.onboardingDietNoPork,
    'no_red_meat' => l.onboardingDietNoRedMeat,
    'no_gluten' => l.onboardingDietNoGluten,
    'no_dairy' => l.onboardingDietNoDairy,
    'no_egg' => l.onboardingDietNoEgg,
    'no_peanut' => l.onboardingDietNoPeanut,
    'no_tree_nut' => l.onboardingDietNoTreeNut,
    'no_seed' => l.onboardingDietNoSeed,
    'no_sesame' => l.onboardingDietNoSesame,
    'no_soy' => l.onboardingDietNoSoy,
    'no_fish' => l.onboardingDietNoFish,
    'no_shellfish' => l.onboardingDietNoShellfish,
    _ => o.name,
  };

  static String diet(AppL10n l, OptionDto o) => switch (o.id) {
    'none' => l.onboardingDietNone,
    'vegetarian' => l.onboardingDietVegetarian,
    'vegan' => l.onboardingDietVegan,
    'pescatarian' => l.onboardingDietPescatarian,
    _ => o.name,
  };

  /// Danh sách trắng xu hướng sức khỏe (D-ONB-03): chỉ 4 id này hiện cho người dùng; thẻ nội bộ không bao giờ hiện.
  static const healthLeaningIds = [
    'nhieu_xo',
    'it_duong',
    'tot_cho_tim',
    'it_beo',
  ];

  /// Nhãn xu hướng theo id từ i18n.
  static String leaning(AppL10n l, OptionDto o) => switch (o.id) {
    'nhieu_xo' => l.healthNhieuXo,
    'it_duong' => l.healthItDuong,
    'tot_cho_tim' => l.healthTotChoTim,
    'it_beo' => l.healthItBeo,
    _ => o.name,
  };

  /// Mô tả ngắn của xu hướng theo id từ i18n.
  static String leaningDesc(AppL10n l, OptionDto o) => switch (o.id) {
    'nhieu_xo' => l.healthNhieuXoDesc,
    'it_duong' => l.healthItDuongDesc,
    'tot_cho_tim' => l.healthTotChoTimDesc,
    'it_beo' => l.healthItBeoDesc,
    _ => o.description,
  };

  /// Bậc ngân sách: `budget.tier.*` (tên) + `.desc` (mô tả), ví dụ "Tiết kiệm — Chủ yếu là…".
  static String budgetTier(AppL10n l, String key) => switch (key) {
    'economy' => '${l.budgetTierEconomy} — ${l.budgetTierEconomyDesc}',
    'moderate' => '${l.budgetTierModerate} — ${l.budgetTierModerateDesc}',
    'comfortable' =>
      '${l.budgetTierComfortable} — ${l.budgetTierComfortableDesc}',
    _ => key,
  };

  static String aisle(String id, Map<String, String> serverNames) =>
      serverNames[id] ?? id;
}
