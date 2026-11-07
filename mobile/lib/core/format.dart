import 'package:intl/intl.dart';

final NumberFormat _int = NumberFormat.decimalPattern('vi');
final NumberFormat _one = NumberFormat('#,##0.#', 'vi');

/// Số nguyên kiểu vi-VN: `600000` → `600.000`. Dùng với chuỗi i18n `commonVnd` để ra `600.000 ₫`.
String formatVnd(num v) => _int.format(v.round());

/// Số nguyên có dấu phân cách nghìn.
String formatInt(num v) => _int.format(v.round());

/// Số thập phân tối đa 1 chữ số (dấu phẩy kiểu Việt): `5.5` → `5,5`.
String formatDecimal(num v) => _one.format(v);

/// Ngày `yyyy-MM-dd` (đúng định dạng API) theo giờ máy.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Ngày mai theo giờ máy (US-1.6 AC3: tuần bắt đầu từ ngày mai).
DateTime tomorrow([DateTime? now]) {
  final n = now ?? DateTime.now();
  return DateTime(n.year, n.month, n.day).add(const Duration(days: 1));
}
