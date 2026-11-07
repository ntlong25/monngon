import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitpro_mamdu/api/generated/api_client.dart';
import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_adapter.dart';

Map<String, dynamic> _json(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

dynamic _jsonAny(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync());

void main() {
  group('Hợp đồng OpenAPI', () {
    final spec = jsonDecode(
      File('../backend/openapi/openapi.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final models = File('lib/api/generated/models.dart').readAsStringSync();
    final client = File('lib/api/generated/api_client.dart').readAsStringSync();

    test(
      'mọi schema trong openapi.json đều có lớp Dart (client chưa lỗi thời)',
      () {
        final schemas =
            (spec['components'] as Map<String, dynamic>)['schemas']
                as Map<String, dynamic>;
        for (final name in schemas.keys) {
          expect(
            models.contains('class $name {'),
            isTrue,
            reason: 'thiếu $name — chạy: python mobile/tool/gen_client.py',
          );
        }
      },
    );

    test('mọi operationId trong openapi.json đều có phương thức Dart', () {
      final paths = spec['paths'] as Map<String, dynamic>;
      for (final entry in paths.entries) {
        for (final op in (entry.value as Map<String, dynamic>).values) {
          final id = (op as Map<String, dynamic>)['operationId'] as String;
          final method = id[0].toLowerCase() + id.substring(1);
          expect(
            RegExp('Future<[^>]+(?:<[^>]+>)?> $method\\(').hasMatch(client),
            isTrue,
            reason: 'thiếu $method — chạy: python mobile/tool/gen_client.py',
          );
        }
      }
    });

    test('mọi thuộc tính của schema đều có trong lớp Dart', () {
      final schemas =
          (spec['components'] as Map<String, dynamic>)['schemas']
              as Map<String, dynamic>;
      for (final s in schemas.entries) {
        final props =
            (s.value as Map<String, dynamic>)['properties']
                as Map<String, dynamic>? ??
            {};
        for (final key in props.keys) {
          expect(
            models.contains("'$key':"),
            isTrue,
            reason: '${s.key}.$key chưa có trong toJson',
          );
        }
      }
    });
  });

  group('Phản hồi thật của API → model', () {
    test('PlanResponse đọc được, có mâm, macro và danh sách đi chợ', () {
      final r = PlanResponse.fromJson(_json('plan_response.json'));
      expect(r.plan.days, hasLength(7));
      expect(r.plan.status, isIn(['ready', 'partial']));
      expect(r.recipes, isNotEmpty);
      expect(r.ingredients, isNotEmpty);
      final meals = r.plan.days.expand((d) => d.meals).toList();
      expect(meals.any((m) => (m.dishes ?? const []).isNotEmpty), isTrue);
      expect(r.plan.shopping.items, isNotEmpty);
      expect(r.trace, isNotEmpty);
      expect(r.targets.proteinG, greaterThan(0));
    });

    test('PlanResponse: fromJson → toJson → fromJson giữ nguyên dữ liệu', () {
      final raw = _json('plan_response.json');
      final once = PlanResponse.fromJson(raw);
      final twice = PlanResponse.fromJson(
        jsonDecode(jsonEncode(once.toJson())) as Map<String, dynamic>,
      );
      expect(jsonEncode(twice.toJson()), jsonEncode(once.toJson()));
    });

    test(
      'Mọi bữa lên thực đơn có recipe_id nằm trong bản đồ công thức offline',
      () {
        final r = PlanResponse.fromJson(_json('plan_response.json'));
        for (final m in r.plan.days.expand((d) => d.meals)) {
          if (m.status != 'planned') continue;
          expect(
            r.recipes.containsKey(m.recipeId),
            isTrue,
            reason: '${m.recipeId}',
          );
        }
      },
    );

    test('ReferenceResponse, Targets, SlotsPreview, BudgetRange, ShoppingList, RecipeDetail', () {
      final ref = ReferenceResponse.fromJson(_json('reference.json'));
      expect(ref.stores, isNotEmpty);
      expect(ref.swipeCards, isNotEmpty);
      expect(ref.aisles, isNotEmpty);
      final t = Targets.fromJson(_json('targets.json'));
      expect(t.kcalMin, lessThan(t.kcalTarget));
      expect(t.steps, isNotNull);
      final sp = SlotsPreviewResponse.fromJson(_json('slots_preview.json'));
      expect(sp.slots, hasLength(5));
      final b = BudgetRangeResponse.fromJson(_json('budget_range.json'));
      expect(b.minVnd, lessThan(b.maxVnd));
      expect(b.tiers.map((x) => x.key), ['economy', 'moderate', 'comfortable']);
      final s = ShoppingList.fromJson(_json('shopping_list.json'));
      expect(s.byAisle, isNotEmpty);
      final d = RecipeDetailResponse.fromJson(_json('recipe_detail.json'));
      expect(d.macros.lines, isNotEmpty);
      final ing = (_jsonAny('ingredients_search.json') as List<dynamic>)
          .map((e) => IngredientDto.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(ing, isNotEmpty);
    });

    test('PlanRequest gửi đúng khóa snake_case và bỏ trường null', () {
      final req = PlanRequest.fromJson(_json('plan_request.json'));
      final j = req.toJson();
      expect(
        j.keys,
        containsAll(['profile', 'preferences', 'start_date', 'seed']),
      );
      expect(
        (j['profile'] as Map<String, dynamic>).containsKey('manual_kcal'),
        isFalse,
      );
      expect(
        (j['preferences'] as Map<String, dynamic>)['store_id'],
        isA<String>(),
      );
    });
  });

  group('MonNgonApi', () {
    MonNgonApi api(FakeAdapter a) => MonNgonApi(
      Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = a,
    );

    test('health trả true khi máy chủ nói ok', () async {
      final a = FakeAdapter()..on('GET', '/health', {'status': 'ok'});
      expect(await api(a).health(), isTrue);
    });

    test('computeTargets gửi POST /v1/targets và đọc Targets', () async {
      final a = FakeAdapter()..on('POST', '/v1/targets', _json('targets.json'));
      final t = await api(a).computeTargets(
        TargetsRequest.fromJson({
          'profile': _json('plan_request.json')['profile'],
        }),
      );
      expect(t.proteinG, greaterThan(0));
      expect(a.requests.single.method, 'POST');
    });

    test('searchIngredients gửi tham số q/limit', () async {
      final a = FakeAdapter()
        ..on('GET', '/v1/ingredients', _jsonAny('ingredients_search.json'));
      await api(a).searchIngredients(q: 'ga', limit: 5);
      expect(a.requests.single.uri.queryParameters, {'q': 'ga', 'limit': '5'});
    });

    test('getRecipe mã hóa id trong đường dẫn', () async {
      final a = FakeAdapter()
        ..on('GET', '/v1/recipes/a%2Fb', _json('recipe_detail.json'));
      await api(a).getRecipe('a/b');
      expect(a.requests.single.uri.path, '/v1/recipes/a%2Fb');
    });

    test('400 → ApiException có lỗi theo trường', () async {
      final a = FakeAdapter()
        ..on('POST', '/v1/plans', {
          'title': 'One or more validation errors occurred.',
          'status': 400,
          'errors': {
            'profile.age': ['phải trong khoảng 14–90'],
          },
        }, status: 400);
      await expectLater(
        api(a).createPlan(PlanRequest.fromJson(_json('plan_request.json'))),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 400)
              .having(
                (e) => e.fieldErrors['profile.age'],
                'errors',
                isNotEmpty,
              ),
        ),
      );
    });

    test('mất mạng → ApiException.isNetwork', () async {
      final a = FakeAdapter()..failWithConnectionError = true;
      await expectLater(
        api(a).health(),
        throwsA(
          isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue),
        ),
      );
    });
  });
}
