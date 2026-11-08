import 'dart:convert';

import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/rice.dart';
import 'package:fitpro_mamdu/features/meal/rice_card.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

Map<String, Object?> _item(
  String habit,
  double targetG, {
  required double feasibleCups,
  String? reason,
  int? withFull,
  int? budget,
  int? needed,
}) => {
  'habit': habit,
  'target_g': targetG,
  'target_cups': targetG / 150,
  'feasible_g': feasibleCups * 150,
  'feasible_cups': feasibleCups,
  'feasible': reason == null,
  'reason': ?reason,
  if (withFull != null) ...{
    'meals_planned': 14,
    'meals_with_full_rice': withFull,
    'meals_with_rice': withFull,
  },
  'budget_vnd': ?budget,
  'budget_needed_vnd': ?needed,
};

/// Phản hồi `/v1/rice/feasibility`: không có `preferences` → bản nhanh (kcal/đạm); có → bản có ngân sách.
Map<String, Object?> _feasibility({required bool full, int? needed = 806000}) =>
    {
      'targets': {
        'mode': 'lose',
        'kcal_target': 1400,
        'kcal_min': 1330,
        'kcal_max': 1470,
        'protein_g': 120,
      },
      'habits': [
        _item('it', 75, feasibleCups: 0.5),
        _item('vua', 150, feasibleCups: 1),
        _item('nhieu', 300, feasibleCups: 1.5, reason: 'kcal_protein'),
        if (full)
          _item(
            'rat_nhieu',
            450,
            feasibleCups: 1.5,
            reason: 'budget',
            withFull: 4,
            budget: 600000,
            needed: needed,
          )
        else
          _item('rat_nhieu', 450, feasibleCups: 1.5, reason: 'kcal_protein'),
      ],
    };

FakeAdapter _api({bool withBudget = true, int? needed = 806000}) =>
    FakeAdapter()
      ..onRequest('POST', '/v1/rice/feasibility', (o) {
        final hasPrefs = (o.data as Map)['preferences'] != null;
        return _feasibility(full: hasPrefs && withBudget, needed: needed);
      })
      ..on('POST', '/v1/targets', fixture('targets.json'))
      ..on('POST', '/v1/budget-range', fixture('budget_range.json'))
      ..on('POST', '/v1/slots/preview', fixture('slots_preview.json'))
      ..on('POST', '/v1/plans', fixture('plan_response.json'))
      ..on('GET', '/v1/reference', fixture('reference.json'));

const _diet = 8;
const _rice = 9;
const _dislike = 10;
const _summary = 13;

Future<ProviderContainer> _pumpAt(WidgetTester t, int step) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 3600);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: testOverrides(store: onboardingAt(step), adapter: _api()),
      child: const FitProApp(),
    ),
  );
  await _settle(t);
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 400));
  }
  await t.pumpAndSettle();
}

