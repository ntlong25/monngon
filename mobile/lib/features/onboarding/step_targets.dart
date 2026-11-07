import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/number_field.dart';
import '../../ui/ui.dart';
import '../common/api_error_view.dart';
import 'onboarding_providers.dart';
import 'onboarding_scaffold.dart';
import 'validation.dart';

/// Bước 4 — màn chỉ tiêu: kết quả từ `POST /v1/targets`, từng dòng phép tính, chuyển sang "Tự nhập" (US-1.1 AC2–AC5).
class TargetsStep extends ConsumerWidget {
  const TargetsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final profile = ref.watch(profileProvider);
    final async = ref.watch(targetsProvider);
    final targets = async.value;
    final manual = profile.targetMode == 'manual';
    final bad = validateProfile(profile);
    final error = async.hasError && async.error is! SupersededRequest
        ? async.error
        : null;
    final ready =
        targets != null && !async.isLoading && bad.isEmpty && error == null;

    void setMode(String mode) {
      final n = ref.read(profileProvider.notifier);
      if (mode == 'manual') {
        n.update(
          (p) => p.copyWith(
            targetMode: 'manual',
            manualKcal: p.manualKcal ?? targets?.kcalTarget,
            manualProteinG: p.manualProteinG ?? targets?.proteinG,
          ),
        );
      } else {
        n.update((p) => p.copyWith(targetMode: 'formula'));
      }
    }

    return OnboardingScaffold(
      title: l.onboardingTargetsTitle,
      subtitle: l.onboardingTargetsEditNote,
      canContinue: ready,
      children: [
        SegmentedControl<String>(
          value: profile.targetMode,
          onChanged: setMode,
          options: [
            SegmentOption(
              value: 'formula',
              label: l.onboardingTargetsFormulaMode,
            ),
            SegmentOption(
              value: 'manual',
              label: l.onboardingTargetsManualMode,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (manual) ...[
          Text(
            l.onboardingTargetsManualHint,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          NumberField(
            fieldKey: const Key('field-manual-kcal'),
            label: l.onboardingTargetsManualKcal,
            value: profile.manualKcal,
            errorText: bad.contains(ProfileField.manualKcal)
                ? l.validationRange(
                    l.onboardingTargetsKcalLabel,
                    Limits.manualKcal.min,
                    Limits.manualKcal.max,
                  )
                : null,
            onChanged: (v) => ref
                .read(profileProvider.notifier)
                .update((p) => p.copyWith(manualKcal: v ?? 0)),
          ),
          const SizedBox(height: AppSpacing.lg),
          NumberField(
            fieldKey: const Key('field-manual-protein'),
            label: l.onboardingTargetsManualProtein,
            value: profile.manualProteinG,
            errorText: bad.contains(ProfileField.manualProtein)
                ? l.validationRange(
                    l.onboardingTargetsProteinLabel,
                    Limits.manualProteinG.min,
                    Limits.manualProteinG.max,
                  )
                : null,
            onChanged: (v) => ref
                .read(profileProvider.notifier)
                .update((p) => p.copyWith(manualProteinG: v ?? 0)),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (error != null)
          ApiErrorView(
            error: error,
            onRetry: () => ref.invalidate(targetsProvider),
          )
        else if (targets == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          _ResultCard(targets: targets, refreshing: async.isLoading),
          if (targets.steps != null && !manual) ...[
            const SizedBox(height: AppSpacing.xl),
            _CalcSteps(steps: targets.steps!, targets: targets),
          ],
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.targets, required this.refreshing});

  final Targets targets;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: refreshing ? 0.5 : 1,
      child: Card(
        key: const Key('targets-card'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Big(
                      label: l.onboardingTargetsProteinLabel,
                      value: l.commonGram(formatInt(targets.proteinG)),
                      highlight: true,
                      valueKey: const Key('targets-protein'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _Big(
                      label: l.onboardingTargetsKcalLabel,
                      value: l.commonKcal(formatInt(targets.kcalTarget)),
                      valueKey: const Key('targets-kcal'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.onboardingTargetsKcalBand(
                  formatInt(targets.kcalMin),
                  formatInt(targets.kcalMax),
                ),
                key: const Key('targets-band'),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 2),
              Text(
                l.onboardingTargetsBandNote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Big extends StatelessWidget {
  const _Big({
    required this.label,
    required this.value,
    required this.valueKey,
    this.highlight = false,
  });

  final String label;
  final String value;
  final Key valueKey;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight ? AppColors.accentContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: highlight
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              key: valueKey,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: highlight ? AppColors.onAccentContainer : AppColors.text,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: highlight
                    ? AppColors.onAccentContainer
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Từng dòng phép tính: BMR → TDEE → mục tiêu → protein (US-1.1 AC4).
class _CalcSteps extends StatelessWidget {
  const _CalcSteps({required this.steps, required this.targets});

  final TargetSteps steps;
  final Targets targets;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final lines = <String>[
      l.onboardingTargetsStepBmr(formatInt(steps.bmr)),
      l.onboardingTargetsStepTdee(
        formatDecimal(steps.activityFactor),
        formatInt(steps.tdee),
      ),
      l.onboardingTargetsStepGoal(
        formatDecimal(steps.goalFactor),
        formatInt(steps.kcalUnrounded),
        formatInt(targets.kcalTarget),
      ),
      l.onboardingTargetsStepProtein(
        formatDecimal(steps.proteinGPerKg),
        formatDecimal(steps.referenceWeightKg),
        formatInt(steps.proteinRawG),
      ),
      if (steps.proteinLimitedBy == 'cap')
        l.onboardingTargetsStepProteinCap(
          formatInt(steps.proteinCapG),
          formatInt(targets.proteinG),
        )
      else if (steps.proteinLimitedBy == 'floor')
        l.onboardingTargetsStepProteinFloor(
          formatInt(steps.proteinFloorG),
          formatInt(targets.proteinG),
        ),
    ];
    return Column(
      key: const Key('calc-steps'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.onboardingTargetsHowTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < lines.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(lines[i], style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
