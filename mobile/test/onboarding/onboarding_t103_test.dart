import 'dart:convert';
import 'dart:io';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/features/onboarding/onboarding_nav.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

/// T-103 / D-ONB-06: thẻ vuốt khẩu vị là bước 2 (ngay sau Mục tiêu), lưu bước theo TÊN.
FakeAdapter _api() => FakeAdapter()
  ..on('POST', '/v1/targets', fixture('targets.json'))
  ..on('POST', '/v1/budget-range', fixture('budget_range.json'))
  ..on('POST', '/v1/slots/preview', fixture('slots_preview.json'))
  ..on('POST', '/v1/plans', fixture('plan_response.json'))
  ..on('GET', '/v1/reference', fixture('reference.json'));

Future<ProviderContainer> _pump(
  WidgetTester t,
  MemoryStore store, {
  FakeAdapter? adapter,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 3600);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: testOverrides(store: store, adapter: adapter ?? _api()),
      child: const FitProApp(),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 400));
  }
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

void main() {
  group('Thứ tự bước (D-ONB-06)', () {
    test('14 bước, khẩu vị ngay sau Mục tiêu, Dụng cụ ở cuối trước Tổng kết', () {
      expect(OnboardingStep.values.map((s) => s.name).toList(), [
        'goal',
        'swipe',
        'body',
        'activity',
        'targets',
        'store',
        'household',
        'budget',
        'meals',
        'diet',
        'rice',
        'dislike',
        'equipment',
        'summary',
      ]);
      expect(OnboardingNav.last, OnboardingStep.values.length - 1);
    });
  });

  group('Lưu bước theo tên (US-1.6 AC4)', () {
    // Thứ tự bước của bản cũ (lưu theo số).
    const legacy = [
      'goal',
      'body',
      'activity',
      'targets',
      'store',
      'household',
      'budget',
      'meals',
      'diet',
      'rice',
      'dislike',
      'swipe',
      'equipment',
      'summary',
    ];

    test('trạng thái cũ (chỉ có số) đổi sang đúng bước theo tên ở thứ tự mới', () {
      for (var i = 0; i < legacy.length; i++) {
        final s = OnboardingState.fromJson({'step': i, 'completed': false});
        expect(
          OnboardingStep.values[s.step].name,
          legacy[i],
          reason: 'số cũ $i',
        );
      }
    });

    test('số cũ ngoài khoảng không nhảy sai: quá cuối → Tổng kết, âm → đầu', () {
      expect(
        OnboardingStep.values[OnboardingState.fromJson({'step': 99}).step],
        OnboardingStep.summary,
      );
      expect(OnboardingState.fromJson({'step': -2}).step, 0);
      expect(OnboardingState.fromJson(const {}).step, 0);
    });

    test('định dạng mới có step_name: ưu tiên tên, vòng lưu → đọc giữ nguyên', () {
      for (final step in OnboardingStep.values) {
        final json = const OnboardingState()
            .copyWith(step: step.index)
            .toJson();
        expect(json['step_name'], step.name);
        // tên thắng số (kể cả khi số lệch)
        final read = OnboardingState.fromJson({...json, 'step': 0});
        expect(read.step, step.index, reason: step.name);
      }
    });

    testWidgets(
      'TC-1-51: bản cũ dừng ở Ngân sách (số 6) → mở lại đúng Ngân sách, giữ lựa chọn',
      (t) async {
        final store = onboardingAt(6)
          ..data[StoreKeys.profile] = jsonEncode(
            Defaults.profile.copyWith(goal: 'build', weightKg: 72).toJson(),
          );
        final c = await _pump(t, store);
        expect(c.read(onboardingProvider).step, OnboardingStep.budget.index);
        expect(find.byKey(const Key('onboarding-back')), findsOneWidget);
        expect(c.read(profileProvider).goal, 'build');
        expect(c.read(profileProvider).weightKg, 72);
        // chưa vuốt thẻ nào → quay về bước khẩu vị vẫn có thẻ
        expect(c.read(onboardingProvider).swipedCardIds, isEmpty);
        // đi tiếp một bước thì lưu theo tên
        c.read(onboardingProvider.notifier).goTo(OnboardingStep.meals.index);
        final saved =
            jsonDecode(store.data[StoreKeys.onboarding]!) as Map<String, dynamic>;
        expect(saved['step_name'], 'meals');
      },
    );

    testWidgets('bước Vuốt lưu dở: tắt app → mở lại đúng thẻ vuốt (US-1.6 AC4)', (
      t,
    ) async {
      final store = onboardingAtStep(OnboardingStep.swipe);
      await _pump(t, store);
      expect(find.text('Vuốt để chọn món bạn thích'), findsOneWidget);
      await t.tap(find.byKey(const Key('swipe-like')));
      await t.pumpAndSettle();
      await t.pumpWidget(const SizedBox());
      final c = await _pump(t, store);
      expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);
      expect(find.text('Thẻ 2/14'), findsOneWidget);
    });
  });

  group('Đi hết các bước theo thứ tự', () {
    testWidgets(
      'Tiếp tục từ Mục tiêu qua từng bước đúng thứ tự; Back về đúng bước trước',
      (t) async {
        final c = await _pump(t, MemoryStore());
        // ngân sách chọn sẵn để bước Ngân sách không chặn
        c
            .read(preferencesProvider.notifier)
            .update((p) => p.copyWith(weeklyBudgetVnd: 900000));
        // Vào onboarding: Mục tiêu → Tiếp tục → màn kế là thẻ vuốt (≤ 2 thao tác, AC5)
        expect(c.read(onboardingProvider).step, OnboardingStep.goal.index);
        await t.tap(find.text('Tiếp tục'));
        await t.pumpAndSettle();
        expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);

        final seen = <String>[OnboardingStep.swipe.name];
        for (var i = 0; i < 20; i++) {
          final step = OnboardingStep.values[c.read(onboardingProvider).step];
          if (step == OnboardingStep.summary) break;
          // bước Vuốt dùng nút "Bỏ qua" cũng là đi tiếp; các bước khác dùng nút CTA
          await t.tap(find.widgetWithText(FilledButton, 'Tiếp tục'));
          for (var k = 0; k < 4; k++) {
            await t.pump(const Duration(milliseconds: 400));
          }
          await t.pumpAndSettle();
          seen.add(OnboardingStep.values[c.read(onboardingProvider).step].name);
        }
        expect(seen, [
          'swipe',
          'body',
          'activity',
          'targets',
          'store',
          'household',
          'budget',
          'meals',
          'diet',
          'rice',
          'dislike',
          'equipment',
          'summary',
        ]);

        // Back từ Tổng kết về Dụng cụ … về Khẩu vị … về Mục tiêu
        for (final expected in seen.reversed.skip(1).toList()) {
          await t.tap(find.byKey(const Key('onboarding-back')));
          await t.pumpAndSettle();
          expect(
            OnboardingStep.values[c.read(onboardingProvider).step].name,
            expected,
          );
        }
        await t.tap(find.byKey(const Key('onboarding-back')));
        await t.pumpAndSettle();
        expect(c.read(onboardingProvider).step, OnboardingStep.goal.index);
        expect(find.byKey(const Key('onboarding-back')), findsNothing);
      },
    );
  });

  group('Thẻ cửa hàng (L-16, D-DATA-01)', () {
    testWidgets(
      'cửa hàng chưa khảo sát giá ghi "Giá ước lượng, chưa khảo sát tại cửa hàng này"; cửa hàng có ngày ghi ngày khảo sát',
      (t) async {
        final reference =
            jsonDecode(File('test/fixtures/reference.json').readAsStringSync())
                as Map<String, dynamic>;
        await _pump(
          t,
          onboardingAtStep(OnboardingStep.store),
          adapter: _api()..on('GET', '/v1/reference', reference),
        );
        // WinMart và Co.opmart: price_survey_date = null
        expect(
          find.text('Giá ước lượng, chưa khảo sát tại cửa hàng này'),
          findsNWidgets(2),
        );
        expect(find.textContaining('06/11/2026'), findsNWidgets(2));
        // không ẩn cửa hàng
        expect(find.text('WinMart'), findsOneWidget);
        expect(find.text('Co.opmart'), findsOneWidget);
      },
    );
  });

  group('Bỏ qua thẻ vuốt (D-ONB-06 ý 3)', () {
    testWidgets(
      'TC-1-49: "Bỏ qua" → sang bước Cơ thể, không có khẩu vị; tổng kết ghi "Khẩu vị: chưa chọn"',
      (t) async {
        final c = await _pump(t, onboardingAtStep(OnboardingStep.swipe));
        expect(find.text('Bỏ qua'), findsOneWidget);
        // vuốt dở một thẻ rồi bỏ qua: xóa sạch lựa chọn đã có
        await t.tap(find.byKey(const Key('swipe-like')));
        await t.pumpAndSettle();
        expect(c.read(preferencesProvider).cuisineLikes, isNotEmpty);
        await t.tap(find.text('Bỏ qua'));
        await t.pumpAndSettle();
        expect(c.read(onboardingProvider).step, OnboardingStep.body.index);
        final prefs = c.read(preferencesProvider);
        expect(prefs.cuisineLikes, isEmpty);
        expect(prefs.cuisineLess, isEmpty);
        expect(c.read(onboardingProvider).swipedCardIds, isEmpty);

        c.read(onboardingProvider.notifier).goTo(OnboardingStep.summary.index);
        await t.pumpAndSettle();
        expect(
          t.widget<Text>(find.byKey(const Key('summary-taste-value'))).data,
          'Khẩu vị: chưa chọn',
        );
        // bấm Sửa quay lại bước khẩu vị
        await t.tap(find.byKey(const Key('summary-taste-edit')));
        await t.pumpAndSettle();
        expect(c.read(onboardingProvider).step, OnboardingStep.swipe.index);
        expect(find.byKey(const Key('swipe-card-card_01')), findsOneWidget);
      },
    );

    testWidgets('đã vuốt hết thẻ thì không còn nút "Bỏ qua" (giữ kết quả)', (
      t,
    ) async {
      await _pump(t, onboardingAtStep(OnboardingStep.swipe));
      for (var i = 0; i < 14; i++) {
        await t.tap(find.byKey(const Key('swipe-like')));
        await t.pumpAndSettle();
      }
      expect(find.text('Khẩu vị của bạn'), findsOneWidget);
      expect(find.text('Bỏ qua'), findsNothing);
    });

    testWidgets('tổng kết hiện các khẩu vị đã thích', (t) async {
      final c = await _pump(t, onboardingAtStep(OnboardingStep.summary));
      c
          .read(preferencesProvider.notifier)
          .update((p) => p.copyWith(cuisineLikes: ['xao']));
      await t.pumpAndSettle();
      expect(
        t.widget<Text>(find.byKey(const Key('summary-taste-value'))).data,
        'Xào nhanh',
      );
    });
  });
}
