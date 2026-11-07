import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'meal_data.dart';

/// Hàng chip macro: protein nổi bật, rồi calo, tinh bột, béo.
class MacroRow extends StatelessWidget {
  const MacroRow({required this.macros, this.large = false, super.key});

  final Macros macros;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        MacroChip(
          kind: MacroKind.protein,
          label: l.macroProtein,
          value: '${formatInt(macros.proteinG)} g',
          large: large,
        ),
        MacroChip(
          kind: MacroKind.kcal,
          label: l.macroKcal,
          value: '${formatInt(macros.kcal)} kcal',
          large: large,
        ),
        MacroChip(
          kind: MacroKind.carb,
          label: l.macroCarb,
          value: '${formatInt(macros.carbG)} g',
          large: large,
        ),
        MacroChip(
          kind: MacroKind.fat,
          label: l.macroFat,
          value: '${formatInt(macros.fatG)} g',
          large: large,
        ),
      ],
    );
  }
}

/// Thẻ Nguyên liệu: tên + gram + quy đổi đơn vị bếp; hộ > 1 người có hai cột "Phần của bạn" / "Cả nồi".
class IngredientsCard extends StatelessWidget {
  const IngredientsCard({
    required this.rows,
    required this.showWhole,
    this.title,
    this.swappable = const {},
    this.onSwap,
    super.key,
  });

  final List<IngredientRow> rows;
  final bool showWhole;
  final String? title;

  /// Mã nguyên liệu có nút "đổi nguyên liệu" (US-5.2), cùng [onSwap].
  final Set<String> swappable;
  final void Function(IngredientRow row)? onSwap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textMuted,
    );
    return Card(
      key: const Key('ingredients-card'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                title ?? l.recipeIngredientsTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (showWhole)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox.shrink()),
                    SizedBox(
                      width: 92,
                      child: Text(
                        l.recipeServingsYours,
                        key: const Key('col-yours'),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    SizedBox(
                      width: 92,
                      child: Text(
                        l.recipeServingsWhole,
                        key: const Key('col-whole'),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            for (final r in rows)
              Padding(
                key: Key('ing-${r.id}'),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: theme.textTheme.bodyLarge),
                          if (r.unit != null) Text(r.unit!, style: muted),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: showWhole ? 92 : 72,
                      child: Text(
                        '${formatInt(r.yours)} g',
                        key: Key('ing-${r.id}-yours'),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (showWhole)
                      SizedBox(
                        width: 92,
                        child: Text(
                          '${formatInt(r.whole)} g',
                          key: Key('ing-${r.id}-whole'),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    if (onSwap != null)
                      SizedBox(
                        width: 48,
                        child: swappable.contains(r.id)
                            ? IconButton(
                                key: Key('ing-swap-${r.id}'),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                tooltip: l.changeIngSwapAction(r.name),
                                icon: const Icon(Icons.swap_horiz, size: 22),
                                color: AppColors.primary,
                                onPressed: () => onSwap!(r),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ Cách làm: chạm từng bước để đánh dấu xong (lưu lâu dài).
class StepsCard extends ConsumerWidget {
  const StepsCard({required this.steps, required this.stateKey, super.key});

  final List<String> steps;

  /// Khóa lưu trạng thái, xem `cookKey`.
  final String stateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final done = ref.watch(
      cookedStepsProvider.select((m) => m[stateKey] ?? const <int>{}),
    );
    final items = parseSteps(steps);
    return Card(
      key: const Key('steps-card'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l.recipeStepsTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.recipeCookModeKeepOn,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (items.isEmpty) Text(l.recipeNoSteps),
            for (final it in items)
              if (it.isHeader)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.xs,
                  ),
                  child: Text(it.text, style: theme.textTheme.titleSmall),
                )
              else
                _StepTile(
                  index: it.index!,
                  text: it.text,
                  done: done.contains(it.index),
                  semanticLabel: l.recipeStepToggle(it.index! + 1, it.text),
                  onTap: () => ref
                      .read(cookedStepsProvider.notifier)
                      .toggle(stateKey, it.index!),
                ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.text,
    required this.done,
    required this.semanticLabel,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool done;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      checked: done,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        key: Key('step-$index'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTouch),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.circle_outlined,
                  key: Key(done ? 'step-$index-done' : 'step-$index-todo'),
                  color: done ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? AppColors.textMuted : AppColors.text,
                    ),
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
