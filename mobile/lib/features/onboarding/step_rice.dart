import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/rice.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
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
    final kcal = ref.watch(targetsProvider).asData?.value.kcalTarget;
    final warn = kcal != null && RiceHabit.exceedsMainMealShare(habit, kcal);
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
        if (warn) ...[
          const SizedBox(height: AppSpacing.lg),
          AppBanner(
            key: const Key('rice-warning'),
            kind: BannerKind.warning,
            message: l.onboardingRiceWarning,
          ),
        ],
      ],
    );
  }
}
