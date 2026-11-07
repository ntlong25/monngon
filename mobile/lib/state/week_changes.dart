import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_providers.dart';
import '../api/generated/models.dart';
import '../core/format.dart';
import 'app_state.dart';
import 'providers.dart';

/// Đồng hồ của app (tách ra để test cố định "hôm nay").
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// Banner "Đã lên lại tuần" ở đầu tab Kế hoạch, cho tới khi người dùng đóng hoặc đổi tuần.
class ReplanNoticeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void dismiss() => state = false;
}

final replanNoticeProvider = NotifierProvider<ReplanNoticeNotifier, bool>(
  ReplanNoticeNotifier.new,
);

/// Đã sửa chỉ tiêu/lựa chọn ở tab Bạn mà chưa lên lại tuần hiện tại (US-6.1).
class ChoicesDirtyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void mark() => state = true;
  void clear() => state = false;
}

final choicesDirtyProvider = NotifierProvider<ChoicesDirtyNotifier, bool>(
  ChoicesDirtyNotifier.new,
);

/// Ảnh chụp trạng thái ngay trước thay đổi gần nhất, để hoàn tác (không lưu xuống máy).
class UndoSnapshot {
  const UndoSnapshot({
    required this.plan,
    required this.shopping,
    required this.blockedRecipeIds,
    required this.savedPlans,
    required this.swapCount,
    required this.replanNotice,
  });

  final PlanResponse plan;
  final ShoppingState shopping;
  final List<String> blockedRecipeIds;
  final List<SavedPlan> savedPlans;
  final int swapCount;
  final bool replanNotice;
}

class UndoNotifier extends Notifier<UndoSnapshot?> {
  @override
  UndoSnapshot? build() => null;

  void push(UndoSnapshot s) => state = s;
  void clear() => state = null;
}

final undoProvider = NotifierProvider<UndoNotifier, UndoSnapshot?>(
  UndoNotifier.new,
);

/// Còn ngày nào sau hôm nay để lên lại không (US-5.5).
bool hasDaysAfter(WeekPlan plan, DateTime now) {
  final today = isoDate(now);
  return plan.days.any((d) => d.date.compareTo(today) > 0);
}

/// Danh sách đi chợ mới nhưng vẫn giữ những món đã đánh dấu "đã mua" mà server không còn trả
/// (bữa bị đổi/ăn ngoài) — chỉ rút khỏi danh sách những món chưa mua (US-5.3 AC3).
ShoppingList keepBoughtItems(
  ShoppingList old,
  ShoppingList next,
  Set<String> bought,
) {
  final have = next.items.map((i) => i.ingredientId).toSet();
  final missing = old.items
      .where(
        (i) =>
            bought.contains(i.ingredientId) && !have.contains(i.ingredientId),
      )
      .toList();
  if (missing.isEmpty) return next;
  final groups = [...next.byAisle];
  for (final it in missing) {
    final gi = groups.indexWhere((g) => g.aisle == it.aisle);
    if (gi >= 0) {
      groups[gi] = groups[gi].copyWith(items: [...groups[gi].items, it]);
    } else {
      groups.add(AisleGroup(aisle: it.aisle, items: [it]));
    }
  }
  return next.copyWith(items: [...next.items, ...missing], byAisle: groups);
}

/// Các thay đổi tuần (US-5.1…5.5): gọi API (tuần hiện tại gửi kèm), áp kết quả, giữ ảnh chụp để hoàn tác.
class WeekChanges {
  const WeekChanges(this._ref);

  final Ref _ref;

  PlanResponse get _plan {
    final p = _ref.read(currentPlanProvider);
    if (p == null) throw StateError('no-plan');
    return p;
  }

  PlanStateDto _state([Preferences? prefs]) => PlanStateDto(
    profile: _ref.read(profileProvider),
    preferences: prefs ?? _ref.read(preferencesProvider),
    plan: _plan.plan,
    includeDessert: true,
  );

  Future<SwapSuggestions> suggestSwaps(String date, String slot) => _ref
      .read(apiProvider)
      .swapSuggestions(
        SwapSuggestionsRequest(state: _state(), date: date, slot: slot),
      );

  Future<IngredientOptions> ingredientOptions(
    String date,
    String slot,
    String ingredientId,
  ) => _ref
      .read(apiProvider)
      .ingredientOptions(
        IngredientOptionsRequest(
          state: _state(),
          date: date,
          slot: slot,
          ingredientId: ingredientId,
        ),
      );

  Future<void> applySwap(String date, String slot, String recipeId) async {
    final next = await _ref
        .read(apiProvider)
        .applySwap(
          ApplySwapRequest(
            state: _state(),
            date: date,
            slot: slot,
            recipeId: recipeId,
          ),
        );
    _commit(next, countSwap: true);
  }

