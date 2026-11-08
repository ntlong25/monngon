// GENERATED FILE — KHÔNG SỬA TAY. Sinh bởi mobile/tool/gen_client.py từ backend/openapi/openapi.json.
// ignore_for_file: unnecessary_cast

import 'package:dio/dio.dart';

import 'models.dart';

/// Lỗi API: HTTP != 2xx hoặc không kết nối được.
class ApiException implements Exception {
  const ApiException({
    this.statusCode,
    this.title,
    this.detail,
    this.fieldErrors = const {},
    this.cause,
  });

  /// null nếu không có phản hồi (mất mạng, hết thời gian chờ).
  final int? statusCode;
  final String? title;
  final String? detail;

  /// Lỗi theo trường (RFC 7807 `errors`), khóa là đường dẫn trường.
  final Map<String, List<String>> fieldErrors;
  final Object? cause;

  bool get isNetwork => statusCode == null;

  @override
  String toString() =>
      'ApiException(${statusCode ?? 'network'}: ${title ?? detail ?? cause})';
}

/// Client API v1 (sinh từ OpenAPI).
class MonNgonApi {
  MonNgonApi(this.dio);

  final Dio dio;

  /// `/health` không nằm trong OpenAPI (ExcludeFromDescription) nhưng app dùng để kiểm kết nối.
  Future<bool> health() async {
    final r = await _send<Map<String, dynamic>>('GET', '/health');
    return r['status'] == 'ok';
  }

  /// `GET /v1/reference`
  Future<ReferenceResponse> getReference() async {
    final r = await _send<Map<String, dynamic>>('GET', '/v1/reference');
    return ReferenceResponse.fromJson(r);
  }

  /// `GET /v1/ingredients`
  Future<List<IngredientDto>> searchIngredients({String? q, int? limit}) async {
    final r = await _send<List<dynamic>>(
      'GET',
      '/v1/ingredients',
      query: {'q': ?q, 'limit': ?limit},
    );
    return r
        .map((e) => IngredientDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /v1/targets`
  Future<Targets> computeTargets(TargetsRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/targets',
      data: body.toJson(),
    );
    return Targets.fromJson(r);
  }

  /// `POST /v1/slots/preview`
  Future<SlotsPreviewResponse> previewSlots(SlotsPreviewRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/slots/preview',
      data: body.toJson(),
    );
    return SlotsPreviewResponse.fromJson(r);
  }

  /// `POST /v1/rice/feasibility`
  Future<RiceFeasibilityResponse> riceFeasibility(
    RiceFeasibilityRequest body,
  ) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/rice/feasibility',
      data: body.toJson(),
    );
    return RiceFeasibilityResponse.fromJson(r);
  }

  /// `POST /v1/budget-range`
  Future<BudgetRangeResponse> budgetRange(BudgetRangeRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/budget-range',
      data: body.toJson(),
    );
    return BudgetRangeResponse.fromJson(r);
  }

  /// `POST /v1/plans`
  Future<PlanResponse> createPlan(PlanRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/plans',
      data: body.toJson(),
    );
    return PlanResponse.fromJson(r);
  }

  /// `POST /v1/plans/swap-suggestions`
  Future<SwapSuggestions> swapSuggestions(SwapSuggestionsRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/plans/swap-suggestions',
      data: body.toJson(),
    );
    return SwapSuggestions.fromJson(r);
  }

  /// `POST /v1/plans/apply-swap`
  Future<PlanResponse> applySwap(ApplySwapRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/plans/apply-swap',
      data: body.toJson(),
    );
    return PlanResponse.fromJson(r);
  }

  /// `POST /v1/plans/ingredient-options`
  Future<IngredientOptions> ingredientOptions(
    IngredientOptionsRequest body,
  ) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/plans/ingredient-options',
      data: body.toJson(),
    );
    return IngredientOptions.fromJson(r);
  }

  /// `POST /v1/plans/swap-ingredient`
  Future<PlanResponse> swapIngredient(SwapIngredientRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/plans/swap-ingredient',
      data: body.toJson(),
    );
    return PlanResponse.fromJson(r);
  }

  /// `POST /v1/plans/eat-out`
  Future<PlanResponse> eatOut(EatOutRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/plans/eat-out',
      data: body.toJson(),
    );
    return PlanResponse.fromJson(r);
  }

  /// `POST /v1/plans/regenerate-rest`
  Future<PlanResponse> regenerateRest(RegenerateRestRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/plans/regenerate-rest',
      data: body.toJson(),
    );
    return PlanResponse.fromJson(r);
  }

  /// `POST /v1/shopping-list`
  Future<ShoppingList> buildShoppingList(ShoppingListRequest body) async {
    final r = await _send<Map<String, dynamic>>(
      'POST',
      '/v1/shopping-list',
      data: body.toJson(),
    );
    return ShoppingList.fromJson(r);
  }

  /// `GET /v1/recipes/{id}`
  Future<RecipeDetailResponse> getRecipe(String id) async {
    final r = await _send<Map<String, dynamic>>(
      'GET',
      '/v1/recipes/${Uri.encodeComponent(id)}',
    );
    return RecipeDetailResponse.fromJson(r);
  }

  Future<T> _send<T>(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? data,
  }) async {
    try {
      final r = await dio.request<T>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      final body = r.data;
      if (body == null) {
        throw ApiException(statusCode: r.statusCode, title: 'Phản hồi rỗng');
      }
      return body;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  static ApiException _toApiException(DioException e) {
    final res = e.response;
    if (res == null) return ApiException(cause: e.error ?? e.message);
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final errs = <String, List<String>>{};
      final raw = data['errors'];
      if (raw is Map<String, dynamic>) {
        raw.forEach(
          (k, v) =>
              errs[k] = (v as List<dynamic>).map((x) => x.toString()).toList(),
        );
      }
      return ApiException(
        statusCode: res.statusCode,
        title: data['title'] as String?,
        detail: data['detail'] as String?,
        fieldErrors: errs,
      );
    }
    return ApiException(statusCode: res.statusCode, title: res.statusMessage);
  }
}
