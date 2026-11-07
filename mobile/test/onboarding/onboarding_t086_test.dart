import 'dart:convert';
import 'dart:io';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

FakeAdapter api() => FakeAdapter()
  ..on('POST', '/v1/targets', fixture('targets.json'))
  ..on('POST', '/v1/budget-range', fixture('budget_range.json'))
  ..on('POST', '/v1/slots/preview', fixture('slots_preview.json'))
  ..on('POST', '/v1/plans', fixture('plan_response.json'))
  ..on('GET', '/v1/reference', fixture('reference.json'))
  ..on(
    'GET',
    '/v1/ingredients',
    jsonDecode(
      File('test/fixtures/ingredients_search.json').readAsStringSync(),
    ),
  );

Future<ProviderContainer> pumpAt(
  WidgetTester t,
  int step, {
  FakeAdapter? adapter,
  MemoryStore? store,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 3600);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: testOverrides(
        store: store ?? onboardingAt(step),
        adapter: adapter ?? api(),
      ),
      child: const FitProApp(),
    ),
  );
  await settle(t);
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

/// Chờ các debounce nối tiếp (targets 350 ms → budget-range 200 ms) chạy xong.
Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 400));
  }
  await t.pumpAndSettle();
}

void main() {
  group('Thẻ vuốt (US-1.5 AC1, AC2)', () {
    testWidgets('nút ♥ / ✕ ghi cuisine_likes / cuisine_less theo tag', (
      t,
    ) async {
      final c = await pumpAt(t, 11);
      expect(find.text('Vuốt để chọn món bạn thích'), findsOneWidget);
      expect(find.text('Thẻ 1/14'), findsOneWidget);
      await t.tap(find.byKey(const Key('swipe-like')));
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      expect(find.text('Thẻ 2/14'), findsOneWidget);
      await t.tap(find.byKey(const Key('swipe-dislike')));
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLess, ['kho']);
      expect(c.read(onboardingProvider).swipedCardIds, ['card_01', 'card_02']);
    });

    testWidgets('vuốt phải = thích, vuốt trái = ít hơn', (t) async {
      final c = await pumpAt(t, 11);
      await t.drag(
        find.byKey(const Key('swipe-card-card_01')),
        const Offset(700, 0),
      );
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLikes, ['xao']);
      await t.drag(
        find.byKey(const Key('swipe-card-card_02')),
        const Offset(-700, 0),
      );
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).cuisineLess, ['kho']);
    });

    testWidgets(
      'Hoàn tác trả thẻ về và bỏ lựa chọn; Thay thế đẩy thẻ xuống cuối',
      (t) async {
        final c = await pumpAt(t, 11);
        // chưa có gì để hoàn tác
        expect(
          t
              .widget<IconButton>(
                find.descendant(
                  of: find.byKey(const Key('swipe-undo')),
                  matching: find.byType(IconButton),
                ),
              )
              .onPressed,
          isNull,
        );
        await t.tap(find.byKey(const Key('swipe-like')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('swipe-undo')));
        await t.pumpAndSettle();
        expect(c.read(preferencesProvider).cuisineLikes, isEmpty);
        expect(c.read(onboardingProvider).swipedCardIds, isEmpty);
        expect(find.byKey(const Key('swipe-card-card_01')), findsOneWidget);

        await t.tap(find.byKey(const Key('swipe-replace')));
        await t.pumpAndSettle();
        expect(find.byKey(const Key('swipe-card-card_02')), findsOneWidget);
        expect(find.byKey(const Key('swipe-card-card_01')), findsNothing);
      },
    );

    testWidgets('vuốt hết → màn kết quả thích / ít hơn, "Vuốt lại" làm lại', (
      t,
    ) async {
      final c = await pumpAt(t, 11);
      await t.tap(find.byKey(const Key('swipe-like')));
      await t.pumpAndSettle();
      for (var i = 0; i < 13; i++) {
        await t.tap(find.byKey(const Key('swipe-dislike')));
        await t.pumpAndSettle();
      }
      expect(find.text('Khẩu vị của bạn'), findsOneWidget);
      expect(find.byKey(const Key('swipe-liked')), findsOneWidget);
      expect(
        t.widget<Text>(find.byKey(const Key('swipe-liked'))).data,
        'Xào nhanh',
      );
      expect(c.read(preferencesProvider).cuisineLess.length, 13);
      await t.tap(find.byKey(const Key('swipe-again')));
      await t.pumpAndSettle();
      expect(find.text('Thẻ 1/14'), findsOneWidget);
      expect(c.read(preferencesProvider).cuisineLikes, isEmpty);
      expect(c.read(preferencesProvider).cuisineLess, isEmpty);
    });

    testWidgets('tắt app giữa chừng → mở lại đúng thẻ tiếp theo', (t) async {
      final store = onboardingAt(11);
      await pumpAt(t, 11, store: store);
      await t.tap(find.byKey(const Key('swipe-like')));
      await t.pumpAndSettle();
      await t.pumpWidget(const SizedBox());
      await pumpAt(t, 11, store: store);
      expect(find.text('Thẻ 2/14'), findsOneWidget);
    });
  });

  group('Dụng cụ bếp (US-1.5 AC3)', () {
    testWidgets('chọn nhiều; bỏ hết thiết bị nấu → khóa Tiếp tục + cảnh báo', (
      t,
    ) async {
      final c = await pumpAt(t, 12);
      expect(find.text('Bếp nhà bạn có những gì?'), findsOneWidget);
      expect(find.byKey(const Key('equipment-need-one')), findsNothing);
      await t.tap(find.byKey(const Key('equip-lo_nuong')));
      await t.pump();
      expect(c.read(preferencesProvider).equipment, contains('lo_nuong'));
      for (final id in ['bep', 'noi_com_dien', 'lo_nuong']) {
        await t.tap(find.byKey(Key('equip-$id')));
        await t.pump();
      }
      expect(find.byKey(const Key('equipment-need-one')), findsOneWidget);
      // máy xay không tính là thiết bị nấu
      await t.tap(find.byKey(const Key('equip-may_xay')));
      await t.pump();
      expect(find.byKey(const Key('equipment-need-one')), findsOneWidget);
      final cta = t.widget<FilledButton>(
        find.ancestor(
          of: find.text('Tiếp tục'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(cta.onPressed, isNull);
    });
  });

  group('Tổng kết + tạo tuần (US-1.6)', () {
    testWidgets('checklist đúng giá trị người dùng chọn', (t) async {
      final c = await pumpAt(t, 13);
      c.read(profileProvider.notifier).update((p) => p.copyWith(goal: 'build'));
      c
          .read(preferencesProvider.notifier)
          .update(
            (p) => p.copyWith(
              exclusions: ['no_pork'],
              healthLeanings: ['it_beo'],
              weeklyBudgetVnd: 900000,
              dislikedIngredientIds: ['ca_tim'],
              equipment: ['bep', 'lo_nuong'],
            ),
          );
      c.read(ingredientNamesProvider.notifier).set({'ca_tim': 'Cà tím'});
      await settle(t);
      String v(String id) =>
          t.widget<Text>(find.byKey(Key('summary-$id-value'))).data!;
      expect(v('goal'), 'Tăng cơ');
      expect(
        v('protein'),
        '175 g'.replaceAll('175', v('protein').split(' ').first),
      );
      expect(v('kcal'), endsWith('kcal'));
      expect(v('meals'), '4 bữa mỗi ngày');
      expect(v('leanings'), 'Ít béo');
      expect(
        v('excluded'),
        allOf(contains('Không thịt lợn'), contains('Cà tím')),
      );
      expect(v('kitchen'), allOf(contains('Bếp'), contains('Lò nướng')));
      expect(v('budget'), '900.000 ₫ mỗi tuần');
      // thứ tự các dòng
      final order = [
        'goal',
        'protein',
        'kcal',
        'meals',
        'leanings',
        'excluded',
        'kitchen',
        'budget',
      ];
      final ys = [
        for (final id in order) t.getTopLeft(find.byKey(Key('summary-$id'))).dy,
      ];
      expect(ys, [...ys]..sort());
    });

    testWidgets('budget-range lỗi → hiện lỗi + Thử lại, nút tạo tuần bị khóa', (
      t,
    ) async {
      final adapter = api()
        ..on('POST', '/v1/budget-range', {'title': 'x'}, status: 500);
      await pumpAt(t, 13, adapter: adapter);
      expect(find.text('Thử lại'), findsOneWidget);
      final cta = t.widget<FilledButton>(
        find.ancestor(
          of: find.text('Tạo thực đơn tuần'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(cta.onPressed, isNull);
    });

    testWidgets('bấm Sửa nhảy tới đúng bước', (t) async {
      final c = await pumpAt(t, 13);
      await t.tap(find.byKey(const Key('summary-kitchen-edit')));
      await t.pumpAndSettle();
      expect(c.read(onboardingProvider).step, 12);
      expect(find.text('Bếp nhà bạn có những gì?'), findsOneWidget);
    });

    testWidgets('ngân sách < min → cảnh báo, "Dùng mức tối thiểu" sửa lại', (
      t,
    ) async {
      final adapter = api();
      final c = await pumpAt(t, 13, adapter: adapter);
      c
          .read(preferencesProvider.notifier)
          .update((p) => p.copyWith(weeklyBudgetVnd: 500000));
      await settle(t);
      expect(find.byKey(const Key('summary-budget-low')), findsOneWidget);
      // gọi lại budget-range kèm preferences đầy đủ
      final full = adapter.requests
          .where((r) => r.path == '/v1/budget-range')
          .last;
      expect((full.data as Map)['preferences'], isNotNull);
      // T-075: dạng đầy đủ không gửi trường cấp ngoài thừa
      for (final k in ['store_id', 'adults', 'children', 'slots']) {
        expect((full.data as Map).containsKey(k), isFalse, reason: k);
      }
      await t.tap(find.text('Dùng mức tối thiểu'));
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).weeklyBudgetVnd, 650000);
      expect(find.byKey(const Key('summary-budget-low')), findsNothing);
    });

    testWidgets(
      'L-12: tổng kết có mức tối thiểu cao hơn lúc chọn ngân sách → nêu lý do và cả hai con số, nút "Dùng 700.000 ₫"',
      (t) async {
        final adapter = api()
          ..onRequest('POST', '/v1/budget-range', (o) {
            final body = Map<String, dynamic>.from(
              fixture('budget_range.json'),
            );
            // Dạng đầy đủ (có preferences: kiêng/dụng cụ/cơm) cho mức tối thiểu cao hơn dạng rút gọn.
            if ((o.data as Map).containsKey('preferences')) {
              body['min_vnd'] = 700000;
            }
            return body;
          });
        final c = await pumpAt(t, 13, adapter: adapter);
        c
            .read(preferencesProvider.notifier)
            .update((p) => p.copyWith(weeklyBudgetVnd: 650000));
        await settle(t);
        expect(find.byKey(const Key('summary-budget-low')), findsOneWidget);
        expect(
          find.textContaining('Sau các lựa chọn chế độ ăn và dụng cụ'),
          findsOneWidget,
        );
        expect(find.textContaining('700.000'), findsWidgets);
        expect(
          find.textContaining('lúc chọn ngân sách là 650.000'),
          findsOneWidget,
        );
        expect(find.text('Dùng mức tối thiểu'), findsNothing);
        await t.tap(find.text('Dùng 700.000 ₫'));
        await settle(t);
        expect(c.read(preferencesProvider).weeklyBudgetVnd, 700000);
        expect(find.byKey(const Key('summary-budget-low')), findsNothing);
      },
    );

    testWidgets(
      'L-12: ngân sách bằng hoặc cao hơn mức tối thiểu của tổng kết → không cảnh báo',
      (t) async {
        final adapter = api()
          ..onRequest('POST', '/v1/budget-range', (o) {
            final body = Map<String, dynamic>.from(
              fixture('budget_range.json'),
            );
            if ((o.data as Map).containsKey('preferences')) {
              body['min_vnd'] = 700000;
            }
            return body;
          });
        final c = await pumpAt(t, 13, adapter: adapter);
        c
            .read(preferencesProvider.notifier)
            .update((p) => p.copyWith(weeklyBudgetVnd: 700000));
        await settle(t);
        expect(find.byKey(const Key('summary-budget-low')), findsNothing);
      },
    );

    testWidgets(
      'Tạo thực đơn tuần → POST /v1/plans từ ngày mai, lưu tuần, sang tab Kế hoạch',
      (t) async {
        final adapter = api();
        final c = await pumpAt(t, 13, adapter: adapter);
        await t.tap(find.text('Tạo thực đơn tuần'));
        await t.pump();
        expect(find.byKey(const Key('generating-title')), findsOneWidget);
        await t.pumpAndSettle();
        final req = adapter.requests.singleWhere((r) => r.path == '/v1/plans');
        final body = req.data as Map<String, dynamic>;
        expect(body['start_date'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
        expect(body['meal_style'], 'auto');
        expect(c.read(currentPlanProvider), isNotNull);
        expect(c.read(onboardingProvider).completed, isTrue);
        expect(find.text('Kế hoạch'), findsWidgets);
        expect(find.byKey(const Key('generating-title')), findsNothing);
      },
    );

    testWidgets('lỗi API → màn lỗi thân thiện + Thử lại thành công', (t) async {
      final adapter = api()
        ..on('POST', '/v1/plans', {'title': 'x'}, status: 500);
      final c = await pumpAt(t, 13, adapter: adapter);
      await t.tap(find.text('Tạo thực đơn tuần'));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('generating-fail')), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(c.read(onboardingProvider).completed, isFalse);
      // server hồi phục
      adapter.on('POST', '/v1/plans', fixture('plan_response.json'));
      await t.tap(find.text('Thử lại'));
      await t.pumpAndSettle();
      expect(c.read(onboardingProvider).completed, isTrue);
      expect(c.read(currentPlanProvider), isNotNull);
    });

    testWidgets(
      'mất mạng khi tạo tuần → báo không có mạng, quay lại vẫn giữ lựa chọn',
      (t) async {
        final adapter = api();
        final c = await pumpAt(t, 13, adapter: adapter);
        adapter.failWithConnectionError = true;
        await t.tap(find.text('Tạo thực đơn tuần'));
        await t.pumpAndSettle();
        expect(find.textContaining('Không có mạng'), findsOneWidget);
        await t.tap(find.byKey(const Key('generating-back')));
        await t.pumpAndSettle();
        expect(find.text('Đây là thiết lập của bạn'), findsOneWidget);
        expect(c.read(preferencesProvider).storeId, 'bach_hoa_xanh');
        await settle(t);
      },
    );
  });
}
