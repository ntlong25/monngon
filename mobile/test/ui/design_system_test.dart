import 'dart:io';
import 'dart:math' as math;

import 'package:fitpro_mamdu/features/debug/gallery_page.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:fitpro_mamdu/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('vi'),
  supportedLocales: AppL10n.supportedLocales,
  localizationsDelegates: const [
    AppL10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final la = _lum(a);
  final lb = _lum(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('Tương phản WCAG AA', () {
    const textPairs = <String, (Color, Color)>{
      'chữ / nền kem': (AppColors.text, AppColors.background),
      'chữ / thẻ trắng': (AppColors.text, AppColors.surface),
      'chữ phụ / nền kem': (AppColors.textMuted, AppColors.background),
      'chữ phụ / thẻ trắng': (AppColors.textMuted, AppColors.surface),
      'chữ phụ / nền biến thể': (AppColors.textMuted, AppColors.surfaceVariant),
      'chữ / nền biến thể': (AppColors.text, AppColors.surfaceVariant),
      'chữ trên nút chính': (AppColors.onPrimary, AppColors.primary),
      'chữ xanh / nền kem (nút text)': (
        AppColors.primary,
        AppColors.background,
      ),
      'chữ xanh / thẻ trắng': (AppColors.primary, AppColors.surface),
      'chữ trên container xanh': (
        AppColors.onPrimaryContainer,
        AppColors.primaryContainer,
      ),
      'chữ chip protein': (
        AppColors.onAccentContainer,
        AppColors.accentContainer,
      ),
      'banner info': (AppColors.onInfoContainer, AppColors.infoContainer),
      'banner cảnh báo': (
        AppColors.onWarningContainer,
        AppColors.warningContainer,
      ),
      'banner lỗi': (AppColors.onErrorContainer, AppColors.errorContainer),
      'banner thành công': (
        AppColors.onSuccessContainer,
        AppColors.successContainer,
      ),
      'lỗi trên nền kem': (AppColors.error, AppColors.background),
    };
    textPairs.forEach((name, pair) {
      test('$name ≥ 4.5:1', () {
        expect(
          contrast(pair.$1, pair.$2),
          greaterThanOrEqualTo(4.5),
          reason: name,
        );
      });
    });

    const uiPairs = <String, (Color, Color)>{
      'viền / nền kem': (AppColors.outline, AppColors.background),
      'viền / thẻ trắng': (AppColors.outline, AppColors.surface),
      'biểu tượng cảnh báo': (
        AppColors.warningIcon,
        AppColors.warningContainer,
      ),
      'biểu tượng info': (AppColors.infoIcon, AppColors.infoContainer),
      'biểu tượng lỗi': (AppColors.error, AppColors.errorContainer),
    };
    uiPairs.forEach((name, pair) {
      test('thành phần UI: $name ≥ 3:1', () {
        expect(
          contrast(pair.$1, pair.$2),
          greaterThanOrEqualTo(3.0),
          reason: name,
        );
      });
    });
  });

  group('Vùng chạm ≥ 44', () {
    void expectTouch(WidgetTester t, Finder f, {String? why}) {
      expect(f, findsWidgets, reason: why);
      for (final e in f.evaluate()) {
        final size = t.getSize(find.byElementPredicate((x) => x == e));
        expect(
          size.width,
          greaterThanOrEqualTo(44),
          reason: '${why ?? ''} rộng',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(44),
          reason: '${why ?? ''} cao',
        );
      }
    }

    testWidgets('AppButton cả 3 kiểu', (t) async {
      await t.pumpWidget(
        _host(
          Column(
            children: [
              AppButton(label: 'A', onPressed: () {}),
              AppButton(
                label: 'B',
                onPressed: () {},
                kind: AppButtonKind.secondary,
              ),
              AppButton(label: 'C', onPressed: () {}, kind: AppButtonKind.text),
            ],
          ),
        ),
      );
      expectTouch(
        t,
        find.byWidgetPredicate(
          (w) => w is FilledButton || w is OutlinedButton || w is TextButton,
        ),
        why: 'nút',
      );
    });

    testWidgets('Chip, chip có ✕, SelectCard, Toggle, ListRow, Segmented', (
      t,
    ) async {
      await t.pumpWidget(
        _host(
          Column(
            children: [
              AppChip(label: 'x', onTap: () {}),
              AppChip(label: 'y', onDeleted: () {}),
              SelectCard(title: 't', selected: false, onTap: () {}),
              AppToggle(label: 'tg', value: true, onChanged: (_) {}),
              ListRow(title: 'r', onTap: () {}),
              SegmentedControl<int>(
                value: 1,
                onChanged: (_) {},
                options: const [
                  SegmentOption(value: 1, label: 'Một'),
                  SegmentOption(value: 2, label: 'Hai'),
                ],
              ),
            ],
          ),
        ),
      );
      for (final type in [AppChip, SelectCard, AppToggle, ListRow]) {
        expectTouch(t, find.byType(type), why: '$type');
      }
      expectTouch(t, find.byType(SegmentedControl<int>), why: 'segmented');
      // nút ✕ trong chip
      final close = find.byIcon(Icons.close);
      final r = t.getSize(
        find.ancestor(of: close, matching: find.byType(SizedBox)).first,
      );
      expect(r.width, greaterThanOrEqualTo(44));
      expect(r.height, greaterThanOrEqualTo(44));
    });

    testWidgets('Stepper: hai nút 48×48', (t) async {
      await t.pumpWidget(
        _host(
          AppStepper(
            value: 2,
            min: 1,
            max: 6,
            label: 'Người lớn',
            decrementLabel: 'Giảm',
            incrementLabel: 'Tăng',
            onChanged: (_) {},
          ),
        ),
      );
      expectTouch(t, find.byType(IconButton), why: 'stepper');
    });

    testWidgets('Banner có nút hành động ≥ 44', (t) async {
      await t.pumpWidget(
        _host(
          AppBanner(
            message: 'm',
            kind: BannerKind.warning,
            actionLabel: 'Xem',
            onAction: () {},
          ),
        ),
      );
      expectTouch(t, find.byType(TextButton), why: 'banner');
    });

    testWidgets('DishCard ≥ 88 cao', (t) async {
      await t.pumpWidget(
        _host(
          DishCard(
            roleLabel: 'Món chính',
            name: 'Cá kho',
            proteinText: '30 g',
            kcalText: '200 kcal',
            proteinLabel: 'Protein',
            kcalLabel: 'Calo',
            onTap: () {},
          ),
        ),
      );
      expect(t.getSize(find.byType(DishCard)).height, greaterThanOrEqualTo(88));
    });
  });

  group('Hành vi', () {
    testWidgets('Stepper giữ trong [min, max]', (t) async {
      var v = 1;
      await t.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, set) => AppStepper(
              value: v,
              min: 1,
              max: 2,
              label: 'n',
              decrementLabel: 'Giảm',
              incrementLabel: 'Tăng',
              onChanged: (x) => set(() => v = x),
            ),
          ),
        ),
      );
      await t.tap(find.byIcon(Icons.remove));
      expect(v, 1); // đã ở min
      await t.tap(find.byIcon(Icons.add));
      await t.pump();
      expect(v, 2);
      await t.tap(find.byIcon(Icons.add));
      expect(v, 2); // đã ở max
    });

    testWidgets(
      'SelectCard & Segmented gọi callback; chọn có dấu ✓ không chỉ màu',
      (t) async {
        var picked = '';
        var seg = 'hot';
        await t.pumpWidget(
          _host(
            Column(
              children: [
                SelectCard(
                  title: 'Giảm mỡ',
                  selected: true,
                  onTap: () => picked = 'lose',
                ),
                SelectCard(
                  title: 'Giữ cân',
                  selected: false,
                  onTap: () => picked = 'hold',
                ),
                SegmentedControl<String>(
                  value: seg,
                  onChanged: (v) => seg = v,
                  options: const [
                    SegmentOption(value: 'hot', label: 'Nóng'),
                    SegmentOption(value: 'packed', label: 'Mang đi'),
                  ],
                ),
              ],
            ),
          ),
        );
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
        await t.tap(find.text('Giữ cân'));
        expect(picked, 'hold');
        await t.tap(find.text('Mang đi'));
        expect(seg, 'packed');
      },
    );

    testWidgets('Nút đang tải không bấm được', (t) async {
      var n = 0;
      await t.pumpWidget(
        _host(AppButton(label: 'Tạo', onPressed: () => n++, loading: true)),
      );
      await t.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(n, 0);
    });

    testWidgets('Semantics: SelectCard báo đã chọn, Stepper có giá trị', (
      t,
    ) async {
      final h = t.ensureSemantics();
      await t.pumpWidget(
        _host(
          Column(
            children: [
              SelectCard(title: 'Giảm mỡ', selected: true, onTap: () {}),
              AppStepper(
                value: 3,
                min: 1,
                max: 6,
                label: 'Người lớn',
                decrementLabel: 'Giảm',
                incrementLabel: 'Tăng',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );
      expect(
        t.getSemantics(find.byType(SelectCard)),
        isSemantics(
          label: 'Giảm mỡ',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Người lớn')), findsWidgets);
      expect(find.byTooltip('Giảm Người lớn'), findsOneWidget);
      expect(find.byTooltip('Tăng Người lớn'), findsOneWidget);
      h.dispose();
    });
  });

  group('Ảnh món', () {
    testWidgets('image = null vẽ placeholder cho mọi nhóm, không lỗi', (
      t,
    ) async {
      await t.pumpWidget(
        _host(
          Wrap(
            children: [
              for (final g in ImageGroup.values) DishImage(group: g),
              const DishImage(),
              const DishImage(image: ''),
            ],
          ),
        ),
      );
      expect(t.takeException(), isNull);
      expect(
        find.byType(DishPlaceholder),
        findsNWidgets(ImageGroup.values.length + 2),
      );
    });

    testWidgets('URL ảnh hỏng → rơi về placeholder', (t) async {
      await t.pumpWidget(
        _host(
          const DishImage(
            image: 'http://127.0.0.1:1/x.png',
            group: ImageGroup.kho,
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 100));
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await t.pump();
      expect(t.takeException(), isNull);
      expect(find.byType(DishPlaceholder), findsOneWidget);
    });

    test('ImageGroup.fromWire khớp image_group của API, giá trị lạ → cơm', () {
      for (final g in [
        'kho',
        'xao',
        'canh',
        'luoc_hap',
        'com',
        'sang',
        'phu',
      ]) {
        expect(ImageGroup.fromWire(g).wire, g);
      }
      expect(ImageGroup.fromWire(null), ImageGroup.com);
      expect(ImageGroup.fromWire('xyz'), ImageGroup.com);
    });
  });

  testWidgets('Gallery hiển thị mọi component', (t) async {
    t.view.physicalSize = const Size(900, 9000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_host(const SizedBox())); // khởi tạo
    await t.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('vi'),
        supportedLocales: AppL10n.supportedLocales,
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const GalleryPage(),
      ),
    );
    await t.pump(const Duration(milliseconds: 300));
    for (final type in <Type>[
      AppButton,
      AppChip,
      MacroChip,
      SelectCard,
      AppStepper,
      AppToggle,
      ProgressSegments,
      AppBanner,
      ListRow,
      DishImage,
      DishCard,
      BottomCTA,
    ]) {
      expect(find.byType(type), findsWidgets, reason: '$type');
    }
    expect(find.byType(SegmentedControl<String>), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('NFR-03: không hard-code chuỗi tiếng Việt trong widget (trừ gallery debug và mã sinh)', () {
    final viet = RegExp(
      "['\"][^'\"\\n]*[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ][^'\"\\n]*['\"]",
      caseSensitive: false,
    );
    final offenders = <String>[];
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      final p = f.path.replaceAll('\\', '/');
      if (!p.endsWith('.dart') ||
          p.contains('/l10n/') ||
          p.contains('/debug/') ||
          p.contains('/api/generated/')) {
        continue;
      }
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//') || line.startsWith('///')) continue;
        if (viet.hasMatch(line)) offenders.add('$p:${i + 1}: $line');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
