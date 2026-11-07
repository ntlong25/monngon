import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/api_error_view.dart';
import 'budget_view.dart';
import 'onboarding_nav.dart';
import 'onboarding_providers.dart';
import 'onboarding_scaffold.dart';

/// Bước 7 — ngân sách tuần: thanh trượt bước 50.000 ₫, min/max/bậc từ `POST /v1/budget-range` (US-1.2 AC2, AC2b, AC4).
class BudgetStep extends ConsumerWidget {
  const BudgetStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final prefs = ref.watch(preferencesProvider);
    final targetsAsync = ref.watch(targetsProvider);
    final targets = targetsAsync.value;

    Widget body;
    var canContinue = false;
    VoidCallback? onContinue;
    String? caption;

    if (targets == null) {
      final e = targetsAsync.error;
      body = e != null && e is! SupersededRequest
          ? ApiErrorView(
              error: e,
              onRetry: () => ref.invalidate(targetsProvider),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      final q = budgetQueryFor(targets, prefs, full: false);
      final rangeAsync = ref.watch(budgetRangeProvider(q));
      final range = rangeAsync.value;
      if (range == null) {
        final e = rangeAsync.error;
        body = e != null && e is! SupersededRequest
            ? ApiErrorView(
                error: e,
                onRetry: () => ref.invalidate(budgetRangeProvider(q)),
              )
            : const Center(child: CircularProgressIndicator());
      } else {
        final value = effectiveBudget(prefs.weeklyBudgetVnd, range);
        final mealsPerDay = [
          prefs.slots.breakfast,
          prefs.slots.lunch,
          prefs.slots.dinner,
          prefs.slots.snackAm,
          prefs.slots.snackPm,
        ].where((m) => m == 'on').length;
        void save(double v) => ref
            .read(preferencesProvider.notifier)
            .update((p) => p.copyWith(weeklyBudgetVnd: v));
        canContinue = true;
        // Người dùng bấm Tiếp tục mà chưa kéo thanh trượt → lưu mức gợi ý đang hiển thị.
        onContinue = () {
          save(value);
          OnboardingNav(ref).next();
        };
        caption = l.onboardingBudgetEstimate(
          l.commonVnd(formatVnd(snapBudget(range.estimateVnd, range))),
        );
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BudgetSlider(range: range, value: value, onChanged: save),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.onboardingBudgetMealsRef(mealsPerDay * 7),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppBanner(message: l.onboardingBudgetNote),
          ],
        );
      }
    }

    return OnboardingScaffold(
      title: l.onboardingBudgetTitle,
      canContinue: canContinue,
      onContinue: onContinue,
      caption: caption,
      children: [body],
    );
  }
}
