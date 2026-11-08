import '../api/generated/models.dart';
import '../l10n/gen/app_localizations.dart';

/// Thói quen ăn cơm của người dùng chính (D-COM-01). Gram là cơm chín mỗi bữa trưa/tối; do engine quyết định,
/// ở đây chỉ để hiển thị và cảnh báo sớm.
enum RiceHabit {
  it('it', 75),
  vua('vua', 150),
  nhieu('nhieu', 300),
  ratNhieu('rat_nhieu', 450);

  const RiceHabit(this.id, this.grams);

  final String id;
  final int grams;

  /// Gram cơm chín của 1 chén (hằng số, Research chốt ở T-059c).
  static const gramsPerCup = 150;

  /// Giá trị rỗng/lạ (dữ liệu cũ chưa có `rice_habit`) = Vừa.
  static RiceHabit parse(String? id) =>
      values.firstWhere((h) => h.id == id, orElse: () => vua);

  static String label(AppL10n l, RiceHabit h) => switch (h) {
    it => l.onboardingRiceIt,
    vua => l.onboardingRiceVua,
    nhieu => l.onboardingRiceNhieu,
    ratNhieu => l.onboardingRiceRatNhieu,
  };

  /// Dòng "Ít tinh bột: mâm không có cơm" hoặc nhãn mức ở màn tổng kết / tab Bạn.
  static String summary(AppL10n l, Preferences p) =>
      p.lowCarb ? l.mealRiceSummaryLowCarb : label(l, parse(p.riceHabit));

  /// Số chén (đã làm tròn xuống ½ chén ở server) dạng chữ: `1.5` → "1½", `0.5` → "½", `0` → "0".
  static String halfCups(double cups) {
    final halves = (cups * 2).floor();
    final whole = halves ~/ 2;
    final half = halves.isOdd ? '½' : '';
    if (whole == 0) return half.isEmpty ? '0' : half;
    return '$whole$half';
  }
}

/// Cảnh báo ở bước "Thói quen ăn cơm" (D-COM-04, D-COM-05). Mọi con số do server tính (`POST /v1/rice/feasibility`);
/// app chỉ chọn mức người dùng đang chọn và quyết định có hiện hay không.
class RiceWarning {
  const RiceWarning({
    required this.item,
    required this.kcal,
    required this.proteinG,
  });

  final RiceFeasibilityItem item;
  final double kcal;
  final double proteinG;

  /// `budget` (ngân sách không đủ giữ cơm ở mức chọn) hoặc `kcal_protein` (mặc định khi server không ghi lý do).
  bool get isBudget => item.reason == 'budget';
}

/// Cảnh báo cho mức [habit]: dùng bản có ngân sách ([full]) khi đã về, chưa có thì bản nhanh theo kcal/đạm ([quick]).
/// Trả null khi chưa có dữ liệu hoặc mức khả thi (số chén khả thi ≥ mức chọn).
RiceWarning? riceWarningFor(
  RiceHabit habit,
  RiceFeasibilityResponse? quick,
  RiceFeasibilityResponse? full,
) {
  final source = full ?? quick;
  if (source == null) return null;
  final item = source.habits.where((i) => i.habit == habit.id).firstOrNull;
  if (item == null || item.feasible) return null;
  return RiceWarning(
    item: item,
    kcal: source.targets.kcalTarget,
    proteinG: source.targets.proteinG,
  );
}
