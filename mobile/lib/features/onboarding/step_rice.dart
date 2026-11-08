import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/rice.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../meal/rice_card.dart';
import 'onboarding_providers.dart';
import 'onboarding_scaffold.dart';

/// Bước "Thói quen ăn cơm" (US-1.4b / D-COM-01): 4 lựa chọn, "Vừa" chọn sẵn, đặt sau bước kiểu ăn.
/// Bỏ qua khi bật "Ít tinh bột" (do `OnboardingNav`). Mức cơm chiếm quá nửa kcal bữa chính → cảnh báo, không chặn.
class RiceStep extends ConsumerWidget {
  const RiceStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final habit = RiceHabit.parse(
      ref.watch(preferencesProvider.select((p) => p.riceHabit)),
    );
    // Số chén khả thi do server tính (D-COM-04/05): bản nhanh theo kcal/đạm về trước, bản có ngân sách về sau thay thế.
    final quick = ref.watch(riceFeasibilityQuickProvider).asData?.value;
    final full = ref.watch(riceFeasibilityFullProvider).asData?.value;
    final warning = riceWarningFor(habit, quick, full);
    return OnboardingScaffold(
      title: l.onboardingRiceTitle,
      subtitle: l.onboardingRiceQuestion,
      children: [
        for (final h in RiceHabit.values) ...[
          SelectCard(
            key: Key('rice-${h.id}'),
            title: RiceHabit.label(l, h),
            selected: h == habit,
            onTap: () => ref
                .read(preferencesProvider.notifier)
                .update((p) => p.copyWith(riceHabit: h.id)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          l.onboardingRiceNote,
          key: const Key('rice-note'),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textMuted),
        ),
        if (warning != null) ...[
          const SizedBox(height: AppSpacing.lg),
          AppBanner(
            key: const Key('rice-warning'),
            kind: BannerKind.warning,
            message: _warningText(l, warning),
          ),
        ],
      ],
    );
  }
}

String _warningText(AppL10n l, RiceWarning w) {
  final i = w.item;
  final chosen = RiceCard.cups(i.targetG);
  if (!w.isBudget) {
    return l.onboardingRiceFeasibleWarning(
      formatInt(w.kcal),
      formatInt(w.proteinG),
      RiceHabit.halfCups(i.feasibleCups),
      chosen,
    );
  }
  final budget = l.commonVnd(formatVnd(i.budgetVnd ?? 0));
  final meals = '${i.mealsWithFullRice ?? i.mealsWithRice ?? 0}';
  final needed = i.budgetNeededVnd;
  return needed == null
      ? l.onboardingRiceBudgetWarningShort(budget, meals, chosen)
      : l.onboardingRiceBudgetWarning(
          budget,
          meals,
          chosen,
          l.commonVnd(formatVnd(needed)),
        );
}
