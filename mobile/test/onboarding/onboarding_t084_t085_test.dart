import 'dart:convert';
import 'dart:io';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/format.dart';
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
  await t.pump(const Duration(milliseconds: 600));
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

void main() {
  group('T-084 Cửa hàng', () {
    testWidgets('chọn đúng 1 cửa hàng, hiện ghi chú giá ước tính', (t) async {
      final c = await pumpAt(t, 4);
      expect(find.text('Bạn hay đi chợ ở đâu?'), findsOneWidget);
      expect(find.text('Bách hóa Xanh'), findsOneWidget);
      expect(find.text('WinMart'), findsOneWidget);
      await t.tap(find.text('WinMart'));
      await t.pump();
      expect(c.read(preferencesProvider).storeId, 'winmart');
      await t.tap(find.text('Bách hóa Xanh'));
      await t.pump();
      expect(c.read(preferencesProvider).storeId, 'bach_hoa_xanh');
      // đúng một thẻ được chọn
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('T-084 Hộ gia đình', () {
    testWidgets('stepper người lớn 1–6, trẻ em 0–4', (t) async {
      final c = await pumpAt(t, 5);
      expect(find.text('Ai sẽ ăn cùng bạn?'), findsOneWidget);
      expect(c.read(preferencesProvider).adults, 1);
      // không giảm dưới 1
      await t.tap(find.byTooltip('Giảm Người lớn'));
      await t.pump();
      expect(c.read(preferencesProvider).adults, 1);
      for (var i = 0; i < 8; i++) {
        await t.tap(find.byTooltip('Tăng Người lớn'));
        await t.pump();
      }
      expect(c.read(preferencesProvider).adults, 6);
      // trẻ em 0..4
      await t.tap(find.byTooltip('Giảm Trẻ em'));
      await t.pump();
      expect(c.read(preferencesProvider).children, 0);
      for (var i = 0; i < 6; i++) {
        await t.tap(find.byTooltip('Tăng Trẻ em'));
        await t.pump();
      }
      expect(c.read(preferencesProvider).children, 4);
    });
  });

  group('T-084 Ngân sách', () {
    testWidgets(
      'min/max/ước tính từ API, mặc định = ước tính, tiền kiểu vi-VN',
      (t) async {
        final adapter = api();
        final c = await pumpAt(t, 6, adapter: adapter);
        expect(
          find.text('Mỗi tuần bạn muốn chi bao nhiêu cho đi chợ?'),
          findsOneWidget,
        );
        // ước tính 847.000 → làm tròn bước 50.000 từ min 650.000 → 850.000
        expect(find.text('850.000 ₫'), findsWidgets);
        expect(formatVnd(600000), '600.000');
        expect(find.text('Tối thiểu 650.000 ₫'), findsOneWidget);
        expect(find.text('Tối đa 2.150.000 ₫'), findsOneWidget);
        final reqs = adapter.requests.where(
          (r) => r.path == '/v1/budget-range',
        );
        expect(reqs, isNotEmpty);
        // T-075: dạng rút gọn (chưa có preferences đầy đủ) gửi các trường cấp ngoài, không gửi preferences
        final body = reqs.last.data as Map;
        expect(body['store_id'], isNotNull);
        expect(body.containsKey('preferences'), isFalse);
        // chưa kéo mà bấm Tiếp tục → lưu mức đang hiển thị
        await t.tap(find.text('Tiếp tục'));
        await t.pumpAndSettle();
        expect(c.read(preferencesProvider).weeklyBudgetVnd, 850000);
      },
    );

    testWidgets(
      'kéo thanh trượt → nhãn bậc đổi theo i18n; mép phải ≥ bậc thoải mái',
      (t) async {
        final c = await pumpAt(t, 6);
        final before = find.descendant(
          of: find.byKey(const Key('budget-tier')),
          matching: find.byType(Text),
        );
        final first = (t.widget(before.first) as Text).data;
        expect(first, contains('Vừa phải'));
        final slider = find.byKey(const Key('budget-slider'));
        await t.drag(slider, const Offset(2000, 0));
        await t.pumpAndSettle();
        final after = (t.widget(before.first) as Text).data;
        expect(after, contains('Thoải mái'));
        expect(c.read(preferencesProvider).weeklyBudgetVnd, 2150000);
        await t.drag(slider, const Offset(-4000, 0));
        await t.pumpAndSettle();
        expect((t.widget(before.first) as Text).data, contains('Tiết kiệm'));
        expect(c.read(preferencesProvider).weeklyBudgetVnd, 650000);
      },
    );

    testWidgets('mất mạng → hiện lỗi thân thiện và nút Thử lại', (t) async {
      final adapter = api()..failWithConnectionError = true;
      await pumpAt(t, 6, adapter: adapter);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });

  group('T-085 Bữa ăn', () {
    testWidgets(
      '5 bữa, chọn Tự lo / Không lên món, footer từ /v1/slots/preview',
      (t) async {
        final c = await pumpAt(t, 7);
        expect(find.text('Lên thực đơn những bữa nào?'), findsOneWidget);
        for (final s in [
          'breakfast',
          'lunch',
          'dinner',
          'snack_am',
          'snack_pm',
        ]) {
          expect(find.byKey(Key('slot-$s')), findsOneWidget);
        }
        expect(find.textContaining('Mỗi bữa ~'), findsOneWidget);
        await t.tap(
          find.descendant(
            of: find.byKey(const Key('slot-breakfast')),
            matching: find.text('Tự lo'),
          ),
        );
        await t.pump();
        expect(c.read(preferencesProvider).slots.breakfast, 'self');
        expect(find.byKey(const Key('slot-breakfast-sub')), findsOneWidget);
        await t.pump(const Duration(seconds: 1));
      },
    );

    testWidgets('kiểu bữa trưa nóng/mang đi và bữa phụ chiều ngọt/mặn', (
      t,
    ) async {
      final c = await pumpAt(t, 7);
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('slot-lunch')),
          matching: find.text('Mang đi'),
        ),
      );
      await t.pump();
      expect(c.read(preferencesProvider).slots.lunchStyle, 'packed');
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('slot-snack_pm')),
          matching: find.text('Ngọt'),
        ),
      );
      await t.pump();
      expect(c.read(preferencesProvider).slots.snackPmStyle, 'sweet');
      await t.pump(const Duration(seconds: 1)); // chờ debounce slots/preview
    });

    testWidgets('không cho tắt hết bữa chính — hiện cảnh báo, giữ nguyên', (
      t,
    ) async {
      final c = await pumpAt(t, 7);
      for (final s in ['breakfast', 'lunch']) {
        await t.tap(
          find.descendant(
            of: find.byKey(Key('slot-$s')),
            matching: find.text('Không lên món'),
          ),
        );
        await t.pump();
      }
      expect(find.byKey(const Key('meals-need-one')), findsNothing);
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('slot-dinner')),
          matching: find.text('Không lên món'),
        ),
      );
      await t.pump();
      expect(find.byKey(const Key('meals-need-one')), findsOneWidget);
      expect(c.read(preferencesProvider).slots.dinner, 'on');
      await t.pump(const Duration(seconds: 1)); // chờ debounce slots/preview
    });

    testWidgets(
      'D-QA-05: trạng thái không còn bữa chính nào (vd khôi phục từ bộ nhớ) → nhắc và khóa Tiếp tục',
      (t) async {
        final c = await pumpAt(t, 7);
        c
            .read(preferencesProvider.notifier)
            .update(
              (p) => p.copyWith(
                slots: p.slots.copyWith(
                  breakfast: 'skip',
                  lunch: 'skip',
                  dinner: 'skip',
                ),
              ),
            );
        await t.pump();
        expect(find.byKey(const Key('meals-need-one')), findsOneWidget);
        final cta = t.widget<FilledButton>(
          find.ancestor(
            of: find.text('Tiếp tục'),
            matching: find.byType(FilledButton),
          ),
        );
        expect(cta.onPressed, isNull);
        await t.pump(const Duration(seconds: 1)); // chờ debounce slots/preview
      },
    );
  });

  group('T-085 Kiêng', () {
    testWidgets(
      'chọn kiểu ăn đơn lẻ; "Không kiêng" loại trừ; ít tinh bột kết hợp được',
      (t) async {
        final c = await pumpAt(t, 8);
        expect(find.text('Bạn có kiêng gì không?'), findsOneWidget);
        await t.tap(find.byKey(const Key('diet-vegetarian')));
        await t.pump();
        expect(c.read(preferencesProvider).diet, 'vegetarian');
        await t.tap(find.byKey(const Key('diet-vegan')));
        await t.pump();
        expect(c.read(preferencesProvider).diet, 'vegan');
        await t.tap(find.byKey(const Key('diet-low-carb')));
        await t.pump();
        expect(c.read(preferencesProvider).lowCarb, isTrue);
        expect(c.read(preferencesProvider).diet, 'vegan');
        await t.tap(find.byKey(const Key('diet-none')));
        await t.pump();
        expect(c.read(preferencesProvider).diet, 'none');
      },
    );

    testWidgets(
      'loại bỏ hoàn toàn hiện phạm vi nguyên liệu; xu hướng có lưu ý y tế',
      (t) async {
        final c = await pumpAt(t, 8);
        await t.ensureVisible(find.byKey(const Key('excl-no_pork')));
        await t.tap(find.byKey(const Key('excl-no_pork')));
        await t.pump();
        expect(c.read(preferencesProvider).exclusions, contains('no_pork'));
        expect(find.byKey(const Key('scope-no_pork')), findsOneWidget);
        expect(find.textContaining('Thịt heo ba chỉ'), findsOneWidget);
        await t.ensureVisible(find.byKey(const Key('lean-nhieu_xo')));
        expect(find.byKey(const Key('leanings-note')), findsOneWidget);
        // D-ONB-03: chỉ 4 xu hướng chính thức, nhãn + mô tả từ i18n, kèm miễn trừ y tế
        for (final id in ['nhieu_xo', 'it_duong', 'tot_cho_tim', 'it_beo']) {
          expect(find.byKey(Key('lean-$id')), findsOneWidget, reason: id);
          expect(find.byKey(Key('lean-desc-$id')), findsOneWidget, reason: id);
        }
        for (final id in ['giau_dam', 'omega3', 'chay', 'low_carb']) {
          expect(find.byKey(Key('lean-$id')), findsNothing, reason: id);
        }
        expect(
          find.textContaining('không phải lời khuyên y tế'),
          findsOneWidget,
        );
        expect(find.textContaining('Hỏi bác sĩ'), findsOneWidget);
        await t.tap(find.byKey(const Key('lean-nhieu_xo')));
        await t.pump();
        expect(c.read(preferencesProvider).healthLeanings, ['nhieu_xo']);
        // bỏ chọn
        await t.tap(find.byKey(const Key('excl-no_pork')));
        await t.pump();
        expect(c.read(preferencesProvider).exclusions, isEmpty);
      },
    );
  });

  group('T-085 Không thích nguyên liệu', () {
    testWidgets(
      '≥ 6 gợi ý nhanh; chọn gợi ý → thành chip "Đã loại", bỏ bằng ✕',
      (t) async {
        final c = await pumpAt(t, 10);
        expect(
          find.text('Có gì bạn không bao giờ muốn thấy trên thực đơn?'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dislike-empty')), findsOneWidget);
        final suggestions = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('suggest-'),
        );
        expect(suggestions.evaluate().length, greaterThanOrEqualTo(6));
        await t.ensureVisible(find.byKey(const Key('suggest-ca_tim')));
        await t.tap(find.byKey(const Key('suggest-ca_tim')));
        await t.pump();
        expect(c.read(preferencesProvider).dislikedIngredientIds, ['ca_tim']);
        expect(find.byKey(const Key('picked-ca_tim')), findsOneWidget);
        expect(find.byKey(const Key('suggest-ca_tim')), findsNothing);
        await t.tap(find.byTooltip('Bỏ loại Cà tím'));
        await t.pump();
        expect(c.read(preferencesProvider).dislikedIngredientIds, isEmpty);
      },
    );

    testWidgets('tìm không dấu qua API rồi thêm', (t) async {
      final adapter = api();
      final c = await pumpAt(t, 10, adapter: adapter);
      await t.enterText(find.byKey(const Key('dislike-search')), 'trung ga');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      final q = adapter.requests.where((r) => r.path == '/v1/ingredients');
      expect(q.single.queryParameters['q'], 'trung ga');
      await t.tap(find.byKey(const Key('result-trung_ga')));
      await t.pumpAndSettle();
      expect(c.read(preferencesProvider).dislikedIngredientIds, ['trung_ga']);
      expect(find.byKey(const Key('picked-trung_ga')), findsOneWidget);
      // tên được nhớ để mở lại không cần mạng
      expect(c.read(ingredientNamesProvider)['trung_ga'], 'Trứng gà');
    });
  });
}
