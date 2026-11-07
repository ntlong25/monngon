import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/features/onboarding/onboarding_providers.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester t, {
  required MemoryStore store,
  FakeAdapter? adapter,
}) async {
  final a =
      adapter ??
      (FakeAdapter()..on('POST', '/v1/targets', fixture('targets.json')));
  await t.pumpWidget(
    ProviderScope(
      overrides: testOverrides(store: store, adapter: a),
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

Future<void> pumpDebounce(WidgetTester t) async {
  await t.pump(const Duration(milliseconds: 500));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Chưa xong onboarding → mở thẳng bước 1 (mục tiêu)', (t) async {
    await pumpApp(t, store: MemoryStore());
    expect(find.text('Bạn muốn đạt mục tiêu nào?'), findsOneWidget);
    expect(find.text('Giảm mỡ'), findsOneWidget);
    expect(find.text('Giữ cân'), findsOneWidget);
    expect(find.text('Tăng cơ'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-back')), findsNothing);
  });

  testWidgets('Chọn mục tiêu rồi Tiếp tục → bước cơ thể; Back giữ lựa chọn', (
    t,
  ) async {
    final c = await pumpApp(t, store: MemoryStore());
    await t.tap(find.text('Tăng cơ'));
    await t.pump();
    expect(c.read(profileProvider).goal, 'build');
    await t.tap(find.text('Tiếp tục'));
    await t.pumpAndSettle();
    expect(find.text('Cho mình biết về cơ thể bạn'), findsOneWidget);
    expect(c.read(onboardingProvider).step, 1);

    await t.tap(find.byKey(const Key('onboarding-back')));
    await t.pumpAndSettle();
    expect(find.text('Bạn muốn đạt mục tiêu nào?'), findsOneWidget);
    // thẻ "Tăng cơ" vẫn được chọn
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(c.read(profileProvider).goal, 'build');
  });

  testWidgets('Tắt app giữa chừng → mở lại đúng bước và đúng lựa chọn', (
    t,
  ) async {
    final store = MemoryStore();
    final c = await pumpApp(t, store: store);
    c
        .read(profileProvider.notifier)
        .update((p) => p.copyWith(weightKg: 77, goal: 'hold'));
    c.read(onboardingProvider.notifier).goTo(2);
    await t.pumpAndSettle();
    expect(find.text('Bạn vận động mỗi tuần thế nào?'), findsOneWidget);

    // "Tắt app": dựng lại toàn bộ cây trên cùng kho
    await t.pumpWidget(const SizedBox());
    await pumpApp(t, store: store);
    expect(find.text('Bạn vận động mỗi tuần thế nào?'), findsOneWidget);
    final c2 = ProviderScope.containerOf(t.element(find.byType(FitProApp)));
    expect(c2.read(profileProvider).weightKg, 77);
    expect(c2.read(profileProvider).goal, 'hold');
  });

  group('Bước cơ thể: kiểm tra khoảng và khóa nút', () {
    Future<void> enter(WidgetTester t, String key, String text) async {
      await t.enterText(find.byKey(Key(key)), text);
      await t.pump();
    }

    bool ctaEnabled(WidgetTester t) {
      final b = t.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Tiếp tục'),
      );
      return b.onPressed != null;
    }

    testWidgets('tuổi 10 → báo lỗi tại chỗ, nút Tiếp tục bị khóa', (t) async {
      await pumpApp(t, store: onboardingAt(1));
      expect(ctaEnabled(t), isTrue);
      await enter(t, 'field-age', '10');
      expect(find.text('Tuổi từ 14 đến 90'), findsOneWidget);
      expect(ctaEnabled(t), isFalse);
      await enter(t, 'field-age', '35');
      expect(find.text('Tuổi từ 14 đến 90'), findsNothing);
      expect(ctaEnabled(t), isTrue);
    });

    testWidgets('chiều cao và cân nặng ngoài khoảng', (t) async {
      await pumpApp(t, store: onboardingAt(1));
      await enter(t, 'field-height', '230');
      expect(find.text('Chiều cao từ 120 đến 220'), findsOneWidget);
      expect(ctaEnabled(t), isFalse);
      await enter(t, 'field-height', '175');
      await enter(t, 'field-weight', '20');
      expect(find.text('Cân nặng từ 30 đến 250'), findsOneWidget);
      expect(ctaEnabled(t), isFalse);
      await enter(t, 'field-weight', '70,5');
      expect(ctaEnabled(t), isTrue);
    });

    testWidgets('ô trống cũng là không hợp lệ', (t) async {
      await pumpApp(t, store: onboardingAt(1));
      await enter(t, 'field-age', '');
      expect(find.text('Tuổi từ 14 đến 90'), findsOneWidget);
      expect(ctaEnabled(t), isFalse);
    });

    testWidgets('biên 14/90 hợp lệ', (t) async {
      await pumpApp(t, store: onboardingAt(1));
      for (final v in ['14', '90']) {
        await enter(t, 'field-age', v);
        expect(find.text('Tuổi từ 14 đến 90'), findsNothing, reason: v);
      }
    });
  });

  group('Màn chỉ tiêu', () {
    testWidgets('lấy kết quả từ POST /v1/targets và hiện từng dòng phép tính', (
      t,
    ) async {
      final adapter = FakeAdapter()
        ..on('POST', '/v1/targets', fixture('targets.json'));
      await pumpApp(t, store: onboardingAt(3), adapter: adapter);
      await pumpDebounce(t);

      expect(find.byKey(const Key('targets-protein')), findsOneWidget);
      expect(find.text('120 g'), findsOneWidget);
      expect(find.text('1.400 kcal'), findsOneWidget);
      // AC5: dải ±5%
      expect(find.text('Calo trong khoảng 1.330–1.470'), findsOneWidget);
      // AC4: từng dòng phép tính
      expect(find.byKey(const Key('calc-steps')), findsOneWidget);
      expect(find.textContaining('BMR'), findsOneWidget);
      expect(find.textContaining('TDEE'), findsOneWidget);
      expect(find.textContaining('hệ số mục tiêu'), findsOneWidget);
      expect(find.textContaining('Trần 35% calo'), findsOneWidget);
      expect(
        adapter.requests.where((r) => r.path == '/v1/targets'),
        hasLength(1),
      );
      expect(adapter.requests.first.method, 'POST');
    });

    testWidgets('gõ liên tục chỉ gọi API một lần (debounce)', (t) async {
      final adapter = FakeAdapter()
        ..on('POST', '/v1/targets', fixture('targets.json'));
      await pumpApp(t, store: onboardingAt(1), adapter: adapter);
      final c = ProviderScope.containerOf(t.element(find.byType(FitProApp)));
      // đang ở bước cơ thể; mở sẵn provider chỉ tiêu như màn kế tiếp
      c.listen(targetsProvider, (_, _) {});
      for (final w in ['70', '71', '72', '73']) {
        c
            .read(profileProvider.notifier)
            .update((p) => p.copyWith(weightKg: double.parse(w)));
        await t.pump(const Duration(milliseconds: 50));
      }
      await pumpDebounce(t);
      expect(
        adapter.requests.where((r) => r.path == '/v1/targets'),
        hasLength(1),
      );
      final body = adapter.requests.last.data as Map<String, dynamic>;
      expect((body['profile'] as Map<String, dynamic>)['weight_kg'], 73);
    });

    testWidgets('chuyển sang Tự nhập: gửi manual_kcal/manual_protein_g', (
      t,
    ) async {
      final adapter = FakeAdapter()
        ..on('POST', '/v1/targets', fixture('targets.json'));
      final c = await pumpApp(t, store: onboardingAt(3), adapter: adapter);
      await pumpDebounce(t);
      await t.tap(find.text('Tự nhập'));
      await pumpDebounce(t);
      expect(find.byKey(const Key('field-manual-kcal')), findsOneWidget);
      // điền sẵn bằng giá trị đang có
      expect(c.read(profileProvider).targetMode, 'manual');
      expect(c.read(profileProvider).manualKcal, 1400);

      await t.enterText(find.byKey(const Key('field-manual-kcal')), '1800');
      await t.enterText(find.byKey(const Key('field-manual-protein')), '140');
      await pumpDebounce(t);
      final body = adapter.requests.last.data as Map<String, dynamic>;
      final prof = body['profile'] as Map<String, dynamic>;
      expect(prof['target_mode'], 'manual');
      expect(prof['manual_kcal'], 1800);
      expect(prof['manual_protein_g'], 140);
    });

    testWidgets(
      'tự nhập ngoài khoảng → lỗi tại chỗ, khóa Tiếp tục, không gọi API',
      (t) async {
        final adapter = FakeAdapter()
          ..on('POST', '/v1/targets', fixture('targets.json'));
        await pumpApp(t, store: onboardingAt(3), adapter: adapter);
        await pumpDebounce(t);
        await t.tap(find.text('Tự nhập'));
        await pumpDebounce(t);
        final before = adapter.requests.length;
        await t.enterText(find.byKey(const Key('field-manual-kcal')), '300');
        await pumpDebounce(t);
        expect(find.text('Calo mỗi ngày từ 800 đến 6000'), findsOneWidget);
        final b = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Tiếp tục'),
        );
        expect(b.onPressed, isNull);
        expect(adapter.requests.length, before);
      },
    );

    testWidgets('mất mạng → báo lỗi thân thiện và Thử lại', (t) async {
      final adapter = FakeAdapter()..failWithConnectionError = true;
      await pumpApp(t, store: onboardingAt(3), adapter: adapter);
      await pumpDebounce(t);
      expect(
        find.text('Không có mạng. Dữ liệu vẫn được giữ trên máy.'),
        findsOneWidget,
      );
      adapter
        ..failWithConnectionError = false
        ..on('POST', '/v1/targets', fixture('targets.json'));
      await t.tap(find.text('Thử lại'));
      await pumpDebounce(t);
      expect(find.text('120 g'), findsOneWidget);
    });

    testWidgets('nút Tiếp tục khóa khi chưa có kết quả', (t) async {
      final adapter = FakeAdapter()..failWithConnectionError = true;
      await pumpApp(t, store: onboardingAt(3), adapter: adapter);
      await pumpDebounce(t);
      final b = t.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Tiếp tục'),
      );
      expect(b.onPressed, isNull);
    });
  });

  testWidgets(
    'Đã xong onboarding → vào thẳng tab Kế hoạch, không thấy wizard',
    (t) async {
      await pumpApp(t, store: completedStore());
      expect(find.text('Bạn muốn đạt mục tiêu nào?'), findsNothing);
      expect(find.text('Đi chợ'), findsOneWidget);
    },
  );
}
