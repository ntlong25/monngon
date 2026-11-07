import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Nhóm ảnh placeholder (khớp `Recipe.image_group` của API).
enum ImageGroup {
  kho('kho'),
  xao('xao'),
  canh('canh'),
  luocHap('luoc_hap'),
  com('com'),
  sang('sang'),
  phu('phu');

  const ImageGroup(this.wire);

  final String wire;

  /// Giá trị lạ hoặc null → [phu] hiển thị trung tính? Không: dùng [com] (hình bát cơm) làm mặc định.
  static ImageGroup fromWire(String? s) => ImageGroup.values.firstWhere(
    (g) => g.wire == s,
    orElse: () => ImageGroup.com,
  );
}

/// Ảnh món: nếu có [image] (URL) thì tải ảnh, lỗi hoặc `null` thì vẽ minh họa theo nhóm — không bao giờ lỗi.
class DishImage extends StatelessWidget {
  const DishImage({
    this.image,
    this.group,
    this.size = 72,
    this.borderRadius = AppRadius.md,
    super.key,
  });

  final String? image;
  final ImageGroup? group;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = DishPlaceholder(group: group ?? ImageGroup.com);
    final hasImage = image != null && image!.isNotEmpty;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox.square(
          dimension: size,
          child: hasImage
              ? Image.network(
                  image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                  loadingBuilder: (_, child, p) =>
                      p == null ? child : placeholder,
                )
              : placeholder,
        ),
      ),
    );
  }
}

/// Minh họa tự vẽ cho từng nhóm món, co giãn theo ô chứa.
class DishPlaceholder extends StatelessWidget {
  const DishPlaceholder({required this.group, super.key});

  final ImageGroup group;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DishPainter(group), child: const SizedBox.expand());
}

class _Palette {
  const _Palette(this.bg, this.main, this.dark, this.light);

  final Color bg;
  final Color main;
  final Color dark;
  final Color light;
}

_Palette _paletteOf(ImageGroup g) => switch (g) {
  ImageGroup.kho => const _Palette(
    Color(0xFFF3DFC8),
    Color(0xFF9A5B2E),
    Color(0xFF5B3418),
    Color(0xFFFFFFFF),
  ),
  ImageGroup.xao => const _Palette(
    Color(0xFFFFE9C9),
    Color(0xFF3E4A47),
    Color(0xFF1F2825),
    Color(0xFFF2A93B),
  ),
  ImageGroup.canh => const _Palette(
    Color(0xFFD7EFE3),
    Color(0xFF2E8B67),
    Color(0xFF0B3A2A),
    Color(0xFFFFFFFF),
  ),
  ImageGroup.luocHap => const _Palette(
    Color(0xFFE3EEF6),
    Color(0xFFB88A4A),
    Color(0xFF6B4A1D),
    Color(0xFFFFFFFF),
  ),
  ImageGroup.com => const _Palette(
    Color(0xFFF1ECE0),
    Color(0xFF3D6FA3),
    Color(0xFF1A3A5C),
    Color(0xFFFFFFFF),
  ),
  ImageGroup.sang => const _Palette(
    Color(0xFFFFF0C2),
    Color(0xFFE2E2DC),
    Color(0xFF8A8577),
    Color(0xFFF2A93B),
  ),
  ImageGroup.phu => const _Palette(
    Color(0xFFFCE4E1),
    Color(0xFFC9402F),
    Color(0xFF6E1D12),
    Color(0xFF3E8E41),
  ),
};

class _DishPainter extends CustomPainter {
  const _DishPainter(this.group);

