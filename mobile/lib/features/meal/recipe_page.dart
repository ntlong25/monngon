import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../core/wakelock.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../plan/plan_view.dart';
import 'change_sheets.dart';
import 'meal_data.dart';
import 'recipe_widgets.dart';

/// Công thức riêng của một món trong mâm (US-3.2 AC6) + chế độ nấu: màn hình luôn sáng, chạm bước để đánh dấu xong.
class RecipePage extends ConsumerWidget {
  const RecipePage({
    required this.date,
    required this.slot,
    required this.recipeId,
    super.key,
  });

  final String date;
  final String slot;
  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final plan = ref.watch(currentPlanProvider);
    final meal = plan == null ? null : findMeal(plan, date, slot);
    Dish? dish;
    for (final d in meal?.dishes ?? const <Dish>[]) {
      if (d.recipeId == recipeId) dish = d;
    }
    if (plan == null || meal == null || dish == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.mealNotFound)),
      );
    }
    final prefs = ref.watch(preferencesProvider);
    final recipe = plan.recipes[recipeId];
    final minutes = recipe?.cookMinutes ?? 0;
    final weekday = Labels.weekday(l, parseIsoDate(date).weekday);
    final household = prefs.adults + prefs.children > 1;

    return Scaffold(
      appBar: AppBar(),
      body: KeepAwake(
        child: ListView(
          key: const Key('recipe-list'),
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
              '${l.mealContext(weekday, Labels.slot(l, slot))} · '
                      '${Labels.dishRole(l, dish.role)}'
                  .toUpperCase(),
              key: const Key('recipe-context'),
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              header: true,
              child: Text(
                dish.name,
                key: const Key('recipe-title'),
                style: theme.textTheme.headlineSmall,
              ),
            ),
            if (minutes > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.planCookMinutes(formatInt(minutes)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            MacroRow(macros: dish.macros, large: true),
            const SizedBox(height: AppSpacing.lg),
            IngredientsCard(
              showWhole: household,
              swappable: swappableIngredients(recipe, dish.grams),
              onSwap: (row) => showIngredientSwapSheet(
                context,
                date: date,
                slot: slot,
                ingredientId: row.id,
                ingredientName: row.name,
              ),
              rows: buildRows(
                l: l,
                yours: dish.grams,
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
              stateKey: cookKey(date, slot, recipeId),
            ),
          ],
        ),
      ),
    );
  }
}
