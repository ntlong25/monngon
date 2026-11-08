import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/rice.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../ui/ui.dart';
import 'meal_data.dart';

/// Thẻ tinh bột của bữa mâm (D-COM-01, D-COM-03): gọi đúng tên món ([dishName], vd "Khoai lang hấp").
/// `rice.kind = com` → "Cơm gạo lứt · 1 chén (150 g)"; `other` → "Khoai lang hấp · ~115 g (thay ½ chén cơm)"
/// (chén lấy từ `rice_equiv_g`, không ghi "chén cơm" làm nhãn chính). Khi bị bớt thì kèm ghi chú `rice_reduced` cùng dạng.
class RiceCard extends ConsumerWidget {
  const RiceCard({required this.rice, this.notes, this.dishName, super.key});

  final RiceInfo rice;
  final List<MealNote>? notes;

  /// Tên món tinh bột (món `carb_base` của mâm); null → dùng nhãn cơm chung (dữ liệu cũ không có món).
  final String? dishName;

  bool get _isOther => rice.kind == 'other';

  /// Chén cơm tương đương của [grams] tinh bột thực tế (khoai/bún: nhân tỉ lệ `rice_equiv_g / actual_g`).
  double _equivG(double grams) =>
      _isOther && rice.actualG > 0 && rice.riceEquivG > 0
      ? grams * rice.riceEquivG / rice.actualG
      : grams;

  /// 1 chén ≈ 150 g. Làm tròn tới phân số dễ đọc nhất (⅓, ½, ⅔, nguyên) để số chén khớp với số gram hiển thị kèm:
  /// 100 g ≈ ⅔ chén (không làm tròn ½ chén rồi ghi ~100 g, vì hai số mâu thuẫn nhau). Ví dụ: 75 g → "½", 100 g → "⅔", 225 g → "1½".
  static String cups(double grams) {
    final sixths = (grams / RiceHabit.gramsPerCup * 6).round();
    var whole = sixths ~/ 6;
    var rem = sixths % 6;
    // Chỉ dùng ⅓, ½, ⅔: ⅙ và ⅚ gần nhất là 0 (hoặc ⅓) và 1 (hoặc ⅔).
    if (rem == 1) {
      rem = 0;
    } else if (rem == 5) {
      whole += 1;
      rem = 0;
    }
    if (whole == 0 && rem == 0) rem = 2;
    final frac = switch (rem) {
      2 => '⅓',
      3 => '½',
      4 => '⅔',
      _ => '',
    };
    return whole == 0 ? frac : '$whole$frac';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final note = notes?.where((n) => n.code == 'rice_reduced').firstOrNull;
    final grams = formatInt(rice.actualG);
    final name = dishName?.trim();
    final hasName = name != null && name.isNotEmpty;
    final title = switch (hasName) {
      true when _isOther => l.mealStarchOther(
        name!,
        grams,
        cups(_equivG(rice.actualG)),
      ),
      true => l.mealStarchCups(name!, cups(rice.actualG), grams),
      false => l.mealRiceCups(cups(rice.actualG), grams),
    };
    final noteGrams = note?.actualG ?? rice.actualG;
    final noteText = note == null
        ? null
        : _isOther && hasName
        ? l.mealStarchReducedOther(
            formatInt(noteGrams),
            riceName(name),
            cups(_equivG(noteGrams)),
          )
        : l.mealRiceReducedCups(cups(noteGrams));
    return Container(
      key: const Key('rice-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rice_bowl_outlined, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  key: const Key('rice-amount'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (noteText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              noteText,
              key: const Key('rice-reduced-note'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
