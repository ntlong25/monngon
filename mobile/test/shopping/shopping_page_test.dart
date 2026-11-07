import 'dart:convert';

import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/share.dart';
import 'package:fitpro_mamdu/features/shopping/shopping_view.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

class FakeShare implements ShareController {
  final shared = <String>[];

  @override
  Future<void> shareText(String text, {String? subject}) async =>
      shared.add(text);
}

AisleGroup _group(String aisle) => AisleGroup(
  aisle: aisle,
  items: [ShoppingItem(ingredientId: aisle, name: aisle)],
);

MemoryStore seeded({String? shopping}) {
  final s = completedStore();
  s.data[StoreKeys.currentPlan] = jsonEncode(fixture('plan_response.json'));
  if (shopping != null) s.data[StoreKeys.shopping] = shopping;
  return s;
}

FakeAdapter api() =>
    FakeAdapter()..on('GET', '/v1/reference', fixture('reference.json'));

Future<ProviderContainer> pumpShopping(
  WidgetTester t, {
  MemoryStore? store,
  FakeShare? share,
  FakeAdapter? adapter,
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 12000);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(store: store ?? seeded(), adapter: adapter ?? api()),
        shareProvider.overrideWithValue(share ?? FakeShare()),
      ],
      child: const FitProApp(),
    ),
  );
  await t.pumpAndSettle();
  await t.tap(find.text('Đi chợ'));
  await t.pumpAndSettle();
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

