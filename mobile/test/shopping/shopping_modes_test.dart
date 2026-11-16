import 'dart:convert';

import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/share.dart';
import 'package:fitpro_mamdu/features/shopping/shopping_view.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:fitpro_mamdu/state/week_changes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

class _FakeShare implements ShareController {
  final shared = <String>[];

  @override
  Future<void> shareText(String text, {String? subject}) async =>
      shared.add(text);
}

/// Danh sách mẫu T-116: thịt gà (Theo ngày, cấp đông được) dùng ngày 1 và 4; súp lơ (3 ngày) dùng ngày 1 và 3 → 1 đợt;
/// trứng (Theo tuần); nước mắm (Theo tuần, chưa có nguồn, nhà có sẵn); tỏi (Theo ngày nhưng nhà có sẵn).
ShoppingItem _item(
  String id,
  String name,
  String aisle, {
  required double needG,
  required int packs,
  required double packG,
  required String label,
  required double price,
  String? group,
  int? fresh,
  bool noInfo = false,
  bool freezable = false,
  bool pantry = false,
}) => ShoppingItem(
  ingredientId: id,
  name: name,
  aisle: aisle,
  needG: needG,
  packs: packs,
  packG: packG,
  packLabel: label,
  priceVndPerPack: price,
  usedCostVnd: needG / packG * price,
  tillCostVnd: packs * price,
  displayQty: '$packs $label',
  isDefaultPantry: pantry,
  isPantry: pantry,
  buyGroup: group,
  freshDays: fresh,
  noShelfInfo: group == null ? null : noInfo,
  freezableMeat: group == null ? null : freezable,
);

ShoppingList sampleList({int chickenWeekPacks = 1}) {
  ShoppingItem chicken(double need, int packs) => _item(
    'uc_ga',
    'Ức gà',
    'thit',
    needG: need,
    packs: packs,
    packG: 500,
    label: 'khay 500 g',
    price: 12000,
    group: 'day',
    fresh: 1,
    freezable: true,
  );
  final sup = _item(
    'sup_lo',
    'Súp lơ xanh',
    'rau_cu',
    needG: 200,
    packs: 1,
    packG: 300,
    label: 'bó 300 g',
    price: 20000,
    group: 'day',
    fresh: 3,
  );
  final egg = _item(
    'trung_ga',
    'Trứng gà',
    'trung_dau_phu',
    needG: 300,
    packs: 1,
    packG: 500,
    label: 'vỉ 10 quả',
    price: 40000,
    group: 'week',
    fresh: 21,
  );
  final fish = _item(
    'nuoc_mam',
    'Nước mắm',
    'gia_vi_dau',
    needG: 30,
    packs: 1,
    packG: 500,
    label: 'chai 500 ml',
    price: 30000,
    group: 'week',
    noInfo: true,
    pantry: true,
  );
  final garlic = _item(
    'toi',
    'Tỏi',
    'gia_vi_dau',
    needG: 20,
    packs: 1,
    packG: 100,
    label: 'gói 100 g',
    price: 10000,
    group: 'day',
    fresh: 3,
    pantry: true,
  );
  final items = [chicken(400, chickenWeekPacks), sup, egg, fish, garlic];
  return ShoppingList(
    items: items,
    byAisle: [
      AisleGroup(aisle: 'thit', items: [items[0]]),
      AisleGroup(aisle: 'trung_dau_phu', items: [egg]),
      AisleGroup(aisle: 'rau_cu', items: [sup]),
      AisleGroup(aisle: 'gia_vi_dau', items: [garlic, fish]),
    ],
    weekFoodCost: 70000,
    tillCost: 72000,
    trips: [
      ShoppingTrip(
        dayIndex: 0,
        items: [chicken(200, 1), sup, garlic],
        tillCost: 32000,
      ),
      ShoppingTrip(dayIndex: 3, items: [chicken(200, 1)], tillCost: 12000),
    ],
  );
}

MemoryStore _seeded({ShoppingList? list, Map<String, String>? extra}) {
  final s = completedStore();
  final plan = fixture('plan_response.json');
  (plan['plan'] as Map<String, dynamic>)['shopping'] = (list ?? sampleList())
      .toJson();
  s.data[StoreKeys.currentPlan] = jsonEncode(plan);
  if (extra != null) s.data.addAll(extra);
  return s;
}

