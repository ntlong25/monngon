import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'onboarding_scaffold.dart';
import 'validation.dart';

/// Bước 6 — số người ăn: người lớn 1–6, trẻ em 0–4; chỉ tiêu dinh dưỡng vẫn là của riêng bạn (US-1.2 AC3).
class HouseholdStep extends ConsumerWidget {
  const HouseholdStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final adults = ref.watch(preferencesProvider.select((p) => p.adults));
    final children = ref.watch(preferencesProvider.select((p) => p.children));
    final n = ref.read(preferencesProvider.notifier);

    Widget row(
      String label,
      String hint,
      int value,
      ({int min, int max}) range,
      ValueChanged<int> onChanged,
    ) => Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleMedium),
                  Text(
                    hint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AppStepper(
              value: value,
              min: range.min,
              max: range.max,
              label: label,
              decrementLabel: l.commonDecrease,
              incrementLabel: l.commonIncrease,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );

    return OnboardingScaffold(
      title: l.onboardingHouseholdTitle,
      children: [
        row(
          l.onboardingHouseholdAdults,
          l.onboardingHouseholdAdultsHint,
          adults,
          Limits.adults,
          (v) => n.update((p) => p.copyWith(adults: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        row(
          l.onboardingHouseholdChildren,
          l.onboardingHouseholdChildrenHint,
          children,
          Limits.children,
          (v) => n.update((p) => p.copyWith(children: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppBanner(message: l.onboardingHouseholdNote),
      ],
    );
  }
}
