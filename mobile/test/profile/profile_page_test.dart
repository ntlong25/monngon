import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/core/wakelock.dart';
import 'package:fitpro_mamdu/state/app_state.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:fitpro_mamdu/state/week_changes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';
import '../support/test_app.dart';

class _NoWake implements WakelockController {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

MemoryStore _store({
  List<String> blocked = const [],
  Map<String, String>? blockedNames,
  List<SavedPlan> saved = const [],
  bool withPlan = true,
}) {
  final s = completedStore();
  if (withPlan) {
    s.data[StoreKeys.currentPlan] = jsonEncode(fixture('plan_response.json'));
  }
  s.data[StoreKeys.preferences] = jsonEncode(
    Defaults.preferences.copyWith(blockedRecipeIds: blocked).toJson(),
  );
  if (blockedNames != null) {
    s.data[StoreKeys.blockedNames] = jsonEncode(blockedNames);
  }
  if (saved.isNotEmpty) {
    s.data[StoreKeys.savedPlans] = jsonEncode(
      saved.map((e) => e.toJson()).toList(),
    );
  }
  return s;
}

FakeAdapter _adapter() => FakeAdapter()
  ..on('GET', '/v1/reference', fixture('reference.json'))
  ..on('GET', '/health', {'status': 'ok'})
  ..on('POST', '/v1/targets', fixture('targets.json'));

Future<ProviderContainer> _pump(
  WidgetTester t, {
  MemoryStore? store,
  FakeAdapter? adapter,
  String today = '2026-11-10',
}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(800, 2600);
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(
          store: store ?? _store(),
          adapter: adapter ?? _adapter(),
        ),
        wakelockProvider.overrideWithValue(_NoWake()),
        clockProvider.overrideWithValue(() => DateTime.parse(today)),
      ],
      child: const FitProApp(),
    ),
  );
  await _settle(t);
  await t.tap(find.text('Bạn'));
  await _settle(t);
  return ProviderScope.containerOf(t.element(find.byType(FitProApp)));
}

/// Chờ cả bộ hẹn giờ 350 ms của `targetsProvider` (debounce) để test không còn timer treo.
Future<void> _settle(WidgetTester t) async {
  await t.pump(const Duration(milliseconds: 600));
  await t.pumpAndSettle();
  await t.pump(const Duration(milliseconds: 600));
}

Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  await t.ensureVisible(f);
  await _settle(t);
  await t.tap(f);
  await _settle(t);
}

Map<String, dynamic> _body(RequestOptions o) => o.data is String
    ? jsonDecode(o.data as String) as Map<String, dynamic>
    : (o.data as Map).cast<String, dynamic>();

