import 'package:flutter/material.dart';

import 'tokens.dart';

/// Thanh tiến độ chia đoạn của wizard onboarding. [current] bắt đầu từ 1.
class ProgressSegments extends StatelessWidget {
  const ProgressSegments({
    required this.total,
    required this.current,
    required this.semanticLabel,
    super.key,
  });

  final int total;
  final int current;

  /// Nhãn đọc, vd "Bước 3 trên 10".
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    excludeSemantics: true,
    child: Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 6,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
