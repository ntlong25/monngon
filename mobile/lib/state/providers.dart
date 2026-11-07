import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_providers.dart';
import '../api/generated/api_client.dart';
import '../api/generated/models.dart';
import 'app_state.dart';
import 'storage.dart';
import 'week_changes.dart';

/// Riverpod 3 tự thử lại provider lỗi; app muốn hiện lỗi ngay (kèm nút Thử lại) nên tắt.
Duration? noRetry(int retryCount, Object error) => null;

/// Kho lưu cục bộ. Phải được override trong `main()` (sau khi nạp SharedPreferences và migrate).
final storeProvider = Provider<KeyValueStore>(
  (ref) =>
      throw UnimplementedError('storeProvider must be overridden in main()'),
);

/// Notifier có lưu: nạp từ kho khi khởi tạo, ghi lại mỗi lần đổi.
/// Dữ liệu hỏng hoặc sai dạng → dùng [initial] thay vì làm app lỗi.
abstract class PersistedNotifier<T> extends Notifier<T> {
  String get key;
  T get initial;
  T decode(Object json);
  Object? encode(T value);

  @override
  T build() {
    final raw = ref.watch(storeProvider).readJson(key);
    if (raw == null) return initial;
    try {
      return decode(raw);
    } on Object {
      return initial;
    }
  }

  void set(T value) {
    state = value;
    unawaited(ref.read(storeProvider).writeJson(key, encode(value)));
  }

  void update(T Function(T current) change) => set(change(state));
}

// --- Onboarding, hồ sơ, lựa chọn -------------------------------------------------

class OnboardingNotifier extends PersistedNotifier<OnboardingState> {
  @override
  String get key => StoreKeys.onboarding;
  @override
  OnboardingState get initial => const OnboardingState();
  @override
  OnboardingState decode(Object json) =>
      OnboardingState.fromJson(json as Map<String, dynamic>);
  @override
  Object? encode(OnboardingState value) => value.toJson();

  void goTo(int step) => update((s) => s.copyWith(step: step < 0 ? 0 : step));

  void markSwiped(String cardId) => update(
    (s) => s.swipedCardIds.contains(cardId)
        ? s
        : s.copyWith(swipedCardIds: [...s.swipedCardIds, cardId]),
  );

  void unmarkSwiped(String cardId) => update(
    (s) => s.copyWith(
      swipedCardIds: s.swipedCardIds.where((e) => e != cardId).toList(),
    ),
  );

  void resetSwiped() => update((s) => s.copyWith(swipedCardIds: const []));

  void complete() => update((s) => s.copyWith(completed: true));
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

class ProfileNotifier extends PersistedNotifier<Profile> {
  @override
  String get key => StoreKeys.profile;
  @override
  Profile get initial => Defaults.profile;
  @override
  Profile decode(Object json) => Profile.fromJson(json as Map<String, dynamic>);
  @override
  Object? encode(Profile value) => value.toJson();
}

final profileProvider = NotifierProvider<ProfileNotifier, Profile>(
  ProfileNotifier.new,
);

class PreferencesNotifier extends PersistedNotifier<Preferences> {
  @override
  String get key => StoreKeys.preferences;
  @override
  Preferences get initial => Defaults.preferences;
  @override
  Preferences decode(Object json) {
    final p = Preferences.fromJson(json as Map<String, dynamic>);
    // Dữ liệu lưu từ bản cũ chưa có thói quen ăn cơm → Vừa (server từ chối giá trị rỗng).
    return p.riceHabit.isEmpty ? p.copyWith(riceHabit: 'vua') : p;
  }

  @override
  Object? encode(Preferences value) => value.toJson();

  /// "Không hợp với tôi": chặn món khỏi các tuần sau (US-5.4).
  void blockRecipe(String id) => update(
    (p) => p.blockedRecipeIds.contains(id)
        ? p
        : p.copyWith(blockedRecipeIds: [...p.blockedRecipeIds, id]),
  );

  void unblockRecipe(String id) => update(
    (p) => p.copyWith(
      blockedRecipeIds: p.blockedRecipeIds.where((x) => x != id).toList(),
    ),
  );
}

final preferencesProvider = NotifierProvider<PreferencesNotifier, Preferences>(
  PreferencesNotifier.new,
);

/// Danh sách món đã chặn (đọc từ lựa chọn).
final blockedRecipesProvider = Provider<List<String>>(
  (ref) => ref.watch(preferencesProvider).blockedRecipeIds,
);

// --- Tuần hiện tại và tuần đã lưu ------------------------------------------------

/// Tuần hiện tại (kèm công thức/nguyên liệu để xem offline). `null` khi chưa tạo.
class CurrentPlanNotifier extends Notifier<PlanResponse?> {
  @override
  PlanResponse? build() {
    final raw = ref.watch(storeProvider).readJson(StoreKeys.currentPlan);
    if (raw is! Map<String, dynamic>) return null;
    try {
      return PlanResponse.fromJson(raw);
    } on Object {
      return null;
    }
  }

