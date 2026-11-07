import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import 'generated/api_client.dart';

/// Địa chỉ API (override trong test).
final apiBaseUrlProvider = Provider<String>((ref) => Env.apiBaseUrl);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(apiBaseUrlProvider),
      connectTimeout: const Duration(seconds: 8),
      // Tạo tuần có thể mất vài giây (PRD: tổng ≤ 5 s); chừa dư cho mạng chậm.
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final apiProvider = Provider<MonNgonApi>(
  (ref) => MonNgonApi(ref.watch(dioProvider)),
);

/// Kết quả gọi `/health`; `true` nếu máy chủ trả `ok`.
final healthProvider = FutureProvider.autoDispose<bool>(
  retry: (_, _) => null,
  (ref) => ref.watch(apiProvider).health(),
);