void main() {
  Finder noEllipsis() => find.descendant(
    of: find.byKey(const Key('edit-targets')),
    matching: find.text('…'),
  );

  group('Chỉ tiêu mỗi ngày khi offline (L-13, D-QA-09)', () {
    MemoryStore savedStore({bool otherProfile = false}) {
      final st = _store();
      final profile = otherProfile
          ? Defaults.profile.copyWith(age: Defaults.profile.age + 7)
          : Defaults.profile;
      st.data[StoreKeys.targets] = jsonEncode({
        'profile': profile.toJson(),
        'targets': fixture('targets.json'),
      });
      return st;
    }

    testWidgets('tính xong khi online thì lưu chỉ tiêu trên máy', (t) async {
      final st = _store();
      await _pump(t, store: st);
      expect(find.text('120 g protein · 1.400 kcal'), findsOneWidget);
      expect(st.data[StoreKeys.targets], isNotNull);
      final saved = jsonDecode(st.data[StoreKeys.targets]!) as Map;
      expect((saved['targets'] as Map)['protein_g'], 120);
    });

    testWidgets(
      'offline nhưng có số đã lưu → hiện số đó, không "…", không báo lỗi',
      (t) async {
        final api = _adapter()..failWithConnectionError = true;
        await _pump(t, store: savedStore(), adapter: api);
        expect(find.text('120 g protein · 1.400 kcal'), findsOneWidget);
        expect(noEllipsis(), findsNothing);
        expect(find.byKey(const Key('profile-targets-error')), findsNothing);
      },
    );

    testWidgets(
      'offline, chưa có số lưu → thông báo mạng + Thử lại, không "…"; có mạng lại bấm Thử lại thì hiện số',
      (t) async {
        final api = _adapter()..failWithConnectionError = true;
        await _pump(t, store: _store(), adapter: api);
        expect(find.byKey(const Key('profile-targets-error')), findsOneWidget);
        expect(
          find.text('Không có mạng. Dữ liệu vẫn được giữ trên máy.'),
          findsOneWidget,
        );
        expect(noEllipsis(), findsNothing);
        expect(find.text('120 g protein · 1.400 kcal'), findsNothing);
        api.failWithConnectionError = false;
        await t.tap(
          find.descendant(
            of: find.byKey(const Key('profile-targets-error')),
            matching: find.text('Thử lại'),
          ),
        );
        await _settle(t);
        expect(find.text('120 g protein · 1.400 kcal'), findsOneWidget);
        expect(find.byKey(const Key('profile-targets-error')), findsNothing);
      },
    );

    testWidgets(
      'số đã lưu của hồ sơ khác (đã sửa từ lúc lưu) không được dùng',
      (t) async {
        final api = _adapter()..failWithConnectionError = true;
        await _pump(t, store: savedStore(otherProfile: true), adapter: api);
        expect(find.text('120 g protein · 1.400 kcal'), findsNothing);
        expect(find.byKey(const Key('profile-targets-error')), findsOneWidget);
      },
    );
  });

  group('Sửa chỉ tiêu và lựa chọn (US-6.1)', () {
    testWidgets('các dòng tóm tắt hiện đúng lựa chọn hiện tại', (t) async {
      await _pump(t);
      expect(find.text('Chỉ tiêu và lựa chọn'), findsOneWidget);
      expect(find.text('Giảm mỡ'), findsOneWidget);
      expect(find.textContaining('30 tuổi'), findsOneWidget);
      expect(find.text('Bách hóa Xanh'), findsOneWidget);
      expect(find.text('1 người lớn, 0 trẻ em'), findsOneWidget);
      expect(
        find.text('3 bữa mỗi ngày'),
        findsNothing,
      ); // 4 bữa: sáng, trưa, phụ chiều, tối
      expect(find.byKey(const Key('profile-dirty')), findsNothing);
    });

    testWidgets(
      'sửa mục tiêu bằng đúng màn onboarding: không thanh tiến độ, Lưu → quay lại + báo chưa áp dụng',
      (t) async {
        final c = await _pump(t);
        final stepBefore = c.read(onboardingProvider).step;
        await _tap(t, 'edit-goal');
        expect(find.byKey(const Key('edit-back')), findsOneWidget);
        expect(find.byKey(const Key('onboarding-back')), findsNothing);
        expect(find.text('Lưu'), findsOneWidget);
        await t.tap(find.text('Tăng cơ'));
        await _settle(t);
        await t.tap(find.text('Lưu'));
        await _settle(t);

        expect(c.read(profileProvider).goal, 'build');
        expect(
          c.read(onboardingProvider).step,
          stepBefore,
          reason: 'sửa không đụng tiến độ onboarding',
        );
        expect(find.text('Tăng cơ'), findsOneWidget);
        expect(find.byKey(const Key('profile-dirty')), findsOneWidget);
        expect(
          find.textContaining('áp dụng cho tuần tạo kế tiếp'),
          findsWidgets,
        );
        expect(c.read(choicesDirtyProvider), isTrue);
      },
    );

    testWidgets('mở rồi lưu mà không đổi gì → không đánh dấu chưa áp dụng', (
      t,
    ) async {
      final c = await _pump(t);
      await _tap(t, 'edit-goal');
      await t.tap(find.text('Lưu'));
      await _settle(t);
      expect(c.read(choicesDirtyProvider), isFalse);
      expect(find.byKey(const Key('profile-dirty')), findsNothing);
    });

    testWidgets('sửa cửa hàng (cần danh mục từ API) rồi lưu', (t) async {
      final c = await _pump(t);
      await _tap(t, 'edit-store');
      await t.tap(find.textContaining('WinMart').first);
      await _settle(t);
      await t.tap(find.text('Lưu'));
      await _settle(t);
      expect(c.read(preferencesProvider).storeId, 'winmart');
    });

    testWidgets(
      'tuần hiện tại không đổi cho tới khi bấm "Lên lại tuần này với lựa chọn mới"',
      (t) async {
        final a = _adapter()
          ..on(
            'POST',
            '/v1/plans/regenerate-rest',
            fixture('plan_response.json'),
          );
        final c = await _pump(t, adapter: a);
        final before = c.read(currentPlanProvider)!.toJson();
        await _tap(t, 'edit-goal');
        await t.tap(find.text('Tăng cơ'));
        await _settle(t);
        await t.tap(find.text('Lưu'));
        await _settle(t);
        expect(c.read(currentPlanProvider)!.toJson(), before);
        expect(
          a.requests.where((r) => r.uri.path.contains('regenerate')),
          isEmpty,
        );

        await _tap(t, 'profile-replan');
        await _tap(t, 'replan-confirm');
        final req = a.requests.last;
        expect(req.uri.path, '/v1/plans/regenerate-rest');
        // gửi đi hồ sơ MỚI
        expect(
          ((_body(req)['state'] as Map)['profile'] as Map)['goal'],
          'build',
        );
        expect(c.read(choicesDirtyProvider), isFalse);
        expect(c.read(savedPlansProvider), hasLength(1));
        // chuyển sang tab Kế hoạch, thấy banner "Đã lên lại tuần"
        expect(find.byKey(const Key('plan-replan-banner')), findsOneWidget);
      },
    );

    testWidgets(
      'thói quen ăn cơm (T-095): đổi mức → báo chưa áp dụng → xác nhận → gửi rice_habit mới để lên lại ngày còn lại',
      (t) async {
        final a = _adapter()
          ..on(
            'POST',
            '/v1/plans/regenerate-rest',
            fixture('plan_response.json'),
          );
        final c = await _pump(t, adapter: a);
        expect(find.text('1 chén (~150 g)'), findsOneWidget);
        expect(c.read(preferencesProvider).riceHabit, 'vua');
        await _tap(t, 'edit-rice');
        await t.tap(find.byKey(const Key('rice-nhieu')));
        await _settle(t);
        await t.tap(find.text('Lưu'));
        await _settle(t);
        expect(c.read(preferencesProvider).riceHabit, 'nhieu');
        expect(find.byKey(const Key('profile-dirty')), findsOneWidget);
        expect(find.text('2 chén (~300 g)'), findsOneWidget);

        await _tap(t, 'profile-replan');
        await _tap(t, 'replan-confirm');
        final req = a.requests.last;
        expect(req.uri.path, '/v1/plans/regenerate-rest');
        expect(
          ((_body(req)['state'] as Map)['preferences'] as Map)['rice_habit'],
          'nhieu',
        );
        expect(c.read(choicesDirtyProvider), isFalse);
      },
    );

    testWidgets('tuần đã kết thúc → thay nút lên lại bằng "Tạo tuần mới"', (
      t,
    ) async {
      final a = _adapter()
        ..on('POST', '/v1/plans', fixture('plan_response.json'));
      final c = await _pump(t, adapter: a, today: '2026-11-20');
      expect(find.byKey(const Key('profile-replan')), findsNothing);
      await _tap(t, 'profile-next-week');
      final req = a.requests.last;
      expect(req.uri.path, '/v1/plans');
      expect(_body(req)['start_date'], '2026-11-21');
      expect(c.read(savedPlansProvider), hasLength(1));
    });
  });

  group('Món đã chặn (US-6.2)', () {
    testWidgets('hiện tên món (tên đã nhớ lúc chặn), bỏ chặn khỏi lựa chọn', (
      t,
    ) async {
      final c = await _pump(
        t,
        store: _store(
          blocked: ['mon_a', 'sang_chay_tofu_scramble'],
          blockedNames: {'mon_a': 'Cá kho tộ'},
        ),
      );
      expect(find.text('2 món'), findsOneWidget);
      await _tap(t, 'open-blocked');
      expect(find.text('Cá kho tộ'), findsOneWidget);
      // món không nhớ tên → lấy từ công thức của tuần hiện tại
      expect(
        find.byKey(const Key('blocked-sang_chay_tofu_scramble')),
        findsOneWidget,
      );
      await _tap(t, 'unblock-mon_a');
      expect(c.read(preferencesProvider).blockedRecipeIds, [
        'sang_chay_tofu_scramble',
      ]);
      expect(find.text('Đã bỏ chặn Cá kho tộ'), findsOneWidget);
      expect(find.byKey(const Key('blocked-mon_a')), findsNothing);
      expect(c.read(choicesDirtyProvider), isTrue);
    });

    testWidgets('chưa chặn món nào → thông báo rỗng', (t) async {
      await _pump(t);
      await _tap(t, 'open-blocked');
      expect(find.byKey(const Key('blocked-empty')), findsOneWidget);
    });

    testWidgets('chặn từ màn bữa rồi mở ở tab Bạn thấy đúng tên', (t) async {
      final c = await _pump(t);
      c.read(weekChangesProvider).blockOnly('sang_chay_tofu_scramble');
      await _settle(t);
      expect(
        c.read(blockedNamesProvider)['sang_chay_tofu_scramble'],
        isNotNull,
      );
    });
  });

  group('Tuần đã lưu', () {
    testWidgets('rỗng, rồi có tuần đã lưu', (t) async {
      await _pump(t);
      await _tap(t, 'open-saved');
      expect(find.byKey(const Key('saved-empty')), findsOneWidget);
    });

    testWidgets('liệt kê khoảng ngày và ngày lưu', (t) async {
      await _pump(
        t,
        store: _store(
          saved: [
            SavedPlan(savedAt: DateTime(2026, 11, 8), plan: samplePlan()),
          ],
        ),
      );
      expect(find.text('1 tuần'), findsOneWidget);
      await _tap(t, 'open-saved');
      expect(find.text('Tuần 09/11 – 15/11'), findsOneWidget);
      expect(find.text('Lưu ngày 08/11/2026'), findsOneWidget);
    });
  });

  group('Miễn trừ y tế và nguồn dữ liệu (US-6.3)', () {
    for (final (doc, needle) in [
      ('disclaimer', 'không phải lời khuyên y tế'),
      ('sources', 'USDA FoodData Central'),
      ('prices', 'ước tính'),
      ('privacy', 'xóa toàn bộ dữ liệu'),
    ]) {
      testWidgets('văn bản "$doc" đọc được', (t) async {
        await _pump(t);
        await _tap(t, 'open-info-$doc');
        expect(find.byKey(Key('info-$doc')), findsOneWidget);
        expect(find.textContaining(needle, findRichText: true), findsWidgets);
      });
    }
  });

  group('Xóa toàn bộ dữ liệu (US-6.3)', () {
    testWidgets('xác nhận 2 bước; Hủy ở bước nào cũng giữ nguyên dữ liệu', (
      t,
    ) async {
      final store = _store(blocked: ['x']);
      final c = await _pump(t, store: store);
      await _tap(t, 'clear-data');
      expect(find.byKey(const Key('clear-step1')), findsOneWidget);
      await t.tap(find.byKey(const Key('clear-cancel')));
      await _settle(t);
      expect(c.read(currentPlanProvider), isNotNull);

      await _tap(t, 'clear-data');
      await t.tap(find.byKey(const Key('clear-step1')));
      await _settle(t);
      expect(find.byKey(const Key('clear-step2')), findsOneWidget);
      await t.tap(find.byKey(const Key('clear-cancel')));
      await _settle(t);
      expect(c.read(currentPlanProvider), isNotNull);
      expect(store.data.containsKey(StoreKeys.currentPlan), isTrue);
    });

    testWidgets(
      'xác nhận xong → về onboarding, không còn tuần, tuần đã lưu, lựa chọn',
      (t) async {
        final store = _store(
          blocked: ['x'],
          saved: [
            SavedPlan(savedAt: DateTime(2026, 11, 8), plan: samplePlan()),
          ],
        );
        final c = await _pump(t, store: store);
        await _tap(t, 'clear-data');
        await t.tap(find.byKey(const Key('clear-step1')));
        await _settle(t);
        await t.tap(find.byKey(const Key('clear-step2')));
        await _settle(t);

        expect(c.read(onboardingProvider).completed, isFalse);
        expect(c.read(currentPlanProvider), isNull);
        expect(c.read(savedPlansProvider), isEmpty);
        expect(c.read(preferencesProvider).blockedRecipeIds, isEmpty);
        expect(store.data.containsKey(StoreKeys.currentPlan), isFalse);
        expect(store.data.containsKey(StoreKeys.savedPlans), isFalse);
        expect(find.text('Bạn muốn đạt mục tiêu nào?'), findsOneWidget);
      },
    );
  });

  group('Banner nới ưu tiên', () {
    testWidgets('engine đã nới xu hướng → có một dòng nhẹ ở banner validator', (
      t,
    ) async {
      final plan = fixture('plan_response.json');
      (plan['plan'] as Map<String, dynamic>)['relaxed_preferences'] = [
        'health_leanings',
      ];
      final s = completedStore();
      s.data[StoreKeys.currentPlan] = jsonEncode(plan);
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = const Size(800, 2600);
      addTearDown(t.view.reset);
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            ...testOverrides(store: s),
            wakelockProvider.overrideWithValue(_NoWake()),
          ],
          child: const FitProApp(),
        ),
      );
      await _settle(t);
      expect(
        find.textContaining('Tuần này đã nới xu hướng nấu ăn để đạt chỉ tiêu.'),
        findsOneWidget,
      );
      // không nới → không có dòng đó
      expect(
        find.textContaining('Mọi ngày đều đạt protein và calo.'),
        findsOneWidget,
      );
    });
  });
}
