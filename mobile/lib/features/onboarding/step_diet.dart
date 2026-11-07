import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/reference_gate.dart';
import 'onboarding_scaffold.dart';

List<String> _toggle(List<String> list, String id) =>
    list.contains(id) ? (list.where((e) => e != id).toList()) : [...list, id];

/// Bước 9 — kiểu ăn, loại bỏ hoàn toàn, xu hướng sức khoẻ (US-1.4).
///
///  - Kiểu ăn: chọn đúng 1 (`none` loại trừ mọi kiểu khác; chay / thuần chay / chay có cá không đi cùng nhau).
///  - "Ít tinh bột" kết hợp được với kiểu ăn bất kỳ.
///  - Mỗi lựa chọn loại bỏ hiện phạm vi (nguyên liệu bị loại) lấy từ `reference`.
///  - Xu hướng là ưu tiên mềm, kèm lưu ý không phải lời khuyên y tế.
class DietStep extends ConsumerWidget {
  const DietStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final diet = prefs.diet.isEmpty ? 'none' : prefs.diet;

    return OnboardingScaffold(
      title: l.onboardingDietTitle,
      subtitle: l.onboardingDietHint,
      children: [
        ReferenceGate(
          builder: (context, r) {
            final selectedExclusions = r.exclusions
                .where((o) => prefs.exclusions.contains(o.id))
                .toList();
            // D-ONB-03: chỉ 4 xu hướng chính thức; thẻ nội bộ (giau_dam, omega3, chay, low_carb) không hiện.
            final leanings = r.healthLeanings
                .where((o) => Labels.healthLeaningIds.contains(o.id))
                .toList();
            return [
              _SectionTitle(l.onboardingDietKindTitle),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final d in r.diets)
                    AppChip(
                      key: Key('diet-${d.id}'),
                      label: Labels.diet(l, d),
                      selected: d.id == diet,
                      onTap: () => notifier.update(
                        (p) => p.copyWith(diet: d.id == diet ? 'none' : d.id),
                      ),
                    ),
                  AppChip(
                    key: const Key('diet-low-carb'),
                    label: l.onboardingDietLowCarb,
                    selected: prefs.lowCarb,
                    onTap: () =>
                        notifier.update((p) => p.copyWith(lowCarb: !p.lowCarb)),
                  ),
                ],
              ),
              if (diet != 'none') ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  r.diets
                      .firstWhere(
                        (d) => d.id == diet,
                        orElse: () => const OptionDto(),
                      )
                      .description,
                  key: const Key('diet-scope'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(l.onboardingDietExcludeTitle),
              Text(
                l.onboardingDietExcludeHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final e in r.exclusions)
                    AppChip(
                      key: Key('excl-${e.id}'),
                      label: Labels.exclusion(l, e),
                      selected: prefs.exclusions.contains(e.id),
                      onTap: () => notifier.update(
                        (p) =>
                            p.copyWith(exclusions: _toggle(p.exclusions, e.id)),
                      ),
                    ),
                ],
              ),
              if (selectedExclusions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(l.onboardingDietScopeTitle),
                for (final e in selectedExclusions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text.rich(
                      key: Key('scope-${e.id}'),
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${Labels.exclusion(l, e)}: ',
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: e.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(l.onboardingDietLeaningsTitle),
              Text(
                l.healthDisclaimer,
                key: const Key('leanings-note'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final h in leanings)
                    AppChip(
                      key: Key('lean-${h.id}'),
                      label: Labels.leaning(l, h),
                      selected: prefs.healthLeanings.contains(h.id),
                      onTap: () => notifier.update(
                        (p) => p.copyWith(
                          healthLeanings: _toggle(p.healthLeanings, h.id),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final h in leanings)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '${Labels.leaning(l, h)}: ${Labels.leaningDesc(l, h)}',
                    key: Key('lean-desc-${h.id}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ];
          },
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}
