import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_providers.dart';
import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../core/rice.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/api_error_view.dart';
import 'budget_view.dart';
import 'onboarding_nav.dart';
import 'onboarding_providers.dart';
import 'onboarding_scaffold.dart';

enum _Phase { review, generating, failed }

/// Bước 13 — checklist tổng kết rồi tạo tuần (US-1.6).
///
///  - Hiện lần lượt: mục tiêu, protein tối thiểu, calo, số bữa, xu hướng, đã loại, căn bếp, ngân sách.
///  - Gọi lại `budget-range` kèm đầy đủ `preferences` (US-1.2 AC2c); ngân sách < min → cảnh báo.
///  - "Tạo thực đơn tuần" gọi `POST /v1/plans` không chặn UI; lỗi → màn lỗi thân thiện + Thử lại.
class SummaryStep extends ConsumerStatefulWidget {
  const SummaryStep({super.key});

  @override
  ConsumerState<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends ConsumerState<SummaryStep> {
  _Phase _phase = _Phase.review;
  Object? _error;
  double _budget = 0;

  Future<void> _create(double budget) async {
    _budget = budget;
    setState(() {
      _phase = _Phase.generating;
      _error = null;
    });
    try {
      final req = PlanRequest(
        profile: ref.read(profileProvider),
        preferences: ref
            .read(preferencesProvider)
            .copyWith(weeklyBudgetVnd: budget),
        startDate: isoDate(tomorrow()),
        mealStyle: 'auto',
        includeDessert: true,
      );
      final plan = await ref.read(apiProvider).createPlan(req);
      if (!mounted) return;
      ref.read(appActionsProvider).startNewWeek(plan);
      // Hoàn tất → router tự chuyển sang tab Kế hoạch.
      ref.read(onboardingProvider.notifier).complete();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase != _Phase.review) return _buildGenerating(context);
    final l = AppL10n.of(context);
    final profile = ref.watch(profileProvider);
    final prefs = ref.watch(preferencesProvider);
    final names = ref.watch(ingredientNamesProvider);
    final reference = ref.watch(referenceProvider).value;
    final targetsAsync = ref.watch(targetsProvider);
    final targets = targetsAsync.value;
    final nav = OnboardingNav(ref);

    BudgetRangeResponse? range;
    Object? rangeError;
    BudgetQuery? rangeQuery;
    if (targets != null) {
      rangeQuery = budgetQueryFor(targets, prefs, full: true);
      final rangeAsync = ref.watch(budgetRangeProvider(rangeQuery));
      range = rangeAsync.value;
      if (range == null && rangeAsync.error is! SupersededRequest) {
        rangeError = rangeAsync.error;
      }
    }
    // Mức tối thiểu lúc chọn ngân sách (dạng rút gọn, trước bước kiêng/dụng cụ/cơm) — để giải thích khi tổng kết cao hơn (D-QA-08).
    final earlierMin = targets == null
        ? null
        : ref
              .watch(
                budgetRangeProvider(
                  budgetQueryFor(targets, prefs, full: false),
                ),
              )
              .value
              ?.minVnd;
    final chosen = range == null
        ? prefs.weeklyBudgetVnd
        : (prefs.weeklyBudgetVnd > 0
              ? prefs.weeklyBudgetVnd
              : effectiveBudget(0, range));
    final tooLow = range != null && chosen > 0 && chosen < range.minVnd;
    final minRaisedByChoices =
        tooLow && earlierMin != null && range.minVnd > earlierMin + 1;

    String optionName(
      List<OptionDto> list,
      String id,
      String Function(OptionDto) label,
    ) {
      final o = list.where((e) => e.id == id);
      return o.isEmpty ? id : label(o.first);
    }

    final mealsPerDay = [
      prefs.slots.breakfast,
      prefs.slots.lunch,
      prefs.slots.dinner,
      prefs.slots.snackAm,
      prefs.slots.snackPm,
    ].where((m) => m == 'on').length;

    final leanings = <String>[
      if (prefs.lowCarb) l.onboardingSummaryLowCarb,
      for (final id in prefs.healthLeanings)
        optionName(
          reference?.healthLeanings ?? const [],
          id,
          (o) => Labels.leaning(l, o),
        ),
    ];
    final excluded = <String>[
      if (prefs.diet.isNotEmpty && prefs.diet != 'none')
        optionName(
          reference?.diets ?? const [],
          prefs.diet,
          (o) => Labels.diet(l, o),
        ),
      for (final id in prefs.exclusions)
        optionName(
          reference?.exclusions ?? const [],
          id,
          (o) => Labels.exclusion(l, o),
        ),
      for (final id in prefs.dislikedIngredientIds) names[id] ?? id,
    ];
    final kitchen = [
      for (final id in prefs.equipment)
        optionName(
          reference?.equipment ?? const [],
          id,
          (o) => Labels.equipment(l, o),
        ),
    ];
    String list(List<String> v) =>
        v.isEmpty ? l.onboardingSummaryNone : v.join(', ');

    final rows = <_Row>[
      _Row(
        'goal',
        l.onboardingSummaryGoal,
        Labels.goal(l, profile.goal),
        OnboardingStep.goal,
      ),
      _Row(
        'protein',
        l.onboardingSummaryProtein,
        targets == null ? '…' : '${formatInt(targets.proteinG)} g',
        OnboardingStep.targets,
      ),
      _Row(
        'kcal',
        l.onboardingSummaryKcal,
        targets == null ? '…' : '${formatInt(targets.kcalTarget)} kcal',
        OnboardingStep.targets,
      ),
      _Row(
        'meals',
        l.onboardingSummaryMeals,
        l.onboardingSummaryMealsValue(mealsPerDay),
        OnboardingStep.meals,
      ),
      _Row(
        'leanings',
        l.onboardingSummaryLeanings,
        list(leanings),
        OnboardingStep.diet,
      ),
      _Row(
        'rice',
        l.profileRiceHabitTitle,
        RiceHabit.summary(l, prefs),
        prefs.lowCarb ? OnboardingStep.diet : OnboardingStep.rice,
      ),
      _Row(
        'excluded',
        l.onboardingSummaryExcluded,
        list(excluded),
        OnboardingStep.dislike,
      ),
      _Row(
        'kitchen',
        l.onboardingSummaryKitchen,
        list(kitchen),
        OnboardingStep.equipment,
      ),
      _Row(
        'budget',
        l.onboardingSummaryBudget,
        chosen <= 0
            ? '…'
            : '${l.commonVnd(formatVnd(chosen))} ${l.onboardingBudgetPerWeek}',
        OnboardingStep.budget,
      ),
    ];

    final ready = targets != null && range != null && validateReady(prefs);
    return OnboardingScaffold(
      title: l.onboardingSummaryTitle,
      ctaLabel: l.onboardingSummaryCreate,
      canContinue: ready,
      onContinue: ready ? () => _create(chosen) : null,
      children: [
        if (tooLow) ...[
          AppBanner(
            key: const Key('summary-budget-low'),
            kind: BannerKind.warning,
            message: minRaisedByChoices
                ? l.onboardingSummaryBudgetLowReason(
                    l.commonVnd(formatVnd(range.minVnd)),
                    l.commonVnd(formatVnd(earlierMin)),
                  )
                : l.onboardingSummaryBudgetLow(
                    l.commonVnd(formatVnd(chosen)),
                    l.commonVnd(formatVnd(range.minVnd)),
                  ),
            actionLabel: minRaisedByChoices
                ? l.onboardingSummaryUseMinAmount(
                    l.commonVnd(formatVnd(range.minVnd)),
                  )
                : l.onboardingSummaryUseMin,
            onAction: () => ref
                .read(preferencesProvider.notifier)
                .update((p) => p.copyWith(weeklyBudgetVnd: range!.minVnd)),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (targetsAsync.hasError && targets == null)
          ApiErrorView(
            error: targetsAsync.error!,
            onRetry: () => ref.invalidate(targetsProvider),
          ),
        if (rangeError != null && rangeQuery != null) ...[
          ApiErrorView(
            error: rangeError,
            onRetry: () => ref.invalidate(budgetRangeProvider(rangeQuery!)),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        for (final r in rows)
          _SummaryRow(
            row: r,
            editLabel: l.onboardingSummaryEdit,
            onEdit: () => nav.goTo(r.step),
          ),
      ],
    );
  }

  /// Đủ điều kiện tạo tuần: có bữa chính và có thiết bị nấu.
  bool validateReady(Preferences p) =>
      [p.slots.breakfast, p.slots.lunch, p.slots.dinner].contains('on') &&
      p.equipment.isNotEmpty;

  Widget _buildGenerating(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final failed = _phase == _Phase.failed;
    return Scaffold(
      appBar: failed
          ? AppBar(
              leading: IconButton(
                key: const Key('generating-back'),
                tooltip: l.commonBack,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _phase = _Phase.review),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: failed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.onboardingGeneratingFail,
                        key: const Key('generating-fail'),
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ApiErrorView(
                        error: _error!,
                        onRetry: () => _create(_budget),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.xl),
                      Semantics(
                        liveRegion: true,
                        header: true,
                        child: Text(
                          l.onboardingGeneratingTitle,
                          key: const Key('generating-title'),
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l.onboardingGeneratingChecklist,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l.onboardingGeneratingWait,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Row {
  const _Row(this.id, this.label, this.value, this.step);

  final String id;
  final String label;
  final String value;
  final OnboardingStep step;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.row,
    required this.editLabel,
    required this.onEdit,
  });

  final _Row row;
  final String editLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: Key('summary-${row.id}'),
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      row.value,
                      key: Key('summary-${row.id}-value'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              TextButton(
                key: Key('summary-${row.id}-edit'),
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  minimumSize: const Size(kMinTouch, kMinTouch),
                ),
                child: Text(editLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
