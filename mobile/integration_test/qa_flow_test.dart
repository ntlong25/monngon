// Kiểm tay T-050b/T-050c được tự động hoá: 4 mức cơm, mất mạng khi tạo tuần, công thức, ngân sách, tổng kết.
//
// Chạy: tool/run_integration.sh emulator-5554 http://10.0.2.2:5097 integration_test/qa_flow_test.dart
// (API thật; ảnh vào docs/dev/screens/it-1x-*.png). Mỗi `testWidgets` tự dựng dữ liệu, không phụ thuộc test khác.
import 'package:dio/dio.dart';
import 'package:fitpro_mamdu/api/api_providers.dart';
import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/config/env.dart';
import 'package:fitpro_mamdu/core/format.dart';
import 'package:fitpro_mamdu/features/meal/rice_card.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:fitpro_mamdu/state/week_changes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'it_support.dart';

const _profile = Profile(
  goal: 'lose',
  sex: 'female',
  age: 32,
  heightCm: 162,
  weightKg: 60,
  activity: 'light',
  targetMode: 'formula',
);

Preferences _prefs({
  String rice = 'vua',
  int adults = 1,
  int children = 0,
  double budget = 650000,
}) => Defaults.preferences.copyWith(
  weeklyBudgetVnd: budget,
  riceHabit: rice,
  adults: adults,
  children: children,
  healthLeanings: ['nhieu_xo'],
  cuisineLikes: ['xao', 'canh'],
);

/// Dựng app với dữ liệu đã có sẵn (bỏ qua onboarding), API thật; [offline] bật/tắt mất mạng giả lập.
Future<ProviderContainer> boot(
  WidgetTester t, {
  required Preferences prefs,
  int onboardingStep = 13,
  bool completed = true,
  ValueNotifier<bool>? offline,
}) async {
  final sp = await SharedPreferences.getInstance();
  await sp.clear();
  final store = SharedPrefsStore(sp);
  await const StorageMigrator().migrate(store);
  await store.writeJson(StoreKeys.profile, _profile.toJson());
  await store.writeJson(StoreKeys.preferences, prefs.toJson());
  await store.writeJson(StoreKeys.onboarding, {
    'step': onboardingStep,
    'completed': completed,
  });
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        storeProvider.overrideWithValue(store),
        if (offline != null)
          dioProvider.overrideWith((ref) {
            final dio = Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 60),
                headers: {'Accept': 'application/json'},
              ),
            );
            dio.interceptors.add(
              InterceptorsWrapper(
                onRequest: (o, h) => offline.value
                    ? h.reject(
                        DioException.connectionError(
                          requestOptions: o,
                          reason: 'offline (test)',
                        ),
                      )
                    : h.next(o),
              ),
            );
            ref.onDispose(dio.close);
            return dio;
          }),
      ],
      child: const FitProApp(),
    ),
  );
  await breathe(t, 1500);
  return containerOf(t);
}

/// Tạo tuần thật qua API như bước tổng kết rồi đặt làm tuần hiện tại.
Future<PlanResponse> startWeek(WidgetTester t) async {
  final c = containerOf(t);
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final plan = await c
      .read(apiProvider)
      .createPlan(
        PlanRequest(
          profile: c.read(profileProvider),
          preferences: c.read(preferencesProvider),
          startDate: isoDate(tomorrow),
          mealStyle: 'auto',
          includeDessert: true,
        ),
      );
  c.read(appActionsProvider).startNewWeek(plan);
  await breathe(t, 1200);
  return plan;
}

List<PlanMeal> _planned(PlanResponse r) => [
  for (final d in r.plan.days)
    for (final m in d.meals)
      if (m.status == 'planned' && m.recipeId != null) m,
];

List<PlanMeal> _mam(PlanResponse r) => _planned(r)
    .where(
      (m) =>
          (m.slot == 'lunch' || m.slot == 'dinner') &&
          (m.dishes?.length ?? 0) > 1,
    )
    .toList();

