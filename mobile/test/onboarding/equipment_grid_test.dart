import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/features/onboarding/onboarding_nav.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

/// T-108 / D-ONB-09: bước Dụng cụ bếp là lưới thẻ có hình, 2 cột (3 cột khi ≥ 600 dp).
const _ids = [
  'bep',
  'noi_com_dien',
  'lo_vi_song',
  'noi_chien_khong_dau',
  'lo_nuong',
  'noi_ap_suat',
  'may_xay',
];

FakeAdapter _api() => FakeAdapter()
  ..on('POST', '/v1/targets', fixture('targets.json'))
  ..on('GET', '/v1/reference', fixture('reference.json'));

Future<ProviderContainer> _pump(
  WidgetTester t, {
  Size size = const Size(412, 1600),
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
        store: onboardingAtStep(OnboardingStep.equipment),
        adapter: _api(),
      ),
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

Finder _tile(String id) => find.byKey(Key('equip-$id'));

Finder _check(String id) => find.descendant(
  of: _tile(id),
  matching: find.byKey(const Key('equip-check')),
);

/// Số cột = số thẻ có cùng toạ độ y với thẻ đầu.
int _columns(WidgetTester t) {
  final y = t.getTopLeft(_tile('bep')).dy;
  return _ids.where((id) => (t.getTopLeft(_tile(id)).dy - y).abs() < 1).length;
}

String _nameOf(String id) => switch (id) {
  'bep' => 'Bếp',
  'noi_com_dien' => 'Nồi cơm điện',
  'lo_vi_song' => 'Lò vi sóng',
  'noi_chien_khong_dau' => 'Nồi chiên không dầu',
  'lo_nuong' => 'Lò nướng',
  'noi_ap_suat' => 'Nồi áp suất',
  _ => 'Máy xay',
};

void main() {
  group('Lưới (AC1)', () {
    for (final (w, cols) in [
      (360.0, 2),
      (412.0, 2),
      (599.0, 2),
      (600.0, 3),
      (800.0, 3),
    ]) {
      testWidgets('màn $w dp → $cols cột, đủ 7 thẻ có hình + tên', (t) async {
        await _pump(t, size: Size(w, 1600));
        expect(_columns(t), cols);
        for (final id in _ids) {
          expect(_tile(id), findsOneWidget, reason: id);
          expect(
            find.descendant(of: _tile(id), matching: find.text(_nameOf(id))),
            findsOneWidget,
            reason: id,
          );
        }
        expect(find.byKey(const Key('equipment-grid')), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('mỗi thẻ có hình minh họa theo mã dụng cụ (PNG trong gói)', (
      t,
    ) async {
      await _pump(t);
      for (final id in _ids) {
        final file = 'dungcu-${id.replaceAll('_', '-')}';
        expect(
          find.byKey(Key('illustration-$file')),
          findsOneWidget,
          reason: file,
        );
        expect(
          find.byKey(Key('illustration-fallback-$file')),
          findsNothing,
          reason: file,
        );
      }
    });
  });

  testWidgets('hình và tên căn giữa trong thẻ (lệch ≤ 1 dp)', (t) async {
    await _pump(t, size: const Size(360, 1600));
    for (final id in _ids) {
      final tileX = t.getCenter(_tile(id)).dx;
      final img = find.descendant(
        of: _tile(id),
        matching: find.byWidgetPredicate((w) => w is Illustration),
      );
      final name = find.descendant(
        of: _tile(id),
        matching: find.text(_nameOf(id)),
      );
      expect(
        (t.getCenter(img).dx - tileX).abs(),
        lessThanOrEqualTo(1),
        reason: id,
      );
      expect(
        (t.getCenter(name).dx - tileX).abs(),
        lessThanOrEqualTo(1),
        reason: id,
      );
    }
  });

  group('Trạng thái chọn (AC2, AC4)', () {
    testWidgets(
      'chọn nhiều; thẻ đã chọn có dấu ✓ và viền dày, không chỉ đổi màu',
      (t) async {
        final c = await _pump(t);
        final selectedAtStart = c.read(preferencesProvider).equipment.toSet();
        for (final id in _ids) {
          expect(
            _check(id),
            selectedAtStart.contains(id) ? findsOneWidget : findsNothing,
            reason: id,
          );
        }
        final unselected = _ids.firstWhere(
          (id) => !selectedAtStart.contains(id),
        );
        Material material(String id) => t.widget<Material>(
          find.descendant(of: _tile(id), matching: find.byType(Material)).first,
        );
        final before =
            (material(unselected).shape! as RoundedRectangleBorder).side.width;
        await t.tap(_tile(unselected));
        await t.pump();
        expect(c.read(preferencesProvider).equipment, contains(unselected));
        expect(_check(unselected), findsOneWidget);
        final after =
            (material(unselected).shape! as RoundedRectangleBorder).side.width;
        expect(after, greaterThan(before));
        expect(material(unselected).color, AppColors.primaryContainer);
        for (final id in selectedAtStart) {
          expect(c.read(preferencesProvider).equipment, contains(id));
        }
        await t.tap(_tile(unselected));
        await t.pump();
        expect(_check(unselected), findsNothing);
        expect(
          c.read(preferencesProvider).equipment,
          isNot(contains(unselected)),
        );
      },
    );

    testWidgets(
      'bắt buộc ≥ 1 thiết bị nấu: chỉ còn máy xay → cảnh báo + khóa Tiếp tục',
      (t) async {
        final c = await _pump(t);
        for (final id in _ids) {
          if (id != 'may_xay' &&
              c.read(preferencesProvider).equipment.contains(id)) {
            await t.tap(_tile(id));
            await t.pump();
          }
        }
        if (!c.read(preferencesProvider).equipment.contains('may_xay')) {
          await t.tap(_tile('may_xay'));
          await t.pump();
        }
        expect(c.read(preferencesProvider).equipment, ['may_xay']);
        expect(find.byKey(const Key('equipment-need-one')), findsOneWidget);
        final cta = t.widget<FilledButton>(
          find.ancestor(
            of: find.text('Tiếp tục'),
            matching: find.byType(FilledButton),
          ),
        );
        expect(cta.onPressed, isNull);
        await t.tap(_tile('bep'));
        await t.pump();
        expect(find.byKey(const Key('equipment-need-one')), findsNothing);
        expect(
          c.read(preferencesProvider).equipment,
          containsAll(['may_xay', 'bep']),
        );
      },
    );
  });

  group('Trợ năng (AC3)', () {
    testWidgets('vùng chạm mỗi thẻ ≥ 48 dp', (t) async {
      await _pump(t, size: const Size(360, 1600));
      for (final id in _ids) {
        final s = t.getSize(_tile(id));
        expect(s.width, greaterThanOrEqualTo(48), reason: id);
        expect(s.height, greaterThanOrEqualTo(48), reason: id);
      }
    });

    testWidgets('Semantics: ô chọn có tên và trạng thái đã chọn / chưa chọn', (
      t,
    ) async {
      final handle = t.ensureSemantics();
      final c = await _pump(t);
      final selected = c.read(preferencesProvider).equipment.toSet();
      final onId = _ids.firstWhere(selected.contains);
      final offId = _ids.firstWhere((id) => !selected.contains(id));
      expect(
        t.getSemantics(_tile(onId)),
        matchesSemantics(
          hasCheckedState: true,
          isChecked: true,
          hasTapAction: true,
          label: _nameOf(onId),
        ),
      );
      expect(
        t.getSemantics(_tile(offId)),
        matchesSemantics(
          hasCheckedState: true,
          isChecked: false,
          hasTapAction: true,
          label: _nameOf(offId),
        ),
      );
      handle.dispose();
    });

    testWidgets('cỡ chữ 1.3× ở màn 360 dp không vỡ bố cục', (t) async {
      await _pump(t, size: const Size(360, 2400), textScale: 1.3);
      expect(t.takeException(), isNull);
      expect(_columns(t), 2);
    });
  });

  group('Thiếu hình (AC5)', () {
    testWidgets('file hình không có → biểu tượng dự phòng, không lỗi', (
      t,
    ) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Illustration(
              name: 'khong-co-file-nay',
              fallback: Icons.kitchen,
              size: 72,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(
        find.byKey(const Key('illustration-fallback-khong-co-file-nay')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.kitchen), findsOneWidget);
    });
  });
}
