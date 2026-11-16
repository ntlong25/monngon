import '../api/generated/models.dart';
import '../features/onboarding/onboarding_nav.dart' show OnboardingStep;

/// Thứ tự bước của bản cũ (trước T-103), khi bước đang làm còn lưu THEO SỐ. Chỉ để đọc lại trạng thái cũ.
const _legacyStepNames = [
  'goal',
  'body',
  'activity',
  'targets',
  'store',
  'household',
  'budget',
  'meals',
  'diet',
  'rice',
  'dislike',
  'swipe',
  'equipment',
  'summary',
];

/// Tiến độ onboarding: bước hiện tại (0 = bước đầu) để mở lại đúng chỗ khi tắt app giữa chừng.
/// Lưu theo TÊN bước (`step_name`, D-ONB-06 ý 4) nên đổi thứ tự bước không làm nhảy sai bước.
/// Trạng thái cũ chỉ có `step` (số theo thứ tự cũ) được đổi sang tên rồi sang số của thứ tự mới.
class OnboardingState {
  const OnboardingState({
    this.step = 0,
    this.completed = false,
    this.swipedCardIds = const [],
    this.goalChosen = false,
  });

  factory OnboardingState.fromJson(Map<String, dynamic> j) => OnboardingState(
    step: _stepFromJson(j),
    completed: j['completed'] as bool? ?? false,
    // Dữ liệu cũ chưa có cờ: đã qua bước Mục tiêu (hoặc đã xong onboarding) nghĩa là mục tiêu đã được chọn.
    goalChosen:
        j['goal_chosen'] as bool? ??
        (_stepFromJson(j) > 0 || (j['completed'] as bool? ?? false)),
    swipedCardIds:
        (j['swiped_card_ids'] as List<dynamic>?)?.cast<String>().toList() ??
        const [],
  );

  static int _stepFromJson(Map<String, dynamic> j) {
    final byName = OnboardingStep.values.where((s) => s.name == j['step_name']);
    if (byName.isNotEmpty) return byName.first.index;
    final legacy = (j['step'] as num?)?.toInt() ?? 0;
    if (legacy < 0) return 0;
    if (legacy >= _legacyStepNames.length) return OnboardingStep.summary.index;
    return OnboardingStep.values
        .firstWhere((s) => s.name == _legacyStepNames[legacy])
        .index;
  }

  final int step;
  final bool completed;

  /// Các thẻ vuốt đã xem (để mở lại đúng thẻ tiếp theo).
  final List<String> swipedCardIds;

  /// Người dùng đã chọn mục tiêu (bước Mục tiêu là bộ thẻ quẹt chọn 1, T-107): chưa chọn thì "Tiếp tục" khóa.
  /// `Profile.goal` luôn có giá trị mặc định nên không dùng nó để biết đã chọn hay chưa.
  final bool goalChosen;

  OnboardingState copyWith({
    int? step,
    bool? completed,
    List<String>? swipedCardIds,
    bool? goalChosen,
  }) => OnboardingState(
    step: step ?? this.step,
    completed: completed ?? this.completed,
    swipedCardIds: swipedCardIds ?? this.swipedCardIds,
    goalChosen: goalChosen ?? this.goalChosen,
  );

  Map<String, dynamic> toJson() => {
    'step': step,
    'step_name': OnboardingStep
        .values[step.clamp(0, OnboardingStep.values.length - 1)]
        .name,
    'completed': completed,
    'swiped_card_ids': swipedCardIds,
    'goal_chosen': goalChosen,
  };
}

/// Một tuần đã lưu ("Tuần đã lưu", US-5.5 AC3).
class SavedPlan {
  const SavedPlan({required this.savedAt, required this.plan});

  factory SavedPlan.fromJson(Map<String, dynamic> j) => SavedPlan(
    savedAt: DateTime.parse(j['saved_at'] as String),
    plan: PlanResponse.fromJson(j['plan'] as Map<String, dynamic>),
  );

  final DateTime savedAt;
  final PlanResponse plan;

  Map<String, dynamic> toJson() => {
    'saved_at': savedAt.toIso8601String(),
    'plan': plan.toJson(),
  };
}

/// Trạng thái tab Đi chợ gắn với tuần hiện tại: đã mua, nhà có sẵn.
class ShoppingState {
  const ShoppingState({
    this.bought = const {},
    this.pantryOverrides = const {},
  });

  factory ShoppingState.fromJson(Map<String, dynamic> j) => ShoppingState(
    bought: (j['bought'] as List<dynamic>?)?.cast<String>().toSet() ?? const {},
    pantryOverrides:
        (j['pantry'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as bool),
        ) ??
        const {},
  );

  /// Mã nguyên liệu đã đánh dấu đã mua.
  final Set<String> bought;

  /// Người dùng chọn tay: `true` = nhà có sẵn, `false` = nhà không có (ghi đè gợi ý mặc định).
  final Map<String, bool> pantryOverrides;

  /// Nhà có sẵn không? Ưu tiên lựa chọn của người dùng, nếu chưa chọn thì theo gợi ý [defaultPantry].
  bool pantryHave(String id, {required bool defaultPantry}) =>
      pantryOverrides[id] ?? defaultPantry;

  ShoppingState copyWith({
    Set<String>? bought,
    Map<String, bool>? pantryOverrides,
  }) => ShoppingState(
    bought: bought ?? this.bought,
    pantryOverrides: pantryOverrides ?? this.pantryOverrides,
  );

  Map<String, dynamic> toJson() => {
    'bought': bought.toList()..sort(),
    'pantry': pantryOverrides,
  };
}

/// Chế độ xem của tab Đi chợ (D-SHP-06): mua một lần theo tuần hay chia đợt theo ngày.
enum ShopMode { weekly, daily }

/// Lựa chọn xem tab Đi chợ, nhớ trên máy: chế độ gần nhất (lần đầu: Theo tuần) và công tắc "Mua thịt cá cả tuần rồi cấp đông".
class ShopViewPrefs {
  const ShopViewPrefs({this.mode = ShopMode.weekly, this.freezeMeat = false});

  factory ShopViewPrefs.fromJson(Map<String, dynamic> j) => ShopViewPrefs(
    mode: j['mode'] == 'daily' ? ShopMode.daily : ShopMode.weekly,
    freezeMeat: j['freeze_meat'] == true,
  );

  final ShopMode mode;
  final bool freezeMeat;

  ShopViewPrefs copyWith({ShopMode? mode, bool? freezeMeat}) => ShopViewPrefs(
    mode: mode ?? this.mode,
    freezeMeat: freezeMeat ?? this.freezeMeat,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode == ShopMode.daily ? 'daily' : 'weekly',
    'freeze_meat': freezeMeat,
  };
}

/// Giá trị khởi tạo cho hồ sơ/lựa chọn trước khi người dùng nhập.
abstract final class Defaults {
  static const profile = Profile(
    goal: 'lose',
    sex: 'male',
    age: 30,
    heightCm: 170,
    weightKg: 65,
    activity: 'moderate',
    targetMode: 'formula',
  );

  static const slots = SlotsConfig(
    breakfast: 'on',
    lunch: 'on',
    dinner: 'on',
    snackAm: 'skip',
    snackPm: 'on',
    lunchStyle: 'hot',
    snackPmStyle: 'savory',
  );

  static const preferences = Preferences(
    storeId: 'bach_hoa_xanh',
    weeklyBudgetVnd: 0,
    adults: 1,
    children: 0,
    slots: slots,
    diet: 'none',
    riceHabit: 'vua',
    equipment: ['bep', 'noi_com_dien'],
  );
}