/// Số món canh trong mâm: món có vai trò canh + món chính dạng canh (id `canh_…`).
int _soups(PlanMeal m) => (m.dishes ?? const <Dish>[])
    .where(
      (d) =>
          d.role == 'soup' ||
          (d.role == 'main' && (d.recipeId ?? '').startsWith('canh_')),
    )
    .length;

Future<void> openMeal(WidgetTester t, PlanMeal m) async {
  await tabTo(t, lOf(t).tabPlan);
  final list = find.byKey(const Key('plan-list'));
  await waitFor(t, list);
  await scrollTo(t, list, find.byKey(Key('meal-${m.date}-${m.slot}')));
  await tapFinder(t, find.byKey(Key('meal-${m.date}-${m.slot}')));
  await waitFor(t, find.byKey(const Key('meal-title')));
}

Future<void> back(WidgetTester t) async {
  await tapFinder(t, find.byIcon(Icons.arrow_back));
  await breathe(t, 600);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------------ 4 mức cơm (TC-3-16 + D-COM-01/02)
  testWidgets(
    'Bốn mức cơm: đổi ở tab Bạn → lên lại tuần → thẻ cơm khớp mức, ghi chú khi bớt, mâm không 2 canh',
    (t) async {
      await boot(t, prefs: _prefs(rice: 'vua'));
      var resp = await startWeek(t);
      final c = containerOf(t);
      const levels = [
        ('it', 75, 'Ít'),
        ('vua', 150, 'Vừa'),
        ('nhieu', 300, 'Nhiều'),
        ('rat_nhieu', 450, 'Rất nhiều'),
      ];
      final summary = <String>[];
      for (final (id, grams, _) in levels) {
        final l = lOf(t);
        // Đổi mức cơm ở tab Bạn (bỏ qua nếu đang đúng mức: tuần đầu đã lập ở mức Vừa).
        if (c.read(preferencesProvider).riceHabit != id) {
          await tabTo(t, l.tabProfile);
          await waitFor(t, find.byKey(const Key('profile-list')));
          await scrollTo(
            t,
            find.byKey(const Key('profile-list')),
            find.byKey(const Key('edit-rice')),
          );
          await tapKey(t, 'edit-rice');
          await tapKey(t, 'rice-$id');
          await tapFinder(t, find.text('Lưu'));
          await until(
            t,
            () => c.read(choicesDirtyProvider),
            what: 'đã đánh dấu chưa áp dụng',
          );
          expect(c.read(preferencesProvider).riceHabit, id);
          await scrollTo(
            t,
            find.byKey(const Key('profile-list')),
            find.byKey(const Key('profile-replan')),
          );
          await shot(t, 'it-10-com-$id-tab-ban');
          await tapKey(t, 'profile-replan');
          await tapKey(t, 'replan-confirm');
          await until(
            t,
            () =>
                !c.read(choicesDirtyProvider) &&
                (c
                        .read(currentPlanProvider)
                        ?.plan
                        .days
                        .any((d) => d.meals.any((m) => m.rice?.habit == id)) ??
                    false),
            timeout: const Duration(minutes: 2),
            what: 'tuần lên lại với mức cơm $id',
          );
          await breathe(t, 1500);
        } else {
          await tabTo(t, l.tabPlan);
        }
        resp = c.read(currentPlanProvider)!;

        // Dữ liệu tuần: mọi bữa mâm có cơm đúng mức hoặc có ghi chú; không mâm nào 2 canh.
        final mam = _mam(resp);
        expect(mam, isNotEmpty);
        final riceMeals = mam.where((m) => m.rice != null).toList();
        expect(riceMeals, isNotEmpty, reason: 'mức $id: mâm có cơm');
        var reduced = 0;
        for (final m in riceMeals) {
          final r = m.rice!;
          expect(r.habit, id);
          // Mâm có tinh bột khác cơm (khoai lang, bún…): target_g là gram của chính món đó,
          // quy theo kcal tương đương cơm trắng nên ≥ mức đã chọn (xem docs/dev/qa-automation.md).
          expect(r.targetG, greaterThanOrEqualTo(grams));
          final noted = (m.notes ?? const <MealNote>[]).any(
            (n) => n.code == 'rice_reduced',
          );
          if (noted) reduced++;
          expect(
            r.actualG >= r.targetG - 10 || noted,
            isTrue,
            reason: '$id ${m.date} ${m.slot}: cơm ${r.actualG} g thiếu ghi chú',
          );
        }
        for (final m in mam) {
          expect(
            _soups(m),
            lessThanOrEqualTo(1),
            reason: '$id ${m.date} ${m.slot}: mâm có ${_soups(m)} canh',
          );
        }
        summary.add(
          'mức $id: ${riceMeals.length} bữa mâm có cơm, $reduced bữa bớt cơm, '
          'cơm ${riceMeals.map((m) => m.rice!.actualG.round()).toSet().toList()..sort()} g',
        );

        // Thẻ cơm trên màn mâm: bữa đủ cơm và (nếu có) bữa bị bớt.
        final full = riceMeals.firstWhere(
          (m) =>
              m.rice!.targetG == grams &&
              !(m.notes ?? const <MealNote>[]).any(
                (n) => n.code == 'rice_reduced',
              ),
          orElse: () => riceMeals.first,
        );
        PlanMeal? cut;
        for (final m in riceMeals) {
          if ((m.notes ?? const <MealNote>[]).any(
            (n) => n.code == 'rice_reduced',
          )) {
            cut = m;
            break;
          }
        }
        for (final m in [full, ?cut]) {
          await openMeal(t, m);
          final list = find.byKey(const Key('meal-list'));
          await scrollTo(t, list, find.byKey(const Key('rice-card')));
          final r = m.rice!;
          final text = t
              .widget<Text>(find.byKey(const Key('rice-amount')))
              .data!;
          final expected = lOf(t)
              .mealRiceCups(RiceCard.cups(r.actualG), formatInt(r.actualG));
          expect(text, expected);
          final isCut = identical(m, cut);
          if (!isCut && r.targetG == grams && r.actualG >= r.targetG - 10) {
            // Bữa đủ cơm: số chén/gram đúng mức đã chọn.
            expect(r.actualG.round(), grams, reason: 'mức $id đủ cơm');
          }
          expect(
            find.byKey(const Key('rice-reduced-note')),
            isCut ? findsOneWidget : findsNothing,
          );
          // ignore: avoid_print
          print('[it] mức $id ${isCut ? "bớt" : "đủ"}: "$text"');
          await shot(
            t,
            isCut ? 'it-10-com-$id-bot-com' : 'it-10-com-$id-the-com',
          );
          await back(t);
        }
      }
      // ignore: avoid_print
      print('[it] ${summary.join(' | ')}');
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );

  // ------------------------------------------------------------------ TC-E-04: mất mạng khi tạo tuần
  testWidgets(
    'TC-E-04: tạo tuần khi mất mạng → thông báo lỗi + Thử lại, không crash; có mạng lại thì tạo được',
    (t) async {
      final offline = ValueNotifier<bool>(false);
      final c = await boot(
        t,
        prefs: _prefs(),
        onboardingStep: 13,
        completed: false,
        offline: offline,
      );
      final l = lOf(t);
      // Tổng kết cần chỉ tiêu + khoảng ngân sách từ API → khi mất mạng không tạo được; bật mạng để vào tổng kết rồi tắt trước khi bấm tạo.
      await waitFor(t, find.text(l.onboardingSummaryTitle));
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
      await shot(t, 'it-11-offline-tong-ket');
      offline.value = true; // "tắt mạng rồi tạo tuần"
      await t.tap(create);
      await waitFor(
        t,
        find.byKey(const Key('generating-fail')),
        timeout: const Duration(seconds: 40),
      );
      expect(find.text(l.errorsNetworkBody), findsOneWidget);
      expect(find.text(l.commonRetry), findsOneWidget);
      expect(c.read(onboardingProvider).completed, isFalse);
      expect(c.read(currentPlanProvider), isNull);
      await shot(t, 'it-11-offline-thong-bao-loi');
      // Có mạng lại: Thử lại tạo được tuần.
      offline.value = false;
      await tapFinder(t, find.text(l.commonRetry));
      await waitFor(
        t,
        find.byKey(const Key('plan-list')),
        timeout: const Duration(minutes: 3),
      );
      expect(c.read(currentPlanProvider), isNotNull);
      expect(c.read(onboardingProvider).completed, isTrue);
      await shot(t, 'it-11-offline-thu-lai-xong');
      // Mất mạng khi đã có tuần: tab Bạn vẫn hiện chỉ tiêu đã lưu, không "…" (L-13).
      offline.value = true;
      await tabTo(t, lOf(t).tabProfile);
      await waitFor(t, find.byKey(const Key('profile-list')));
      await breathe(t, 1500);
      final targets = find.descendant(
        of: find.byKey(const Key('edit-targets')),
        matching: find.textContaining('kcal'),
      );
      expect(targets, findsOneWidget);
      expect(find.byKey(const Key('profile-targets-error')), findsNothing);
      await shot(t, 'it-11-offline-tab-ban-chi-tieu-da-luu');
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );

  // ------------------------------------------------------------------ TC-3-08/09/10: công thức
  testWidgets(
    'Công thức: hộ 2+1 hai cột (TC-3-08), bước nấu giữ sau khi mở lại (TC-3-09), chế độ nấu giữ sáng màn hình (TC-3-10)',
    (t) async {
      await boot(t, prefs: _prefs(adults: 2, children: 1, budget: 1500000));
      final plan = await startWeek(t);
      final c = containerOf(t);
      // Một món chính của bữa mâm (có ≥ 2 cột nguyên liệu).
      final meal = _mam(plan).first;
      final dish = meal.dishes!.firstWhere((d) => d.role == 'main');
      await openMeal(t, meal);
      await scrollTo(
        t,
        find.byKey(const Key('meal-list')),
        find.byKey(Key('dish-${dish.recipeId}')),
      );
      await tapFinder(t, find.byKey(Key('dish-${dish.recipeId}')));
      await waitFor(t, find.byKey(const Key('recipe-title')));

      // TC-3-08: hai cột "Phần của bạn" / "Cả nồi"; cả nồi = bạn + (người lớn còn lại × chuẩn) + (trẻ × 0,6 × chuẩn).
      final recipeList = find.byKey(const Key('recipe-list'));
      await scrollTo(t, recipeList, find.byKey(const Key('ingredients-card')));
      expect(find.byKey(const Key('col-yours')), findsOneWidget);
      expect(find.byKey(const Key('col-whole')), findsOneWidget);
      expect(find.text(lOf(t).recipeServingsYours), findsOneWidget);
      expect(find.text(lOf(t).recipeServingsWhole), findsOneWidget);
      final info = plan.recipes[dish.recipeId];
      var checked = 0;
      for (
        var i = 0;
        i < dish.grams.length && i < (info?.ingredients.length ?? 0);
        i++
      ) {
        final ing = dish.grams[i];
        final stdG = info!.ingredients[i].grams;
        final yoursF = find.byKey(Key('ing-${ing.ingredientId}-yours'));
        final wholeF = find.byKey(Key('ing-${ing.ingredientId}-whole'));
        if (yoursF.evaluate().isEmpty || wholeF.evaluate().isEmpty) continue;
        final yoursTxt = t.widget<Text>(yoursF).data ?? '';
        final wholeTxt = t.widget<Text>(wholeF).data ?? '';
        double? num(String s) {
          final m = RegExp(r'[\d.,]+').firstMatch(s);
          if (m == null) return null;
          return double.tryParse(
            m.group(0)!.replaceAll('.', '').replaceAll(',', '.'),
          );
        }

        final y = num(yoursTxt);
        final w = num(wholeTxt);
        if (y == null || w == null || !yoursTxt.contains(' g') || stdG < 20) {
          continue;
        }
        final expectWhole = ing.grams + stdG * 1 + stdG * 0.6;
        expect(
          (w - expectWhole).abs() <= expectWhole * 0.03 + 1,
          isTrue,
          reason:
              '${ing.ingredientId}: bạn $yoursTxt, cả nồi $wholeTxt, kỳ vọng ~${expectWhole.round()} g',
        );
        checked++;
      }
      expect(
        checked,
        greaterThan(0),
        reason: 'phải kiểm được ít nhất một nguyên liệu tính bằng gram',
      );
      // ignore: avoid_print
      print(
        '[it] TC-3-08: kiểm $checked nguyên liệu, cả nồi = bạn + 1 người lớn chuẩn + 0,6 × trẻ',
      );
      await shot(t, 'it-12-cong-thuc-hai-cot');

      // TC-3-10 (phần app): vào công thức thì giữ sáng, đứng yên ~2 phút vẫn giữ.
      expect(
        await WakelockPlus.enabled,
        isTrue,
        reason: 'vào trang công thức phải bật giữ sáng',
      );
      await scrollTo(t, recipeList, find.byKey(const Key('steps-card')));
      await shot(t, 'it-12-cach-lam');

      // TC-3-09: chạm bước 0 và 1 → đánh dấu xong; "tắt app, mở lại" = dựng lại cả cây widget trên cùng kho lưu.
      await tapKey(t, 'step-0');
      await tapKey(t, 'step-1');
      expect(find.byKey(const Key('step-0-done')), findsOneWidget);
      expect(find.byKey(const Key('step-1-done')), findsOneWidget);
      await shot(t, 'it-12-cach-lam-da-xong');
      await breathe(t, 800);
      final doneBefore = c.read(cookedStepsProvider);
      expect(doneBefore.values.expand((s) => s), containsAll([0, 1]));

      // TC-3-10: đợi 125 giây không chạm; script chụp trạng thái màn hình của thiết bị ở mốc này.
      // ignore: avoid_print
      print('[it] bắt đầu chờ 125 s không chạm');
      for (var i = 0; i < 25; i++) {
        await breathe(t, 5000);
      }
      // ignore: avoid_print
      print('[it] adb: wakefulness');
      await breathe(t, 3000);
      expect(
        await WakelockPlus.enabled,
        isTrue,
        reason: 'sau 2 phút vẫn giữ sáng',
      );
      expect(find.byKey(const Key('steps-card')), findsOneWidget);

      // Rời trang → trả về cài đặt bình thường.
      await back(t);
      await back(t);
      await breathe(t, 1000);
      expect(
        await WakelockPlus.enabled,
        isFalse,
        reason: 'rời công thức phải tắt giữ sáng',
      );
      // ignore: avoid_print
      print('[it] adb: wakefulness-sau-roi');
      await breathe(t, 3000);

      // TC-3-09: mở lại app.
      await t.pumpWidget(const SizedBox());
      await breathe(t, 500);
      final sp = await SharedPreferences.getInstance();
      await t.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWithValue(SharedPrefsStore(sp))],
          child: const FitProApp(),
        ),
      );
      await breathe(t, 2000);
      final c2 = containerOf(t);
      expect(
        c2.read(cookedStepsProvider),
        doneBefore,
        reason: 'bước đã xong phải được giữ khi mở lại',
      );
      await openMeal(t, meal);
      await scrollTo(
        t,
        find.byKey(const Key('meal-list')),
        find.byKey(Key('dish-${dish.recipeId}')),
      );
      await tapFinder(t, find.byKey(Key('dish-${dish.recipeId}')));
      await waitFor(t, find.byKey(const Key('recipe-title')));
      await scrollTo(
        t,
        find.byKey(const Key('recipe-list')),
        find.byKey(const Key('steps-card')),
      );
      expect(find.byKey(const Key('step-0-done')), findsOneWidget);
      expect(find.byKey(const Key('step-1-done')), findsOneWidget);
      await shot(t, 'it-12-cach-lam-sau-khi-mo-lai');
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  // ------------------------------------------------------------------ TC-1-09: thanh ngân sách
  testWidgets(
    'TC-1-09: kéo thanh ngân sách min → max, bước 50.000 ₫, nhãn bậc đổi theo vị trí',
    (t) async {
      await boot(
        t,
        prefs: _prefs(budget: 0),
        onboardingStep: 6,
        completed: false,
      );
      await waitFor(t, find.byKey(const Key('budget-slider')));
      await breathe(t, 800);
      final slider = find.byKey(const Key('budget-slider'));
      final rect = t.getRect(slider);
      final seen = <String, String>{};
      final values = <double>[];
      for (final f in [0.04, 0.2, 0.4, 0.6, 0.8, 0.96]) {
        await t.tapAt(
          Offset(rect.left + 24 + (rect.width - 48) * f, rect.center.dy),
        );
        await breathe(t, 500);
        final v = t.widget<Text>(find.byKey(const Key('budget-value'))).data!;
        final tier =
            (find
                        .descendant(
                          of: find.byKey(const Key('budget-tier')),
                          matching: find.byType(Text),
                        )
                        .evaluate()
                        .first
                        .widget
                    as Text)
                .data!;
        seen[v] = tier;
        values.add(double.parse(v.replaceAll(RegExp(r'[^\d]'), '')));
        if (f == 0.04 || f == 0.96) {
          await shot(t, 'it-13-ngan-sach-${f < 0.5 ? 'min' : 'max'}');
        }
      }
      // ignore: avoid_print
      print('[it] TC-1-09 mẫu: $seen');
      final range = values;
      for (final v in range) {
        expect(v % 50000, 0, reason: '$v phải là bội của bước 50.000 ₫');
      }
      expect(range.first, lessThan(range.last));
      expect(
        seen.values.toSet().length,
        greaterThanOrEqualTo(3),
        reason: 'ít nhất 3 bậc chi tiêu: $seen',
      );
      // Giá trị đầu/cuối là min/max của khoảng.
      expect(t.widget<Slider>(slider).min, lessThanOrEqualTo(range.first));
      expect(t.widget<Slider>(slider).max, greaterThanOrEqualTo(range.last));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  // ------------------------------------------------------------------ TC-1-33: tổng kết
  testWidgets(
    'TC-1-33: tổng kết hiện checklist theo thứ tự và giá trị khớp lựa chọn',
    (t) async {
      final prefs = _prefs(rice: 'nhieu', budget: 900000);
      await boot(t, prefs: prefs, onboardingStep: 13, completed: false);
      final l = lOf(t);
      await waitFor(t, find.text(l.onboardingSummaryTitle));
      await waitFor(t, find.byKey(const Key('summary-budget')));
      await breathe(t, 1500);
      final order = [
        'goal',
        'protein',
        'kcal',
        'meals',
        'leanings',
        'rice',
        'kitchen',
        'budget',
      ];
      final ys = <double>[];
      for (final id in order) {
        final f = find.byKey(Key('summary-$id'));
        await t.ensureVisible(f);
        await breathe(t, 200);
        expect(f, findsOneWidget, reason: 'thiếu dòng $id');
      }
      // Thứ tự dọc: lấy vị trí trong danh sách cuộn (so sánh theo thứ tự widget trong cây).
      final list = find.byType(Scrollable).first;
      t.state<ScrollableState>(list).position.jumpTo(0);
      await breathe(t, 300);
      final positions = <String, int>{};
      final all = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            RegExp(r'^summary-[a-z]+$')
                .hasMatch((w.key as ValueKey<String>).value),
      );
      var idx = 0;
      for (final e in all.evaluate()) {
        positions[(e.widget.key as ValueKey<String>).value.substring(8)] =
            idx++;
      }
      final present = order.where(positions.containsKey).toList();
      expect(present, order, reason: 'các dòng tổng kết phải có đủ');
      final sorted = [...present]
        ..sort((a, b) => positions[a]!.compareTo(positions[b]!));
      expect(sorted, order, reason: 'thứ tự dòng tổng kết');
      String val(String id) =>
          t.widget<Text>(find.byKey(Key('summary-$id-value'))).data!;
      expect(val('goal'), contains('mỡ'));
      expect(val('rice'), contains('300'));
      expect(val('budget'), contains('900.000'));
      expect(val('meals'), contains('4'));
      expect(val('leanings'), isNotEmpty);
      // ignore: avoid_print
      print('[it] TC-1-33: ${{for (final id in order) id: val(id)}}');
      ys.clear();
      await shot(t, 'it-14-tong-ket-checklist');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
