import 'package:flutter/material.dart';

import 'tokens.dart';

/// Hình minh họa tự vẽ (mục tiêu, dụng cụ bếp) từ `assets/illustrations/<tên>.png` (đủ 1x/2x/3x, sinh bằng
/// `tools/svg_to_png.py` từ SVG của Research). Thiếu file hoặc lỗi giải mã thì vẽ [fallback] (biểu tượng), không lỗi.
/// Hình chỉ để trang trí: tên của mục đã có ở chữ bên cạnh nên không đọc lại cho trình đọc màn hình.
class Illustration extends StatelessWidget {
  const Illustration({
    required this.name,
    required this.fallback,
    this.size = 96,
    super.key,
  });

  /// Tên file không có đuôi, vd `goal-giam-mo`, `dungcu-bep`.
  final String name;

  /// Biểu tượng dự phòng khi chưa có hình.
  final IconData fallback;

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: Image.asset(
        'assets/illustrations/$name.png',
        key: Key('illustration-$name'),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, _, _) => Container(
          key: Key('illustration-fallback-$name'),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          alignment: Alignment.center,
          child: Icon(fallback, size: size * 0.5, color: AppColors.primary),
        ),
      ),
    ),
  );
}
