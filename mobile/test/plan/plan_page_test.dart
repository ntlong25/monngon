import 'dart:convert';

import 'package:fitpro_mamdu/features/meal/meal_data.dart';
import 'package:fitpro_mamdu/features/plan/plan_page.dart';
import 'package:fitpro_mamdu/features/plan/plan_view.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:fitpro_mamdu/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

Map<String, dynamic> planJson() => fixture('plan_response.json');

MemoryStore storeWith(Map<String, dynamic>? plan) => MemoryStore({
  StoreKeys.schemaVersion: '$kStorageSchemaVersion',
  if (plan != null) StoreKeys.currentPlan: jsonEncode(plan),
});

Future<void> pumpPlan(
  WidgetTester t,
  MemoryStore store, {
  DateTime? now,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 9000);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: testOverrides(store: store),
      child: MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: PlanPage(now: now ?? DateTime(2026, 11, 8, 9)),
      ),
    ),
  );
  await t.pumpAndSettle();
}

String textOf(WidgetTester t, String key) =>
    t.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  testWidgets('lời chào theo giờ và trạng thái "bắt đầu từ ngày mai"', (
    t,
  ) async {
    await pumpPlan(t, storeWith(planJson()), now: DateTime(2026, 11, 8, 9));
    expect(textOf(t, 'plan-greeting'), 'Chào buổi sáng');
    expect(textOf(t, 'plan-status'), 'Tuần của bạn bắt đầu từ ngày mai');
    expect(find.byKey(const Key('plan-today-chip')), findsNothing);
  });

  testWidgets('giữa tuần: "Hôm nay là ngày 3", chip Hôm nay, chào buổi chiều', (
    t,
  ) async {
    await pumpPlan(t, storeWith(planJson()), now: DateTime(2026, 11, 11, 14));
    expect(textOf(t, 'plan-greeting'), 'Chào buổi chiều');
    expect(textOf(t, 'plan-status'), 'Hôm nay là ngày 3');
    expect(find.byKey(const Key('plan-today-chip')), findsOneWidget);
  });

  testWidgets('7 ngày: tiêu đề "Thứ Hai · 09/11" và tổng protein/kcal', (
    t,
  ) async {
    await pumpPlan(t, storeWith(planJson()));
    expect(find.byKey(const Key('plan-list')), findsOneWidget);
    for (var i = 9; i <= 15; i++) {
      expect(
        find.byKey(Key('day-2026-11-$i'.replaceAll('-9', '-09'))),
        findsOneWidget,
      );
    }
    expect(textOf(t, 'day-heading-2026-11-09'), 'Thứ Hai · 09/11');
    expect(textOf(t, 'day-heading-2026-11-15'), 'Chủ nhật · 15/11');
    expect(textOf(t, 'day-totals-2026-11-09'), '123 g protein · 1.432 kcal');
  });

  testWidgets('bữa ghép mâm hiện tên các món nối bằng " + "', (t) async {
    await pumpPlan(t, storeWith(planJson()));
    expect(
      textOf(t, 'meal-title-2026-11-09-lunch'),
      'Đậu phụ chiên nước mắm + canh cải thảo trứng + bắp cải xào cà rốt + khoai lang hấp',
    );
    expect(find.text('Tráng miệng: Sữa đậu nành không đường'), findsWidgets);
    // món đơn
    expect(
      textOf(t, 'meal-title-2026-11-09-breakfast'),
      'Đậu phụ xào trứng chay',
    );
  });

  testWidgets('mỗi bữa có nhãn bữa + thời gian nấu và chip protein/kcal', (
    t,
  ) async {
    await pumpPlan(t, storeWith(planJson()));
    final tile = find.byKey(const Key('meal-2026-11-09-lunch'));
    expect(
      find.descendant(
        of: tile,
        matching: find.textContaining('BỮA TRƯA · 57 PHÚT'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tile, matching: find.text('Protein')),
      findsOneWidget,
    );
  });

  testWidgets('món nấu 1 lần cho nhiều bữa có nhãn "Nấu 1 lần cho 2 bữa"', (
    t,
  ) async {
    await pumpPlan(t, storeWith(planJson()));
    expect(find.byKey(const Key('batch-2026-11-09-snack_pm')), findsOneWidget);
    expect(find.byKey(const Key('batch-2026-11-10-snack_pm')), findsOneWidget);
    expect(find.byKey(const Key('batch-2026-11-11-snack_pm')), findsNothing);
    expect(find.text('Nấu 1 lần cho 2 bữa'), findsWidgets);
  });

  testWidgets('bữa tự lo / ăn ngoài hiện dạng dòng mờ, không có món', (
    t,
  ) async {
    final j = planJson();
    final days = (j['plan'] as Map<String, dynamic>)['days'] as List<dynamic>;
    final meals = (days[0] as Map<String, dynamic>)['meals'] as List<dynamic>;
    for (final m in meals.cast<Map<String, dynamic>>()) {
      if (m['slot'] == 'breakfast') {
        m['status'] = 'self';
        m['recipe_id'] = null;
        m['dishes'] = null;
      }
      if (m['slot'] == 'snack_pm') {
        m['status'] = 'skip';
        m['recipe_id'] = null;
        m['dishes'] = null;
      }
    }
    await pumpPlan(t, storeWith(j));
    expect(
      find.byKey(const Key('meal-title-2026-11-09-breakfast')),
      findsNothing,
    );
    expect(find.text('Tôi tự lo'), findsOneWidget);
    expect(find.text('Ăn ngoài'), findsOneWidget);
  });

  testWidgets('banner đạt: mọi ngày đạt protein và calo', (t) async {
    await pumpPlan(t, storeWith(planJson()));
    expect(
      t
          .widget<Text>(
            find
                .descendant(
                  of: find.byKey(const Key('plan-banner')),
                  matching: find.byType(Text),
                )
                .first,
          )
          .data,
      'Mọi ngày đều đạt protein và calo.',
    );
  });

  testWidgets('banner partial nêu đúng ngày và mức thiếu', (t) async {
    final j = planJson();
    final plan = j['plan'] as Map<String, dynamic>;
    plan['status'] = 'partial';
    final v = plan['validation'] as Map<String, dynamic>;
    v['ok'] = false;
    v['shortfalls'] = [
      {'date': '2026-11-12', 'kind': 'protein_low', 'amount': 8.0},
    ];
    for (final d in (v['days'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      if (d['date'] == '2026-11-12') {
        d['ok'] = false;
        d['protein_short_g'] = 8.0;
      }
    }
    await pumpPlan(t, storeWith(j));
    expect(
      find.descendant(
        of: find.byKey(const Key('plan-banner')),
        matching: find.text('Có 1 ngày chưa đạt. Thứ Năm thiếu 8 g protein'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('chưa có tuần → trạng thái rỗng có nút Thiết lập ngay', (
    t,
  ) async {
    await pumpPlan(t, storeWith(null));
    expect(find.text('Chưa có thực đơn'), findsOneWidget);
    expect(find.text('Thiết lập ngay'), findsOneWidget);
  });

  group('hàm hiển thị thuần', () {
    test('tên mâm bỏ hậu tố món chính, giữ ghi chú (chay)', () {
      final p = samplePlan();
      var kept = 0;
      for (final day in p.plan.days) {
        for (final meal in day.meals.where((m) => isMam(m))) {
          final title = mealTitle(meal, p.recipes);
          expect(title, isNot(contains('món chính')));
          // ghi chú khác "(món chính)" như "(mang đi)", "(chay)" được giữ nguyên
          for (final d in meal.dishes!.where(
            (d) =>
                d.role != 'dessert' &&
                d.role != 'extra' &&
                d.grams.any((g) => g.grams >= 1),
          )) {
            final note = RegExp(r'\(([^)]*)\)').firstMatch(d.name)?.group(0);
            if (note != null && note != '(món chính)') {
              kept++;
              expect(title, contains(note));
            }
          }
        }
      }
      expect(kept, greaterThan(0));
    });
  });
}
