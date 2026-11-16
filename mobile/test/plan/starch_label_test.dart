import 'dart:convert';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/wakelock.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

class _Wakelock implements WakelockController {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

/// T-102 / D-COM-06 — nhãn vai trò của món tinh bột trong danh sách mâm: "CƠM" khi `rice.kind = com`,
/// "TINH BỘT" khi `other` (khoai lang, bún...).
void main() {
  Future<String> carbRoleLabel(
    WidgetTester t, {
    required String dishName,
    required String kind,
  }) async {
    final plan = fixture('plan_response.json');
    final days = (plan['plan'] as Map<String, dynamic>)['days'] as List;
    final meal =
        (days.firstWhere((d) => d['date'] == '2026-11-09')['meals'] as List)
                .firstWhere((m) => m['slot'] == 'lunch')
            as Map<String, dynamic>;
    final dish = (meal['dishes'] as List).firstWhere(
      (d) => d['role'] == 'carb_base',
    ) as Map<String, dynamic>;
    dish['name'] = dishName;
    meal['rice'] = {
      'habit': 'vua',
      'target_g': 150,
      'actual_g': 150,
      'kind': kind,
      'rice_equiv_g': 150,
    };
    final store = completedStore();
    store.data[StoreKeys.currentPlan] = jsonEncode(plan);
    store.data[StoreKeys.preferences] = jsonEncode(
      Defaults.preferences.toJson(),
    );
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(800, 9000);
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(store: store),
          wakelockProvider.overrideWithValue(_Wakelock()),
        ],
        child: const FitProApp(),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('meal-2026-11-09-lunch')));
    await t.pumpAndSettle();
    final card = find.byKey(Key('dish-${dish['recipe_id']}'));
    expect(card, findsOneWidget);
    for (final label in ['CƠM', 'TINH BỘT']) {
      if (find
          .descendant(of: card, matching: find.text(label))
          .evaluate()
          .isNotEmpty) {
        return label;
      }
    }
    return '';
  }

  testWidgets('cơm (kind = com) → nhãn CƠM', (t) async {
    expect(await carbRoleLabel(t, dishName: 'Cơm gạo lứt', kind: 'com'), 'CƠM');
  });

  testWidgets('khoai lang (kind = other) → nhãn TINH BỘT', (t) async {
    expect(
      await carbRoleLabel(t, dishName: 'Khoai lang hấp', kind: 'other'),
      'TINH BỘT',
    );
  });

  testWidgets('bún (kind = other) → nhãn TINH BỘT', (t) async {
    expect(
      await carbRoleLabel(t, dishName: 'Bún tươi', kind: 'other'),
      'TINH BỘT',
    );
  });
}
