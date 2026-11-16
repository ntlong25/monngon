import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitpro_mamdu/api/api_providers.dart';
import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/features/onboarding/onboarding_nav.dart';
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

/// Kho dừng ở một bước onboarding, ghi theo định dạng CŨ (chỉ có số bước theo thứ tự cũ trước T-103:
/// 0 goal, 1 body, 2 activity, 3 targets, 4 store, 5 household, 6 budget, 7 meals, 8 diet, 9 rice, 10 dislike, 11 swipe, 12 equipment, 13 summary).
/// App đọc lại bằng cách đổi số cũ → tên bước → số mới. Dùng [onboardingAtStep] khi muốn chỉ rõ theo tên.
MemoryStore onboardingAt(int step) => MemoryStore({
  StoreKeys.schemaVersion: '$kStorageSchemaVersion',
  StoreKeys.onboarding: jsonEncode({'step': step, 'completed': false}),
});

/// Kho dừng ở một bước onboarding, ghi theo định dạng mới (theo tên bước).
MemoryStore onboardingAtStep(OnboardingStep step) => MemoryStore({
  StoreKeys.schemaVersion: '$kStorageSchemaVersion',
  StoreKeys.onboarding: jsonEncode({
    'step': step.index,
    'step_name': step.name,
    'completed': false,
  }),
});
