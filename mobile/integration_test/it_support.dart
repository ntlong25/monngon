// Hàm dùng chung cho các integration test (chạy trên emulator/thiết bị, API thật).
import 'dart:convert';

import 'package:fitpro_mamdu/app.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:fitpro_mamdu/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Chờ tối đa [timeout] cho đến khi [cond] đúng; vẫn bơm khung hình để UI/Future chạy.
Future<void> until(
  WidgetTester t,
  bool Function() cond, {
  Duration timeout = const Duration(seconds: 60),
  Object? what = '',
}) async {
  final end = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(end)) {
      String desc;
      try {
        desc = '$what';
      } catch (_) {
        desc = '(không mô tả được)';
      }
      throw TestFailure('Hết giờ chờ ${timeout.inSeconds}s: $desc');
    }
    await t.pump(const Duration(milliseconds: 200));
  }
  await t.pump(const Duration(milliseconds: 100));
}

Future<void> waitFor(
  WidgetTester t,
  Finder f, {
  Duration timeout = const Duration(seconds: 60),
}) => until(t, () => f.evaluate().isNotEmpty, timeout: timeout, what: f);

Future<void> waitGone(
  WidgetTester t,
  Finder f, {
  Duration timeout = const Duration(seconds: 60),
}) => until(t, () => f.evaluate().isEmpty, timeout: timeout, what: f);

/// Bơm một lúc để animation/transition xong (không dùng pumpAndSettle vì còn spinner).
Future<void> breathe(WidgetTester t, [int ms = 600]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

/// Báo cho tool/run_integration.sh chụp màn hình thiết bị (adb screencap) rồi chờ cho nó chụp xong.
/// (`flutter test` không có driver nhận ảnh, và app bị gỡ cài đặt sau khi chạy nên không để ảnh trên máy được.)
Future<void> shot(WidgetTester t, String name) async {
  await breathe(t, 400);
  // ignore: avoid_print
  print('[it] ảnh: $name');
  await breathe(t, 2500);
}

Future<void> tapFinder(WidgetTester t, Finder f) async {
  await waitFor(t, f);
  await t.ensureVisible(f.first);
  await breathe(t, 300);
  await t.tap(f.first);
  await breathe(t, 500);
}

Future<void> tapKey(WidgetTester t, String key) =>
    tapFinder(t, find.byKey(Key(key)));

/// Cuộn danh sách [list] cho đến khi [target] xuất hiện (ListView dựng lười).
Future<void> scrollTo(WidgetTester t, Finder list, Finder target) async {
  await waitFor(t, list);
  final scrollable = find
      .descendant(of: list, matching: find.byType(Scrollable))
      .first;
  // Luôn về đầu danh sách rồi cuộn xuống (mục tiêu có thể nằm phía trên vị trí hiện tại).
  t.state<ScrollableState>(scrollable).position.jumpTo(0);
  await breathe(t, 300);
  await t.scrollUntilVisible(
    target,
    300,
    scrollable: scrollable,
    maxScrolls: 80,
  );
  await breathe(t, 300);
}

Future<void> next(WidgetTester t) async {
  final l = lOf(t);
  final btn = find.ancestor(
    of: find.text(l.commonContinue),
    matching: find.byType(FilledButton),
  );
  await until(
    t,
    () =>
        btn.evaluate().isNotEmpty &&
        t.widget<FilledButton>(btn).onPressed != null,
    what: 'nút Tiếp tục bật',
  );
  await t.tap(btn);
  await breathe(t, 700);
}

AppL10n lOf(WidgetTester t) =>
    AppL10n.of(t.element(find.byType(Scaffold).first));

ProviderContainer containerOf(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(FitProApp)));

Future<void> tabTo(WidgetTester t, String label) => tapFinder(
  t,
  find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
);

String kcalIn(WidgetTester t, Finder root) {
  final texts = find
      .descendant(of: root, matching: find.byType(Text))
      .evaluate()
      .map((e) => ((e.widget as Text).data ?? '').trim());
  final re = RegExp(r'^[\d.,]+\s*kcal$');
  return texts.firstWhere(re.hasMatch, orElse: () => '');
}

String planJson(WidgetTester t) =>
    jsonEncode(containerOf(t).read(currentPlanProvider)!.toJson());
