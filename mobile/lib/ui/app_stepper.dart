import 'package:flutter/material.dart';

import 'tokens.dart';

/// Bộ tăng giảm số nguyên (người lớn, trẻ em…). Hai nút 48×48.
class AppStepper extends StatelessWidget {
  const AppStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
    required this.decrementLabel,
    required this.incrementLabel,
    super.key,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  /// Nhãn đọc cho trình đọc màn hình (vd "Người lớn").
  final String label;

  /// Nhãn nút −/+ cho trình đọc màn hình (vd "Giảm", "Tăng"); lấy từ i18n.
  final String decrementLabel;
  final String incrementLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: label,
      value: '$value',
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            icon: Icons.remove,
            tooltip: '$decrementLabel $label',
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
          _RoundButton(
            icon: Icons.add,
            tooltip: '$incrementLabel $label',
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
    onPressed: onPressed,
    tooltip: tooltip,
    icon: Icon(icon),
    style: IconButton.styleFrom(
      minimumSize: const Size.square(48),
      fixedSize: const Size.square(48),
      foregroundColor: AppColors.primary,
      side: BorderSide(
        color: onPressed == null ? AppColors.divider : AppColors.primary,
        width: 1.5,
      ),
    ),
  );
}
