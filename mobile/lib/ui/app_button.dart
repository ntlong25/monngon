import 'package:flutter/material.dart';

import 'tokens.dart';

enum AppButtonKind { primary, secondary, text }

/// Nút bấm: cao ≥ 48, có trạng thái đang xử lý.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final child = loading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );
    const size = Size(kMinTouch, 48);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    );
    final cb = enabled ? onPressed : null;
    final button = switch (kind) {
      AppButtonKind.primary => FilledButton(
        onPressed: cb,
        style: FilledButton.styleFrom(
          minimumSize: size,
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: child,
      ),
      AppButtonKind.secondary => OutlinedButton(
        onPressed: cb,
        style: OutlinedButton.styleFrom(
          minimumSize: size,
          shape: shape,
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: enabled ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: child,
      ),
      AppButtonKind.text => TextButton(
        onPressed: cb,
        style: TextButton.styleFrom(
          minimumSize: size,
          shape: shape,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: child,
      ),
    };
    final wrapped = Semantics(
      button: true,
      enabled: enabled,
      label: loading ? label : null,
      excludeSemantics: false,
      child: button,
    );
    return expand ? SizedBox(width: double.infinity, child: wrapped) : wrapped;
  }
}
