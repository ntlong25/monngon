import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'meal_data.dart';
import 'recipe_widgets.dart';

/// Một dòng của bảng tính.
class CalcLine {
  const CalcLine({
    required this.name,
    required this.grams,
    required this.macros,
    required this.source,
  });

  final String name;
  final double grams;
  final Macros macros;

  /// Chuỗi nguồn đã định dạng; null nếu chưa truy được (dòng gộp).
  final String? source;
}

/// "Cách chúng mình tính" (US-3.3): từng nguyên liệu gram × giá trị/100 g, nguồn dữ liệu, tổng khớp chip macro.
class CalcPage extends ConsumerWidget {
  const CalcPage({required this.date, required this.slot, super.key});

  final String date;
  final String slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final plan = ref.watch(currentPlanProvider);
    final meal = plan == null ? null : findMeal(plan, date, slot);
    final trace = plan == null ? null : findTrace(plan, date, slot);
    if (plan == null || meal == null || trace == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.mealNotFound)),
      );
    }

    CalcLine fromTrace(TraceLine t) => CalcLine(
      name: t.name,
      grams: t.grams,
      macros: t.macros,
      source: t.source,
    );
    final main = trace.lines.map(fromTrace).toList();
    final extras = trace.extras.map(fromTrace).toList();
    final dessertLines = trace.dessert.map(fromTrace).toList();

    Widget section(String? title, List<CalcLine> lines) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          const SizedBox(height: AppSpacing.md),
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        for (var i = 0; i < lines.length; i++) ...[
          SizedBox(
            width: double.infinity,
            child: _CalcCard(line: lines[i]),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.calcTitle)),
      body: ListView(
        key: const Key('calc-list'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Text(l.calcIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          section(null, main),
          if (extras.isNotEmpty) section(l.calcExtrasHeading, extras),
          if (dessertLines.isNotEmpty) section(l.dishRoleDessert, dessertLines),
          const SizedBox(height: AppSpacing.md),
          Card(
            key: const Key('calc-total'),
            color: AppColors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.calcTotal, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  MacroRow(macros: meal.macros),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l.calcTotalNote, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.calcSourceNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  const _CalcCard({required this.line});

  final CalcLine line;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final per100 = line.grams > 0 ? line.macros.kcal / line.grams * 100 : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.name, style: theme.textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(
              '${l.calcFormula(formatInt(line.grams), formatInt(per100))} '
              '= ${formatInt(line.macros.kcal)} kcal',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            MacroRow(macros: line.macros),
            if (line.source != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                line.source!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
