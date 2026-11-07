import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/rice.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../ui/ui.dart';

/// Thẻ cơm của bữa mâm (D-COM-01): số chén + gram thực tế; khi cơm bị bớt thì kèm ghi chú `rice_reduced`
/// (nói theo chén, làm tròn ½ chén).
class RiceCard extends ConsumerWidget {
  const RiceCard({required this.rice, this.notes, super.key});

  final RiceInfo rice;
  final List<MealNote>? notes;

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
                  l.mealRiceCups(cups(rice.actualG), grams),
                  key: const Key('rice-amount'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.mealRiceReducedCups(cups(note.actualG ?? rice.actualG)),
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
