import 'package:flutter/material.dart';

import 'tokens.dart';

/// Chip chọn được (kiêng, dụng cụ, gợi ý nguyên liệu…). Vùng chạm cao ≥ 44.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.onDeleted,
    this.deleteLabel,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Có giá trị → hiện nút ✕ (chip nguyên liệu đã loại).
  final VoidCallback? onDeleted;

  /// Nhãn đọc cho nút ✕ (ví dụ "Bỏ loại Cà tím").
  final String? deleteLabel;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimaryContainer : AppColors.text;
    final bg = selected ? AppColors.primaryContainer : AppColors.surface;
    final border = selected ? AppColors.primary : AppColors.outline;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          side: BorderSide(color: border, width: selected ? 2 : 1),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTouch),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected && onDeleted == null) ...[
                    Icon(Icons.check, size: 18, color: fg),
                    const SizedBox(width: AppSpacing.xs),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onDeleted != null)
                    Semantics(
                      button: true,
                      label: deleteLabel,
                      excludeSemantics: deleteLabel != null,
                      child: Tooltip(
                        message: deleteLabel ?? '',
                        child: InkResponse(
                          onTap: onDeleted,
                          radius: 22,
                          child: const SizedBox.square(
                            dimension: kMinTouch,
                            child: Icon(Icons.close, size: 18),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: AppSpacing.xs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum MacroKind { protein, kcal, carb, fat }

/// Chip macro: protein nổi bật (vàng nghệ), các chất còn lại nhẹ hơn.
class MacroChip extends StatelessWidget {
  const MacroChip({
    required this.kind,
    required this.value,
    required this.label,
    this.large = false,
    super.key,
  });

  final MacroKind kind;

  /// Chuỗi đã định dạng, vd `45 g`, `620 kcal`.
  final String value;

  /// Nhãn, vd `Protein`.
  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final highlight = kind == MacroKind.protein;
    final bg = highlight ? AppColors.accentContainer : AppColors.surfaceVariant;
    final fg = highlight ? AppColors.onAccentContainer : AppColors.text;
    final valueStyle = TextStyle(
      color: fg,
      fontWeight: FontWeight.w800,
      fontSize: large ? 18 : 14,
    );
    final labelStyle = TextStyle(
      color: highlight ? AppColors.onAccentContainer : AppColors.textMuted,
      fontSize: large ? 13 : 12,
    );
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: highlight
              ? Border.all(color: AppColors.accent, width: 1.5)
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: large ? AppSpacing.md : AppSpacing.sm + 2,
            vertical: large ? AppSpacing.sm : AppSpacing.xs + 1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: valueStyle),
              Text(label, style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}
