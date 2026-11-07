import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';

/// Các bước của wizard theo thứ tự. Bước hiện tại được lưu để mở lại đúng chỗ.
enum OnboardingStep {
  goal,
  body,
  activity,
  targets,
  store,

  /// Người ăn đứng TRƯỚC ngân sách vì min/max ngân sách phụ thuộc số người (US-1.2 AC2).
  household,
  budget,
  meals,
  diet,

  /// Thói quen ăn cơm (US-1.4b): sau kiểu ăn; bỏ qua khi bật "Ít tinh bột".
  rice,
  dislike,
  swipe,
  equipment,
  summary,
}

/// Chuyển bước (lưu lại ngay).
class OnboardingNav {
  const OnboardingNav(this._ref);

  final WidgetRef _ref;

  static const last = 13;

  /// Khi đã hoàn tất onboarding (đang sửa từ tab Bạn) các bước không tự chuyển bước.
  bool get _editing => _ref.read(onboardingProvider).completed;

  void next() {
    if (_editing) return;
    final s = _ref.read(onboardingProvider).step;
    if (s < last) {
      _ref.read(onboardingProvider.notifier).goTo(_skipRice(s + 1, 1));
    }
  }

  void back() {
    if (_editing) return;
    final s = _ref.read(onboardingProvider).step;
    if (s > 0) {
      _ref.read(onboardingProvider.notifier).goTo(_skipRice(s - 1, -1));
    }
  }

  /// "Ít tinh bột" → mâm không có cơm nên bước thói quen ăn cơm bị bỏ qua (cả khi tiến lẫn lùi).
  int _skipRice(int target, int dir) =>
      target == OnboardingStep.rice.index &&
          _ref.read(preferencesProvider).lowCarb
      ? target + dir
      : target;

  void goTo(OnboardingStep step) =>
      _ref.read(onboardingProvider.notifier).goTo(step.index);
}
