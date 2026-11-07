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

FakeAdapter _api() => FakeAdapter()
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
    testWidgets('đặt sau bước kiểu ăn; Vừa chọn sẵn và ghi gram từng lựa chọn', (
      t,
    ) async {
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
    });

    testWidgets(
      'chọn mức rất nhiều → cảnh báo (không chặn Tiếp tục); chọn lại mức ít thì hết cảnh báo',
      (t) async {
        final c = await _pumpAt(t, _rice);
        await t.tap(find.byKey(const Key('rice-rat_nhieu')));
        await _settle(t);
        expect(c.read(preferencesProvider).riceHabit, 'rat_nhieu');
        expect(find.byKey(const Key('rice-warning')), findsOneWidget);
        expect(
          find.textContaining('một số bữa sẽ phải bớt cơm'),
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
        expect(
          _text(t, 'summary-rice-value'),
          'Ít tinh bột: mâm không có cơm',
        );
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

    test('cảnh báo khi cơm > 45% kcal bữa chính (≈ 1/3 chỉ tiêu ngày)', () {
      expect(RiceHabit.exceedsMainMealShare(RiceHabit.vua, 1400), isFalse);
      expect(RiceHabit.exceedsMainMealShare(RiceHabit.nhieu, 1400), isTrue);
      expect(RiceHabit.exceedsMainMealShare(RiceHabit.nhieu, 2800), isFalse);
      expect(RiceHabit.exceedsMainMealShare(RiceHabit.ratNhieu, 2800), isTrue);
      expect(RiceHabit.exceedsMainMealShare(RiceHabit.it, 0), isFalse);
    });
  });

  group('Thẻ cơm trên màn mâm', () {
    Future<void> pumpCard(
      WidgetTester t,
      RiceInfo rice,
      List<MealNote>? notes,
    ) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: testOverrides(adapter: _api()),
          child: MaterialApp(
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            locale: const Locale('vi'),
            home: Scaffold(body: RiceCard(rice: rice, notes: notes)),
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

    testWidgets('100 g hiện "⅔ chén cơm (~100 g)", không còn "0,5 chén"', (t) async {
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
          find.text(
            'Bữa này bớt còn 1 chén cơm để giữ đúng calo.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
