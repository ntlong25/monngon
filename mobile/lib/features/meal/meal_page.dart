import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/labels.dart';
import '../../core/wakelock.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../state/week_changes.dart';
import '../../ui/ui.dart';
import '../plan/plan_view.dart';
import 'change_sheets.dart';
import 'meal_data.dart';
import 'recipe_widgets.dart';
import 'rice_card.dart';

/// Màn bữa (US-3.2): ảnh, ngữ cảnh, tên, thời gian, chip macro, "Cách chúng mình tính",
/// rồi — bữa một món: Nguyên liệu + Cách làm; bữa ghép mâm: thẻ từng món (AC6).
class MealPage extends ConsumerWidget {
  const MealPage({required this.date, required this.slot, super.key});

  final String date;
  final String slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final plan = ref.watch(currentPlanProvider);
    final meal = plan == null ? null : findMeal(plan, date, slot);
    if (plan == null || meal == null || !isCooked(meal)) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(l.mealNotFound, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final prefs = ref.watch(preferencesProvider);
    final recipe = plan.recipes[meal.recipeId];
    final mam = isMam(meal);
    final dishes = mamDishes(meal);
    final minutes = recipe?.cookMinutes ?? 0;
    final weekday = Labels.weekday(l, parseIsoDate(date).weekday);
    final household = prefs.adults + prefs.children > 1;

    final body = ListView(
      key: const Key('meal-list'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Center(
          child: DishImage(
            image: recipe?.image,
            group: ImageGroup.fromWire(recipe?.imageGroup),
            size: 160,
            borderRadius: AppRadius.lg,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l.mealContext(weekday, Labels.slot(l, slot)).toUpperCase(),
          key: const Key('meal-context'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          header: true,
          child: Text(
            mealTitle(meal, plan.recipes),
            key: const Key('meal-title'),
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (minutes > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                l.planCookMinutes(formatInt(minutes)),
                key: const Key('meal-minutes'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        KeyedSubtree(
          key: const Key('meal-macros'),
          child: MacroRow(macros: meal.macros, large: true),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: const Key('calc-link'),
            onPressed: () => context.push(Routes.mealCalc(date, slot)),
            child: Text(l.recipeCalcLink),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ChangeActions(date: date, slot: slot),
        const SizedBox(height: AppSpacing.md),
        if (mam) ...[
          Semantics(
            header: true,
            child: Text(l.mealMamTitle, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final d in dishes) ...[
            DishCard(
              key: Key('dish-${d.recipeId}'),
              roleLabel: Labels.dishRole(l, d.role),
              name: d.name,
              proteinText: '${formatInt(d.macros.proteinG)} g',
              kcalText: '${formatInt(d.macros.kcal)} kcal',
              proteinLabel: l.macroProtein,
              kcalLabel: l.macroKcal,
              image: plan.recipes[d.recipeId]?.image,
              group: ImageGroup.fromWire(plan.recipes[d.recipeId]?.imageGroup),
              onTap: () =>
                  context.push(Routes.mealDish(date, slot, d.recipeId!)),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (meal.rice case final rice?) ...[
            RiceCard(
              rice: rice,
              notes: meal.notes,
              dishName: dishes
                  .where((d) => d.role == 'carb_base')
                  .firstOrNull
                  ?.name,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (meal.extras.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            IngredientsCard(
              title: l.mealExtrasTitle,
              showWhole: false,
              rows: buildRows(
                l: l,
                yours: meal.extras,
                standard: const {},
                info: plan.ingredients,
                adults: 1,
                children: 0,
                formatCount: formatDecimal,
              ),
            ),
          ],
        ] else ...[
          IngredientsCard(
            showWhole: household,
            swappable: swappableIngredients(recipe, meal.grams),
            onSwap: (row) => showIngredientSwapSheet(
              context,
              date: date,
              slot: slot,
              ingredientId: row.id,
              ingredientName: row.name,
            ),
            rows: buildRows(
              l: l,
              yours: meal.grams,
              standard: standardOf(recipe),
              info: plan.ingredients,
              adults: prefs.adults,
              children: prefs.children,
              formatCount: formatDecimal,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          StepsCard(
            steps: recipe?.steps ?? const [],
            stateKey: cookKey(date, slot, meal.recipeId!),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: const Key('not-for-me'),
            onPressed: () async {
              // Mâm: chặn món chính của mâm; bữa một món: chặn chính món đó.
              final target = mam && dishes.isNotEmpty
                  ? dishes.first.recipeId!
                  : meal.recipeId!;
              final canReplan = hasDaysAfter(
                plan.plan,
                ref.read(clockProvider)(),
              );
              final choice = await askBlock(context, canReplan: canReplan);
              if (choice == null || !context.mounted) return;
              final changes = ref.read(weekChangesProvider);
              if (choice == BlockChoice.blockOnly) {
                changes.blockOnly(target);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l.recipeBlocked),
                      action: SnackBarAction(
                        label: l.commonUndo,
                        onPressed: changes.undo,
                      ),
                    ),
                  );
                return;
              }
              final nav = GoRouter.of(context);
              final ok = await runChange(
                context,
                () => changes.regenerateRest(blockRecipeId: target),
                done: l.planReplanTitle,
              );
              if (ok && context.mounted) nav.pop();
            },
            child: Text(l.recipeNotForMe),
          ),
        ),
      ],
    );
    // Bữa một món có hướng dẫn nấu ngay trên màn này → giữ màn hình sáng.
    return Scaffold(
      appBar: AppBar(),
      body: mam ? body : KeepAwake(child: body),
    );
  }
}

/// Nút thay đổi bữa: đổi món, ăn ngoài / bỏ bữa (US-5.1, 5.3).
class _ChangeActions extends StatelessWidget {
  const _ChangeActions({required this.date, required this.slot});

  final String date;
  final String slot;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppButton(
          key: const Key('change-meal'),
          label: l.changeSwapMeal,
          icon: Icons.swap_horiz,
          kind: AppButtonKind.secondary,
          onPressed: () => showSwapSheet(context, date: date, slot: slot),
        ),
        AppButton(
          key: const Key('eat-out'),
          label: l.changeEatOut,
          icon: Icons.restaurant_outlined,
          kind: AppButtonKind.secondary,
          onPressed: () async {
            final nav = GoRouter.of(context);
            final done = await showOutSheet(context, date: date, slot: slot);
            // Bữa đã đánh dấu không còn món để xem: quay lại tab Kế hoạch.
            if (done && context.mounted) nav.pop();
          },
        ),
      ],
    );
  }
}
