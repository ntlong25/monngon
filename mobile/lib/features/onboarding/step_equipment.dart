import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/reference_gate.dart';
import 'onboarding_scaffold.dart';
import 'validation.dart';

/// Bước 13 — dụng cụ bếp: lưới thẻ có hình, chọn nhiều, bắt buộc ≥ 1 thiết bị nấu (US-1.5 AC3, D-ONB-09, T-108).
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
            _EquipmentGrid(
              options: r.equipment,
              selected: equipment,
              titleOf: (o) => Labels.equipment(l, o),
              onToggle: (id) => ref
                  .read(preferencesProvider.notifier)
                  .update(
                    (p) => p.copyWith(
                      equipment: p.equipment.contains(id)
                          ? p.equipment.where((e) => e != id).toList()
                          : [...p.equipment, id],
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Số cột: 2, và 3 khi màn hình rộng từ 600 dp.
int equipmentColumns(double width) => width >= 600 ? 3 : 2;

String _illustrationOf(String id) => 'dungcu-${id.replaceAll('_', '-')}';

IconData _fallbackIconOf(String id) => switch (id) {
  'bep' => Icons.local_fire_department_outlined,
  'noi_com_dien' => Icons.rice_bowl_outlined,
  'lo_vi_song' => Icons.microwave_outlined,
  'may_xay' => Icons.blender_outlined,
  _ => Icons.soup_kitchen_outlined,
};

class _EquipmentGrid extends StatelessWidget {
  const _EquipmentGrid({
    required this.options,
    required this.selected,
    required this.titleOf,
    required this.onToggle,
  });

  final List<OptionDto> options;
  final List<String> selected;
  final String Function(OptionDto o) titleOf;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      // Theo chiều rộng MÀN HÌNH (≥ 600 dp → 3 cột), không phải bề rộng đã trừ lề của cột nội dung.
      final cols = equipmentColumns(MediaQuery.sizeOf(context).width);
      final rows = <Widget>[];
      for (var i = 0; i < options.length; i += cols) {
        final chunk = options.skip(i).take(cols).toList();
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < cols; j++) ...[
                  if (j > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: j < chunk.length
                        ? _EquipmentTile(
                            key: Key('equip-${chunk[j].id}'),
                            id: chunk[j].id,
                            title: titleOf(chunk[j]),
                            selected: selected.contains(chunk[j].id),
                            onTap: () => onToggle(chunk[j].id),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
        rows.add(const SizedBox(height: AppSpacing.md));
      }
      return Column(
        key: const Key('equipment-grid'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    },
  );
}

/// Thẻ dụng cụ: hình + tên. Đã chọn thì có viền dày, nền nhạt VÀ dấu ✓ (không chỉ đổi màu). Cả thẻ là vùng chạm.
class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.id,
    required this.title,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String id;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      checked: selected,
      label: title,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? AppColors.primaryContainer : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  // Trải hết bề rộng thẻ để hình và tên căn giữa (Stack xếp con về góc trên trái).
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Illustration(
                          name: _illustrationOf(id),
                          fallback: _fallbackIconOf(id),
                          size: 72,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          title,
                          style: theme.textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (selected)
                  const Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Icon(
                      Icons.check_circle,
                      key: Key('equip-check'),
                      size: 24,
                      color: AppColors.primary,
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
