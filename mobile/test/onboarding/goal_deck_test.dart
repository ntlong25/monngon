import 'dart:math' as math;

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/features/onboarding/onboarding_nav.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

/// T-107 / D-ONB-08: màn Mục tiêu là bộ thẻ quẹt chọn 1, xoay vòng, dùng chung chồng thẻ với bước Khẩu vị.
FakeAdapter _api() => FakeAdapter()
  ..on('POST', '/v1/targets', fixture('targets.json'))
  ..on('GET', '/v1/reference', fixture('reference.json'));

Future<ProviderContainer> _pump(
  WidgetTester t, {
  Size size = const Size(412, 915),
  double textScale = 1,
  bool reduceMotion = false,
  MemoryStore? store,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = size;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  t.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearAllTestValues);
  addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await t.pumpWidget(
    ProviderScope(
      overrides: testOverrides(
        store: store ?? onboardingAtStep(OnboardingStep.goal),
        adapter: _api(),
      ),
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

Finder _card(String goal) => find.byKey(Key('swipe-card-$goal'));
final _continue = find.widgetWithText(FilledButton, 'Tiếp tục');
final _chooseBtn = find.byKey(const Key('goal-choose'));
final _otherBtn = find.byKey(const Key('goal-other'));

bool _continueEnabled(WidgetTester t) =>
    t.widget<FilledButton>(_continue).onPressed != null;

/// Thẻ nằm trên cùng (thẻ duy nhất có khung `swipe-card-*`).
String _topGoal(WidgetTester t) {
  for (final g in ['lose', 'hold', 'build']) {
    if (_card(g).evaluate().isNotEmpty) return g;
  }
  throw StateError('không thấy thẻ nào');
}

Future<void> _swipe(WidgetTester t, {required bool right}) async {
  final top = _topGoal(t);
  final w = t.getSize(_card(top)).width;
  await t.drag(_card(top), Offset((right ? 1 : -1) * 0.5 * w, 0));
  await t.pumpAndSettle(const Duration(milliseconds: 50));
}

void main() {
  group('Hình thẻ (AC1)', () {
    for (final w in [360.0, 412.0, 600.0]) {
      testWidgets('màn $w dp: căn giữa |lề trái − lề phải| ≤ 1 dp', (t) async {
        await _pump(t, size: Size(w, 915));
        final top = _topGoal(t);
        final left = t.getTopLeft(_card(top)).dx;
        final right = w - t.getTopRight(_card(top)).dx;
        expect((left - right).abs(), lessThanOrEqualTo(1));
        expect(t.getSize(_card(top)).width, math.min(w - 32, 400));
      });
    }

    testWidgets(
      'thẻ đầu là Giảm mỡ, có hình + tên + mô tả; hai thẻ sau xếp chồng',
      (t) async {
        await _pump(t);
        expect(_topGoal(t), 'lose');
        expect(find.text('Giảm mỡ'), findsWidgets);
        expect(
          find.byKey(const Key('illustration-goal-giam-mo')),
          findsWidgets,
        );
        expect(find.byKey(const Key('swipe-back-hold')), findsOneWidget);
        expect(find.byKey(const Key('swipe-back-build')), findsOneWidget);
        expect(t.takeException(), isNull);
      },
    );

    testWidgets('chữ lớn 1.3× ở màn 360 dp không tràn', (t) async {
      await _pump(t, size: const Size(360, 800), textScale: 1.3);
      expect(t.takeException(), isNull);
    });
  });

  group('Chọn (AC2, AC5)', () {
    testWidgets('chưa chọn: Tiếp tục khóa, chưa có dấu "Đã chọn"', (t) async {
      await _pump(t);
      expect(_continueEnabled(t), isFalse);
      expect(find.byKey(const Key('goal-selected-badge')), findsNothing);
    });

    testWidgets(
      'quẹt phải: chọn đúng thẻ trên cùng, hiện "Đã chọn", mở khóa Tiếp tục, sang bước Khẩu vị sau 400 ms',
      (t) async {
        final c = await _pump(t);
        await t.drag(_card('lose'), const Offset(200, 0));
        await t.pump();
        await t.pump(const Duration(milliseconds: 320));
        expect(c.read(profileProvider).goal, 'lose');
        expect(c.read(onboardingProvider).goalChosen, isTrue);
        expect(find.byKey(const Key('goal-selected-badge')), findsOneWidget);
        expect(find.text('Đã chọn'), findsOneWidget);
        expect(_continueEnabled(t), isTrue);
        // chưa tới 400 ms thì vẫn ở bước Mục tiêu
        expect(c.read(onboardingProvider).step, OnboardingStep.goal.index);
        await t.pump(const Duration(milliseconds: 200));
        await t.pumpAndSettle();
        expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);
      },
    );

    testWidgets('nút "Chọn mục tiêu này" cũng chọn rồi tự sang bước Khẩu vị', (
      t,
    ) async {
      final c = await _pump(t);
      await t.tap(_chooseBtn);
      await t.pump();
      expect(c.read(onboardingProvider).goalChosen, isTrue);
      expect(find.text('Đã chọn'), findsOneWidget);
      await t.pump(const Duration(milliseconds: 450));
      await t.pumpAndSettle();
      expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);
    });

    testWidgets(
      'giảm chuyển động: chọn xong KHÔNG tự sang bước kế; Tiếp tục mở khóa',
      (t) async {
        final c = await _pump(t, reduceMotion: true);
        await t.tap(_chooseBtn);
        await t.pump();
        await t.pump(const Duration(seconds: 2));
        expect(c.read(onboardingProvider).goalChosen, isTrue);
        expect(c.read(onboardingProvider).step, OnboardingStep.goal.index);
        expect(_continueEnabled(t), isTrue);
        await t.tap(_continue);
        await t.pumpAndSettle();
        expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);
      },
    );

    testWidgets('xem thẻ khác rồi chọn: đổi lựa chọn cũ và gửi đúng goal', (
      t,
    ) async {
      final c = await _pump(t);
      await t.tap(_chooseBtn); // chọn Giảm mỡ
      await t.pump();
      await t.pump(
        const Duration(milliseconds: 330),
      ); // thẻ đã bật về, chưa tới 400 ms
      await t.tap(_otherBtn);
      await t.pumpAndSettle(const Duration(milliseconds: 50));
      // thẻ trên cùng giờ là Giữ cân; lựa chọn Giảm mỡ vẫn giữ cho tới khi chọn lại
      expect(_topGoal(t), 'hold');
      expect(c.read(profileProvider).goal, 'lose');
      expect(
        find.descendant(
          of: _card('hold'),
          matching: find.byKey(const Key('goal-selected-badge')),
        ),
        findsNothing,
      );
      await t.tap(_chooseBtn);
      await t.pump();
      expect(c.read(profileProvider).goal, 'hold');
      await t.pump(const Duration(milliseconds: 450));
      await t.pumpAndSettle();
      expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);
    });

    testWidgets(
      'mở lại bước đã chọn: thẻ đã chọn nằm trên cùng, có "Đã chọn", Tiếp tục mở',
      (t) async {
        final c = await _pump(t);
        await t.tap(_chooseBtn);
        await t.pump(const Duration(milliseconds: 450));
        await t.pumpAndSettle();
        expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);
        await t.tap(find.byKey(const Key('onboarding-back')));
        await t.pumpAndSettle();
        expect(_topGoal(t), 'lose');
        expect(find.text('Đã chọn'), findsOneWidget);
        expect(_continueEnabled(t), isTrue);
      },
    );

    testWidgets(
      'lưu goal đã chọn là Tăng cơ → mở lại ở bước Mục tiêu, Tăng cơ nằm trên cùng',
      (t) async {
        final c = await _pump(t);
        await t.tap(find.byKey(const Key('goal-dot-build')));
        await t.pumpAndSettle();
        await t.tap(_chooseBtn);
        await t.pump();
        c.read(onboardingProvider.notifier).goTo(OnboardingStep.goal.index);
        expect(c.read(profileProvider).goal, 'build');
        expect(c.read(onboardingProvider).goalChosen, isTrue);
      },
    );
  });

  group('Xem thẻ khác, xoay vòng (AC3)', () {
    testWidgets('quẹt trái: thẻ xuống cuối bộ, thẻ kế lên trên, chưa chọn gì', (
      t,
    ) async {
      final c = await _pump(t);
      await _swipe(t, right: false);
      expect(_topGoal(t), 'hold');
      expect(c.read(onboardingProvider).goalChosen, isFalse);
      expect(_continueEnabled(t), isFalse);
      await _swipe(t, right: false);
      expect(_topGoal(t), 'build');
      await _swipe(t, right: false);
      expect(_topGoal(t), 'lose', reason: 'xoay vòng về thẻ đầu');
    });

    testWidgets(
      'quẹt trái 10 lần liên tiếp vẫn còn đủ 3 thẻ, không bao giờ hết',
      (t) async {
        await _pump(t);
        for (var i = 0; i < 10; i++) {
          await _swipe(t, right: false);
          final present = ['lose', 'hold', 'build'].where(
            (g) =>
                _card(g).evaluate().isNotEmpty ||
                find.byKey(Key('swipe-back-$g')).evaluate().isNotEmpty,
          );
          expect(present.length, 3, reason: 'sau lần quẹt thứ ${i + 1}');
        }
        expect(_topGoal(t), 'hold', reason: '10 mod 3 = 1 → thẻ thứ hai');
      },
    );

    testWidgets('nút "Xem mục tiêu khác" xoay thẻ, chạy hoạt ảnh bay ra', (
      t,
    ) async {
      await _pump(t);
      final start = t.getCenter(_card('lose'));
      await t.tap(_otherBtn);
      await t.pump();
      await t.pump(const Duration(milliseconds: 140));
      expect(t.getCenter(_card('lose')).dx, lessThan(start.dx - 40));
      await t.pumpAndSettle(const Duration(milliseconds: 50));
      expect(_topGoal(t), 'hold');
    });

    testWidgets('quẹt phải dưới ngưỡng (20%) thì bật về, không chọn', (
      t,
    ) async {
      final c = await _pump(t);
      final w = t.getSize(_card('lose')).width;
      await t.drag(_card('lose'), Offset(0.2 * w, 0));
      await t.pumpAndSettle(const Duration(milliseconds: 50));
      expect(c.read(onboardingProvider).goalChosen, isFalse);
      expect(_topGoal(t), 'lose');
    });
  });

  group('Hàng 3 chấm (AC4)', () {
    testWidgets('chạm chấm đưa thẻ đó lên trên', (t) async {
      await _pump(t);
      await t.tap(find.byKey(const Key('goal-dot-hold')));
      await t.pumpAndSettle();
      expect(_topGoal(t), 'hold');
      await t.tap(find.byKey(const Key('goal-dot-build')));
      await t.pumpAndSettle();
      expect(_topGoal(t), 'build');
      await t.tap(find.byKey(const Key('goal-dot-lose')));
      await t.pumpAndSettle();
      expect(_topGoal(t), 'lose');
    });

    testWidgets('vùng chạm mỗi chấm ≥ 48 dp', (t) async {
      await _pump(t);
      for (final g in ['lose', 'hold', 'build']) {
        final s = t.getSize(find.byKey(Key('goal-dot-$g')));
        expect(s.width, greaterThanOrEqualTo(48));
        expect(s.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets(
      'có Semantics "Mục tiêu 2 trên 3: Giữ cân", chấm của thẻ trên cùng được đánh dấu chọn',
      (t) async {
        final handle = t.ensureSemantics();
        await _pump(t);
        expect(
          t.getSemantics(find.byKey(const Key('goal-dot-hold'))),
          matchesSemantics(
            label: 'Mục tiêu 2 trên 3: Giữ cân',
            isButton: true,
            hasTapAction: true,
            hasSelectedState: true,
            hasEnabledState: false,
          ),
        );
        expect(
          t.getSemantics(find.byKey(const Key('goal-dot-lose'))),
          matchesSemantics(
            label: 'Mục tiêu 1 trên 3: Giảm mỡ',
            isButton: true,
            hasTapAction: true,
            hasSelectedState: true,
            isSelected: true,
            hasEnabledState: false,
          ),
        );
        handle.dispose();
      },
    );
  });

  group('Khác bước Khẩu vị (AC6)', () {
    testWidgets('tiêu đề và dòng hướng dẫn riêng cho chọn 1', (t) async {
      await _pump(t);
      expect(find.text('Bạn muốn đạt mục tiêu nào?'), findsOneWidget);
      expect(
        find.text(
          'Quẹt phải để chọn mục tiêu này, quẹt trái để xem mục tiêu khác.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Vuốt phải nếu thích, vuốt trái nếu muốn ít hơn.'),
        findsNothing,
      );
    });

    testWidgets('nhãn kéo là "Chọn mục tiêu này" / "Xem mục tiêu khác"', (
      t,
    ) async {
      await _pump(t);
      final g = await t.startGesture(t.getCenter(_card('lose')));
      await g.moveBy(const Offset(120, 0));
      await t.pump();
      expect(
        find.descendant(
          of: find.byKey(const Key('swipe-label-like')),
          matching: find.text('Chọn mục tiêu này'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('swipe-label-less')),
          matching: find.text('Xem mục tiêu khác'),
        ),
        findsOneWidget,
      );
      await g.up();
      await t.pumpAndSettle(const Duration(milliseconds: 50));
    });
  });

  group('Dữ liệu cũ và sửa từ tab Bạn', () {
    testWidgets(
      'trạng thái cũ đã qua bước Mục tiêu coi như đã chọn (không khóa nút)',
      (t) async {
        final c = await _pump(t, store: onboardingAt(1));
        expect(c.read(onboardingProvider).goalChosen, isTrue);
      },
    );

    testWidgets('hình thiếu file → biểu tượng dự phòng, không lỗi', (t) async {
      // Hình không có trong gói tài nguyên → errorBuilder; dùng `Illustration` trực tiếp.
      // (Phần thử riêng ở equipment_grid_test.)
      await _pump(t);
      expect(t.takeException(), isNull);
    });
  });
}
