import 'dart:math' as math;

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/features/onboarding/onboarding_nav.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

/// T-106 / D-ONB-07: thẻ vuốt căn giữa + cử chỉ quẹt (tự viết, không thêm package).
FakeAdapter _api() => FakeAdapter()
  ..on('POST', '/v1/targets', fixture('targets.json'))
  ..on('GET', '/v1/reference', fixture('reference.json'));

Future<ProviderContainer> _pump(
  WidgetTester t, {
  Size size = const Size(412, 915),
  double textScale = 1,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = size;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearAllTestValues);
  await t.pumpWidget(
    ProviderScope(
      overrides: testOverrides(
        store: onboardingAtStep(OnboardingStep.swipe),
        adapter: _api(),
      ),
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

final _top = find.byKey(const Key('swipe-card-card_01'));
Finder _next(String id) => find.byKey(Key('swipe-card-$id'));

double _topWidth(WidgetTester t) => t.getSize(_top).width;

void main() {
  group('Căn giữa, rộng theo màn hình (AC1)', () {
    for (final w in [360.0, 412.0, 600.0]) {
      testWidgets('màn $w dp: |lề trái − lề phải| ≤ 1 dp, rộng ≤ 400 dp', (t) async {
        await _pump(t, size: Size(w, 915));
        final left = t.getTopLeft(_top).dx;
        final right = w - t.getTopRight(_top).dx;
        expect((left - right).abs(), lessThanOrEqualTo(1), reason: 'trái $left phải $right');
        expect(t.getSize(_top).width, math.min(w - 32, 400));
      });
    }
  });

  group('Hình thẻ và xếp chồng (AC2, AC3)', () {
    testWidgets('bo góc 20 dp, có bóng; chữ lớn 1.3× không tràn', (t) async {
      await _pump(t, size: const Size(360, 915), textScale: 1.3);
      expect(t.takeException(), isNull);
      final material = t.widget<Material>(
        find.descendant(of: _top, matching: find.byType(Material)).first,
      );
      expect(material.elevation, greaterThan(0));
      expect(material.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('sau thẻ đang xem thấy 2 thẻ kế tiếp, scale 0,95 và 0,90, lệch xuống 8/16 dp', (
      t,
    ) async {
      await _pump(t);
      expect(find.byKey(const Key('swipe-back-card_02')), findsOneWidget);
      expect(find.byKey(const Key('swipe-back-card_03')), findsOneWidget);
      expect(find.byKey(const Key('swipe-back-card_04')), findsNothing);
      List<Transform> tf(String id) => t
          .widgetList<Transform>(
            find.descendant(
              of: find.byKey(Key('swipe-back-$id')),
              matching: find.byType(Transform),
            ),
          )
          .toList();
      double scaleOf(String id) =>
          tf(id).map((x) => x.transform.storage[0]).reduce(math.min);
      double dyOf(String id) =>
          tf(id).map((x) => x.transform.getTranslation().y).reduce(math.max);
      expect(scaleOf('card_02'), closeTo(0.95, 1e-6));
      expect(scaleOf('card_03'), closeTo(0.90, 1e-6));
      expect(dyOf('card_02'), closeTo(8, 1e-6));
      expect(dyOf('card_03'), closeTo(16, 1e-6));
    });

    testWidgets('thẻ sau "tiến lên" khi kéo thẻ trước', (t) async {
      await _pump(t);
      final g = await t.startGesture(t.getCenter(_top));
      await g.moveBy(Offset(0.2 * _topWidth(t), 0));
      await t.pump();
      final scale = t
          .widgetList<Transform>(
            find.descendant(
              of: find.byKey(const Key('swipe-back-card_02')),
              matching: find.byType(Transform),
            ),
          )
          .map((x) => x.transform.storage[0])
          .reduce(math.min);
      expect(scale, greaterThan(0.95));
      expect(scale, lessThan(1.0));
      await g.up();
      await t.pumpAndSettle();
    });
  });

  group('Kéo, xoay, nhãn (AC4, AC5)', () {
    testWidgets('thẻ đi theo ngón tay cả hai trục và xoay theo độ kéo ngang, tối đa ±12°', (
      t,
    ) async {
      await _pump(t);
      final start = t.getCenter(_top);
      final g = await t.startGesture(start);
      await g.moveBy(const Offset(60, 40));
      await t.pump();
      final moved = t.getCenter(_top) - start;
      expect(moved.dx, closeTo(60, 1));
      expect(moved.dy, closeTo(40, 1));
      double angle() => t
          .widgetList<Transform>(
            find.ancestor(of: _top, matching: find.byType(Transform)),
          )
          .map((x) => math.atan2(x.transform.storage[1], x.transform.storage[0]))
          .reduce((a, b) => a.abs() > b.abs() ? a : b);
      expect(angle(), greaterThan(0));
      expect(angle() * 180 / math.pi, lessThanOrEqualTo(12 + 1e-6));
      await g.moveBy(const Offset(2000, 0));
      await t.pump();
      expect(angle() * 180 / math.pi, closeTo(12, 1e-6));
      await g.moveBy(const Offset(-6000, 0));
      await t.pump();
      expect(angle() * 180 / math.pi, closeTo(-12, 1e-6));
      await g.up();
      await t.pumpAndSettle();
    });

    testWidgets('nhãn "Thích" / "Ít hơn" hiện dần, đầy đủ khi tới ngưỡng, có chữ', (
      t,
    ) async {
      await _pump(t);
      double op(String key) =>
          t.widget<Opacity>(find.descendant(of: find.byKey(Key(key)), matching: find.byType(Opacity))).opacity;
      expect(op('swipe-label-like'), 0);
      expect(op('swipe-label-less'), 0);
      final w = _topWidth(t);
      final g = await t.startGesture(t.getCenter(_top));
      await g.moveBy(Offset(0.15 * w, 0));
      await t.pump();
      final part = op('swipe-label-like');
      expect(part, inExclusiveRange(0, 1));
      expect(op('swipe-label-less'), 0);
      await g.moveBy(Offset(0.25 * w, 0));
      await t.pump();
      expect(op('swipe-label-like'), 1);
      expect(find.descendant(of: find.byKey(const Key('swipe-label-like')), matching: find.text('Thích')), findsOneWidget);
      // kéo sang trái → nhãn "Ít hơn"
      await g.moveBy(Offset(-0.9 * w, 0));
      await t.pump();
      expect(op('swipe-label-like'), 0);
      expect(op('swipe-label-less'), greaterThan(0));
      expect(find.descendant(of: find.byKey(const Key('swipe-label-less')), matching: find.text('Ít hơn')), findsOneWidget);
      await g.up();
      await t.pumpAndSettle();
    });
  });

  group('Ngưỡng và hoạt ảnh (AC6)', () {
    testWidgets('kéo 30% chiều rộng → bật về giữa trong 300 ms, không ghi trọng số', (t) async {
      final c = await _pump(t);
      final start = t.getCenter(_top);
      final g = await t.startGesture(start);
      await g.moveBy(Offset(0.3 * _topWidth(t), 0));
      await t.pump();
      await g.up();
      await t.pump(); // khung đầu tiên: bắt đầu hoạt ảnh
      await t.pump(const Duration(milliseconds: 150));
      expect((t.getCenter(_top) - start).dx, greaterThan(1)); // đang bật về
      await t.pump(const Duration(milliseconds: 160));
      expect((t.getCenter(_top) - start).distance, lessThan(1));
      expect(c.read(preferencesProvider).cuisineLikes, isEmpty);
      expect(c.read(preferencesProvider).cuisineLess, isEmpty);
      expect(c.read(onboardingProvider).swipedCardIds, isEmpty);
      await t.pumpAndSettle();
    });

    testWidgets('kéo 40% sang phải → bay ra (250–300 ms) rồi ghi "thích"', (t) async {
      final c = await _pump(t);
      final g = await t.startGesture(t.getCenter(_top));
      await g.moveBy(Offset(0.4 * _topWidth(t), 0));
      await t.pump();
      await g.up();
      await t.pump();
      await t.pump(const Duration(milliseconds: 240));
      expect(c.read(preferencesProvider).cuisineLikes, isEmpty, reason: 'còn đang bay');
      await t.pump(const Duration(milliseconds: 60));
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      expect(_next('card_02'), findsOneWidget);
      expect(_top, findsNothing);
      await t.pumpAndSettle();
    });

    testWidgets('kéo 40% sang trái → ghi "ít hơn"', (t) async {
      final c = await _pump(t);
      final g = await t.startGesture(t.getCenter(_top));
      await g.moveBy(Offset(-0.4 * _topWidth(t), 0));
      await t.pump();
      await g.up();
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLess, ['xao']);
      expect(c.read(preferencesProvider).cuisineLikes, isEmpty);
    });

    testWidgets('ném nhanh 20% với vận tốc 800 dp/s → ghi đúng hướng', (t) async {
      final c = await _pump(t);
      final w = _topWidth(t);
      await t.fling(_top, Offset(0.2 * w, 0), 800);
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      await t.fling(_next('card_02'), Offset(-0.2 * w, 0), 800);
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLess, ['kho']);
    });

    testWidgets('kéo 20% chậm (vận tốc thấp) → bật về', (t) async {
      final c = await _pump(t);
      await t.fling(_top, Offset(0.2 * _topWidth(t), 0), 200);
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLikes, isEmpty);
      expect(_top, findsOneWidget);
    });
  });

  group('Nút thay thế và hoàn tác (AC7)', () {
    testWidgets('giữ 4 Key, nút ≥ 48 dp', (t) async {
      await _pump(t);
      for (final k in ['swipe-undo', 'swipe-dislike', 'swipe-replace', 'swipe-like']) {
        final s = t.getSize(find.byKey(Key(k)));
        expect(s.width, greaterThanOrEqualTo(48), reason: k);
        final btn = find.descendant(of: find.byKey(Key(k)), matching: find.byType(IconButton));
        expect(t.getSize(btn).height, greaterThanOrEqualTo(48), reason: k);
      }
    });

    testWidgets('bấm ♥ chạy cùng hoạt ảnh bay ra: chưa ghi ngay, xong thì ghi', (t) async {
      final c = await _pump(t);
      final start = t.getCenter(_top);
      await t.tap(find.byKey(const Key('swipe-like')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(c.read(preferencesProvider).cuisineLikes, isEmpty);
      expect((t.getCenter(_top) - start).dx, greaterThan(20));
      await t.pump(const Duration(milliseconds: 200));
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      await t.pumpAndSettle();
    });

    testWidgets('bấm ✕ bay sang trái, ghi "ít hơn"', (t) async {
      final c = await _pump(t);
      final start = t.getCenter(_top);
      await t.tap(find.byKey(const Key('swipe-dislike')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect((t.getCenter(_top) - start).dx, lessThan(-20));
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLess, ['xao']);
    });

    testWidgets('Hoàn tác: thẻ quay lại từ phía đã bay ra (250 ms), trả trọng số cũ', (t) async {
      final c = await _pump(t);
      await t.tap(find.byKey(const Key('swipe-like')));
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      await t.tap(find.byKey(const Key('swipe-undo')));
      await t.pump();
      // vừa quay lại: còn ở ngoài màn hình bên phải
      expect(t.getTopLeft(_top).dx, greaterThan(412));
      expect(c.read(preferencesProvider).cuisineLikes, isEmpty);
      await t.pump(); // khung đầu tiên: bắt đầu hoạt ảnh
      await t.pump(const Duration(milliseconds: 130));
      expect(t.getTopLeft(_top).dx, lessThan(412));
      await t.pump(const Duration(milliseconds: 140));
      expect(t.getCenter(_top).dx, closeTo(206, 1));
      await t.pumpAndSettle();
    });

    testWidgets('vuốt trái rồi Hoàn tác: quay lại từ bên trái', (t) async {
      await _pump(t);
      await t.tap(find.byKey(const Key('swipe-dislike')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('swipe-undo')));
      await t.pump();
      expect(t.getTopRight(_top).dx, lessThan(0));
      await t.pumpAndSettle();
    });
  });

  group('Trợ năng (AC8)', () {
    testWidgets('thẻ có Semantics: tên nhóm món + hành động "Thích", "Ít hơn"', (t) async {
      final handle = t.ensureSemantics();
      await _pump(t);
      final data = t.getSemantics(_top).getSemanticsData();
      expect(data.label, contains('Xào nhanh'));
      final labels = data.customSemanticsActionIds!
          .map((id) => CustomSemanticsAction.getAction(id)!.label)
          .toSet();
      expect(labels, {'Thích', 'Ít hơn'});
      handle.dispose();
    });

    testWidgets('chạy hành động Thích bằng trình đọc màn hình (không cần vuốt)', (t) async {
      final handle = t.ensureSemantics();
      final c = await _pump(t);
      final node = t.getSemantics(_top);
      final id = node
          .getSemanticsData()
          .customSemanticsActionIds!
          .firstWhere((i) => CustomSemanticsAction.getAction(i)!.label == 'Thích');
      node.owner!.performAction(node.id, SemanticsAction.customAction, id);
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      handle.dispose();
    });

    testWidgets('giảm chuyển động: không xoay, không scale, đổi thẻ ngay', (t) async {
      t.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final c = await _pump(t);
      final g = await t.startGesture(t.getCenter(_top));
      await g.moveBy(const Offset(170, 0)); // ≥ 35% chiều rộng thẻ (400 dp)
      await t.pump();
      final angles = t
          .widgetList<Transform>(find.ancestor(of: _top, matching: find.byType(Transform)))
          .map((x) => x.transform.storage[1].abs());
      expect(angles.every((a) => a < 1e-9), isTrue);
      final scales = t
          .widgetList<Transform>(
            find.descendant(of: find.byKey(const Key('swipe-back-card_02')), matching: find.byType(Transform)),
          )
          .map((x) => x.transform.storage[0]);
      expect(scales.every((s) => (s - 1).abs() < 1e-9), isTrue);
      await g.up();
      await t.pump(); // một khung hình: đổi thẻ ngay, không bay
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      expect(_next('card_02'), findsOneWidget);
      // nút cũng đổi ngay
      await t.tap(find.byKey(const Key('swipe-dislike')));
      await t.pump();
      expect(c.read(preferencesProvider).cuisineLess, ['kho']);
    });
  });

  group('Hết thẻ (AC9)', () {
    testWidgets('hết thẻ → màn kết quả có "Vuốt lại"; "Bỏ qua" và dòng không ảnh hưởng calo giữ nguyên', (t) async {
      await _pump(t);
      expect(find.textContaining('Không ảnh hưởng calo, đạm hay dị ứng'), findsOneWidget);
      expect(find.text('Bỏ qua'), findsOneWidget);
      for (var i = 0; i < 14; i++) {
        await t.tap(find.byKey(const Key('swipe-like')));
        await t.pumpAndSettle();
      }
      expect(find.text('Khẩu vị của bạn'), findsOneWidget);
      expect(find.byKey(const Key('swipe-again')), findsOneWidget);
    });
  });
}
