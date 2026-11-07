import 'dart:convert';

import 'package:flutter/material.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../ui/ui.dart';
import 'onboarding_providers.dart';

/// Truy vấn khoảng ngân sách từ chỉ tiêu + lựa chọn hiện tại.
BudgetQuery budgetQueryFor(
  Targets targets,
  Preferences prefs, {
  required bool full,
}) => BudgetQuery(
  kcal: targets.kcalTarget,
  proteinG: targets.proteinG,
  // Khi chưa "full": chỉ các trường ảnh hưởng tới min/max ở bước ngân sách.
  preferencesJson: jsonEncode(
    full
        ? prefs.toJson()
        : {
            'store': prefs.storeId,
            'adults': prefs.adults,
            'children': prefs.children,
            'slots': prefs.slots.toJson(),
          },
  ),
  full: full,
);

/// Làm tròn [v] về bước gần nhất trong [min, max].
double snapBudget(double v, BudgetRangeResponse r) {
  if (r.stepVnd <= 0) return v.clamp(r.minVnd, r.maxVnd).toDouble();
  final snapped = r.minVnd + ((v - r.minVnd) / r.stepVnd).round() * r.stepVnd;
  return snapped.clamp(r.minVnd, r.maxVnd).toDouble();
}

/// Giá trị ngân sách đang hiệu lực: giá trị đã chọn nếu còn nằm trong khoảng, nếu không thì mức ước tính.
double effectiveBudget(double chosen, BudgetRangeResponse r) {
  if (chosen > 0 && chosen >= r.minVnd && chosen <= r.maxVnd) {
    return snapBudget(chosen, r);
  }
  return snapBudget(r.estimateVnd, r);
}

/// Bậc chi tiêu chứa [v] (3 bậc, nhãn lấy từ i18n theo `key`).
BudgetTierDto tierOf(double v, BudgetRangeResponse r) {
  for (final t in r.tiers) {
    if (v >= t.fromVnd && v < t.toVnd) return t;
  }
  return r.tiers.last;
}

/// Thanh trượt ngân sách + nhãn bậc đổi theo vị trí + ba bậc.
class BudgetSlider extends StatelessWidget {
  const BudgetSlider({
    required this.range,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final BudgetRangeResponse range;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final tier = tierOf(value, range);
    final divisions = range.stepVnd > 0
        ? ((range.maxVnd - range.minVnd) / range.stepVnd).round()
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppSpacing.sm,
          children: [
            Text(
              l.commonVnd(formatVnd(value)),
              key: const Key('budget-value'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(l.onboardingBudgetPerWeek, style: theme.textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppBanner(
          key: const Key('budget-tier'),
          kind: BannerKind.success,
          message: Labels.budgetTier(l, tier.key),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: l.onboardingBudgetPerWeek,
          child: Slider(
            key: const Key('budget-slider'),
            value: value.clamp(range.minVnd, range.maxVnd),
            min: range.minVnd,
            max: range.maxVnd,
            divisions: divisions == null || divisions < 1 ? null : divisions,
            label: l.commonVnd(formatVnd(value)),
            semanticFormatterCallback: (v) => l.commonVnd(formatVnd(v)),
            onChanged: (v) => onChanged(snapBudget(v, range)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l.onboardingBudgetMin(l.commonVnd(formatVnd(range.minVnd))),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  l.onboardingBudgetMax(l.commonVnd(formatVnd(range.maxVnd))),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
