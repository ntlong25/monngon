import 'dart:convert';

import 'package:fitpro_mamdu/api/generated/api_client.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

/// Đợi các lệnh ghi bất đồng bộ (không await) hoàn tất.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late MemoryStore store;
  late ProviderContainer c;

  setUp(() {
    store = MemoryStore();
    c = container(store);
    addTearDown(() => c.dispose());
  });

  /// Mô phỏng tắt app rồi mở lại: container mới trên cùng kho.
  ProviderContainer restart() {
    final n = container(store);
    addTearDown(n.dispose);
    return n;
  }

  group('Giữ nguyên trạng thái sau khi mở lại', () {
    test('mặc định khi chưa có gì', () {
      expect(c.read(onboardingProvider).step, 0);
      expect(c.read(onboardingProvider).completed, isFalse);
      expect(c.read(profileProvider).goal, 'lose');
      expect(c.read(preferencesProvider).storeId, 'bach_hoa_xanh');
      expect(c.read(currentPlanProvider), isNull);
      expect(c.read(savedPlansProvider), isEmpty);
      expect(c.read(swapCountProvider), 0);
    });

    test('onboarding: bước hiện tại và thẻ đã vuốt', () async {
      c.read(onboardingProvider.notifier)
        ..goTo(4)
        ..markSwiped('card_01')
        ..markSwiped('card_01')
        ..markSwiped('card_02');
      await settle();
      final s = restart().read(onboardingProvider);
      expect(s.step, 4);
      expect(s.swipedCardIds, ['card_01', 'card_02']);
      expect(s.completed, isFalse);
    });

    test('goTo không cho bước âm', () {
      c.read(onboardingProvider.notifier).goTo(-3);
      expect(c.read(onboardingProvider).step, 0);
    });

    test('hồ sơ và lựa chọn', () async {
      c
          .read(profileProvider.notifier)
          .update((p) => p.copyWith(age: 41, goal: 'build', weightKg: 80.5));
      c
          .read(preferencesProvider.notifier)
          .update(
            (p) => p.copyWith(
              adults: 3,
              weeklyBudgetVnd: 900000,
              exclusions: ['no_pork'],
              equipment: ['bep', 'lo_vi_song'],
            ),
          );
      await settle();
      final r = restart();
      expect(r.read(profileProvider).age, 41);
      expect(r.read(profileProvider).goal, 'build');
      expect(r.read(profileProvider).weightKg, 80.5);
      final p = r.read(preferencesProvider);
      expect(p.adults, 3);
      expect(p.weeklyBudgetVnd, 900000);
      expect(p.exclusions, ['no_pork']);
      expect(p.equipment, ['bep', 'lo_vi_song']);
      expect(p.slots.lunch, 'on'); // đối tượng lồng nhau cũng giữ
    });

    test(
      'tuần hiện tại (kèm công thức + nguyên liệu để xem offline)',
      () async {
        final plan = samplePlan();
        c.read(currentPlanProvider.notifier).set(plan);
        await settle();
        final back = restart().read(currentPlanProvider)!;
        expect(jsonEncode(back.toJson()), jsonEncode(plan.toJson()));
        expect(back.recipes, isNotEmpty);
        expect(back.plan.shopping.items, isNotEmpty);
      },
    );

    test('đi chợ: đã mua và nhà có sẵn', () async {
      c.read(shoppingStateProvider.notifier)
        ..setBought('trung_ga', bought: true)
        ..setBought('hanh_la', bought: true)
        ..setBought('hanh_la', bought: false)
        ..setPantry('nuoc_mam', have: false)
        ..setPantry('gao', have: true);
      await settle();
      final s = restart().read(shoppingStateProvider);
      expect(s.bought, {'trung_ga'});
      expect(s.pantryHave('nuoc_mam', defaultPantry: true), isFalse);
      expect(s.pantryHave('gao', defaultPantry: false), isTrue);
      // chưa chọn → theo gợi ý mặc định
      expect(s.pantryHave('tieu', defaultPantry: true), isTrue);
      expect(s.pantryHave('tieu', defaultPantry: false), isFalse);
    });

    test('bước nấu đã xong theo từng bữa/món', () async {
      final k = cookKey('2026-11-09', 'lunch', 'ca_kho');
      c.read(cookedStepsProvider.notifier)
        ..toggle(k, 0)
        ..toggle(k, 2)
        ..toggle(k, 0)
        ..toggle(cookKey('2026-11-09', 'dinner', 'x'), 1)
        ..toggle(cookKey('2026-11-09', 'dinner', 'x'), 1);
      await settle();
      final m = restart().read(cookedStepsProvider);
      expect(m[k], {2});
      expect(m.length, 1); // khóa rỗng bị bỏ
    });

    test('đếm số lần đổi món', () async {
      c.read(swapCountProvider.notifier)
        ..increment()
        ..increment();
      await settle();
      expect(restart().read(swapCountProvider), 2);
    });
  });

  group('Dữ liệu hỏng không làm app lỗi', () {
    test('JSON hỏng hoặc sai dạng → dùng giá trị mặc định', () {
      store = MemoryStore({
        StoreKeys.profile: 'không phải json',
        StoreKeys.preferences: '[1,2,3]',
        StoreKeys.currentPlan: '{"plan": 5}',
        StoreKeys.savedPlans: '{"a":1}',
        StoreKeys.onboarding: '"x"',
        StoreKeys.cooked: '[]',
        StoreKeys.swapCount: '"ba"',
      });
      final r = restart();
      expect(r.read(profileProvider).goal, 'lose');
      expect(r.read(preferencesProvider).storeId, 'bach_hoa_xanh');
      expect(r.read(currentPlanProvider), isNull);
      expect(r.read(savedPlansProvider), isEmpty);
      expect(r.read(onboardingProvider).step, 0);
      expect(r.read(cookedStepsProvider), isEmpty);
      expect(r.read(swapCountProvider), 0);
    });
  });

  group('Món bị chặn', () {
    test('chặn / bỏ chặn, không trùng, được lưu', () async {
      final n = c.read(preferencesProvider.notifier)
        ..blockRecipe('a')
        ..blockRecipe('a')
        ..blockRecipe('b');
      expect(c.read(blockedRecipesProvider), ['a', 'b']);
      n.unblockRecipe('a');
      await settle();
      expect(restart().read(blockedRecipesProvider), ['b']);
    });
  });

  group('Tuần mới và tuần đã lưu', () {
    test('tuần đầu tiên: không có gì để lưu', () {
      c.read(appActionsProvider).startNewWeek(samplePlan());
      expect(c.read(savedPlansProvider), isEmpty);
      expect(c.read(currentPlanProvider), isNotNull);
    });

    test('tuần thứ hai: tuần cũ vào "Tuần đã lưu", đi chợ và bước nấu làm lại, nhà có sẵn được nhớ', () async {
      c.read(appActionsProvider).startNewWeek(samplePlan());
      c.read(shoppingStateProvider.notifier)
        ..setBought('x', bought: true)
        ..setPantry('dau_an', have: false);
      c.read(cookedStepsProvider.notifier).toggle('k', 1);
      final second = samplePlan();
      c.read(appActionsProvider).startNewWeek(second);
      await settle();

      final r = restart();
      expect(r.read(savedPlansProvider), hasLength(1));
      expect(r.read(shoppingStateProvider).bought, isEmpty);
      // lựa chọn "nhà có sẵn" được nhớ qua các tuần (D-SHP-01)
      expect(r.read(shoppingStateProvider).pantryOverrides, {'dau_an': false});
      expect(r.read(cookedStepsProvider), isEmpty);
      expect(r.read(currentPlanProvider), isNotNull);
    });

    test('chỉ giữ ${SavedPlansNotifier.max} tuần gần nhất', () {
      final plan = samplePlan();
      for (var i = 0; i < SavedPlansNotifier.max + 3; i++) {
        c
            .read(savedPlansProvider.notifier)
            .add(SavedPlan(savedAt: DateTime(2026, 1, 1 + i), plan: plan));
      }
      final list = c.read(savedPlansProvider);
      expect(list, hasLength(SavedPlansNotifier.max));
      expect(
        list.first.savedAt,
        DateTime(2026, 1, 1 + SavedPlansNotifier.max + 2),
      );
    });
  });

  group('Xoá toàn bộ dữ liệu', () {
    test('về mặc định, giữ số phiên bản schema', () async {
      c.read(profileProvider.notifier).update((p) => p.copyWith(age: 55));
      c.read(onboardingProvider.notifier).complete();
      c.read(appActionsProvider).startNewWeek(samplePlan());
      await settle();
      await c.read(appActionsProvider).clearAll();

      expect(c.read(profileProvider).age, Defaults.profile.age);
      expect(c.read(onboardingProvider).completed, isFalse);
      expect(c.read(currentPlanProvider), isNull);
      expect(store.keys.toSet(), {StoreKeys.schemaVersion});
      expect(store.read(StoreKeys.schemaVersion), '$kStorageSchemaVersion');
    });
  });

  group('referenceProvider (cache offline)', () {
    test('online: trả dữ liệu và ghi cache', () async {
      final a = FakeAdapter()
        ..on('GET', '/v1/reference', fixture('reference.json'));
      final cc = container(store, adapter: a);
      addTearDown(cc.dispose);
      final r = await cc.read(referenceProvider.future);
      expect(r.stores, isNotEmpty);
      expect(store.read(StoreKeys.reference), isNotNull);
    });

    test('mất mạng nhưng có cache → vẫn trả dữ liệu cũ', () async {
      final online = FakeAdapter()
        ..on('GET', '/v1/reference', fixture('reference.json'));
      final c1 = container(store, adapter: online);
      await c1.read(referenceProvider.future);
      c1.dispose();

      final offline = FakeAdapter()..failWithConnectionError = true;
      final c2 = container(store, adapter: offline);
      addTearDown(c2.dispose);
      final r = await c2.read(referenceProvider.future);
      expect(r.swipeCards, isNotEmpty);
    });

    test(
      'mất mạng và chưa có cache → lỗi ApiException (UI hiện màn thử lại)',
      () async {
        final offline = FakeAdapter()..failWithConnectionError = true;
        final c2 = container(store, adapter: offline);
        addTearDown(c2.dispose);
        await expectLater(
          c2.read(referenceProvider.future),
          throwsA(
            isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue),
          ),
        );
      },
    );
  });
}
