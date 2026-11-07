import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitpro_mamdu/api/api_providers.dart';
import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:fitpro_mamdu/state/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fake_adapter.dart';

/// Fixture cho test giao diện: bản chụp CỐ ĐỊNH ở `test/fixtures/ui/` (xem README ở đó). Test hợp đồng đọc bản chụp mới ở `test/fixtures/`.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/ui/$name').readAsStringSync())
        as Map<String, dynamic>;

PlanResponse samplePlan() =>
    PlanResponse.fromJson(fixture('plan_response.json'));

/// Overrides chuẩn cho test: kho trong bộ nhớ + Dio dùng adapter giả.
List<Override> testOverrides({KeyValueStore? store, FakeAdapter? adapter}) => [
  storeProvider.overrideWithValue(store ?? MemoryStore()),
  dioProvider.overrideWithValue(
    Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter ?? FakeAdapter()
      // Phản hồi lớn (> 50 KB) mặc định giải mã trong isolate thật → treo trong fake-async của test.
      ..transformer = SyncTransformer(),
  ),
];

/// Container mới trên cùng một kho — mô phỏng "tắt app rồi mở lại".
ProviderContainer container(KeyValueStore store, {FakeAdapter? adapter}) {
  final c = ProviderContainer(
    overrides: testOverrides(store: store, adapter: adapter),
  );
  return c;
}

/// Kho đã hoàn tất onboarding (để test các tab chính).
MemoryStore completedStore() => MemoryStore({
  StoreKeys.schemaVersion: '$kStorageSchemaVersion',
  StoreKeys.onboarding: jsonEncode({'step': 13, 'completed': true}),
});

/// Kho dừng ở một bước onboarding.
MemoryStore onboardingAt(int step) => MemoryStore({
  StoreKeys.schemaVersion: '$kStorageSchemaVersion',
  StoreKeys.onboarding: jsonEncode({'step': step, 'completed': false}),
});
