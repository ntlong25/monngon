import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/number_field.dart';
import '../../ui/ui.dart';
import 'onboarding_scaffold.dart';
import 'validation.dart';

/// Bước 2 — giới tính, tuổi, chiều cao, cân nặng. Ngoài khoảng → lỗi tại chỗ và khóa nút Tiếp tục (US-1.1 AC1).
class BodyStep extends ConsumerWidget {
  const BodyStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final bad = validateProfile(p);

    String? error(ProfileField f, String label, ({int min, int max}) r) =>
        bad.contains(f) ? l.validationRange(label, r.min, r.max) : null;

    return OnboardingScaffold(
      title: l.onboardingBodyTitle,
      subtitle: l.onboardingBodyHint,
      canContinue: !bad.any(
        (f) => const {
          ProfileField.age,
          ProfileField.heightCm,
          ProfileField.weightKg,
        }.contains(f),
      ),
      children: [
        Text(
          l.onboardingBodySex,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedControl<String>(
          value: p.sex,
          onChanged: (v) => notifier.update((x) => x.copyWith(sex: v)),
          options: [
            SegmentOption(value: 'male', label: l.onboardingBodySexMale),
            SegmentOption(value: 'female', label: l.onboardingBodySexFemale),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        NumberField(
          fieldKey: const Key('field-age'),
          label: l.onboardingBodyAge,
          unit: l.unitYears,
          value: p.age,
          errorText: error(ProfileField.age, l.onboardingBodyAge, Limits.age),
          onChanged: (v) => notifier.update((x) => x.copyWith(age: v ?? 0)),
        ),
        const SizedBox(height: AppSpacing.lg),
        NumberField(
          fieldKey: const Key('field-height'),
          label: l.onboardingBodyHeight,
          unit: l.unitCm,
          decimal: true,
          value: p.heightCm,
          errorText: error(
            ProfileField.heightCm,
            l.onboardingBodyHeight,
            Limits.heightCm,
          ),
          onChanged: (v) =>
              notifier.update((x) => x.copyWith(heightCm: v ?? 0)),
        ),
        const SizedBox(height: AppSpacing.lg),
        NumberField(
          fieldKey: const Key('field-weight'),
          label: l.onboardingBodyWeight,
          unit: l.unitKg,
          decimal: true,
          value: p.weightKg,
          errorText: error(
            ProfileField.weightKg,
            l.onboardingBodyWeight,
            Limits.weightKg,
          ),
          onChanged: (v) =>
              notifier.update((x) => x.copyWith(weightKg: v ?? 0)),
        ),
      ],
    );
  }
}
