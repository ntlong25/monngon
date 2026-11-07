import 'package:flutter/material.dart';

import 'tokens.dart';

enum BannerKind { info, success, warning, error }

/// Dải thông báo: luôn có biểu tượng + chữ (không chỉ màu). Dùng cho `partial`, mất mạng, ngân sách thấp…
class AppBanner extends StatelessWidget {
  const AppBanner({
    required this.message,
    this.kind = BannerKind.info,
    this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final String? title;
  final BannerKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, iconColor, icon) = switch (kind) {
      BannerKind.info => (
        AppColors.infoContainer,
        AppColors.onInfoContainer,
        AppColors.infoIcon,
        Icons.info_outline,
      ),
      BannerKind.success => (
        AppColors.successContainer,
        AppColors.onSuccessContainer,
        AppColors.primary,
        Icons.check_circle_outline,
      ),
      BannerKind.warning => (
        AppColors.warningContainer,
        AppColors.onWarningContainer,
        AppColors.warningIcon,
        Icons.warning_amber_rounded,
      ),
      BannerKind.error => (
        AppColors.errorContainer,
        AppColors.onErrorContainer,
        AppColors.error,
        Icons.error_outline,
      ),
    };
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.textTheme.titleMedium?.copyWith(color: fg),
                      ),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                    ),
                    if (actionLabel != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: onAction,
                          style: TextButton.styleFrom(
                            foregroundColor: fg,
                            minimumSize: const Size(kMinTouch, kMinTouch),
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          child: Text(actionLabel!),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
