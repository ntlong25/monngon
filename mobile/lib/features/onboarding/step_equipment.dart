import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/reference_gate.dart';
import 'onboarding_scaffold.dart';
import 'validation.dart';

/// Bước 12 — dụng cụ bếp, chọn nhiều, bắt buộc ≥ 1 thiết bị nấu (US-1.5 AC3).
/// Công thức cần dụng cụ không có sẽ không bao giờ được chọn (server xử lý theo `equipment`).
class EquipmentStep extends ConsumerWidget {
  const EquipmentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final equipment = ref.watch(preferencesProvider.select((p) => p.equipment));
    final ok = hasCookingDevice(equipment);
    return OnboardingScaffold(
      title: l.onboardingEquipmentTitle,
      subtitle: l.onboardingEquipmentHint,
      canContinue: ok,
      children: [
        if (!ok) ...[
          AppBanner(
            key: const Key('equipment-need-one'),
            kind: BannerKind.warning,
            message: l.onboardingEquipmentNeedOne,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ReferenceGate(
          builder: (context, r) => [
            for (final o in r.equipment) ...[
              SelectCard(
                key: Key('equip-${o.id}'),
                title: Labels.equipment(l, o),
                selected: equipment.contains(o.id),
                onTap: () => ref
                    .read(preferencesProvider.notifier)
                    .update(
                      (p) => p.copyWith(
                        equipment: p.equipment.contains(o.id)
                            ? p.equipment.where((e) => e != o.id).toList()
                            : [...p.equipment, o.id],
                      ),
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ],
    );
  }
}
