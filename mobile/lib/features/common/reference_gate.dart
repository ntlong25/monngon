import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'api_error_view.dart';

/// Chờ danh mục tham chiếu (cửa hàng, dụng cụ, kiêng…) rồi dựng [builder]. Có cache offline; lỗi → hiện Thử lại.
class ReferenceGate extends ConsumerWidget {
  const ReferenceGate({required this.builder, super.key});

  final List<Widget> Function(BuildContext context, ReferenceResponse ref)
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(referenceProvider);
    return async.when(
      data: (r) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: builder(context, r),
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => ApiErrorView(
        error: e,
        onRetry: () => ref.invalidate(referenceProvider),
      ),
    );
  }
}
