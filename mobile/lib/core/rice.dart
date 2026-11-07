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

  /// Kcal của 1 g cơm trắng chín (~130 kcal/100 g) và tỉ lệ ước tính của một bữa chính trong ngày.
  static const kcalPerG = 1.3;
  static const mainMealShare = 0.33;
  static const warnShare = 0.45;

  /// Cơm chiếm > 45% kcal ước tính của bữa chính (≈ 1/3 chỉ tiêu ngày) → cảnh báo mềm (không chặn).
  static bool exceedsMainMealShare(RiceHabit h, double kcalTarget) =>
      kcalTarget > 0 && h.grams * kcalPerG > kcalTarget * mainMealShare * warnShare;

  /// Dòng "Ít tinh bột: mâm không có cơm" hoặc nhãn mức ở màn tổng kết / tab Bạn.
  static String summary(AppL10n l, Preferences p) =>
      p.lowCarb ? l.mealRiceSummaryLowCarb : label(l, parse(p.riceHabit));
}