  Future<void> swapIngredient(
    String date,
    String slot,
    String from,
    String to,
  ) async {
    final next = await _ref
        .read(apiProvider)
        .swapIngredient(
          SwapIngredientRequest(
            state: _state(),
            date: date,
            slot: slot,
            fromIngredientId: from,
            toIngredientId: to,
          ),
        );
    _commit(next, countSwap: true);
  }

  /// [mode]: `eat_out` | `skip` | `undo`.
  Future<void> setOut(String date, String slot, String mode) async {
    final next = await _ref
        .read(apiProvider)
        .eatOut(
          EatOutRequest(state: _state(), date: date, slot: slot, mode: mode),
        );
    _commit(next);
  }

  /// Lên lại các ngày sau hôm nay; [blockRecipeId] (US-5.4) được chặn trước khi lên.
  Future<void> regenerateRest({String? blockRecipeId}) async {
    if (blockRecipeId != null) _rememberName(blockRecipeId);
    final cur = _ref.read(preferencesProvider);
    final prefs =
        blockRecipeId == null || cur.blockedRecipeIds.contains(blockRecipeId)
        ? cur
        : cur.copyWith(
            blockedRecipeIds: [...cur.blockedRecipeIds, blockRecipeId],
          );
    final next = await _ref
        .read(apiProvider)
        .regenerateRest(
          RegenerateRestRequest(
            state: _state(prefs),
            today: isoDate(_ref.read(clockProvider)()),
          ),
        );
    _commit(next, prefs: prefs == cur ? null : prefs, replan: true);
    _ref.read(choicesDirtyProvider.notifier).clear();
  }

  void _rememberName(String id) => _ref
      .read(blockedNamesProvider.notifier)
      .remember(id, _ref.read(currentPlanProvider)?.recipes[id]?.name);

  /// Chỉ chặn món (không lên lại), có thể hoàn tác.
  void blockOnly(String recipeId) {
    _rememberName(recipeId);
    _snapshot();
    _ref.read(preferencesProvider.notifier).blockRecipe(recipeId);
  }

  /// Hoàn tác thay đổi gần nhất. `false` nếu không có gì để hoàn tác.
  bool undo() {
    final s = _ref.read(undoProvider);
    if (s == null) return false;
    _ref.read(currentPlanProvider.notifier).set(s.plan);
    _ref.read(shoppingStateProvider.notifier).set(s.shopping);
    _ref
        .read(preferencesProvider.notifier)
        .update((p) => p.copyWith(blockedRecipeIds: s.blockedRecipeIds));
    _ref.read(savedPlansProvider.notifier).set(s.savedPlans);
    _ref.read(swapCountProvider.notifier).set(s.swapCount);
    s.replanNotice
        ? _ref.read(replanNoticeProvider.notifier).show()
        : _ref.read(replanNoticeProvider.notifier).dismiss();
    _ref.read(undoProvider.notifier).clear();
    return true;
  }

  void _snapshot() {
    final cur = _ref.read(currentPlanProvider);
    if (cur == null) return;
    _ref
        .read(undoProvider.notifier)
        .push(
          UndoSnapshot(
            plan: cur,
            shopping: _ref.read(shoppingStateProvider),
            blockedRecipeIds: _ref.read(preferencesProvider).blockedRecipeIds,
            savedPlans: _ref.read(savedPlansProvider),
            swapCount: _ref.read(swapCountProvider),
            replanNotice: _ref.read(replanNoticeProvider),
          ),
        );
  }

  void _commit(
    PlanResponse next, {
    Preferences? prefs,
    bool countSwap = false,
    bool replan = false,
  }) {
    final cur = _plan;
    _snapshot();
    final bought = _ref.read(shoppingStateProvider).bought;
    final merged = next.copyWith(
      plan: next.plan.copyWith(
        shopping: keepBoughtItems(
          cur.plan.shopping,
          next.plan.shopping,
          bought,
        ),
      ),
    );
    _ref.read(currentPlanProvider.notifier).set(merged);
    if (prefs != null) _ref.read(preferencesProvider.notifier).set(prefs);
    if (countSwap) _ref.read(swapCountProvider.notifier).increment();
    if (replan) {
      // US-5.5 AC3: tuần cũ vào "Tuần đã lưu"; AC2: banner "Đã lên lại tuần".
      _ref
          .read(savedPlansProvider.notifier)
          .add(SavedPlan(savedAt: _ref.read(clockProvider)(), plan: cur));
      _ref.read(replanNoticeProvider.notifier).show();
    }
  }
}

final weekChangesProvider = Provider<WeekChanges>(WeekChanges.new);