  void set(PlanResponse? plan) {
    state = plan;
    final store = ref.read(storeProvider);
    unawaited(
      plan == null
          ? store.delete(StoreKeys.currentPlan)
          : store.writeJson(StoreKeys.currentPlan, plan.toJson()),
    );
  }
}

final currentPlanProvider =
    NotifierProvider<CurrentPlanNotifier, PlanResponse?>(
      CurrentPlanNotifier.new,
    );

class SavedPlansNotifier extends PersistedNotifier<List<SavedPlan>> {
  @override
  String get key => StoreKeys.savedPlans;
  @override
  List<SavedPlan> get initial => const [];
  @override
  List<SavedPlan> decode(Object json) => (json as List<dynamic>)
      .map((e) => SavedPlan.fromJson(e as Map<String, dynamic>))
      .toList();
  @override
  Object? encode(List<SavedPlan> value) =>
      value.map((e) => e.toJson()).toList();

  /// Giữ tối đa [max] tuần gần nhất (tránh phình bộ nhớ máy).
  static const max = 8;

  void add(SavedPlan p) {
    final next = [p, ...state];
    set(next.length > max ? next.sublist(0, max) : next);
  }
}

final savedPlansProvider =
    NotifierProvider<SavedPlansNotifier, List<SavedPlan>>(
      SavedPlansNotifier.new,
    );

// --- Đi chợ, nấu ăn, đếm đổi món --------------------------------------------------

class ShoppingNotifier extends PersistedNotifier<ShoppingState> {
  @override
  String get key => StoreKeys.shopping;
  @override
  ShoppingState get initial => const ShoppingState();
  @override
  ShoppingState decode(Object json) =>
      ShoppingState.fromJson(json as Map<String, dynamic>);
  @override
  Object? encode(ShoppingState value) => value.toJson();

  void setBought(String ingredientId, {required bool bought}) => update((s) {
    final next = {...s.bought};
    bought ? next.add(ingredientId) : next.remove(ingredientId);
    return s.copyWith(bought: next);
  });

  void setPantry(String ingredientId, {required bool have}) => update(
    (s) =>
        s.copyWith(pantryOverrides: {...s.pantryOverrides, ingredientId: have}),
  );
}

final shoppingStateProvider = NotifierProvider<ShoppingNotifier, ShoppingState>(
  ShoppingNotifier.new,
);

/// Các bước nấu đã đánh dấu xong, theo khóa bữa/món (xem [cookKey]).
class CookedStepsNotifier extends PersistedNotifier<Map<String, Set<int>>> {
  @override
  String get key => StoreKeys.cooked;
  @override
  Map<String, Set<int>> get initial => const {};
  @override
  Map<String, Set<int>> decode(Object json) => (json as Map<String, dynamic>)
      .map((k, v) => MapEntry(k, (v as List<dynamic>).cast<int>().toSet()));
  @override
  Object? encode(Map<String, Set<int>> value) =>
      value.map((k, v) => MapEntry(k, v.toList()..sort()));

  void toggle(String cookKey, int step) => update((m) {
    final cur = {...(m[cookKey] ?? const <int>{})};
    cur.contains(step) ? cur.remove(step) : cur.add(step);
    final next = {...m};
    cur.isEmpty ? next.remove(cookKey) : next[cookKey] = cur;
    return next;
  });
}

final cookedStepsProvider =
    NotifierProvider<CookedStepsNotifier, Map<String, Set<int>>>(
      CookedStepsNotifier.new,
    );

/// Khóa trạng thái "đã nấu" cho một món trong một bữa cụ thể.
String cookKey(String date, String slot, String recipeId) =>
    '$date|$slot|$recipeId';

/// Số lần đổi món (phục vụ đo freemium, chưa chặn).
class SwapCountNotifier extends PersistedNotifier<int> {
  @override
  String get key => StoreKeys.swapCount;
  @override
  int get initial => 0;
  @override
  int decode(Object json) => (json as num).toInt();
  @override
  Object? encode(int value) => value;

  void increment() => update((n) => n + 1);
}

final swapCountProvider = NotifierProvider<SwapCountNotifier, int>(
  SwapCountNotifier.new,
);

/// Tên nguyên liệu mà người dùng đã gặp (mã → tên), để hiện chip "Đã loại" khi mở lại app mà chưa có mạng.
class IngredientNamesNotifier extends PersistedNotifier<Map<String, String>> {
  @override
  String get key => StoreKeys.ingredientNames;
  @override
  Map<String, String> get initial => const {};
  @override
  Map<String, String> decode(Object json) =>
      (json as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String));
  @override
  Object? encode(Map<String, String> value) => value;

