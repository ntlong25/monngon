import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'onboarding_scaffold.dart';

/// Bước 1 — mục tiêu: giảm mỡ / giữ cân / tăng cơ (US-1.1 AC1).
class GoalStep extends ConsumerWidget {
  const GoalStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final goal = ref.watch(profileProvider.select((p) => p.goal));
    final hints = {
      'lose': l.onboardingGoalLoseHint,
      'hold': l.onboardingGoalHoldHint,
      'build': l.onboardingGoalBuildHint,
    };
    return OnboardingScaffold(
      title: l.onboardingGoalTitle,
      subtitle: l.onboardingGoalHint,
      children: [
        for (final id in const ['lose', 'hold', 'build']) ...[
          SelectCard(
            title: Labels.goal(l, id),
            subtitle: hints[id],
            selected: goal == id,
            onTap: () => ref
                .read(profileProvider.notifier)
                .update((p) => p.copyWith(goal: id)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