  final ImageGroup group;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _paletteOf(group);
    canvas.drawRect(Offset.zero & size, Paint()..color = p.bg);
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    canvas.scale(s / 100);
    switch (group) {
      case ImageGroup.kho:
        _pot(canvas, p);
      case ImageGroup.xao:
        _wok(canvas, p);
      case ImageGroup.canh:
        _soup(canvas, p);
      case ImageGroup.luocHap:
        _steamer(canvas, p);
      case ImageGroup.com:
        _rice(canvas, p);
      case ImageGroup.sang:
        _breakfast(canvas, p);
      case ImageGroup.phu:
        _fruit(canvas, p);
    }
    canvas.restore();
  }

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  void _steam(Canvas c, _Palette p, double x, double y) {
    final path = Path()
      ..moveTo(x, y)
      ..cubicTo(x - 5, y - 6, x + 5, y - 10, x, y - 16);
    c.drawPath(path, _stroke(p.dark.withValues(alpha: .45), 2.4));
  }

  // Nồi kho: thân nồi, nắp, hai quai, hơi nước.
  void _pot(Canvas c, _Palette p) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(24, 48, 52, 30),
      const Radius.circular(8),
    );
    c.drawRRect(body, _fill(p.main));
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 42, 60, 9),
        const Radius.circular(4),
      ),
      _fill(p.dark),
    );
    c.drawCircle(const Offset(50, 39), 3.2, _fill(p.dark));
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(11, 55, 13, 5),
        const Radius.circular(2.5),
      ),
      _fill(p.dark),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(76, 55, 13, 5),
        const Radius.circular(2.5),
      ),
      _fill(p.dark),
    );
    _steam(c, p, 38, 34);
    _steam(c, p, 62, 34);
    c.drawArc(
      const Rect.fromLTWH(30, 56, 40, 14),
      0.2,
      2.7,
      false,
      _stroke(p.light.withValues(alpha: .35), 2),
    );
  }

  // Chảo xào: lòng chảo, cán dài, lửa, vài miếng nguyên liệu.
  void _wok(Canvas c, _Palette p) {
    final pan = Path()
      ..moveTo(18, 46)
      ..quadraticBezierTo(50, 86, 82, 46)
      ..close();
    c.drawPath(pan, _fill(p.main));
    c.drawLine(const Offset(80, 50), const Offset(98, 40), _stroke(p.dark, 5));
    c.drawOval(const Rect.fromLTWH(18, 42, 64, 10), _fill(p.dark));
    c.drawCircle(const Offset(38, 47), 3.4, _fill(p.light));
    c.drawCircle(const Offset(50, 45), 3.4, _fill(const Color(0xFF3E8E41)));
    c.drawCircle(const Offset(61, 47.5), 3.4, _fill(const Color(0xFFC9402F)));
    for (final x in [34.0, 50.0, 66.0]) {
      final flame = Path()
        ..moveTo(x - 5, 90)
        ..quadraticBezierTo(x - 3, 80, x, 76)
        ..quadraticBezierTo(x + 3, 80, x + 5, 90)
        ..close();
      c.drawPath(flame, _fill(p.light));
    }
  }

  // Tô canh: bát bán nguyệt, mặt canh, hơi nước, thìa.
  void _soup(Canvas c, _Palette p) {
    final bowl = Path()
      ..moveTo(20, 52)
      ..quadraticBezierTo(50, 92, 80, 52)
      ..close();
    c.drawPath(bowl, _fill(p.main));
    c.drawOval(const Rect.fromLTWH(20, 47, 60, 10), _fill(p.dark));
    c.drawOval(const Rect.fromLTWH(24, 49, 52, 6), _fill(p.bg));
    c.drawCircle(const Offset(40, 52), 2.4, _fill(const Color(0xFF3E8E41)));
    c.drawCircle(const Offset(56, 53), 2.4, _fill(const Color(0xFF3E8E41)));
    _steam(c, p, 38, 40);
    _steam(c, p, 52, 40);
    _steam(c, p, 66, 40);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(34, 86, 32, 4),
        const Radius.circular(2),
      ),
      _fill(p.dark.withValues(alpha: .5)),
    );
  }

  // Xửng hấp: hai tầng tre + nắp vòm.
  void _steamer(Canvas c, _Palette p) {
    for (final y in [60.0, 46.0]) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(24, y, 52, 13),
          const Radius.circular(4),
        ),
        _fill(p.main),
      );
      for (final x in [34.0, 46.0, 58.0, 70.0]) {
        c.drawLine(Offset(x, y + 2), Offset(x, y + 11), _stroke(p.dark, 1.6));
      }
      c.drawLine(Offset(24, y), Offset(76, y), _stroke(p.dark, 2.2));
    }
    c.drawArc(
      const Rect.fromLTWH(24, 22, 52, 48),
      math.pi,
      math.pi,
      true,
      _fill(p.dark),
    );
    c.drawCircle(const Offset(50, 29), 3, _fill(p.main));
    _steam(c, p, 34, 24);
    _steam(c, p, 66, 24);
  }

  // Bát cơm: bát, nắm cơm tròn, đôi đũa.
  void _rice(Canvas c, _Palette p) {
    c.drawArc(
      const Rect.fromLTWH(28, 36, 44, 42),
      math.pi,
      math.pi,
      true,
      _fill(p.light),
    );
    c.drawArc(
      const Rect.fromLTWH(28, 36, 44, 42),
      math.pi,
      math.pi,
      false,
      _stroke(p.dark.withValues(alpha: .25), 1.5),
    );
    final bowl = Path()
      ..moveTo(18, 56)
      ..quadraticBezierTo(50, 96, 82, 56)
      ..close();
    c.drawPath(bowl, _fill(p.main));
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 54, 64, 5),
        const Radius.circular(2.5),
      ),
      _fill(p.dark),
    );
    c.drawLine(
      const Offset(64, 20),
      const Offset(52, 50),
      _stroke(p.dark, 2.6),
    );
    c.drawLine(
      const Offset(72, 22),
      const Offset(58, 50),
      _stroke(p.dark, 2.6),
    );
  }

  // Bữa sáng: đĩa với trứng ốp la + mặt trời mọc.
  void _breakfast(Canvas c, _Palette p) {
    c.drawArc(
      const Rect.fromLTWH(30, 18, 40, 40),
      math.pi,
      math.pi,
      true,
      _fill(p.light.withValues(alpha: .65)),
    );
    for (var i = 0; i < 5; i++) {
      final a = math.pi + (i + 0.5) * math.pi / 5;
      c.drawLine(
        Offset(50 + 24 * math.cos(a), 56 + 24 * math.sin(a)),
        Offset(50 + 32 * math.cos(a), 56 + 32 * math.sin(a)),
        _stroke(p.light, 2.4),
      );
    }
    c.drawOval(const Rect.fromLTWH(14, 50, 72, 34), _fill(p.main));
    c.drawOval(const Rect.fromLTWH(14, 50, 72, 34), _stroke(p.dark, 1.6));
    final white = Path()
      ..moveTo(30, 66)
      ..quadraticBezierTo(28, 54, 44, 56)
      ..quadraticBezierTo(60, 52, 68, 62)
      ..quadraticBezierTo(76, 74, 60, 76)
      ..quadraticBezierTo(40, 82, 30, 66)
      ..close();
    c.drawPath(white, _fill(const Color(0xFFFFFFFF)));
    c.drawCircle(const Offset(50, 65), 7, _fill(p.light));
  }

  // Bữa phụ: quả táo + lá.
  void _fruit(Canvas c, _Palette p) {
    final apple = Path()
      ..moveTo(50, 36)
      ..cubicTo(34, 26, 16, 42, 24, 62)
      ..cubicTo(30, 80, 44, 88, 50, 84)
      ..cubicTo(56, 88, 70, 80, 76, 62)
      ..cubicTo(84, 42, 66, 26, 50, 36)
      ..close();
    c.drawPath(apple, _fill(p.main));
    c.drawArc(
      const Rect.fromLTWH(30, 44, 14, 22),
      math.pi * 0.9,
      math.pi * 0.8,
      false,
      _stroke(const Color(0xFFFFFFFF).withValues(alpha: .45), 3),
    );
    c.drawLine(const Offset(50, 36), const Offset(52, 22), _stroke(p.dark, 3));
    final leaf = Path()
      ..moveTo(54, 28)
      ..quadraticBezierTo(66, 14, 78, 22)
      ..quadraticBezierTo(68, 34, 54, 28)
      ..close();
    c.drawPath(leaf, _fill(p.light));
  }

  @override
  bool shouldRepaint(_DishPainter old) => old.group != group;
}
