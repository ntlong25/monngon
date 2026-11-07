import 'package:flutter/material.dart';

/// Báo cho các bước onboarding biết đang ở chế độ **sửa** (từ tab Bạn): không có thanh tiến độ,
/// nút Quay lại đóng màn, nút chính là "Lưu".
class OnboardingEditScope extends InheritedWidget {
  const OnboardingEditScope({required super.child, super.key});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnboardingEditScope>() != null;

  @override
  bool updateShouldNotify(OnboardingEditScope oldWidget) => false;
}
