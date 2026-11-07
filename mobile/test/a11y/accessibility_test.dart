import 'dart:convert';
import 'dart:io';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/wakelock.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:fitpro_mamdu/state/week_changes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

/// T-092 — trợ năng: chữ lớn (text scale 1.3) không vỡ bố cục, vùng chạm ≥ 48 dp, mọi nút có nhãn, độ tương phản.
class _NoWake implements WakelockController {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

FakeAdapter _api() => FakeAdapter()
  ..on('POST', '/v1/targets', fixture('targets.json'))
  ..on('POST', '/v1/budget-range', fixture('budget_range.json'))
  ..on('POST', '/v1/slots/preview', fixture('slots_preview.json'))
  ..on('POST', '/v1/plans', fixture('plan_response.json'))
  ..on('GET', '/v1/reference', fixture('reference.json'))
  ..on('GET', '/health', {'status': 'ok'})
  ..on(
    'GET',
    '/v1/ingredients',
    jsonDecode(
      File('test/fixtures/ingredients_search.json').readAsStringSync(),
    ),
  )
  ..on('POST', '/v1/plans/swap-suggestions', {
    'date': '2026-11-09',
    'slot': 'lunch',
    'current_recipe_id': 'x',
    'any_keeps_day': true,
    'items': [
      for (final (id, name) in [
        (
          'khoai_tay_luoc_muoi',
          'Khoai tây luộc muối tiêu ăn kèm cơm gạo lứt nguội mang đi',
        ),
        ('canh_trung_cai_thao', 'Canh trứng cải thảo'),
      ])
        {
          'recipe_id': id,
          'name': name,
          'dishes': [
            {'role': 'main', 'recipe_id': id, 'name': name},
          ],
          'macros': {
            'kcal': 520.0,
            'protein_g': 31.0,
            'carb_g': 40.0,
            'fat_g': 18.0,
            'fiber_g': 6.0,
          },
          'delta_protein_g': -2.5,
          'delta_kcal': 30.0,
          'delta_cost_vnd': 4000.0,
          'keeps_day_ok': true,
          'day_protein_g': 118.0,
          'day_kcal': 2010.0,
        },
    ],
    'recipes': <String, dynamic>{},
  });

MemoryStore _doneStore() {
  final s = completedStore();
  s.data[StoreKeys.currentPlan] = jsonEncode(fixture('plan_response.json'));
  s.data[StoreKeys.preferences] = jsonEncode(Defaults.preferences.toJson());
  return s;
}

Future<void> _pump(
  WidgetTester t,
  MemoryStore store, {
  double scale = 1.3,
}) async {
  // Điện thoại 360 × 780 dp.
  t.view.devicePixelRatio = 3;
  t.view.physicalSize = const Size(1080, 2340);
  t.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() {
    t.view.reset();
    t.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(store: store, adapter: _api()),
        wakelockProvider.overrideWithValue(_NoWake()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 10)),
      ],
      child: const FitProApp(),
    ),
  );
  await _settle(t);
}

Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 400));
  }
  await t.pumpAndSettle();
}

Future<void> _tap(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      f,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await _settle(t);
}

/// Không tràn bố cục (flutter_test báo `RenderFlex overflowed` thành lỗi) + 3 guideline trợ năng.
Future<void> _a11y(WidgetTester t, {bool contrast = true}) async {
  expect(t.takeException(), isNull);
  await expectLater(t, meetsGuideline(androidTapTargetGuideline));
  await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
  if (contrast) {
    await expectLater(t, meetsGuideline(textContrastGuideline));
  }
}

