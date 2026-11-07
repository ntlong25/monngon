import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import 'onboarding_nav.dart';
import 'step_activity.dart';
import 'step_body.dart';
import 'step_budget.dart';
import 'step_diet.dart';
import 'step_dislike.dart';
import 'step_equipment.dart';
import 'step_goal.dart';
import 'step_household.dart';
import 'step_meals.dart';
import 'step_rice.dart';
import 'step_store.dart';
import 'step_summary.dart';
import 'step_swipe.dart';
import 'step_targets.dart';

/// Màn wizard: hiển thị bước hiện tại, nút Back của hệ thống lùi một bước.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raw = ref.watch(onboardingProvider.select((s) => s.step));
    final step = OnboardingStep.values[raw.clamp(0, OnboardingNav.last)];
    return PopScope(
      canPop: step == OnboardingStep.goal,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) OnboardingNav(ref).back();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(step), child: _buildStep(step)),
      ),
    );
  }

  Widget _buildStep(OnboardingStep step) => buildOnboardingStep(step);
}

/// Widget của một bước (dùng cả ở wizard lẫn khi sửa từ tab Bạn).
Widget buildOnboardingStep(OnboardingStep step) => switch (step) {
  OnboardingStep.goal => const GoalStep(),
  OnboardingStep.body => const BodyStep(),
  OnboardingStep.activity => const ActivityStep(),
  OnboardingStep.targets => const TargetsStep(),
  OnboardingStep.store => const StoreStep(),
  OnboardingStep.household => const HouseholdStep(),
  OnboardingStep.budget => const BudgetStep(),
  OnboardingStep.meals => const MealsStep(),
  OnboardingStep.diet => const DietStep(),
  OnboardingStep.rice => const RiceStep(),
  OnboardingStep.dislike => const DislikeStep(),
  OnboardingStep.swipe => const SwipeStep(),
  OnboardingStep.equipment => const EquipmentStep(),
  OnboardingStep.summary => const SummaryStep(),
};
