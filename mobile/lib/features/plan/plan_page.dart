import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../state/week_changes.dart';
import '../../ui/ui.dart';
import '../meal/change_sheets.dart';
import '../onboarding/onboarding_nav.dart';
import 'plan_view.dart';

/// Tab Kế hoạch (US-3.1): lời chào, trạng thái tuần, banner validator, 7 ngày cuộn dọc.
class PlanPage extends ConsumerWidget {
  const PlanPage({super.key, this.now});

  /// Chỉ dùng trong test để cố định "hôm nay".
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final saved = ref.watch(currentPlanProvider);
    final today = now ?? ref.watch(clockProvider)();
    final replanned = ref.watch(replanNoticeProvider);
    if (saved == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.tabPlan)),
        body: _Empty(
          onSetup: () => ref
              .read(onboardingProvider.notifier)
              .update(
                (s) => s.copyWith(
                  completed: false,
                  step: OnboardingStep.summary.index,
                ),
              ),
        ),
      );
    }
    final plan = saved.plan; // WeekPlan
    final banner = planBanner(l, plan);
    final todayIndex = dayIndexOf(plan.startDate, today);
    final batches = batchCounts(plan);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.tabPlan)),
      body: ListView(
        key: const Key('plan-list'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(
              greeting(l, today),
              key: const Key('plan-greeting'),
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            weekStatus(l, plan.startDate, today),
            key: const Key('plan-status'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Sau khi lên lại tuần: banner "Đã lên lại tuần" kèm kết quả validator (US-5.5 AC2).
          if (replanned)
            AppBanner(
              key: const Key('plan-replan-banner'),
              kind: banner.ok ? BannerKind.success : BannerKind.warning,
              title: l.planReplanTitle,
              message: banner.message,
              actionLabel: l.commonClose,
              onAction: () => ref.read(replanNoticeProvider.notifier).dismiss(),
            )
          else
            AppBanner(
              key: const Key('plan-banner'),
              kind: banner.ok ? BannerKind.success : BannerKind.warning,
              message: banner.message,
            ),
          for (var i = 0; i < plan.days.length; i++) ...[
            const SizedBox(height: AppSpacing.xl),
            _DaySection(
              day: plan.days[i],
              isToday: i == todayIndex,
              exempt: plan.validation.days.any(
                (v) => v.date == plan.days[i].date && v.exempt,
              ),
              recipes: saved.recipes,
              batches: batches,
            ),
          ],
          if (hasDaysAfter(plan, today)) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('replan-rest'),
              label: l.planReplanButton,
              icon: Icons.autorenew,
              kind: AppButtonKind.secondary,
              expand: true,
              onPressed: () => confirmReplan(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onSetup});

  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.planEmptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.planEmptyBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l.planEmptyCta, onPressed: onSetup),
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.isToday,
    required this.exempt,
    required this.recipes,
    required this.batches,
  });

  final PlanDay day;
  final bool isToday;

  /// Ngày có bữa ăn ngoài / bỏ bữa: không bị tính là không đạt.
  final bool exempt;
  final Map<String, Recipe> recipes;
  final Map<String, int> batches;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Column(
      key: Key('day-${day.date}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  dayHeading(l, day.date),
                  key: Key('day-heading-${day.date}'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            if (isToday)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: AppChip(
                  key: const Key('plan-today-chip'),
                  label: l.planDayToday,
                  selected: true,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l.planDayTotals(
            formatInt(day.totals.proteinG),
            formatInt(day.totals.kcal),
          ),
          key: Key('day-totals-${day.date}'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        if (exempt)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppChip(
                key: Key('day-exempt-${day.date}'),
                label: l.planOutDay,
                icon: Icons.restaurant_outlined,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        for (final m in sortedMeals(day)) ...[
          _MealTile(meal: m, recipes: recipes, batches: batches),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

/// Bữa đã đánh dấu ăn ngoài / bỏ bữa: dòng mờ kèm nút Hoàn tác (US-5.3 AC4).
class _OutTile extends ConsumerWidget {
  const _OutTile({required this.meal, super.key});

  final PlanMeal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final slot = Labels.slot(l, meal.slot);
    final text = meal.status == 'skipped' ? l.planSkipped : l.planEatOut;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                container: true,
                label: '$slot. $text',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      text,
                      key: Key('out-label-${meal.date}-${meal.slot}'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppButton(
              key: Key('out-undo-${meal.date}-${meal.slot}'),
              label: l.commonUndo,
              kind: AppButtonKind.text,
              onPressed: () => runChange(
                context,
                () => ref
                    .read(weekChangesProvider)
                    .setOut(meal.date, meal.slot, 'undo'),
                done: l.changeUndone,
                undoable: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.meal,
    required this.recipes,
    required this.batches,
  });

  final PlanMeal meal;
  final Map<String, Recipe> recipes;
  final Map<String, int> batches;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final slot = Labels.slot(l, meal.slot);
    final key = Key('meal-${meal.date}-${meal.slot}');

    if (meal.status == 'eaten_out' || meal.status == 'skipped') {
      return _OutTile(key: key, meal: meal);
    }
    if (!isCooked(meal)) {
      // "Tôi tự lo" / "Ăn ngoài" / chưa lên được món: dòng mờ, không có món.
      final text = switch (meal.status) {
        'self' => l.planSelf,
        'unfilled' => l.planUnfilled,
        _ => l.planEatOut,
      };
      return ListRow(key: key, title: slot, subtitle: text, dimmed: true);
    }

    final recipe = recipes[meal.recipeId];
    final minutes = recipe?.cookMinutes ?? 0;
    final title = mealTitle(meal, recipes);
    final dessert = dessertName(meal);
    final shared = meal.batchGroupId == null
        ? 0
        : (batches[meal.batchGroupId] ?? 0);
    final labelParts = [
      slot,
      if (minutes > 0) l.planCookMinutes(formatInt(minutes)),
    ];
    return Semantics(
      button: true,
      label:
          '${labelParts.join(', ')}. $title. '
          '${l.planDayTotals(formatInt(meal.macros.proteinG), formatInt(meal.macros.kcal))}',
      excludeSemantics: true,
      onTap: () => context.push(Routes.meal(meal.date, meal.slot)),
      child: Card(
        key: key,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push(Routes.meal(meal.date, meal.slot)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DishImage(
                  image: recipe?.image,
                  group: ImageGroup.fromWire(recipe?.imageGroup),
                  size: 72,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelParts.join(' · ').toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        key: Key('meal-title-${meal.date}-${meal.slot}'),
                        style: theme.textTheme.titleMedium,
                      ),
                      if (dessert != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          l.planDessertLine(dessert),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          MacroChip(
                            kind: MacroKind.protein,
                            label: l.macroProtein,
                            value: '${formatInt(meal.macros.proteinG)} g',
                          ),
                          MacroChip(
                            kind: MacroKind.kcal,
                            label: l.macroKcal,
                            value: '${formatInt(meal.macros.kcal)} kcal',
                          ),
                          if (shared > 1)
                            Text(
                              l.planCookOnceN(shared),
                              key: Key('batch-${meal.date}-${meal.slot}'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