String _text(WidgetTester t, String key) =>
    t.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  group('Thói quen ăn cơm (T-095, US-1.4b)', () {
    testWidgets(
      'đặt sau bước kiểu ăn; Vừa chọn sẵn và ghi gram từng lựa chọn',
      (t) async {
        final c = await _pumpAt(t, _diet);
        await t.tap(find.text('Tiếp tục'));
        await _settle(t);
        expect(c.read(onboardingProvider).step, _rice);
        expect(find.text('Thói quen ăn cơm'), findsOneWidget);
        expect(
          find.text('Mỗi bữa trưa/tối bạn thường ăn mấy chén cơm?'),
          findsOneWidget,
        );
        expect(find.text('½ chén (~75 g)'), findsOneWidget);
        expect(find.text('1 chén (~150 g)'), findsOneWidget);
        expect(find.text('2 chén (~300 g)'), findsOneWidget);
        expect(find.text('3 chén trở lên (~450 g)'), findsOneWidget);
        expect(c.read(preferencesProvider).riceHabit, 'vua');
        expect(find.byKey(const Key('rice-note')), findsOneWidget);
        // Vừa với chỉ tiêu 1.400 kcal: không cảnh báo.
        expect(find.byKey(const Key('rice-warning')), findsNothing);
      },
    );

    testWidgets(
      'chọn mức rất nhiều → cảnh báo (không chặn Tiếp tục); chọn lại mức ít thì hết cảnh báo',
      (t) async {
        final c = await _pumpAt(t, _rice);
        await t.tap(find.byKey(const Key('rice-rat_nhieu')));
        await _settle(t);
        expect(c.read(preferencesProvider).riceHabit, 'rat_nhieu');
        expect(find.byKey(const Key('rice-warning')), findsOneWidget);
        // Bản có ngân sách đã về → câu ngân sách của PM (D-COM-05) kèm số do server trả.
        expect(
          find.text(
            'Với ngân sách 600.000 ₫, khoảng 4/14 bữa có đủ 3 chén cơm; cần khoảng 806.000 ₫ để bữa nào cũng đủ.',
          ),
          findsOneWidget,
        );
        final cta = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Tiếp tục'),
        );
        expect(cta.onPressed, isNotNull);
        await t.tap(find.text('Tiếp tục'));
        await _settle(t);
        expect(c.read(onboardingProvider).step, _dislike);

        await t.tap(find.byKey(const Key('onboarding-back')));
        await _settle(t);
        await t.tap(find.byKey(const Key('rice-it')));
        await _settle(t);
        expect(c.read(preferencesProvider).riceHabit, 'it');
        expect(find.byKey(const Key('rice-warning')), findsNothing);
      },
    );

    testWidgets(
      'mức Vừa/Ít khả thi (số chén khả thi ≥ mức chọn) → không có cảnh báo',
      (t) async {
        final c = await _pumpAt(t, _rice);
        await t.tap(find.byKey(const Key('rice-it')));
        await _settle(t);
        expect(find.byKey(const Key('rice-warning')), findsNothing);
        await t.tap(find.byKey(const Key('rice-vua')));
        await _settle(t);
        expect(c.read(preferencesProvider).riceHabit, 'vua');
        expect(find.byKey(const Key('rice-warning')), findsNothing);
      },
    );

    testWidgets(
      'thiếu kcal/đạm: câu cảnh báo kèm số chén khả thi do server trả (D-COM-04)',
      (t) async {
        // Không có bản ngân sách (lỗi/chưa về) → dùng bản nhanh kcal/đạm.
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = const Size(800, 3600);
        addTearDown(t.view.reset);
        await t.pumpWidget(
          ProviderScope(
            overrides: testOverrides(
              store: onboardingAt(_rice),
              adapter: _api(withBudget: false),
            ),
            child: const FitProApp(),
          ),
        );
        await _settle(t);
        await t.tap(find.byKey(const Key('rice-nhieu')));
        await _settle(t);
        expect(
          find.text(
            'Với 1.400 kcal và 120 g đạm, mỗi bữa bạn ăn được khoảng 1½ chén mà vẫn đủ đạm. Bạn vẫn có thể giữ 2 chén; app sẽ bớt cơm ở bữa cần bớt và ghi chú.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('ngân sách'), findsNothing);
      },
    );

    testWidgets(
      'lý do ngân sách nhưng server chưa tính được số tiền cần → câu ngắn, không bịa số',
      (t) async {
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = const Size(800, 3600);
        addTearDown(t.view.reset);
        await t.pumpWidget(
          ProviderScope(
            overrides: testOverrides(
              store: onboardingAt(_rice),
              adapter: _api(needed: null),
            ),
            child: const FitProApp(),
          ),
        );
        await _settle(t);
        await t.tap(find.byKey(const Key('rice-rat_nhieu')));
        await _settle(t);
        expect(
          find.text(
            'Với ngân sách 600.000 ₫, khoảng 4/14 bữa có đủ 3 chén cơm.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('bật "Ít tinh bột" → bỏ qua bước cơm cả khi tiến lẫn lùi', (
      t,
    ) async {
      final c = await _pumpAt(t, _diet);
      c
          .read(preferencesProvider.notifier)
          .update((p) => p.copyWith(lowCarb: true));
      await _settle(t);
      await t.tap(find.text('Tiếp tục'));
      await _settle(t);
      expect(c.read(onboardingProvider).step, _dislike);
      await t.tap(find.byKey(const Key('onboarding-back')));
      await _settle(t);
      expect(c.read(onboardingProvider).step, _diet);
    });

    testWidgets(
      'màn tổng kết hiện mức cơm; Ít tinh bột thì ghi "mâm không có cơm"',
      (t) async {
        final c = await _pumpAt(t, _summary);
        expect(_text(t, 'summary-rice-value'), '1 chén (~150 g)');
        c
            .read(preferencesProvider.notifier)
            .update((p) => p.copyWith(lowCarb: true, riceHabit: 'nhieu'));
        await _settle(t);
        expect(_text(t, 'summary-rice-value'), 'Ít tinh bột: mâm không có cơm');
      },
    );

    testWidgets('bấm Sửa ở tổng kết nhảy tới đúng bước cơm', (t) async {
      final c = await _pumpAt(t, _summary);
      final edit = find.byKey(const Key('summary-rice-edit'));
      await t.ensureVisible(edit);
      await t.tap(edit);
      await _settle(t);
      expect(c.read(onboardingProvider).step, _rice);
    });

    test('dữ liệu lưu từ bản cũ (rice_habit rỗng) được hiểu là Vừa', () {
      final store = onboardingAt(_rice);
      store.data[StoreKeys.preferences] = jsonEncode(
        const Preferences(storeId: 'bach_hoa_xanh', diet: 'none').toJson(),
      );
      final c = container(store, adapter: _api());
      addTearDown(c.dispose);
      expect(c.read(preferencesProvider).riceHabit, 'vua');
    });
  });

  group('RiceHabit', () {
    test('gram từng mức theo PRD và giá trị lạ = Vừa', () {
      expect(RiceHabit.values.map((h) => h.grams), [75, 150, 300, 450]);
      expect(RiceHabit.values.map((h) => h.id), [
        'it',
        'vua',
        'nhieu',
        'rat_nhieu',
      ]);
      expect(RiceHabit.parse(''), RiceHabit.vua);
      expect(RiceHabit.parse('xyz'), RiceHabit.vua);
      expect(RiceHabit.parse('nhieu'), RiceHabit.nhieu);
    });

    test('halfCups: số chén khả thi làm tròn xuống ½ chén', () {
      expect(RiceHabit.halfCups(0), '0');
      expect(RiceHabit.halfCups(0.5), '½');
      expect(RiceHabit.halfCups(1), '1');
      expect(RiceHabit.halfCups(1.5), '1½');
      expect(RiceHabit.halfCups(2.9), '2½');
    });

    test('riceWarningFor: chỉ cảnh báo khi mức chọn không khả thi; ưu tiên bản có ngân sách', () {
      final quick = RiceFeasibilityResponse.fromJson(_feasibility(full: false));
      final full = RiceFeasibilityResponse.fromJson(_feasibility(full: true));
      expect(riceWarningFor(RiceHabit.vua, quick, full), isNull);
      expect(riceWarningFor(RiceHabit.it, quick, null), isNull);
      expect(riceWarningFor(RiceHabit.vua, null, null), isNull);
      expect(riceWarningFor(RiceHabit.nhieu, quick, null)!.isBudget, isFalse);
      final w = riceWarningFor(RiceHabit.ratNhieu, quick, full)!;
      expect(w.isBudget, isTrue);
      expect(w.item.budgetNeededVnd, 806000);
      expect(
        riceWarningFor(RiceHabit.ratNhieu, quick, null)!.isBudget,
        isFalse,
      );
    });
  });

  group('Thẻ cơm trên màn mâm', () {
    Future<void> pumpCard(
      WidgetTester t,
      RiceInfo rice,
      List<MealNote>? notes, {
      String? dishName,
    }) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: testOverrides(adapter: _api()),
          child: MaterialApp(
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            locale: const Locale('vi'),
            home: Scaffold(
              body: RiceCard(rice: rice, notes: notes, dishName: dishName),
            ),
          ),
        ),
      );
      await _settle(t);
    }

    test('số chén làm tròn khớp với gram hiển thị kèm (⅓, ½, ⅔, nguyên)', () {
      expect(RiceCard.cups(75), '½');
      expect(RiceCard.cups(100), '⅔');
      expect(RiceCard.cups(150), '1');
      expect(RiceCard.cups(175), '1');
      expect(RiceCard.cups(200), '1⅓');
      expect(RiceCard.cups(225), '1½');
      expect(RiceCard.cups(300), '2');
      expect(RiceCard.cups(450), '3');
      expect(RiceCard.cups(50), '⅓');
      expect(RiceCard.cups(20), '⅓');
    });

    testWidgets('100 g hiện "⅔ chén cơm (~100 g)", không còn "0,5 chén"', (
      t,
    ) async {
      await pumpCard(
        t,
        const RiceInfo(habit: 'vua', targetG: 150, actualG: 100),
        null,
      );
      expect(find.text('⅔ chén cơm (~100 g)'), findsOneWidget);
    });

    testWidgets('đủ cơm: hiện số chén và gram thực tế, không có ghi chú', (
      t,
    ) async {
      await pumpCard(
        t,
        const RiceInfo(habit: 'vua', targetG: 150, actualG: 150),
        null,
      );
      expect(find.text('1 chén cơm (~150 g)'), findsOneWidget);
      expect(find.byKey(const Key('rice-reduced-note')), findsNothing);
    });

    testWidgets('cơm: gọi đúng tên món — "Cơm gạo lứt · 1 chén (150 g)"', (
      t,
    ) async {
      await pumpCard(
        t,
        const RiceInfo(
          habit: 'vua',
          targetG: 150,
          actualG: 150,
          kind: 'com',
          riceEquivG: 150,
        ),
        null,
        dishName: 'Cơm gạo lứt',
      );
      expect(find.text('Cơm gạo lứt · 1 chén (150 g)'), findsOneWidget);
    });

    testWidgets(
      'khoai lang: "Khoai lang hấp · ~115 g (thay ½ chén cơm)", chén lấy từ rice_equiv_g',
      (t) async {
        await pumpCard(
          t,
          const RiceInfo(
            habit: 'it',
            targetG: 75,
            actualG: 115,
            kind: 'other',
            riceEquivG: 75,
          ),
          null,
          dishName: 'Khoai lang hấp',
        );
        expect(
          find.text('Khoai lang hấp · ~115 g (thay ½ chén cơm)'),
          findsOneWidget,
        );
        // Nhãn chính là tên món, không phải "chén cơm".
        final main = t.widget<Text>(find.byKey(const Key('rice-amount'))).data!;
        expect(main.startsWith('Khoai lang hấp'), isTrue);
        expect(find.text('½ chén cơm (~115 g)'), findsNothing);
      },
    );

    testWidgets('bún: "Bún tươi · ~180 g (thay 1 chén cơm)"', (t) async {
      await pumpCard(
        t,
        const RiceInfo(
          habit: 'vua',
          targetG: 150,
          actualG: 180,
          kind: 'other',
          riceEquivG: 150,
        ),
        null,
        dishName: 'Bún tươi',
      );
      expect(find.text('Bún tươi · ~180 g (thay 1 chén cơm)'), findsOneWidget);
    });

    testWidgets('khoai bị bớt: ghi chú cùng dạng, gọi tên món viết thường', (
      t,
    ) async {
      await pumpCard(
        t,
        const RiceInfo(
          habit: 'vua',
          targetG: 150,
          actualG: 115,
          kind: 'other',
          riceEquivG: 75,
        ),
        const [
          MealNote(
            code: 'rice_reduced',
            targetG: 230,
            actualG: 90,
            reason: 'kcal',
          ),
        ],
        dishName: 'Khoai lang hấp',
      );
      expect(
        find.text(
          'Bữa này bớt còn ~90 g khoai lang hấp (thay ⅓ chén cơm) để giữ đúng calo.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'cơm bị bớt: ghi chú rice_reduced nói theo chén (làm tròn ½ chén)',
      (t) async {
        await pumpCard(
          t,
          const RiceInfo(habit: 'nhieu', targetG: 300, actualG: 175),
          const [
            MealNote(
              code: 'rice_reduced',
              targetG: 300,
              actualG: 175,
              reason: 'kcal',
            ),
          ],
        );
        expect(find.byKey(const Key('rice-reduced-note')), findsOneWidget);
        expect(
          find.text('Bữa này bớt còn 1 chén cơm để giữ đúng calo.'),
          findsOneWidget,
        );
      },
    );
  });
}
