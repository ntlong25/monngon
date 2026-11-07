import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/wakelock.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:fitpro_mamdu/state/week_changes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

class _NoWake implements WakelockController {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

MemoryStore _seeded() {
  final s = completedStore();
  s.data[StoreKeys.currentPlan] = jsonEncode(fixture('plan_response.json'));
  s.data[StoreKeys.preferences] = jsonEncode(Defaults.preferences.toJson());
  return s;
}

Future<ProviderContainer> _pump(
  WidgetTester t,
  FakeAdapter adapter, {
  String today = '2026-11-10',
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 9000);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(store: _seeded(), adapter: adapter),
        wakelockProvider.overrideWithValue(_NoWake()),
        clockProvider.overrideWithValue(() => DateTime.parse(today)),
      ],
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

Future<void> _open(WidgetTester t, String date, String slot) async {
  await t.tap(find.byKey(Key('meal-$date-$slot')));
  await t.pumpAndSettle();
}

Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

Map<String, dynamic> _meal(
  Map<String, dynamic> resp,
  String date,
  String slot,
) {
  final days = (resp['plan'] as Map<String, dynamic>)['days'] as List;
  final day = days.cast<Map<String, dynamic>>().firstWhere(
    (d) => d['date'] == date,
  );
  return (day['meals'] as List).cast<Map<String, dynamic>>().firstWhere(
    (m) => m['slot'] == slot,
  );
}

/// Phản hồi "đã ăn ngoài" cho một bữa: bữa giữ dữ liệu, ngày được miễn.
Map<String, dynamic> _outResponse(String date, String slot, String status) {
  final r = fixture('plan_response.json');
  _meal(r, date, slot)['status'] = status;
  final vdays = ((r['plan'] as Map)['validation'] as Map)['days'] as List;
  for (final v in vdays.cast<Map<String, dynamic>>()) {
    if (v['date'] == date) v['exempt'] = true;
  }
  return r;
}

Map<String, dynamic> _suggestion(
  String id,
  String name, {
  bool keeps = true,
  double dCost = -4000,
}) => {
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
  'delta_protein_g': 2.5,
  'delta_kcal': -30.0,
  'delta_cost_vnd': dCost,
  'keeps_day_ok': keeps,
  'day_protein_g': 118.0,
  'day_kcal': 2010.0,
};

Map<String, dynamic> _suggestions({bool anyKeeps = true}) => {
  'date': '2026-11-09',
  'slot': 'breakfast',
  'current_recipe_id': 'sang_chay_tofu_scramble',
  'any_keeps_day': anyKeeps,
  'items': [
    _suggestion('khoai_tay_luoc_muoi', 'Khoai tây luộc muối', keeps: anyKeeps),
    _suggestion(
      'canh_trung_cai_thao',
      'Canh trứng cải thảo',
      keeps: anyKeeps,
      dCost: 1500,
    ),
  ],
  'recipes': <String, dynamic>{},
};

Map<String, dynamic> _swapped() {
  final r = fixture('plan_response.json');
  _meal(r, '2026-11-09', 'breakfast')['recipe_id'] = 'khoai_tay_luoc_muoi';
  return r;
}

Map<String, dynamic> _body(RequestOptions o) => o.data is String
    ? jsonDecode(o.data as String) as Map<String, dynamic>
    : (o.data as Map).cast<String, dynamic>();

String _title(WidgetTester t, String date, String slot) =>
    t.widget<Text>(find.byKey(Key('meal-title-$date-$slot'))).data!;

void main() {
  group('Đổi món (US-5.1)', () {
    testWidgets(
      'gợi ý hiện chênh lệch + ngày đạt; chọn → bữa đổi, hoàn tác về như cũ',
      (t) async {
        final a = FakeAdapter()
          ..on('POST', '/v1/plans/swap-suggestions', _suggestions())
          ..on('POST', '/v1/plans/apply-swap', _swapped());
        final c = await _pump(t, a);
        final before = c.read(currentPlanProvider)!;
        final beforeTitle = _title(t, '2026-11-09', 'breakfast');
        await _open(t, '2026-11-09', 'breakfast');

        await _tap(t, 'change-meal');
        expect(
          find.byKey(const Key('swap-card-khoai_tay_luoc_muoi')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('swap-card-canh_trung_cai_thao')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('swap-none-keep')), findsNothing);
        expect(
          t
              .widget<Text>(
                find.byKey(const Key('swap-cost-khoai_tay_luoc_muoi')),
              )
              .data,
          contains('−4.000'),
        );
        expect(find.text('Ngày vẫn đạt'), findsWidgets);

        // Trạng thái gửi lên là chính tuần đang xem.
        final req = _body(a.requests.last);
        expect(req['date'], '2026-11-09');
        expect(req['slot'], 'breakfast');
        expect((req['state'] as Map)['plan'], isNotNull);

        await _tap(t, 'swap-pick-khoai_tay_luoc_muoi');
        final apply = a.requests.last;
        expect(apply.uri.path, '/v1/plans/apply-swap');
        expect(_body(apply)['recipe_id'], 'khoai_tay_luoc_muoi');
        expect(c.read(swapCountProvider), 1);
        expect(find.text('Đã đổi món'), findsOneWidget);
        expect(
          c.read(currentPlanProvider)!.plan.days.first.meals.first.recipeId,
          'khoai_tay_luoc_muoi',
        );

        // Hoàn tác từ thanh thông báo → tuần y như trước.
        await t.tap(find.text('Hoàn tác'));
        await t.pumpAndSettle();
        expect(c.read(currentPlanProvider)!.toJson(), before.toJson());
        expect(c.read(swapCountProvider), 0);
        expect(find.text('Đã hoàn tác'), findsOneWidget);
        await t.tap(find.byType(BackButton));
        await t.pumpAndSettle();
        expect(_title(t, '2026-11-09', 'breakfast'), beforeTitle);
      },
    );

    testWidgets(
      'không món nào giữ ngày đạt → cảnh báo, mỗi thẻ ghi "Ngày sẽ không đạt"',
      (t) async {
        final a = FakeAdapter()
          ..on(
            'POST',
            '/v1/plans/swap-suggestions',
            _suggestions(anyKeeps: false),
          );
        await _pump(t, a);
        await _open(t, '2026-11-09', 'breakfast');
        await _tap(t, 'change-meal');
        expect(find.byKey(const Key('swap-none-keep')), findsOneWidget);
        expect(find.text('Ngày sẽ không đạt'), findsNWidgets(2));
      },
    );

    testWidgets('lỗi mạng khi lấy gợi ý → báo lỗi trong sheet, có Thử lại', (
      t,
    ) async {
      final a = FakeAdapter()..failWithConnectionError = true;
      await _pump(t, a);
      await _open(t, '2026-11-09', 'breakfast');
      await _tap(t, 'change-meal');
      expect(find.byKey(const Key('sheet-error')), findsOneWidget);
      a.failWithConnectionError = false;
      a.on('POST', '/v1/plans/swap-suggestions', _suggestions());
      await t.tap(find.text('Thử lại'));
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('swap-card-khoai_tay_luoc_muoi')),
        findsOneWidget,
      );
    });
  });

  group('Đổi nguyên liệu (US-5.2)', () {
    testWidgets(
      'chọn nguyên liệu thay → gửi from/to, tuần cập nhật, đếm lượt đổi',
      (t) async {
        final options = {
          'date': '2026-11-09',
          'slot': 'breakfast',
          'ingredient_id': 'dau_phu',
          'swap_group': 'dau_phu',
          'options': [
            {
              'ingredient_id': 'uc_ga',
              'name': 'Ức gà',
              'grams': 120.0,
              'delta_protein_g': 0.5,
              'delta_kcal': -40.0,
              'delta_cost_vnd': 6000.0,
              'keeps_day_ok': true,
            },
          ],
        };
        final next = fixture('plan_response.json');
        _meal(next, '2026-11-09', 'breakfast')['substitutions'] = [
          {'from': 'dau_phu', 'to': 'uc_ga'},
        ];
        final a = FakeAdapter()
          ..on('POST', '/v1/plans/ingredient-options', options)
          ..on('POST', '/v1/plans/swap-ingredient', next);
        final c = await _pump(t, a);
        await _open(t, '2026-11-09', 'breakfast');

        await _tap(t, 'ing-swap-dau_phu');
        expect(find.byKey(const Key('ing-opt-uc_ga')), findsOneWidget);
        expect(_body(a.requests.last)['ingredient_id'], 'dau_phu');

        await _tap(t, 'ing-opt-uc_ga');
        final req = _body(a.requests.last);
        expect(a.requests.last.uri.path, '/v1/plans/swap-ingredient');
        expect(req['from_ingredient_id'], 'dau_phu');
        expect(req['to_ingredient_id'], 'uc_ga');
        expect(c.read(swapCountProvider), 1);
        expect(find.text('Đã đổi nguyên liệu'), findsOneWidget);
      },
    );

    testWidgets('không có nguyên liệu thay phù hợp → thông báo rỗng', (
      t,
    ) async {
      final a = FakeAdapter()
        ..on('POST', '/v1/plans/ingredient-options', {
          'date': '2026-11-09',
          'slot': 'breakfast',
          'ingredient_id': 'dau_phu',
          'swap_group': 'dau_phu',
          'options': <dynamic>[],
        });
      await _pump(t, a);
      await _open(t, '2026-11-09', 'breakfast');
      await _tap(t, 'ing-swap-dau_phu');
      expect(find.byKey(const Key('ing-swap-empty')), findsOneWidget);
    });
  });

  group('Ăn ngoài / bỏ bữa (US-5.3)', () {
    testWidgets(
      'đánh dấu ăn ngoài → dòng mờ + chip ngày + Hoàn tác trả đúng tuần cũ',
      (t) async {
        final a = FakeAdapter()
          ..on(
            'POST',
            '/v1/plans/eat-out',
            _outResponse('2026-11-09', 'lunch', 'eaten_out'),
          );
        final c = await _pump(t, a);
        final before = c.read(currentPlanProvider)!;
        await _open(t, '2026-11-09', 'lunch');
        await _tap(t, 'eat-out');
        await _tap(t, 'out-eat_out');

        expect(_body(a.requests.last)['mode'], 'eat_out');
        // Về tab Kế hoạch (trang bữa đã đóng).
        expect(
          find.byKey(const Key('out-label-2026-11-09-lunch')),
          findsOneWidget,
        );
        expect(
          t
              .widget<Text>(find.byKey(const Key('out-label-2026-11-09-lunch')))
              .data,
          'Ăn ngoài',
        );
        expect(find.byKey(const Key('day-exempt-2026-11-09')), findsOneWidget);
        expect(find.byKey(const Key('day-exempt-2026-11-10')), findsNothing);

        // Hoàn tác: gọi mode=undo, trả tuần ban đầu.
        a.on('POST', '/v1/plans/eat-out', fixture('plan_response.json'));
        await _tap(t, 'out-undo-2026-11-09-lunch');
        expect(_body(a.requests.last)['mode'], 'undo');
        expect(
          find.byKey(const Key('out-label-2026-11-09-lunch')),
          findsNothing,
        );
        expect(find.byKey(const Key('day-exempt-2026-11-09')), findsNothing);
        expect(c.read(currentPlanProvider)!.toJson(), before.toJson());
      },
    );

    testWidgets('bỏ bữa → nhãn "Bỏ bữa"', (t) async {
      final a = FakeAdapter()
        ..on(
          'POST',
          '/v1/plans/eat-out',
          _outResponse('2026-11-09', 'dinner', 'skipped'),
        );
      await _pump(t, a);
      await _open(t, '2026-11-09', 'dinner');
      await _tap(t, 'eat-out');
      await _tap(t, 'out-skip');
      expect(_body(a.requests.last)['mode'], 'skip');
      expect(
        t
            .widget<Text>(find.byKey(const Key('out-label-2026-11-09-dinner')))
            .data,
        'Bỏ bữa',
      );
    });

    testWidgets(
      'đi chợ: món đã mua vẫn giữ trong danh sách dù bữa bị ăn ngoài',
      (t) async {
        final orig = fixture('plan_response.json');
        final out = _outResponse('2026-11-09', 'breakfast', 'eaten_out');
        // Server không còn trả đậu hũ (bữa đã rút khỏi đi chợ).
        final shopping =
            (out['plan'] as Map)['shopping'] as Map<String, dynamic>;
        (shopping['items'] as List).removeWhere(
          (i) => (i as Map)['ingredient_id'] == 'dau_phu',
        );
        for (final g in shopping['by_aisle'] as List) {
          ((g as Map)['items'] as List).removeWhere(
            (i) => (i as Map)['ingredient_id'] == 'dau_phu',
          );
        }
        final a = FakeAdapter()..on('POST', '/v1/plans/eat-out', out);
        final c = await _pump(t, a);
        c
            .read(shoppingStateProvider.notifier)
            .setBought('dau_phu', bought: true);
        unawaited(
          c
              .read(weekChangesProvider)
              .setOut('2026-11-09', 'breakfast', 'eat_out'),
        );
        await t.pumpAndSettle();
        final items = c.read(currentPlanProvider)!.plan.shopping.items;
        expect(
          items.any((i) => i.ingredientId == 'dau_phu'),
          isTrue,
          reason: 'đã mua → giữ',
        );
        expect((orig['plan'] as Map)['shopping'], isNotNull);
      },
    );
  });

  group('Không hợp với tôi + lên lại (US-5.4, US-5.5)', () {
    testWidgets(
      'chỉ chặn → thêm vào món bị chặn, không gọi server, hoàn tác được',
      (t) async {
        final a = FakeAdapter();
        final c = await _pump(t, a);
        await _open(t, '2026-11-09', 'breakfast');
        await _tap(t, 'not-for-me');
        await _tap(t, 'block-only');
        expect(
          c.read(preferencesProvider).blockedRecipeIds,
          contains('sang_chay_tofu_scramble'),
        );
        expect(
          a.requests.where((r) => r.uri.path.contains('regenerate')),
          isEmpty,
        );
        expect(find.textContaining('không chọn món này'), findsOneWidget);
        await t.tap(find.text('Hoàn tác'));
        await t.pumpAndSettle();
        expect(c.read(preferencesProvider).blockedRecipeIds, isEmpty);
      },
    );

    testWidgets(
      'chặn và lên lại → gửi today + món bị chặn, tuần cũ vào Tuần đã lưu, hiện banner',
      (t) async {
        final next = fixture('plan_response.json');
        _meal(next, '2026-11-12', 'dinner')['recipe_id'] =
            'khoai_tay_luoc_muoi';
        final a = FakeAdapter()..on('POST', '/v1/plans/regenerate-rest', next);
        final c = await _pump(t, a);
        final before = c.read(currentPlanProvider)!;
        await _open(t, '2026-11-09', 'breakfast');
        await _tap(t, 'not-for-me');
        await _tap(t, 'block-replan');

        final req = _body(a.requests.last);
        expect(req['today'], '2026-11-10');
        final prefs = (req['state'] as Map)['preferences'] as Map;
        expect(
          prefs['blocked_recipe_ids'],
          contains('sang_chay_tofu_scramble'),
        );
        expect(
          c.read(preferencesProvider).blockedRecipeIds,
          contains('sang_chay_tofu_scramble'),
        );
        expect(c.read(savedPlansProvider), hasLength(1));
        expect(
          c.read(savedPlansProvider).single.plan.toJson(),
          before.toJson(),
        );
        expect(c.read(replanNoticeProvider), isTrue);
        expect(find.byKey(const Key('plan-replan-banner')), findsOneWidget);
        expect(find.byKey(const Key('plan-banner')), findsNothing);
        expect(find.text('Đã lên lại tuần'), findsWidgets);

        // Đóng banner → về banner thường.
        await t.tap(
          find.descendant(
            of: find.byKey(const Key('plan-replan-banner')),
            matching: find.text('Đóng'),
          ),
        );
        await t.pumpAndSettle();
        expect(find.byKey(const Key('plan-replan-banner')), findsNothing);
        expect(find.byKey(const Key('plan-banner')), findsOneWidget);
      },
    );

    testWidgets(
      'nút "Lên lại phần còn lại": hỏi xác nhận rồi gọi server; Hủy thì không gọi',
      (t) async {
        final a = FakeAdapter()
          ..on(
            'POST',
            '/v1/plans/regenerate-rest',
            fixture('plan_response.json'),
          );
        final c = await _pump(t, a);
        await _tap(t, 'replan-rest');
        await _tap(t, 'replan-cancel');
        expect(
          a.requests.where((r) => r.uri.path.contains('regenerate')),
          isEmpty,
        );

        await _tap(t, 'replan-rest');
        await _tap(t, 'replan-confirm');
        final req = a.requests.last;
        expect(req.uri.path, '/v1/plans/regenerate-rest');
        expect(_body(req)['today'], '2026-11-10');
        expect(c.read(replanNoticeProvider), isTrue);
        expect(c.read(savedPlansProvider), hasLength(1));
      },
    );

    testWidgets('hết ngày sau hôm nay → không có nút lên lại', (t) async {
      await _pump(t, FakeAdapter(), today: '2026-11-15');
      expect(find.byKey(const Key('replan-rest')), findsNothing);
    });

    testWidgets('lỗi mạng khi lên lại → giữ nguyên tuần, báo lỗi', (t) async {
      final a = FakeAdapter()..failWithConnectionError = true;
      final c = await _pump(t, a);
      final before = c.read(currentPlanProvider)!.toJson();
      await _tap(t, 'replan-rest');
      await _tap(t, 'replan-confirm');
      expect(c.read(currentPlanProvider)!.toJson(), before);
      expect(c.read(savedPlansProvider), isEmpty);
      expect(c.read(replanNoticeProvider), isFalse);
    });
  });

  group('Logic thay đổi tuần', () {
    test('hasDaysAfter: chỉ true khi còn ngày sau hôm nay', () {
      final plan = samplePlan().plan; // 09/11 → 15/11
      expect(hasDaysAfter(plan, DateTime(2026, 11, 7)), isTrue);
      expect(hasDaysAfter(plan, DateTime(2026, 11, 14)), isTrue);
      expect(hasDaysAfter(plan, DateTime(2026, 11, 15)), isFalse);
    });

    test('keepBoughtItems: chỉ giữ lại món đã mua mà server không còn trả', () {
      final old = samplePlan().plan.shopping;
      final gone = old.items.take(2).toList();
      final keep = old.items.skip(2).toList();
      final next = old.copyWith(
        items: keep,
        byAisle: [
          for (final g in old.byAisle)
            g.copyWith(
              items: [
                for (final i in g.items)
                  if (!gone.any((x) => x.ingredientId == i.ingredientId)) i,
              ],
            ),
        ].where((g) => g.items.isNotEmpty).toList(),
      );
      final bought = {gone.first.ingredientId};
      final merged = keepBoughtItems(old, next, bought);
      expect(
        merged.items.map((i) => i.ingredientId),
        contains(gone.first.ingredientId),
      );
      expect(
        merged.items.map((i) => i.ingredientId),
        isNot(contains(gone.last.ingredientId)),
      );
      expect(
        merged.byAisle.expand((g) => g.items).map((i) => i.ingredientId),
        contains(gone.first.ingredientId),
      );
      // không có món đã mua nào bị mất → trả nguyên
      expect(identical(keepBoughtItems(old, next, <String>{}), next), isTrue);
    });
  });
}
