import 'package:flutter/material.dart';

import 'app_button.dart';
import 'tokens.dart';

/// Chân màn hình có nút chính cố định (Tiếp tục, Tạo thực đơn…), kèm dòng phụ (vd "mỗi bữa ~620 kcal").
class BottomCTA extends StatelessWidget {
  const BottomCTA({
    required this.label,
    required this.onPressed,
    this.caption,
    this.loading = false,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  /// Dòng thông tin phía trên nút.
  final String? caption;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    elevation: 0,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    caption!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              AppButton(
                label: label,
                onPressed: onPressed,
                loading: loading,
                expand: true,
              ),
              if (secondaryLabel != null)
                AppButton(
                  label: secondaryLabel!,
                  onPressed: onSecondary,
                  kind: AppButtonKind.text,
                  expand: true,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
