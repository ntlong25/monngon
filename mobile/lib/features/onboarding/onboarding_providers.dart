import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_providers.dart';
import '../../api/generated/models.dart';
import '../../state/providers.dart';
import '../../state/storage.dart';
import 'validation.dart';

/// Ném khi một yêu cầu bị thay bằng yêu cầu mới hơn (đang gõ dở) — không hiển thị cho người dùng.
class SupersededRequest implements Exception {
  const SupersededRequest();
}

/// Thời gian chờ sau lần gõ cuối trước khi gọi API (debounce).
const Duration kDebounce = Duration(milliseconds: 350);

/// Chỉ tiêu theo hồ sơ hiện tại (`POST /v1/targets`, debounce). Hồ sơ chưa hợp lệ → không gọi API.
final targetsProvider = FutureProvider<Targets>(retry: noRetry, (ref) async {
  final profile = ref.watch(profileProvider);
  if (validateProfile(profile).isNotEmpty) throw const SupersededRequest();
  await Future<void>.delayed(kDebounce);
  if (!ref.mounted) throw const SupersededRequest();
  final t = await ref
      .watch(apiProvider)
      .computeTargets(TargetsRequest(profile: profile));
  // Lưu để tab Bạn còn hiện chỉ tiêu khi offline (D-QA-09). Lỗi ghi kho không được làm hỏng kết quả.
  try {
    await ref.read(storeProvider).writeJson(StoreKeys.targets, {
      'profile': profile.toJson(),
      'targets': t.toJson(),
    });
  } on Object {
    // bỏ qua
  }
  return t;
});

/// Chỉ tiêu đã lưu trên máy cho đúng hồ sơ hiện tại (null nếu chưa có hoặc hồ sơ đã đổi từ lúc lưu).
final savedTargetsProvider = Provider<Targets?>((ref) {
  final profile = ref.watch(profileProvider);
  // Đọc lại mỗi khi chỉ tiêu tính xong (ghi cache) hoặc hồ sơ đổi.
  ref.watch(targetsProvider);
  final raw = ref.read(storeProvider).readJson(StoreKeys.targets);
  if (raw is! Map<String, dynamic>) return null;
  try {
    final saved = Profile.fromJson(raw['profile'] as Map<String, dynamic>);
    if (jsonEncode(saved.toJson()) != jsonEncode(profile.toJson())) return null;
    return Targets.fromJson(raw['targets'] as Map<String, dynamic>);
  } on Object {
    return null;
  }
});

/// Phân bổ chỉ tiêu theo bữa (`POST /v1/slots/preview`) — cập nhật ngay khi đổi bữa (US-1.3 AC2).
final slotsPreviewProvider = FutureProvider<SlotsPreviewResponse>(
  retry: noRetry,
  (ref) async {
    final profile = ref.watch(profileProvider);
    final slots = ref.watch(preferencesProvider.select((p) => p.slots));
    if (validateProfile(profile).isNotEmpty || !hasPlannedMainMeal(slots)) {
      throw const SupersededRequest();
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!ref.mounted) throw const SupersededRequest();
    return ref
        .watch(apiProvider)
        .previewSlots(SlotsPreviewRequest(profile: profile, slots: slots));
  },
);

/// Mức cơm khả thi — bản nhanh theo kcal/đạm (`POST /v1/rice/feasibility`, không lập tuần).
final riceFeasibilityQuickProvider = FutureProvider<RiceFeasibilityResponse>(
  retry: noRetry,
  (ref) async {
    final profile = ref.watch(profileProvider);
    final slots = ref.watch(preferencesProvider.select((p) => p.slots));
    if (validateProfile(profile).isNotEmpty || !hasPlannedMainMeal(slots)) {
      throw const SupersededRequest();
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!ref.mounted) throw const SupersededRequest();
    return ref
        .watch(apiProvider)
        .riceFeasibility(
          RiceFeasibilityRequest(profile: profile, slots: slots),
        );
  },
);

/// Mức cơm khả thi — bản có ngân sách: gửi kèm lựa chọn nên server lập thử tuần cho cả 4 mức (vài giây đến ~20 s),
/// vì vậy chỉ theo dõi lựa chọn KHÔNG tính thói quen cơm (đổi mức cơm không gọi lại). Lỗi → bước cơm dùng bản nhanh.
final riceFeasibilityFullProvider = FutureProvider<RiceFeasibilityResponse>(
  retry: noRetry,
  (ref) async {
    final profile = ref.watch(profileProvider);
    final prefsJson = ref.watch(
      preferencesProvider.select(
        (p) => jsonEncode(p.copyWith(riceHabit: 'vua').toJson()),
      ),
    );
    final prefs = Preferences.fromJson(
      jsonDecode(prefsJson) as Map<String, dynamic>,
    );
    if (validateProfile(profile).isNotEmpty ||
        !hasPlannedMainMeal(prefs.slots)) {
      throw const SupersededRequest();
    }
    await Future<void>.delayed(kDebounce);
    if (!ref.mounted) throw const SupersededRequest();
    return ref
        .watch(apiProvider)
        .riceFeasibility(
          RiceFeasibilityRequest(
            profile: profile,
            slots: prefs.slots,
            preferences: prefs,
          ),
        );
  },
);

/// Truy vấn khoảng ngân sách: chỉ số người/bữa/cửa hàng (bước ngân sách) hoặc kèm cả kiêng/dụng cụ (tổng kết).
class BudgetQuery {
  const BudgetQuery({
    required this.kcal,
    required this.proteinG,
    required this.preferencesJson,
    required this.full,
  });

  final double kcal;
  final double proteinG;

  /// JSON của lựa chọn — dùng để so sánh bằng nhau.
  final String preferencesJson;

  /// true: gửi cả `preferences` (US-1.2 AC2c); false: chỉ cửa hàng/số người/bữa.
  final bool full;

  @override
  bool operator ==(Object other) =>
      other is BudgetQuery &&
      other.kcal == kcal &&
      other.proteinG == proteinG &&
      other.preferencesJson == preferencesJson &&
      other.full == full;

  @override
  int get hashCode => Object.hash(kcal, proteinG, preferencesJson, full);
}

/// `POST /v1/budget-range` (gửi kèm `targets`; nhãn bậc lấy theo `key` từ i18n).
final budgetRangeProvider = FutureProvider.autoDispose
    .family<BudgetRangeResponse, BudgetQuery>(retry: noRetry, (ref, q) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!ref.mounted) throw const SupersededRequest();
      final prefs = ref.read(preferencesProvider);
      final targets = BudgetTargetsDto(
        kcalTarget: q.kcal,
        proteinG: q.proteinG,
      );
      final req = q.full
          ? BudgetRangeRequest(targets: targets, preferences: prefs)
          : BudgetRangeRequest(
              targets: targets,
              storeId: prefs.storeId,
              adults: prefs.adults,
              children: prefs.children,
              slots: prefs.slots,
            );
      return ref.watch(apiProvider).budgetRange(req);
    });

/// Tìm nguyên liệu không dấu (`GET /v1/ingredients?q=`), debounce.
final ingredientSearchProvider = FutureProvider.autoDispose
    .family<List<IngredientDto>, String>(retry: noRetry, (ref, query) async {
      if (query.trim().isEmpty) return const [];
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!ref.mounted) throw const SupersededRequest();
      return ref
          .watch(apiProvider)
          .searchIngredients(q: query.trim(), limit: 12);
    });
