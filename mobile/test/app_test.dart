import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/config/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_adapter.dart';
import 'support/test_app.dart';

Widget _app(FakeAdapter adapter) => ProviderScope(
  overrides: testOverrides(adapter: adapter, store: completedStore()),
  child: const FitProApp(),
);

Future<void> _showConnection(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('connection-status')),
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Có 3 tab: Kế hoạch · Đi chợ · Bạn và chuyển tab được', (
    tester,
  ) async {
    final adapter = FakeAdapter()..on('GET', '/health', {'status': 'ok'});
    await tester.pumpWidget(_app(adapter));
    await tester.pumpAndSettle();

    expect(find.text('Kế hoạch'), findsWidgets);
    expect(find.text('Đi chợ'), findsOneWidget);
    expect(find.text('Bạn'), findsOneWidget);
    expect(find.text('Chưa có thực đơn'), findsOneWidget);

    await tester.tap(find.text('Đi chợ'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có danh sách'), findsOneWidget);
  });

  testWidgets('Tab Bạn gọi /health và báo đã kết nối', (tester) async {
    final adapter = FakeAdapter()..on('GET', '/health', {'status': 'ok'});
    await tester.pumpWidget(_app(adapter));
    await tester.tap(find.text('Bạn'));
    await tester.pumpAndSettle();
    await _showConnection(tester);

    expect(find.text('Đã kết nối'), findsOneWidget);
    expect(adapter.requests.where((r) => r.path == '/health'), isNotEmpty);
  });

  testWidgets('Mất mạng → báo chưa kết nối và Thử lại gọi lại /health', (
    tester,
  ) async {
    final adapter = FakeAdapter()..failWithConnectionError = true;
    await tester.pumpWidget(_app(adapter));
    await tester.tap(find.text('Bạn'));
    await tester.pumpAndSettle();
    await _showConnection(tester);
    expect(find.text('Chưa kết nối được máy chủ'), findsOneWidget);

    adapter
      ..failWithConnectionError = false
      ..on('GET', '/health', {'status': 'ok'});
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Đã kết nối'), findsOneWidget);
  });

  test('Env: địa chỉ mặc định theo nền tảng test (không phải Android) là localhost', () {
    expect(Env.apiBaseUrl, 'http://localhost:${Env.devPort}');
  });
}
