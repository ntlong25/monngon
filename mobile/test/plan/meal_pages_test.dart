import 'dart:convert';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/wakelock.dart';
import 'package:fitpro_mamdu/features/meal/meal_data.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

class FakeWakelock implements WakelockController {
  int enables = 0;
  int disables = 0;
  bool get on => enables > disables;

  @override
  Future<void> enable() async => enables++;

  @override
  Future<void> disable() async => disables++;
}

MemoryStore seeded({int adults = 1, int children = 0}) {
  final s = completedStore();
  s.data[StoreKeys.currentPlan] = jsonEncode(fixture('plan_response.json'));
  s.data[StoreKeys.preferences] = jsonEncode(
    Defaults.preferences.copyWith(adults: adults, children: children).toJson(),
  );
  return s;
}

Future<ProviderContainer> pumpApp(
  WidgetTester t, {
  MemoryStore? store,
  FakeWakelock? wake,
  FakeAdapter? adapter,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 9000);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(store: store ?? seeded(), adapter: adapter),
        wakelockProvider.overrideWithValue(wake ?? FakeWakelock()),
      ],
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

Future<void> openMeal(WidgetTester t, String date, String slot) async {
  await t.tap(find.byKey(Key('meal-$date-$slot')));
  await t.pumpAndSettle();
}

