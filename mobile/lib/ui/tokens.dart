import 'package:flutter/material.dart';

/// Nhận diện riêng của "FitPro - Mâm đủ": xanh lá đậm (mâm cơm, rau) + vàng nghệ (đạm nổi bật) trên nền kem.
/// Không dùng màu hay linh vật của sản phẩm khác.
abstract final class AppColors {
  static const primary = Color(0xFF1B6B4F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD7EFE3);
  static const onPrimaryContainer = Color(0xFF0B3A2A);

  /// Vàng nghệ — dành cho protein (con số quan trọng nhất của app).
  static const accent = Color(0xFFF2A93B);
  static const accentContainer = Color(0xFFFFE9C9);
  static const onAccentContainer = Color(0xFF4F2D00);

  static const background = Color(0xFFFBF8F1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1ECE0);

  static const text = Color(0xFF1E2420);
  static const textMuted = Color(0xFF55605A);

  /// Viền thành phần giao diện (tương phản ≥ 3:1 với nền kem, WCAG 1.4.11).
  static const outline = Color(0xFF7D7869);
  static const divider = Color(0xFFE4DECF);

  static const error = Color(0xFFB3261E);
  static const errorContainer = Color(0xFFFCE4E1);
  static const onErrorContainer = Color(0xFF5E100B);

  static const warningContainer = Color(0xFFFFF0C2);
  static const onWarningContainer = Color(0xFF5C4300);
  static const warningIcon = Color(0xFF8A6100);

  static const successContainer = Color(0xFFD7EFE3);
  static const onSuccessContainer = Color(0xFF0B3A2A);

  static const infoContainer = Color(0xFFE3EEF6);
  static const onInfoContainer = Color(0xFF13344D);
  static const infoIcon = Color(0xFF1F5A86);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

/// Vùng chạm tối thiểu (PRD §7: ≥ 44 pt).
const double kMinTouch = 48;