String textOf(WidgetTester t, String key) =>
    t.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  group('Tab Đi chợ (US-4.1)', () {
    testWidgets('chưa có tuần → trạng thái rỗng', (t) async {
      await pumpShopping(t, store: completedStore());
      expect(find.text('Chưa có danh sách'), findsOneWidget);
      expect(find.byKey(const Key('shop-share')), findsNothing);
    });

    testWidgets(
      'hai con số chi phí có nhãn "ước tính" + ngày khảo sát giá + so với ngân sách',
      (t) async {
        await pumpShopping(t);
        // chi phí món ăn (gồm cả đồ nhà có sẵn, D-SHP-01) / trả tại quầy (đã trừ món nhà có sẵn mặc định: gia vị, dầu…)
        final food = find.byKey(const Key('shop-food-cost'));
        final till = find.byKey(const Key('shop-till-cost'));
        expect(
          find.descendant(
            of: food,
            matching: find.text('Chi phí món ăn tuần này'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: food, matching: find.text('582.622 ₫')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: till,
            matching: find.text('Ước tính trả tại quầy'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: till, matching: find.text('1.342.390 ₫')),
          findsOneWidget,
        );
        expect(find.text('ước tính'), findsNWidgets(2));
        expect(textOf(t, 'shop-survey'), 'Giá khảo sát ngày 06/11/2026');
        // ngân sách 650.000 so với chi phí món ăn 582.622 → còn dư 67.378
        expect(textOf(t, 'shop-budget'), 'Ngân sách tuần 650.000 ₫');
        // D-QA-02: câu nêu rõ đối tượng so là chi phí món ăn
        expect(
          textOf(t, 'shop-budget-status'),
          'Chi phí món ăn tuần này nằm trong ngân sách (dư 67.378 ₫).',
        );
        // tiền tại quầy (1.342.390 ₫) cao hơn ngân sách → thêm dòng thông tin trung tính
        expect(
          textOf(t, 'shop-till-info'),
          'Lần đi chợ này ước tính 1.342.390 ₫, cao hơn ngân sách vì mua nguyên gói; phần dư dùng tiếp cho tuần sau.',
        );
      },
    );

    testWidgets(
      'tiền tại quầy không vượt ngân sách → không có dòng thông tin',
      (t) async {
        final j = fixture('plan_response.json');
        (j['plan'] as Map<String, dynamic>)['budget_vnd'] = 2000000;
        final s = completedStore();
        s.data[StoreKeys.currentPlan] = jsonEncode(j);
        await pumpShopping(t, store: s);
        expect(
          textOf(t, 'shop-budget-status'),
          'Chi phí món ăn tuần này nằm trong ngân sách (dư 1.417.378 ₫).',
        );
        expect(find.byKey(const Key('shop-till-info')), findsNothing);
      },
    );

    testWidgets('nhóm theo quầy đúng thứ tự, kèm số gói theo bao bì cửa hàng', (
      t,
    ) async {
      await pumpShopping(t);
      expect(textOf(t, 'aisle-title-thit'), 'Thịt');
      expect(textOf(t, 'aisle-title-rau_cu'), 'Rau củ');
      final order = [
        'aisle-thit',
        'aisle-ca_hai_san',
        'aisle-trung_dau_phu',
        'aisle-rau_cu',
        'aisle-trai_cay',
        'aisle-gao_do_kho',
        'aisle-sua',
      ];
      var last = -1.0;
      for (final k in order) {
        final y = t.getTopLeft(find.byKey(Key(k))).dy;
        expect(y, greaterThan(last), reason: k);
        last = y;
      }
      // quầy chỉ có món nhà đã có sẵn thì không hiện (gia vị & dầu có gừng… đều mặc định có sẵn)
      expect(find.byKey(const Key('aisle-gia_vi_dau')), findsNothing);
      expect(
        textOf(t, 'item-thit_heo_xay_nac-qty'),
        '5 × thịt heo xay C.P 200 g',
      );
      expect(textOf(t, 'item-thit_heo_xay_nac-price'), '112.390 ₫');
      expect(
        find.text('Cần 810 g · Dư 190 g · Dùng trong 3 ngày'),
        findsOneWidget,
      );
    });

    testWidgets('đánh dấu đã mua → tiến độ đổi và lưu lại sau khi mở app lại', (
      t,
    ) async {
      final store = seeded();
      final c = await pumpShopping(t, store: store);
      expect(textOf(t, 'shop-progress'), 'Đã mua 0/29 món');
      await t.tap(find.byKey(const Key('item-bap_cai-check')));
      await t.pumpAndSettle();
      expect(c.read(shoppingStateProvider).bought, {'bap_cai'});
      expect(textOf(t, 'shop-progress'), 'Đã mua 1/29 món');
      // chạm cả dòng cũng đánh dấu
      await t.tap(find.byKey(const Key('item-ca_chua')));
      await t.pumpAndSettle();
      expect(textOf(t, 'shop-progress'), 'Đã mua 2/29 món');

      // tắt app rồi mở lại trên cùng kho
      await t.pumpWidget(const SizedBox());
      await pumpShopping(t, store: store);
      expect(textOf(t, 'shop-progress'), 'Đã mua 2/29 món');
      expect(
        t.widget<Checkbox>(find.byKey(const Key('item-bap_cai-check'))).value,
        isTrue,
      );
      // chạm lần nữa: bỏ đánh dấu
      await t.tap(find.byKey(const Key('item-bap_cai-check')));
      await t.pumpAndSettle();
      expect(textOf(t, 'shop-progress'), 'Đã mua 1/29 món');
    });

    testWidgets(
      'nhà có sẵn: gợi ý mặc định, đổi tay, trừ khỏi chi phí và lưu lại',
      (t) async {
        final store = seeded();
        final c = await pumpShopping(t, store: store);
        // gợi ý mặc định: dầu ăn nằm ở mục "Nhà đã có sẵn", không có ở quầy
        expect(textOf(t, 'pantry-section'), 'Nhà đã có sẵn (9)');
        expect(find.byKey(const Key('pantry-dau_an')), findsOneWidget);
        // D-SHP-01: mỗi dòng nhà có sẵn ghi "Nếu phải mua: +X ₫" theo tiền gói của nó
        final ifBuy = t
            .widget<Text>(find.byKey(const Key('pantry-dau_an-ifbuy')))
            .data!;
        expect(ifBuy, matches(RegExp(r'^Nếu phải mua: \+[\d.]+ ₫$')));
        expect(find.byKey(const Key('item-dau_an')), findsNothing);

        // bỏ món cà chua khỏi danh sách mua: tiền tại quầy giảm đúng phần của nó, chi phí món ăn (ngân sách) không đổi
        await t.tap(find.byKey(const Key('item-ca_chua-pantry')));
        await t.pumpAndSettle();
        expect(
          c.read(shoppingStateProvider).pantryOverrides['ca_chua'],
          isTrue,
        );
        expect(textOf(t, 'pantry-section'), 'Nhà đã có sẵn (10)');
        expect(find.byKey(const Key('item-ca_chua')), findsNothing);
        final till = find.byKey(const Key('shop-till-cost'));
        expect(
          find.descendant(of: till, matching: find.text('1.312.390 ₫')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('shop-food-cost')),
            matching: find.text('582.622 ₫'),
          ),
          findsOneWidget,
        );

        // đổi ý với món mặc định có sẵn: dầu ăn cần mua
        await t.tap(find.byKey(const Key('pantry-dau_an-need')));
        await t.pumpAndSettle();
        expect(
          c.read(shoppingStateProvider).pantryOverrides['dau_an'],
          isFalse,
        );
        expect(find.byKey(const Key('item-dau_an')), findsOneWidget);

        // lưu lại khi mở lại app
        await t.pumpWidget(const SizedBox());
        await pumpShopping(t, store: store);
        expect(find.byKey(const Key('item-ca_chua')), findsNothing);
        expect(find.byKey(const Key('item-dau_an')), findsOneWidget);
      },
    );

    testWidgets('vượt ngân sách hiện cảnh báo số tiền vượt', (t) async {
      final j = fixture('plan_response.json');
      (j['plan'] as Map<String, dynamic>)['budget_vnd'] = 500000;
      final s = completedStore();
      s.data[StoreKeys.currentPlan] = jsonEncode(j);
      await pumpShopping(t, store: s);
      expect(textOf(t, 'shop-budget'), 'Ngân sách tuần 500.000 ₫');
      expect(
        textOf(t, 'shop-budget-status'),
        'Chi phí món ăn tuần này vượt ngân sách 82.622 ₫.',
      );
      // vượt ngân sách theo chi phí món ăn: vẫn có dòng thông tin về tiền tại quầy, không phải cảnh báo thứ hai
      expect(find.byKey(const Key('shop-till-info')), findsOneWidget);
    });

    testWidgets(
      'chia sẻ gửi danh sách dạng văn bản: chưa mua theo quầy, bỏ món có sẵn',
      (t) async {
        final share = FakeShare();
        await pumpShopping(t, share: share);
        await t.tap(find.byKey(const Key('item-bap_cai-check')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('shop-share')));
        await t.pumpAndSettle();
        expect(share.shared, hasLength(1));
        final text = share.shared.single;
        expect(text, startsWith('Danh sách đi chợ 09/11 – 15/11'));
        expect(
          text,
          contains(
            '\n\nThịt\n☐ Thịt heo xay (nạc ~96%) — 5 × thịt heo xay C.P 200 g',
          ),
        );
        expect(text, contains('☑ Bắp cải — 2 kg (ước tính)'));
        expect(text, isNot(contains('Dầu ăn')));
        expect(text, contains('Ước tính trả tại quầy: 1.342.390 ₫'));
        expect(text, contains('Giá khảo sát ngày 06/11/2026'));
      },
    );
  });

  group('Logic danh sách đi chợ', () {
    final plan = samplePlan();
    final list = plan.plan.shopping;

    test('totalsOf: tiền tại quầy trừ món nhà có sẵn, chi phí món ăn thì không, và đếm đã mua', () {
      final base = totalsOf(list, const ShoppingState());
      expect(base.pantry, 9);
      expect(base.toBuy, 29);
      expect(base.foodCost.round(), 582622); // gồm cả đồ nhà có sẵn
      expect(base.pantryCostIfBuy, greaterThan(0));
      final st = const ShoppingState(
        bought: {'bap_cai'},
        pantryOverrides: {'dau_an': false, 'bap_cai': true},
      );
      final t = totalsOf(list, st);
      // bắp cải thành "có sẵn" nên không tính đã mua; dầu ăn cần mua
      expect(t.bought, 0);
      expect(t.toBuy, 29);
    });

    test('isPantry: cờ is_pantry của server thắng gợi ý mặc định, lựa chọn tay thắng cả hai', () {
      final it = list.items.first.copyWith(
        isPantry: true,
        isDefaultPantry: false,
      );
      expect(isPantry(it, const ShoppingState()), isTrue);
      final off = it.copyWith(isPantry: false, isDefaultPantry: true);
      expect(isPantry(off, const ShoppingState()), isFalse);
      expect(
        isPantry(off, ShoppingState(pantryOverrides: {off.ingredientId: true})),
        isTrue,
      );
    });

    test('orderedAisles theo thứ tự đi chợ, quầy lạ xếp cuối', () {
      final shuffled = ShoppingList(
        byAisle: [_group('sua'), _group('la_hoa'), _group('thit')],
      );
      expect(orderedAisles(shuffled).map((g) => g.aisle).toList(), [
        'thit',
        'sua',
        'la_hoa',
      ]);
    });

    test('fullDate dd/MM/yyyy, rỗng khi thiếu', () {
      expect(fullDate('2026-11-06'), '06/11/2026');
      expect(fullDate(null), '');
      expect(
        lookupAppL10n(const Locale('vi')).shopProgress('1', '2'),
        isNotEmpty,
      );
    });
  });
}
