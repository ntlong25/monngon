// Luồng chính trên thiết bị thật/emulator, gọi API thật (không fake).
//
// Chạy: xem mục "Integration test" trong mobile/README.md.
// Ảnh chụp từng bước được lưu vào docs/dev/screens/it-*.png (qua test_driver/integration_test.dart).

import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'it_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Luồng chính: onboarding → tuần → công thức → đổi món → ăn ngoài → đi chợ → xóa dữ liệu',
    (t) async {
      // ---------------------------------------------------------------- 1. Xóa dữ liệu
      // ignore: avoid_print
      print('[it] bắt đầu');
      final prefs = await SharedPreferences.getInstance();
      // ignore: avoid_print
      print('[it] có SharedPreferences');
      await prefs.clear();
      final store = SharedPrefsStore(prefs);
      await const StorageMigrator().migrate(store);
      await t.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWithValue(store)],
          child: const FitProApp(),
        ),
      );
      // ignore: avoid_print
      print('[it] đã pumpWidget');
      await breathe(t, 1500);
      final l = lOf(t);
      await waitFor(t, find.text(l.onboardingGoalTitle));
      expect(containerOf(t).read(onboardingProvider).completed, isFalse);
      await shot(t, 'it-01-xoa-du-lieu');

      // ---------------------------------------------------------------- 2. Onboarding 13 bước (hồ sơ p01)
      // 1/13 mục tiêu: giảm mỡ
      await tapFinder(t, find.text(l.onboardingGoalLose));
      await shot(t, 'it-02-onb-01-muc-tieu');
      await next(t);

      // 2/13 cơ thể: nữ, 32 tuổi, 162 cm, 60 kg
      await waitFor(t, find.text(l.onboardingBodyTitle));
      await tapFinder(t, find.text(l.onboardingBodySexFemale));
      await t.enterText(find.byKey(const Key('field-age')), '32');
      await t.enterText(find.byKey(const Key('field-height')), '162');
      await t.enterText(find.byKey(const Key('field-weight')), '60');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await breathe(t);
      final prof = containerOf(t).read(profileProvider);
      expect(
        [prof.sex, prof.age, prof.heightCm, prof.weightKg],
        ['female', 32, 162, 60],
      );
      await shot(t, 'it-02-onb-02-co-the');
      await next(t);

      // 3/13 vận động: nhẹ
      await waitFor(t, find.text(l.onboardingBodyActivityTitle));
      await tapFinder(t, find.text(l.onboardingBodyActivityLight));
      await shot(t, 'it-02-onb-03-van-dong');
      await next(t);

      // 4/13 chỉ tiêu (từ API thật)
      await waitFor(t, find.byKey(const Key('targets-card')));
      await shot(t, 'it-02-onb-04-chi-tieu');
      await next(t);

      // 5/13 cửa hàng: Bách hóa Xanh
      await waitFor(t, find.text(l.onboardingStoreTitle));
      final reference = await containerOf(t).read(referenceProvider.future);
      final bhx = reference.stores.firstWhere((s) => s.id == 'bach_hoa_xanh');
      await tapFinder(t, find.text(bhx.name));
      await shot(t, 'it-02-onb-05-cua-hang');
      await next(t);

      // 6/13 số người ăn: 1 người lớn, 0 trẻ em (mặc định)
      await waitFor(t, find.text(l.onboardingHouseholdTitle));
      await shot(t, 'it-02-onb-06-so-nguoi');
      await next(t);

      // 7/13 ngân sách 650.000 ₫ (đặt thẳng giá trị; thanh trượt khó nhắm đúng số)
      await waitFor(t, find.byKey(const Key('budget-slider')));
      containerOf(t)
          .read(preferencesProvider.notifier)
          .update((p) => p.copyWith(weeklyBudgetVnd: 650000));
      await breathe(t, 800);
      await shot(t, 'it-02-onb-07-ngan-sach');
      await next(t);
      expect(containerOf(t).read(preferencesProvider).weeklyBudgetVnd, 650000);

      // 8/13 bữa ăn: sáng/trưa/tối/xế chiều bật, xế sáng bỏ
      await waitFor(t, find.byKey(const Key('slot-breakfast')));
      final slots = containerOf(t).read(preferencesProvider).slots;
      expect(
        [
          slots.breakfast,
          slots.lunch,
          slots.dinner,
          slots.snackAm,
          slots.snackPm,
        ],
        ['on', 'on', 'on', 'skip', 'on'],
      );
      await shot(t, 'it-02-onb-08-bua-an');
      await next(t);

      // 9/13 kiêng + xu hướng: nhiều xơ
      await waitFor(t, find.byKey(const Key('lean-nhieu_xo')));
      await tapKey(t, 'lean-nhieu_xo');
      expect(containerOf(t).read(preferencesProvider).healthLeanings, [
        'nhieu_xo',
      ]);
      await shot(t, 'it-02-onb-09-kieng');
      await next(t);

      // 9b/14 thói quen ăn cơm (T-095): Vừa chọn sẵn; để nguyên mức Vừa
      await waitFor(t, find.text(l.onboardingRiceTitle));
      expect(containerOf(t).read(preferencesProvider).riceHabit, 'vua');
      await shot(t, 'it-02-onb-09b-thoi-quen-com');
      await next(t);

      // 10/13 nguyên liệu không thích: để trống
      await waitFor(t, find.text(l.onboardingDislikeTitle));
      await shot(t, 'it-02-onb-10-khong-thich');
      await next(t);

      // 11/13 thẻ vuốt: thích "xào" và "canh", các thẻ khác chọn ít hơn
      await waitFor(t, find.byKey(const Key('swipe-progress')));
      final cards = reference.swipeCards;
      expect(cards.map((c) => c.tag), containsAll(['xao', 'canh']));
      await shot(t, 'it-02-onb-11-vuot-the-dau');
      for (final c in cards) {
        final like = c.tag == 'xao' || c.tag == 'canh';
        await tapKey(t, like ? 'swipe-like' : 'swipe-dislike');
      }
      await waitFor(t, find.byKey(const Key('swipe-liked')));
      final pf = containerOf(t).read(preferencesProvider);
      expect(pf.cuisineLikes, containsAll(['xao', 'canh']));
      await shot(t, 'it-02-onb-11-vuot-the-ket-qua');
      await next(t);

      // 12/13 dụng cụ: bếp + nồi cơm điện (mặc định)
      await waitFor(t, find.text(l.onboardingEquipmentTitle));
      expect(containerOf(t).read(preferencesProvider).equipment, [
        'bep',
        'noi_com_dien',
      ]);
      await shot(t, 'it-02-onb-12-dung-cu');
      await next(t);

      // 13/13 tổng kết
      await waitFor(t, find.text(l.onboardingSummaryTitle));
      await waitFor(t, find.byKey(const Key('summary-budget')));
      await shot(t, 'it-02-onb-13-tong-ket');

      // ---------------------------------------------------------------- 3. Tạo tuần
      final create = find.ancestor(
        of: find.text(l.onboardingSummaryCreate),
        matching: find.byType(FilledButton),
      );
      await until(
        t,
        () =>
            create.evaluate().isNotEmpty &&
            t.widget<FilledButton>(create).onPressed != null,
        what: 'nút Tạo thực đơn tuần bật',
      );
      await t.tap(create);
      await breathe(t, 300);
      await shot(t, 'it-03-tao-tuan-dang-tao');
      await waitFor(
        t,
        find.byKey(const Key('plan-list')),
        timeout: const Duration(minutes: 3),
      );
      expect(containerOf(t).read(onboardingProvider).completed, isTrue);
      await breathe(t, 800);

      // ---------------------------------------------------------------- 4. Kế hoạch: 7 ngày, mâm có tráng miệng
      final resp = containerOf(t).read(currentPlanProvider)!;
      final days = resp.plan.days;
      expect(days.length, 7, reason: 'tuần có đủ 7 ngày');
      final mamMeals = <PlanMeal>[];
      for (final d in days) {
        for (final m in d.meals) {
          if (m.status != 'planned' || m.recipeId == null) continue;
          final dishes = m.dishes ?? const <Dish>[];
          if (dishes.length > 1 && (m.slot == 'lunch' || m.slot == 'dinner')) {
            final hasDessert = dishes.any((x) => x.role == 'dessert');
            expect(
              hasDessert,
              isTrue,
              reason: 'mâm ${m.date} ${m.slot} thiếu tráng miệng',
            );
            expect(m.dessertId ?? m.dessert, isNotNull);
            mamMeals.add(m);
          }
        }
      }
      expect(mamMeals, isNotEmpty, reason: 'phải có ít nhất một bữa mâm');
      // T-094: mỗi bữa mâm có cơm thì cơm đủ mức Vừa (±10 g) hoặc có ghi chú rice_reduced.
      final riceMeals = mamMeals.where((m) => m.rice != null).toList();
      expect(riceMeals, isNotEmpty, reason: 'mâm phải có thông tin cơm');
      for (final m in riceMeals) {
        final r = m.rice!;
        expect(r.habit, 'vua');
        final noted = (m.notes ?? const <MealNote>[]).any(
          (n) => n.code == 'rice_reduced',
        );
        expect(
          r.actualG >= r.targetG - 10 || noted,
          isTrue,
          reason:
              'cơm ${m.date} ${m.slot} còn ${r.actualG} g mà không có ghi chú',
        );
      }
      // ignore: avoid_print
      print(
        '[it] cơm Vừa: ${riceMeals.map((m) => m.rice!.actualG.round()).toList()} g, '
        '${riceMeals.where((m) => (m.notes ?? const <MealNote>[]).isNotEmpty).length} bữa có ghi chú',
      );
      // ignore: avoid_print
      print(
        '[it] ${days.length} ngày, ${mamMeals.length} bữa mâm đều có tráng miệng',
      );

      final planList = find.byKey(const Key('plan-list'));
      for (var i = 0; i < days.length; i++) {
        await scrollTo(t, planList, find.byKey(Key('day-${days[i].date}')));
        expect(find.byKey(Key('day-${days[i].date}')), findsOneWidget);
        await shot(t, 'it-04-ke-hoach-ngay-${i + 1}');
      }

      // ---------------------------------------------------------------- 5. Mở công thức, tổng "Cách chúng mình tính" = chip
      final target = mamMeals.firstWhere(
        (m) => m.slot == 'lunch' || m.slot == 'dinner',
        orElse: () => mamMeals.first,
      );
      final mealKey = Key('meal-${target.date}-${target.slot}');
      await scrollTo(t, planList, find.byKey(mealKey));
      await tapFinder(t, find.byKey(mealKey));
      await waitFor(t, find.byKey(const Key('meal-title')));
      final dessertId = (target.dishes!.firstWhere((x) => x.role == 'dessert'))
          .recipeId;
      await scrollTo(
        t,
        find.byKey(const Key('meal-list')),
        find.byKey(Key('dish-$dessertId')),
      );
      await shot(t, 'it-05-bua-mam-co-trang-mieng');
      if (target.rice != null) {
        await scrollTo(
          t,
          find.byKey(const Key('meal-list')),
          find.byKey(const Key('rice-card')),
        );
        expect(find.byKey(const Key('rice-amount')), findsOneWidget);
        await shot(t, 'it-05-bua-mam-the-com');
      }
      final mealList = find.byKey(const Key('meal-list'));
      await t.drag(mealList, const Offset(0, 4000));
      await breathe(t);
      final chip = kcalIn(t, find.byKey(const Key('meal-macros')));
      expect(chip, isNotEmpty, reason: 'chip kcal của bữa');
      await shot(t, 'it-05-bua-mam-chip');
      await tapKey(t, 'calc-link');
      await waitFor(t, find.byKey(const Key('calc-list')));
      await scrollTo(
        t,
        find.byKey(const Key('calc-list')),
        find.byKey(const Key('calc-total')),
      );
      final total = kcalIn(t, find.byKey(const Key('calc-total')));
      expect(total, chip, reason: 'tổng "Cách chúng mình tính" phải khớp chip');
      await shot(t, 'it-05-cach-chung-minh-tinh');
      // ignore: avoid_print
      print('[it] chip = $chip, tổng cách tính = $total');
      await tapFinder(t, find.byIcon(Icons.arrow_back));
      await waitFor(t, find.byKey(const Key('meal-list')));

      // ---------------------------------------------------------------- 6. Đổi món rồi Hoàn tác
      final before = planJson(t);
      final recipeBefore = containerOf(t)
          .read(currentPlanProvider)!
          .plan
          .days
          .expand((d) => d.meals)
          .firstWhere((m) => m.date == target.date && m.slot == target.slot)
          .recipeId;
      await scrollTo(
        t,
        find.byKey(const Key('meal-list')),
        find.byKey(const Key('change-meal')),
      );
      await tapKey(t, 'change-meal');
      final picks = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key as ValueKey<String>).value.startsWith('swap-pick-'),
      );
      await until(
        t,
        () =>
            picks.evaluate().isNotEmpty ||
            find.byKey(const Key('swap-empty')).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 90),
        what: 'gợi ý đổi món',
      );
      expect(picks, findsWidgets, reason: 'có ít nhất một món gợi ý để đổi');
      await shot(t, 'it-06-doi-mon-goi-y');
      await t.tap(picks.first);
      await breathe(t, 1500);
      await until(
        t,
        () => containerOf(t).read(swapCountProvider) == 1,
        timeout: const Duration(seconds: 90),
        what: 'đổi món xong',
      );
      final recipeAfter = containerOf(t)
          .read(currentPlanProvider)!
          .plan
          .days
          .expand((d) => d.meals)
          .firstWhere((m) => m.date == target.date && m.slot == target.slot)
          .recipeId;
      expect(recipeAfter, isNot(recipeBefore));
      await shot(t, 'it-06-doi-mon-xong');
      await tapFinder(t, find.text(lOf(t).commonUndo));
      await until(
        t,
        () => planJson(t) == before,
        timeout: const Duration(seconds: 30),
        what: 'Hoàn tác đổi món trả đúng tuần cũ',
      );
      expect(containerOf(t).read(swapCountProvider), 0);
      await shot(t, 'it-06-doi-mon-hoan-tac');

      // ---------------------------------------------------------------- 7. Ăn ngoài rồi Hoàn tác
      await scrollTo(
        t,
        find.byKey(const Key('meal-list')),
        find.byKey(const Key('eat-out')),
      );
      await tapKey(t, 'eat-out');
      await tapKey(t, 'out-eat_out');
      final label = find.byKey(Key('out-label-${target.date}-${target.slot}'));
      await waitFor(t, label, timeout: const Duration(seconds: 90));
      expect(find.byKey(Key('day-exempt-${target.date}')), findsOneWidget);
      await shot(t, 'it-07-an-ngoai');
      await tapKey(t, 'out-undo-${target.date}-${target.slot}');
      await waitGone(t, label, timeout: const Duration(seconds: 90));
      await until(
        t,
        () => planJson(t) == before,
        timeout: const Duration(seconds: 30),
        what: 'Hoàn tác ăn ngoài trả đúng tuần cũ',
      );
      await shot(t, 'it-07-an-ngoai-hoan-tac');

      // ---------------------------------------------------------------- 8. Đi chợ
      await tabTo(t, lOf(t).tabShopping);
      await waitFor(t, find.byKey(const Key('shop-list')));
      await waitFor(t, find.byKey(const Key('shop-food-cost')));
      final items = containerOf(t)
          .read(currentPlanProvider)!
          .plan
          .shopping
          .items;
      final ids = items.map((i) => i.ingredientId).toList();
      expect(ids, contains('gao_te'), reason: 'danh sách có gạo sống');
      expect(
        ids,
        isNot(contains('com_trang')),
        reason: 'không còn dòng cơm nấu chín',
      );
      final shopList = find.byKey(const Key('shop-list'));
      final rice = items.firstWhere((i) => i.ingredientId == 'gao_te');
      final riceRow = find.byKey(
        Key(rice.isPantry == true ? 'pantry-gao_te' : 'item-gao_te'),
      );
      final shoppingState = containerOf(t).read(shoppingStateProvider);
      final riceIsPantryNow = find.byKey(const Key('pantry-gao_te'));
      await scrollTo(
        t,
        shopList,
        shoppingState.pantryOverrides['gao_te'] == null && rice.isPantry != true
            ? find.byKey(const Key('item-gao_te'))
            : (riceIsPantryNow.evaluate().isNotEmpty
                  ? riceIsPantryNow
                  : riceRow),
      );
      expect(find.byKey(const Key('item-com_trang')), findsNothing);
      expect(find.byKey(const Key('pantry-com_trang')), findsNothing);
      await shot(t, 'it-08-di-cho-gao-song');

      await t.drag(shopList, const Offset(0, 6000));
      await breathe(t);
      final progressBefore = t
          .widget<Text>(find.byKey(const Key('shop-progress')))
          .data;
      final checks = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key as ValueKey<String>).value.startsWith('item-') &&
            (w.key as ValueKey<String>).value.endsWith('-check'),
      );
      await waitFor(t, checks);
      final checkKey =
          (checks.evaluate().first.widget.key as ValueKey<String>).value;
      final boughtId = checkKey.substring(
        'item-'.length,
        checkKey.length - '-check'.length,
      );
      await t.tap(checks.first);
      await breathe(t, 600);
      expect(
        containerOf(t).read(shoppingStateProvider).bought,
        contains(boughtId),
      );
      expect(
        t.widget<Text>(find.byKey(const Key('shop-progress'))).data,
        isNot(progressBefore),
      );
      await shot(t, 'it-08-di-cho-da-mua');

      // ---------------------------------------------------------------- 9. Tab Bạn: Xóa dữ liệu → về onboarding
      await tabTo(t, lOf(t).tabProfile);
      await waitFor(t, find.byKey(const Key('profile-list')));
      await shot(t, 'it-09-tab-ban');
      await scrollTo(
        t,
        find.byKey(const Key('profile-list')),
        find.byKey(const Key('clear-data')),
      );
      await tapKey(t, 'clear-data');
      await tapKey(t, 'clear-step1');
      await shot(t, 'it-09-xoa-du-lieu-buoc-2');
      await tapKey(t, 'clear-step2');
      await waitFor(t, find.text(lOf(t).onboardingGoalTitle));
      expect(containerOf(t).read(onboardingProvider).completed, isFalse);
      expect(containerOf(t).read(currentPlanProvider), isNull);
      await shot(t, 'it-09-ve-onboarding');
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