void main() {
  late SemanticsHandle handle;
  setUp(
    () => handle = TestWidgetsFlutterBinding.ensureInitialized()
        .ensureSemantics(),
  );
  tearDown(() => handle.dispose());

  group('Onboarding ở chữ 1.3×', () {
    for (var step = 0; step <= 13; step++) {
      testWidgets('bước ${step + 1}/14', (t) async {
        await _pump(t, onboardingAt(step));
        await _a11y(t);
      });
    }
  });

  group('Tab chính ở chữ 1.3×', () {
    testWidgets('Kế hoạch', (t) async {
      await _pump(t, _doneStore());
      await _a11y(t);
    });

    testWidgets('Kế hoạch cuộn tới cuối (nút Lên lại)', (t) async {
      await _pump(t, _doneStore());
      await t.scrollUntilVisible(
        find.byKey(const Key('replan-rest')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await _a11y(t);
    });

    testWidgets('Đi chợ', (t) async {
      await _pump(t, _doneStore());
      await _tap(t, find.text('Đi chợ'));
      await _a11y(t);
    });

    testWidgets('Bạn', (t) async {
      await _pump(t, _doneStore());
      await _tap(t, find.text('Bạn'));
      await _a11y(t);
      await t.scrollUntilVisible(
        find.byKey(const Key('clear-data')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await _a11y(t);
    });
  });

  group('Màn mới T-094…T-097 ở chữ 1.3×', () {
    testWidgets('thẻ cơm bị bớt trên màn mâm (ghi chú rice_reduced)', (
      t,
    ) async {
      final plan = fixture('plan_response.json');
      final day = ((plan['plan'] as Map)['days'] as List).first as Map;
      final lunch =
          (day['meals'] as List).firstWhere(
                (Object? m) => (m as Map)['slot'] == 'lunch',
              )
              as Map;
      lunch['rice'] = {'habit': 'rat_nhieu', 'target_g': 450, 'actual_g': 225};
      lunch['notes'] = [
        {
          'code': 'rice_reduced',
          'target_g': 450,
          'actual_g': 225,
          'reason': 'kcal',
        },
      ];
      final store = _doneStore()
        ..data[StoreKeys.currentPlan] = jsonEncode(plan);
      await _pump(t, store);
      await _tap(t, find.byKey(const Key('meal-2026-11-09-lunch')));
      await t.scrollUntilVisible(
        find.byKey(const Key('rice-card')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('rice-reduced-note')), findsOneWidget);
      await _a11y(t);
    });

    testWidgets(
      'tổng kết: cảnh báo mức tối thiểu cao hơn kèm lý do và nút "Dùng …"',
      (t) async {
        final api = _api()
          ..onRequest('POST', '/v1/budget-range', (o) {
            final body = Map<String, dynamic>.from(
              fixture('budget_range.json'),
            );
            if ((o.data as Map).containsKey('preferences')) {
              body['min_vnd'] = 700000;
            }
            return body;
          });
        t.view.devicePixelRatio = 3;
        t.view.physicalSize = const Size(1080, 2340);
        t.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(() {
          t.view.reset();
          t.platformDispatcher.clearTextScaleFactorTestValue();
        });
        final store = onboardingAt(13)
          ..data[StoreKeys.preferences] = jsonEncode(
            Defaults.preferences.copyWith(weeklyBudgetVnd: 650000).toJson(),
          );
        await t.pumpWidget(
          ProviderScope(
            overrides: testOverrides(store: store, adapter: api),
            child: const FitProApp(),
          ),
        );
        await _settle(t);
        expect(find.byKey(const Key('summary-budget-low')), findsOneWidget);
        expect(find.text('Dùng 700.000 ₫'), findsOneWidget);
        await _a11y(t);
      },
    );

    testWidgets(
      'tab Bạn offline chưa có chỉ tiêu đã lưu: thông báo mạng + Thử lại',
      (t) async {
        final api = _api()..failWithConnectionError = true;
        t.view.devicePixelRatio = 3;
        t.view.physicalSize = const Size(1080, 2340);
        t.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(() {
          t.view.reset();
          t.platformDispatcher.clearTextScaleFactorTestValue();
        });
        await t.pumpWidget(
          ProviderScope(
            overrides: [
              ...testOverrides(store: _doneStore(), adapter: api),
              wakelockProvider.overrideWithValue(_NoWake()),
              clockProvider.overrideWithValue(() => DateTime(2026, 11, 10)),
            ],
            child: const FitProApp(),
          ),
        );
        await _settle(t);
        await _tap(t, find.text('Bạn'));
        expect(find.byKey(const Key('profile-targets-error')), findsOneWidget);
        await _a11y(t);
      },
    );
  });

  group('Màn con ở chữ 1.3×', () {
    testWidgets('bữa ghép mâm + công thức món + "Cách chúng mình tính"', (
      t,
    ) async {
      await _pump(t, _doneStore());
      await _tap(t, find.byKey(const Key('meal-2026-11-09-lunch')));
      await _a11y(t);
      await _tap(t, find.byKey(const Key('calc-link')));
      await _a11y(t);
      await t.tap(find.byType(BackButton));
      await _settle(t);
      await t.scrollUntilVisible(
        find.byKey(const Key('not-for-me')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await _a11y(t);
    });

    testWidgets('bữa một món (nguyên liệu + cách làm)', (t) async {
      await _pump(t, _doneStore());
      await _tap(t, find.byKey(const Key('meal-2026-11-09-breakfast')));
      await _a11y(t);
      await t.scrollUntilVisible(
        find.byKey(const Key('not-for-me')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await _a11y(t);
    });

    testWidgets('sheet đổi món và sheet ăn ngoài', (t) async {
      await _pump(t, _doneStore());
      await _tap(t, find.byKey(const Key('meal-2026-11-09-lunch')));
      await _tap(t, find.byKey(const Key('change-meal')));
      await _a11y(t);
      await t.tapAt(const Offset(180, 20)); // đóng sheet
      await _settle(t);
      await _tap(t, find.byKey(const Key('eat-out')));
      await _a11y(t);
    });

    for (final doc in ['disclaimer', 'sources', 'prices', 'privacy']) {
      testWidgets('văn bản $doc', (t) async {
        await _pump(t, _doneStore());
        await _tap(t, find.text('Bạn'));
        await _tap(t, find.byKey(Key('open-info-$doc')));
        await _a11y(t);
      });
    }

    testWidgets('sửa lựa chọn (mục tiêu, bữa ăn) và món đã chặn', (t) async {
      await _pump(t, _doneStore());
      await _tap(t, find.text('Bạn'));
      await _tap(t, find.byKey(const Key('edit-meals')));
      await _a11y(t);
      await t.tap(find.byKey(const Key('edit-back')));
      await _settle(t);
      await _tap(t, find.byKey(const Key('open-blocked')));
      await _a11y(t);
    });

    testWidgets('hộp thoại xác nhận xóa dữ liệu', (t) async {
      await _pump(t, _doneStore());
      await _tap(t, find.text('Bạn'));
      await _tap(t, find.byKey(const Key('clear-data')));
      await _a11y(t, contrast: false);
    });
  });
}
