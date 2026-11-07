import '../api/generated/models.dart';

/// Tiến độ onboarding: bước hiện tại (0 = bước đầu) để mở lại đúng chỗ khi tắt app giữa chừng.
class OnboardingState {
  const OnboardingState({
    this.step = 0,
    this.completed = false,
    this.swipedCardIds = const [],
  });

  factory OnboardingState.fromJson(Map<String, dynamic> j) => OnboardingState(
    step: (j['step'] as num?)?.toInt() ?? 0,
    completed: j['completed'] as bool? ?? false,
    swipedCardIds:
        (j['swiped_card_ids'] as List<dynamic>?)?.cast<String>().toList() ??
        const [],
  );

  final int step;
  final bool completed;

  /// Các thẻ vuốt đã xem (để mở lại đúng thẻ tiếp theo).
  final List<String> swipedCardIds;

  OnboardingState copyWith({
    int? step,
    bool? completed,
    List<String>? swipedCardIds,
  }) => OnboardingState(
    step: step ?? this.step,
    completed: completed ?? this.completed,
    swipedCardIds: swipedCardIds ?? this.swipedCardIds,
  );

  Map<String, dynamic> toJson() => {
    'step': step,
    'completed': completed,
    'swiped_card_ids': swipedCardIds,
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