Future<ProviderContainer> _pump(
  WidgetTester t, {
  MemoryStore? store,
  _FakeShare? share,
  // Tuần của fixture bắt đầu 09/11/2026: "hôm nay" là ngày đầu.
  DateTime? now,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 12000);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(
          store: store ?? _seeded(),
          adapter: FakeAdapter()
            ..on('GET', '/v1/reference', fixture('reference.json')),
        ),
        shareProvider.overrideWithValue(share ?? _FakeShare()),
        clockProvider.overrideWithValue(() => now ?? DateTime(2026, 11, 9, 8)),
      ],
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  await t.tap(find.text('Đi chợ'));
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

String _text(WidgetTester t, String key) =>
    t.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  group('Đi chợ 2 chế độ (D-SHP-06)', () {
    testWidgets(
      'lần đầu mở: Theo tuần; chỉ có dòng nhóm tuần, thịt cá/rau tươi không có ở đây',
      (t) async {
        await _pump(t);
        expect(find.byKey(const Key('shop-mode')), findsOneWidget);
        final seg = t.widget<SegmentedButton<ShopMode>>(
          find.byKey(const Key('shop-mode')),
        );
        expect(seg.selected, {ShopMode.weekly});
        expect(find.byKey(const Key('item-trung_ga')), findsOneWidget);
        expect(find.byKey(const Key('item-uc_ga')), findsNothing);
        expect(find.byKey(const Key('item-sup_lo')), findsNothing);
        expect(find.byKey(const Key('trip-0')), findsNothing);
        // tổng của chế độ + đếm riêng chế độ + tổng toàn tab
        expect(_text(t, 'shop-mode-total'), 'Mua theo tuần: 40.000 ₫');
        expect(_text(t, 'shop-mode-progress'), 'Đã mua 0/1 món');
        expect(_text(t, 'shop-progress'), 'Đã mua 0/4 món');
        // nhãn "Dùng trong N ngày" ở Theo tuần; "Nhà có sẵn" chỉ ở Theo tuần
        expect(_text(t, 'item-trung_ga-fresh'), 'Dùng trong 21 ngày');
        expect(find.byKey(const Key('item-trung_ga-pantry')), findsOneWidget);
        expect(find.byKey(const Key('pantry-nuoc_mam')), findsOneWidget);
        expect(find.byKey(const Key('pantry-toi')), findsOneWidget);
      },
    );

    testWidgets(
      'tổng cả tuần = tuần + ngày, hiện số chênh do mua theo đợt; chi phí món ăn không đổi',
      (t) async {
        await _pump(t);
        final till = find.byKey(const Key('shop-till-cost'));
        // tuần 40.000 + đợt 1 (gà 12.000 + súp lơ 20.000) + đợt 2 (gà 12.000) = 84.000; mua một lần: 72.000
        expect(
          find.descendant(of: till, matching: find.text('84.000 ₫')),
          findsOneWidget,
        );
        expect(_text(t, 'shop-batch-extra'), '+12.000 ₫ do mua theo đợt');
        expect(
          find.descendant(
            of: find.byKey(const Key('shop-food-cost')),
            matching: find.text('50.733 ₫'),
          ),
          findsOneWidget,
        );
        expect(
          _text(t, 'shop-budget-status'),
          'Chi phí món ăn tuần này nằm trong ngân sách (dư 599.267 ₫).',
        );
      },
    );

    testWidgets(
      'chuyển sang Theo ngày: đợt "Hôm nay" mở sẵn, đợt sau gập; tổng và đếm theo đợt; chế độ được nhớ',
      (t) async {
        final store = _seeded();
        await _pump(t, store: store);
        await t.tap(find.byKey(const Key('shop-mode-daily')));
        await t.pumpAndSettle();
        expect(_text(t, 'trip-0-title'), 'Hôm nay · Thứ Hai · 09/11');
        expect(_text(t, 'trip-3-title'), 'Thứ Năm · 12/11');
        expect(
          _text(t, 'trip-0-summary'),
          'Đã mua 0/2 món · Đợt này: 32.000 ₫',
        );
        expect(
          _text(t, 'trip-3-summary'),
          'Đã mua 0/1 món · Đợt này: 12.000 ₫',
        );
        expect(_text(t, 'shop-mode-total'), 'Mua theo ngày: 44.000 ₫');
        expect(_text(t, 'shop-mode-progress'), 'Đã mua 0/3 món');
        // đợt hôm nay mở: có dòng gà + súp lơ (1 lần cho cả ngày 1 và 3), tỏi có sẵn thì không có
        expect(find.byKey(const Key('trip-0-uc_ga')), findsOneWidget);
        expect(find.byKey(const Key('trip-0-sup_lo')), findsOneWidget);
        expect(find.byKey(const Key('trip-0-toi')), findsNothing);
        // đợt ngày 4 gập sẵn
        expect(find.byKey(const Key('trip-3-uc_ga')), findsNothing);
        await t.tap(find.byKey(const Key('trip-3-title')));
        await t.pumpAndSettle();
        expect(find.byKey(const Key('trip-3-uc_ga')), findsOneWidget);
        // nhãn dùng trong N ngày ở Theo ngày; không có nút "Nhà có sẵn", không có nhóm tuần
        expect(_text(t, 'trip-0-sup_lo-fresh'), 'Dùng trong 3 ngày');
        expect(find.byKey(const Key('trip-0-sup_lo-pantry')), findsNothing);
        expect(find.byKey(const Key('item-trung_ga')), findsNothing);
        expect(find.byKey(const Key('pantry-section')), findsNothing);
        // nhớ chế độ trên máy
        expect(jsonDecode(store.data[StoreKeys.shopView]!), {
          'mode': 'daily',
          'freeze_meat': false,
        });
      },
    );

    testWidgets('mở lại app: vào thẳng chế độ gần nhất', (t) async {
      await _pump(
        t,
        store: _seeded(
          extra: {
            StoreKeys.shopView: jsonEncode({
              'mode': 'daily',
              'freeze_meat': false,
            }),
          },
        ),
      );
      expect(find.byKey(const Key('trip-0')), findsOneWidget);
      expect(find.byKey(const Key('item-trung_ga')), findsNothing);
    });

    testWidgets(
      'đánh dấu đã mua tính riêng từng chế độ và từng đợt, cộng lại ở đầu tab',
      (t) async {
        final c = await _pump(t);
        await t.tap(find.byKey(const Key('item-trung_ga-check')));
        await t.pumpAndSettle();
        expect(_text(t, 'shop-mode-progress'), 'Đã mua 1/1 món');
        expect(_text(t, 'shop-progress'), 'Đã mua 1/4 món');
        await t.tap(find.byKey(const Key('shop-mode-daily')));
        await t.pumpAndSettle();
        expect(_text(t, 'shop-mode-progress'), 'Đã mua 0/3 món');
        await t.tap(find.byKey(const Key('trip-0-uc_ga-check')));
        await t.pumpAndSettle();
        expect(_text(t, 'trip-0-summary'), startsWith('Đã mua 1/2 món'));
        expect(_text(t, 'shop-mode-progress'), 'Đã mua 1/3 món');
        expect(_text(t, 'shop-progress'), 'Đã mua 2/4 món');
        // gà ở đợt ngày 4 là lần mua khác: chưa đánh dấu
        await t.tap(find.byKey(const Key('trip-3-title')));
        await t.pumpAndSettle();
        expect(
          t.widget<Checkbox>(find.byKey(const Key('trip-3-uc_ga-check'))).value,
          isFalse,
        );
        expect(c.read(shoppingStateProvider).bought, {
          'trung_ga',
          'trip:0:uc_ga',
        });
      },
    );

    testWidgets(
      'công tắc "mua thịt cá cả tuần rồi cấp đông": gà sang Theo tuần kèm hướng dẫn, rút khỏi các đợt, tổng đổi theo',
      (t) async {
        final store = _seeded();
        await _pump(t, store: store);
        expect(find.byKey(const Key('shop-freeze')), findsOneWidget);
        await t.tap(find.byKey(const Key('shop-freeze')));
        await t.pumpAndSettle();
        // Theo tuần: trứng 40.000 + gà 12.000 (mua một gói cả tuần)
        expect(_text(t, 'shop-mode-total'), 'Mua theo tuần: 52.000 ₫');
        expect(find.byKey(const Key('item-uc_ga')), findsOneWidget);
        expect(
          _text(t, 'item-uc_ga-freeze'),
          'Cấp đông ngay sau khi mua, rã đông trước 1 ngày khi nấu.',
        );
        expect(find.byKey(const Key('item-trung_ga-freeze')), findsNothing);
        // tổng cả tuần = tuần 52.000 + đợt (chỉ súp lơ) 20.000 = 72.000 = mua một lần → không còn dòng chênh
        expect(
          find.descendant(
            of: find.byKey(const Key('shop-till-cost')),
            matching: find.text('72.000 ₫'),
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('shop-batch-extra')), findsNothing);
        await t.tap(find.byKey(const Key('shop-mode-daily')));
        await t.pumpAndSettle();
        expect(find.byKey(const Key('trip-0-uc_ga')), findsNothing);
        expect(find.byKey(const Key('trip-0-sup_lo')), findsOneWidget);
        expect(
          find.byKey(const Key('trip-3')),
          findsNothing,
        ); // đợt chỉ có gà đã chuyển đi
        expect(_text(t, 'shop-mode-total'), 'Mua theo ngày: 20.000 ₫');
        expect(jsonDecode(store.data[StoreKeys.shopView]!), {
          'mode': 'daily',
          'freeze_meat': true,
        });
      },
    );

    testWidgets(
      'bỏ đánh dấu nhà có sẵn ở Theo tuần: tỏi vào đợt mua của Theo ngày',
      (t) async {
        await _pump(t);
        await t.tap(find.byKey(const Key('pantry-toi-need')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('shop-mode-daily')));
        await t.pumpAndSettle();
        expect(find.byKey(const Key('trip-0-toi')), findsOneWidget);
        expect(_text(t, 'shop-mode-total'), 'Mua theo ngày: 54.000 ₫');
      },
    );

    testWidgets(
      'chênh > 15% và có thịt cá cấp đông được ở Theo ngày → gợi ý bật cấp đông; bấm nút thì bật công tắc',
      (t) async {
        final store = _seeded();
        final c = await _pump(t, store: store);
        // 84.000 so với 72.000 = +16,7% > 15%; bật cấp đông còn 72.000 → bớt 12.000
        expect(
          _text(t, 'shop-freeze-hint-text'),
          'Mua thịt cá cả tuần rồi cấp đông để bớt khoảng 12.000 ₫',
        );
        expect(find.text('Bật cấp đông'), findsOneWidget);
        await t.tap(find.byKey(const Key('shop-freeze-hint-on')));
        await t.pumpAndSettle();
        expect(c.read(shopViewProvider).freezeMeat, isTrue);
        expect(
          t
              .widget<Switch>(
                find.descendant(
                  of: find.byKey(const Key('shop-freeze')),
                  matching: find.byType(Switch),
                ),
              )
              .value,
          isTrue,
        );
        expect(find.byKey(const Key('shop-freeze-hint')), findsNothing);
        expect(
          jsonDecode(store.data[StoreKeys.shopView]!)['freeze_meat'],
          true,
        );
      },
    );

    testWidgets('chênh ≤ 15% hoặc đã bật cấp đông thì không gợi ý', (t) async {
      // gà 1 gói cả tuần nhưng đợt: 2 × 12.000 → 84.000/72.000. Đổi giá để chênh nhỏ: súp lơ đắt hơn làm mốc lớn hơn
      final list = sampleList();
      final bigger = ShoppingList(
        items: [
          for (final it in list.items)
            it.ingredientId == 'trung_ga'
                ? ShoppingItem(
                    ingredientId: it.ingredientId,
                    name: it.name,
                    aisle: it.aisle,
                    needG: it.needG,
                    packs: it.packs,
                    packG: it.packG,
                    packLabel: it.packLabel,
                    priceVndPerPack: 140000,
                    usedCostVnd: 100000,
                    tillCostVnd: 140000,
                    displayQty: it.displayQty,
                    buyGroup: 'week',
                    freshDays: 21,
                    noShelfInfo: false,
                    freezableMeat: false,
                  )
                : it,
        ],
        byAisle: list.byAisle,
        weekFoodCost: list.weekFoodCost,
        tillCost: 172000,
        trips: list.trips,
      );
      await _pump(t, store: _seeded(list: bigger));
      // mốc 172.000, tổng mới 184.000 → +7% ≤ 15%
      expect(find.byKey(const Key('shop-freeze-hint')), findsNothing);
      expect(find.byKey(const Key('shop-batch-extra')), findsOneWidget);
    });

    testWidgets(
      'chênh âm hiện "−X ₫ nhờ mua theo cân" và không gợi ý cấp đông',
      (t) async {
        // mua một lần: gà 3 gói (36.000); mua theo cân ở các đợt chỉ còn 2 × 12.000
        await _pump(t, store: _seeded(list: sampleList(chickenWeekPacks: 3)));
        expect(_text(t, 'shop-batch-extra'), '−12.000 ₫ nhờ mua theo cân');
        expect(find.byKey(const Key('shop-freeze-hint')), findsNothing);
      },
    );

    testWidgets('chia sẻ theo đúng chế độ đang xem', (t) async {
      final share = _FakeShare();
      await _pump(t, share: share);
      await t.tap(find.byKey(const Key('shop-mode-daily')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('shop-share')));
      await t.pumpAndSettle();
      final text = share.shared.single;
      expect(text, contains('Hôm nay · Thứ Hai · 09/11'));
      expect(text, contains('☐ Ức gà'));
      expect(text, contains('Thứ Năm · 12/11'));
      expect(text, isNot(contains('Trứng gà')));
      expect(text, contains('Ước tính trả tại quầy: 44.000 ₫'));
    });

    testWidgets(
      'kế hoạch lưu từ bản cũ (chưa có nhóm mua) không hiện chọn chế độ',
      (t) async {
        final legacy = ShoppingList(
          items: [
            for (final it in sampleList().items)
              ShoppingItem(
                ingredientId: it.ingredientId,
                name: it.name,
                aisle: it.aisle,
                needG: it.needG,
                packs: it.packs,
                packG: it.packG,
                packLabel: it.packLabel,
                priceVndPerPack: it.priceVndPerPack,
                usedCostVnd: it.usedCostVnd,
                tillCostVnd: it.tillCostVnd,
                displayQty: it.displayQty,
              ),
          ],
          byAisle: [
            AisleGroup(aisle: 'thit', items: [sampleList().items.first]),
          ],
        );
        await _pump(t, store: _seeded(list: legacy));
        expect(find.byKey(const Key('shop-mode')), findsNothing);
        expect(find.byKey(const Key('item-uc_ga')), findsOneWidget);
      },
    );

    testWidgets('đợt của ngày đã qua xếp cuối và ghi "Đã qua"', (t) async {
      await _pump(
        t,
        now: DateTime(2026, 11, 11, 8),
      ); // hôm nay = ngày thứ 3 → đợt ngày 1 đã qua
      await t.tap(find.byKey(const Key('shop-mode-daily')));
      await t.pumpAndSettle();
      expect(_text(t, 'trip-0-title'), 'Thứ Hai · 09/11 · Đã qua');
      expect(_text(t, 'trip-3-title'), 'Thứ Năm · 12/11');
      final upcoming = t.getTopLeft(find.byKey(const Key('trip-3'))).dy;
      final past = t.getTopLeft(find.byKey(const Key('trip-0'))).dy;
      expect(upcoming, lessThan(past));
    });
  });

  group('Logic Theo tuần / Theo ngày', () {
    test('modeTotals: tổng, đếm, chênh do mua theo đợt', () {
      final l = sampleList();
      const st = ShoppingState();
      final off = modeTotals(l, st, const ShopViewPrefs());
      expect((off.weeklyTill, off.dailyTill, off.total), (40000, 44000, 84000));
      expect((off.weeklyCount, off.dailyCount), (1, 3));
      expect(off.delta, 12000);
      expect(off.baseline, 72000);
      expect(off.deltaRatio, closeTo(12000 / 72000, 1e-9));
      final on = modeTotals(l, st, const ShopViewPrefs(freezeMeat: true));
      expect((on.weeklyTill, on.dailyTill), (52000, 20000));
      expect(on.delta, 0);
    });

    test('inWeekly: kế hoạch cũ không có nhóm → Theo tuần', () {
      final it = ShoppingItem(ingredientId: 'x', name: 'x');
      expect(inWeekly(it, const ShopViewPrefs()), isTrue);
    });

    test('tripHeading: hôm nay, sắp tới, đã qua', () {
      // cần AppL10n: dùng bản tiếng Việt trực tiếp
      final l = lookupAppL10n(const Locale('vi'));
      final now = DateTime(2026, 11, 10);
      expect(tripHeading(l, '2026-11-09', 1, now), 'Hôm nay · Thứ Ba · 10/11');
      expect(tripHeading(l, '2026-11-09', 0, now), 'Thứ Hai · 09/11 · Đã qua');
      expect(tripHeading(l, '2026-11-09', 2, now), 'Thứ Tư · 11/11');
    });
  });
}
