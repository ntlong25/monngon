import 'package:flutter/material.dart';

import '../../api/generated/api_client.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../ui/ui.dart';

/// Lỗi gọi API thân thiện: mất mạng / lỗi chung, kèm nút Thử lại.
class ApiErrorView extends StatelessWidget {
  const ApiErrorView({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final network = error is ApiException && (error as ApiException).isNetwork;
    return AppBanner(
      kind: BannerKind.error,
      title: l.errorsGenericTitle,
      message: network ? l.errorsNetworkBody : l.errorsGenericBody,
      actionLabel: l.commonRetry,
      onAction: onRetry,
    );
  }
}

/// Toàn màn hình: dùng khi cả màn phụ thuộc vào dữ liệu từ API.
class ApiErrorScreen extends StatelessWidget {
  const ApiErrorScreen({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ApiErrorView(error: error, onRetry: onRetry),
    ),
  );
}