  void remember(Iterable<IngredientDto> items) {
    final next = {...state};
    var changed = false;
    for (final i in items) {
      if (next[i.id] != i.name) {
        next[i.id] = i.name;
        changed = true;
      }
    }
    if (changed) set(next);
  }
}

final ingredientNamesProvider =
    NotifierProvider<IngredientNamesNotifier, Map<String, String>>(
      IngredientNamesNotifier.new,
    );

/// Tên các món đã chặn (mã → tên), để tab Bạn hiện đúng tên dù tuần đã đổi (US-6.2).
class BlockedNamesNotifier extends PersistedNotifier<Map<String, String>> {
  @override
  String get key => StoreKeys.blockedNames;
  @override
  Map<String, String> get initial => const {};
  @override
  Map<String, String> decode(Object json) =>
      (json as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String));
  @override
  Object? encode(Map<String, String> value) => value;

  void remember(String id, String? name) {
    if (name == null || name.isEmpty || state[id] == name) return;
    set({...state, id: name});
  }
}

final blockedNamesProvider =
    NotifierProvider<BlockedNamesNotifier, Map<String, String>>(
      BlockedNamesNotifier.new,
    );

// --- Dữ liệu tham chiếu có cache ----------------------------------------------------

/// Danh mục tham chiếu (cửa hàng, dụng cụ, kiêng, thẻ vuốt…). Gọi API; thất bại thì dùng bản cache lần trước.
final referenceProvider = FutureProvider<ReferenceResponse>(retry: noRetry, (
  ref,
) async {
  final store = ref.watch(storeProvider);
  try {
    final r = await ref.watch(apiProvider).getReference();
    await store.writeJson(StoreKeys.reference, r.toJson());
    return r;
  } on ApiException {
    final raw = store.readJson(StoreKeys.reference);
    if (raw is Map<String, dynamic>) {
      try {
        return ReferenceResponse.fromJson(raw);
      } on Object {
        // rơi xuống ném lại lỗi mạng
      }
    }
    rethrow;
  }
});

// --- Thao tác xuyên nhiều trạng thái ---------------------------------------------------

/// Thao tác ảnh hưởng nhiều provider: tạo tuần mới, xoá dữ liệu.
class AppActions {
  const AppActions(this._ref);

  final Ref _ref;

  /// Đặt tuần mới làm tuần hiện tại. Tuần cũ (nếu có) được lưu vào "Tuần đã lưu";
  /// danh sách đi chợ (các món đã mua) và các bước đã nấu bắt đầu lại; lựa chọn "nhà có sẵn" được nhớ cho các tuần sau (D-SHP-01).
  void startNewWeek(PlanResponse plan) {
    final old = _ref.read(currentPlanProvider);
    if (old != null) {
      _ref
          .read(savedPlansProvider.notifier)
          .add(SavedPlan(savedAt: DateTime.now(), plan: old));
    }
    _ref.read(currentPlanProvider.notifier).set(plan);
    _ref
        .read(shoppingStateProvider.notifier)
        .set(
          ShoppingState(
            pantryOverrides: _ref.read(shoppingStateProvider).pantryOverrides,
          ),
        );
    _ref.read(cookedStepsProvider.notifier).set(const {});
    _ref.read(undoProvider.notifier).clear();
    _ref.read(replanNoticeProvider.notifier).dismiss();
    _ref.read(choicesDirtyProvider.notifier).clear();
  }

  /// Xoá toàn bộ dữ liệu trên máy (US-6.3). Giữ lại số phiên bản schema.
  Future<void> clearAll() async {
    final store = _ref.read(storeProvider);
    for (final k in store.keys.toList()) {
      await store.delete(k);
    }
    await store.write(StoreKeys.schemaVersion, '$kStorageSchemaVersion');
    _ref
      ..invalidate(onboardingProvider)
      ..invalidate(profileProvider)
      ..invalidate(preferencesProvider)
      ..invalidate(currentPlanProvider)
      ..invalidate(savedPlansProvider)
      ..invalidate(shoppingStateProvider)
      ..invalidate(cookedStepsProvider)
      ..invalidate(swapCountProvider)
      ..invalidate(ingredientNamesProvider)
      ..invalidate(blockedNamesProvider)
      ..invalidate(undoProvider)
      ..invalidate(replanNoticeProvider)
      ..invalidate(choicesDirtyProvider)
      ..invalidate(referenceProvider);
  }
}

final appActionsProvider = Provider<AppActions>(AppActions.new);
