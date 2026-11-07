import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'onboarding_providers.dart';
import 'onboarding_scaffold.dart';
import 'validation.dart';

const _mainSlots = ['breakfast', 'lunch', 'dinner'];

String _modeOf(SlotsConfig s, String slot) => switch (slot) {
  'breakfast' => s.breakfast,
  'lunch' => s.lunch,
  'dinner' => s.dinner,
  'snack_am' => s.snackAm,
  _ => s.snackPm,
};

SlotsConfig _withMode(SlotsConfig s, String slot, String mode) =>
    switch (slot) {
      'breakfast' => s.copyWith(breakfast: mode),
      'lunch' => s.copyWith(lunch: mode),
      'dinner' => s.copyWith(dinner: mode),
      'snack_am' => s.copyWith(snackAm: mode),
      _ => s.copyWith(snackPm: mode),
    };

/// Bước 8 — chọn bữa cần lên thực đơn (US-1.3). Phân bổ lấy từ `POST /v1/slots/preview`.
class MealsStep extends ConsumerStatefulWidget {
  const MealsStep({super.key});

  @override
  ConsumerState<MealsStep> createState() => _MealsStepState();
}

class _MealsStepState extends ConsumerState<MealsStep> {
  /// Đã thử tắt bữa chính cuối cùng → hiện cảnh báo (AC4).
  bool _blocked = false;

  void _setMode(String slot, String mode) {
    final cur = ref.read(preferencesProvider).slots;
    final next = _withMode(cur, slot, mode);
    if (!hasPlannedMainMeal(next)) {
      setState(() => _blocked = true);
      return;
    }
    setState(() => _blocked = false);
    ref
        .read(preferencesProvider.notifier)
        .update((p) => p.copyWith(slots: next));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final slots = ref.watch(preferencesProvider.select((p) => p.slots));
    final preview = ref.watch(slotsPreviewProvider).value;
    final bySlot = {
      for (final s in preview?.slots ?? <SlotTarget>[]) s.slot: s,
    };
    final planned = (preview?.slots ?? const <SlotTarget>[])
        .where((s) => s.planned)
        .toList();
    final caption = planned.isEmpty
        ? null
        : l.onboardingMealsFooter(
            formatInt(
              planned.fold<double>(0, (a, s) => a + s.kcal) / planned.length,
            ),
            formatInt(
              planned.fold<double>(0, (a, s) => a + s.proteinG) /
                  planned.length,
            ),
          );

    Widget slotCard(String slot) {
      final mode = _modeOf(slots, slot);
      final isMain = _mainSlots.contains(slot);
      final t = bySlot[slot];
      final subtitle = switch (mode) {
        'on' when t != null => l.onboardingMealsPerSlot(
          formatInt(t.kcal),
          formatInt(t.proteinG),
        ),
        'self' => l.onboardingMealsSelfHint,
        'skip' => l.onboardingMealsOffHint,
        _ => null,
      };
      return Card(
        key: Key('slot-$slot'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Labels.slot(l, slot), style: theme.textTheme.titleMedium),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    key: Key('slot-$slot-sub'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              if (isMain)
                SegmentedControl<String>(
                  value: mode,
                  onChanged: (m) => _setMode(slot, m),
                  options: [
                    SegmentOption(value: 'on', label: l.onboardingMealsOn),
                    SegmentOption(value: 'self', label: l.onboardingMealsSelf),
                    SegmentOption(value: 'skip', label: l.onboardingMealsOff),
                  ],
                )
              else
                AppToggle(
                  label: l.onboardingMealsOn,
                  value: mode == 'on',
                  onChanged: (v) => _setMode(slot, v ? 'on' : 'skip'),
                ),
              if (slot == 'lunch' && mode == 'on') ...[
                const SizedBox(height: AppSpacing.md),
                SegmentedControl<String>(
                  value: slots.lunchStyle,
                  onChanged: (v) => ref
                      .read(preferencesProvider.notifier)
                      .update(
                        (p) =>
                            p.copyWith(slots: p.slots.copyWith(lunchStyle: v)),
                      ),
                  options: [
                    SegmentOption(value: 'hot', label: l.onboardingMealsHot),
                    SegmentOption(
                      value: 'packed',
                      label: l.onboardingMealsPacked,
                    ),
                  ],
                ),
              ],
              if (slot == 'snack_pm' && mode == 'on') ...[
                const SizedBox(height: AppSpacing.md),
                SegmentedControl<String>(
                  value: slots.snackPmStyle,
                  onChanged: (v) => ref
                      .read(preferencesProvider.notifier)
                      .update(
                        (p) => p.copyWith(
                          slots: p.slots.copyWith(snackPmStyle: v),
                        ),
                      ),
                  options: [
                    SegmentOption(
                      value: 'sweet',
                      label: l.onboardingMealsSweet,
                    ),
                    SegmentOption(
                      value: 'savory',
                      label: l.onboardingMealsSavory,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    return OnboardingScaffold(
      title: l.onboardingMealsTitle,
      subtitle: l.onboardingMealsHint,
      caption: caption,
      canContinue: hasPlannedMainMeal(slots),
      children: [
        if (_blocked || !hasPlannedMainMeal(slots)) ...[
          AppBanner(
            key: const Key('meals-need-one'),
            kind: BannerKind.warning,
            message: l.onboardingMealsNeedOne,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        for (final slot in const [
          'breakfast',
          'lunch',
          'dinner',
          'snack_am',
          'snack_pm',
        ]) ...[slotCard(slot), const SizedBox(height: AppSpacing.md)],
      ],
    );
  }
}