String textOf(WidgetTester t, String key) =>
    t.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  group('Bữa ghép mâm (US-3.2 AC6)', () {
    testWidgets(
      'mở từ tab Kế hoạch: ngữ cảnh, tên, thời gian, chip tổng cả mâm',
      (t) async {
        await pumpApp(t);
        await openMeal(t, '2026-11-09', 'lunch');
        expect(textOf(t, 'meal-context'), 'THỨ HAI · BỮA TRƯA');
        expect(
          textOf(t, 'meal-title'),
          'Đậu phụ chiên nước mắm + canh cải thảo trứng + bắp cải xào cà rốt + khoai lang hấp',
        );
        expect(textOf(t, 'meal-minutes'), '57 phút');
        // chip macro đầu trang = tổng cả mâm (591 kcal, gồm tráng miệng)
        final macros = find.byKey(const Key('meal-macros'));
        expect(
          find.descendant(of: macros, matching: find.text('591 kcal')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('calc-link')), findsOneWidget);
      },
    );

    testWidgets(
      'mỗi món là một thẻ (kể cả cơm và tráng miệng); mở công thức riêng',
      (t) async {
        await pumpApp(t);
        await openMeal(t, '2026-11-09', 'lunch');
        expect(
          find.byKey(const Key('dish-lac_rang_nuoc_mam_tofu_chien_mam')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dish-canh_trung_cai_thao')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dish-bap_cai_xao_ca_rot')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dish-dessert_sua_dau_nanh_khong_duong')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dish-khoai_lang_hap')), findsOneWidget);
        await t.tap(find.byKey(const Key('dish-canh_trung_cai_thao')));
        await t.pumpAndSettle();
        expect(textOf(t, 'recipe-title'), 'Canh cải thảo trứng');
        expect(textOf(t, 'recipe-context'), 'THỨ HAI · BỮA TRƯA · CANH');
        expect(find.byKey(const Key('ingredients-card')), findsOneWidget);
        expect(find.byKey(const Key('steps-card')), findsOneWidget);
      },
    );
  });

  group('Bữa một món: nguyên liệu + cách làm + chế độ nấu', () {
    testWidgets('chạm bước để đánh dấu xong và lưu lâu dài', (t) async {
      final store = seeded();
      final c = await pumpApp(t, store: store);
      await openMeal(t, '2026-11-09', 'breakfast');
      expect(textOf(t, 'meal-title'), 'Đậu phụ xào trứng chay');
      expect(find.byKey(const Key('step-0-todo')), findsOneWidget);
      await t.tap(find.byKey(const Key('step-0')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('step-0-done')), findsOneWidget);
      final key = cookKey('2026-11-09', 'breakfast', 'sang_chay_tofu_scramble');
      expect(c.read(cookedStepsProvider)[key], {0});
      // tắt app rồi mở lại: bước vẫn xong
      await t.pumpWidget(const SizedBox());
      await pumpApp(t, store: store);
      await openMeal(t, '2026-11-09', 'breakfast');
      expect(find.byKey(const Key('step-0-done')), findsOneWidget);
      // chạm lần nữa: bỏ đánh dấu
      await t.tap(find.byKey(const Key('step-0')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('step-0-todo')), findsOneWidget);
    });

    testWidgets('wakelock bật khi vào trang công thức, tắt khi rời', (t) async {
      final wake = FakeWakelock();
      await pumpApp(t, wake: wake);
      expect(wake.on, isFalse);
      await openMeal(t, '2026-11-09', 'breakfast');
      expect(wake.on, isTrue);
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
      expect(wake.on, isFalse);
      // trang món trong mâm cũng giữ sáng
      await openMeal(t, '2026-11-09', 'lunch');
      expect(wake.on, isFalse);
      await t.tap(find.byKey(const Key('dish-canh_trung_cai_thao')));
      await t.pumpAndSettle();
      expect(wake.on, isTrue);
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
      expect(wake.on, isFalse);
    });

    testWidgets('1 người: một cột gram; nguyên liệu 0 g bị ẩn', (t) async {
      await pumpApp(t);
      await openMeal(t, '2026-11-09', 'breakfast');
      expect(find.byKey(const Key('col-whole')), findsNothing);
      expect(textOf(t, 'ing-dau_phu-yours'), '150 g');
      expect(find.byKey(const Key('ing-com_trang')), findsNothing);
    });

    testWidgets(
      'hộ 2 người lớn + 1 trẻ em: hai cột, cả nồi = phần bạn + 1 + 0,6 khẩu phần',
      (t) async {
        await pumpApp(t, store: seeded(adults: 2, children: 1));
        await openMeal(t, '2026-11-09', 'breakfast');
        expect(textOf(t, 'col-yours'), 'Phần của bạn');
        expect(textOf(t, 'col-whole'), 'Cả nồi');
        expect(textOf(t, 'ing-dau_phu-yours'), '150 g');
        // 150 + 200 (người lớn) + 0,6 × 200 (trẻ em) = 470
        expect(textOf(t, 'ing-dau_phu-whole'), '470 g');
        // cà chua chuẩn 100 g, không co phần: 100 + 100 + 60 = 260
        expect(textOf(t, 'ing-ca_chua-whole'), '260 g');
      },
    );

    testWidgets('"Không hợp với tôi" chặn món khỏi các tuần sau', (t) async {
      final c = await pumpApp(t);
      await openMeal(t, '2026-11-09', 'breakfast');
      await t.tap(find.byKey(const Key('not-for-me')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('block-only')));
      await t.pump();
      expect(
        c.read(preferencesProvider).blockedRecipeIds,
        contains('sang_chay_tofu_scramble'),
      );
      expect(
        find.textContaining('không chọn món này ở các tuần sau'),
        findsOneWidget,
      );
      await t.pump(const Duration(seconds: 5));
    });
  });

  group('"Cách chúng mình tính" (US-3.3)', () {
    FakeAdapter noDetail() => FakeAdapter();

    testWidgets(
      'mỗi nguyên liệu có gram × giá trị/100 g và nguồn; tổng = chip macro',
      (t) async {
        await pumpApp(t, adapter: noDetail());
        await openMeal(t, '2026-11-09', 'lunch');
        await t.tap(find.byKey(const Key('calc-link')));
        await t.pumpAndSettle();
        expect(find.text('Cách chúng mình tính'), findsWidgets);
        expect(find.text('Đậu hũ (đậu phụ) cứng'), findsOneWidget);
        // 145 g × 144 kcal/100 g = 209 kcal; nguồn truy được
        expect(find.text('145 g × 144 kcal/100 g = 209 kcal'), findsOneWidget);
        expect(find.text('USDA FDC #172475'), findsWidgets);
        // món thêm và tráng miệng: backend đưa cả hai vào trace, từng nguyên liệu có nguồn
        expect(find.text('Món thêm'), findsOneWidget);
        expect(find.text('Tráng miệng'), findsOneWidget);
        expect(find.text('Sữa đậu nành không đường'), findsOneWidget);
        expect(find.text('200 g × 33 kcal/100 g = 66 kcal'), findsOneWidget);
        final total = find.byKey(const Key('calc-total'));
        expect(
          find.descendant(of: total, matching: find.text('591 kcal')),
          findsOneWidget,
        );
      },
    );

    test('tổng trace (đã gồm tráng miệng) khớp chip macro của bữa', () {
      final p = samplePlan();
      for (final day in p.plan.days) {
        for (final m in day.meals) {
          if (!(m.status == 'planned' && m.recipeId != null)) continue;
          final tr = findTrace(p, m.date, m.slot)!;
          // Backend đã cộng tráng miệng vào trace: không cần cộng thêm ở client.
          expect(
            (tr.total.kcal - m.macros.kcal).abs(),
            lessThan(m.macros.kcal * 0.005 + 0.5),
            reason: '${m.date} ${m.slot}',
          );
        }
      }
    });
  });

  group('Dữ liệu hiển thị', () {
    test('parseSteps tách tiêu đề phần và đánh số bước', () {
      final items = parseSteps(['— Canh —', 'Bước một.', 'Bước hai.']);
      expect(items.first.isHeader, isTrue);
      expect(items.first.text, 'Canh');
      expect(items[1].index, 0);
      expect(items[2].index, 1);
    });

    test('formatSource: USDA và bảng TPDD VN', () {
      final l = lookupAppL10n(const Locale('vi'));
      expect(formatSource(l, 'USDA_FDC', '172475'), 'USDA FDC #172475');
      expect(
        formatSource(l, 'VN_TPDD_2007', 'A12'),
        'Bảng TPDD VN 2007 · mã A12',
      );
    });
  });
}
