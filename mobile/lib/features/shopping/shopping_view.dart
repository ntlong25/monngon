import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/app_state.dart';
import '../plan/plan_view.dart' show parseIsoDate;

/// Thứ tự quầy khi đi chợ (PRD US-4.1 AC1); quầy lạ xếp cuối.
const kAisleOrder = [
  'thit',
  'ca_hai_san',
  'trung_dau_phu',
  'rau_cu',
  'trai_cay',
  'gao_do_kho',
  'gia_vi_dau',
  'sua',
];

/// Nhà có sẵn không? Ưu tiên lựa chọn của người dùng, nếu chưa chọn thì theo server (`is_pantry`, tính từ `default_pantry`).
bool isPantry(ShoppingItem it, ShoppingState st) => st.pantryHave(
  it.ingredientId,
  defaultPantry: it.isPantry ?? it.isDefaultPantry ?? false,
);

/// Các nhóm quầy theo thứ tự đi chợ, chỉ giữ nhóm còn món.
List<AisleGroup> orderedAisles(ShoppingList s) {
  int rank(String id) {
    final i = kAisleOrder.indexOf(id);
    return i < 0 ? kAisleOrder.length : i;
  }

  final groups = [
    for (final g in s.byAisle)
      if (g.items.isNotEmpty) g,
  ];
  // sort ổn định: quầy cùng hạng giữ thứ tự server
  final indexed = [for (var i = 0; i < groups.length; i++) (i, groups[i])];
  indexed.sort((a, b) {
    final c = rank(a.$2.aisle).compareTo(rank(b.$2.aisle));
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

/// Chi phí sau khi trừ món nhà đã có sẵn.
class ShoppingTotals {
  const ShoppingTotals({
    required this.foodCost,
    required this.tillCost,
    required this.pantryCostIfBuy,
    required this.toBuy,
    required this.bought,
    required this.pantry,
  });

  /// "Chi phí món ăn tuần này": phần nguyên liệu thực dùng, gồm cả đồ nhà có sẵn (D-SHP-01: ngân sách không đổi khi bật/tắt).
  final double foodCost;

  /// "Ước tính trả tại quầy": tiền mua theo gói, không gồm đồ nhà có sẵn.
  final double tillCost;

  /// "Nếu phải mua": tiền theo gói của các dòng nhà có sẵn.
  final double pantryCostIfBuy;

  /// Số món cần mua (không tính nhà có sẵn).
  final int toBuy;
  final int bought;
  final int pantry;
}

ShoppingTotals totalsOf(ShoppingList s, ShoppingState st) {
  double food = 0, till = 0, ifBuy = 0;
  var toBuy = 0, bought = 0, pantry = 0;
  for (final it in s.items) {
    food += it.usedCostVnd;
    if (isPantry(it, st)) {
      pantry++;
      ifBuy += it.tillCostVnd;
      continue;
    }
    till += it.tillCostVnd;
    toBuy++;
    if (st.bought.contains(it.ingredientId)) bought++;
  }
  return ShoppingTotals(
    foodCost: food,
    tillCost: till,
    pantryCostIfBuy: ifBuy,
    toBuy: toBuy,
    bought: bought,
    pantry: pantry,
  );
}

/// Mô tả số lượng cần mua: "5 × thịt heo xay C.P 200 g".
String itemQty(ShoppingItem it) =>
    it.displayQty ?? '${it.packs} × ${it.packLabel}';

/// `dd/MM/yyyy` từ ngày ISO; rỗng nếu không đọc được.
String fullDate(String? iso) {
  if (iso == null || iso.length < 10) return '';
  final d = parseIsoDate(iso);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

/// Văn bản chia sẻ: danh sách theo quầy, chưa mua trước, bỏ món nhà có sẵn (US-4.1 AC5).
String shareText({
  required AppL10n l,
  required ShoppingList list,
  required ShoppingState state,
  required Map<String, String> aisleNames,
  required String startDate,
  String? surveyDate,
}) {
  final start = parseIsoDate(startDate);
  final end = start.add(const Duration(days: 6));
  String dm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  final b = StringBuffer(l.shopShareTitle(dm(start), dm(end)));
  for (final g in orderedAisles(list)) {
    final items = [
      for (final it in g.items)
        if (!isPantry(it, state)) it,
    ];
    if (items.isEmpty) continue;
    b
      ..writeln()
      ..writeln()
      ..write(aisleNames[g.aisle] ?? g.aisle);
    for (final it in items) {
      final mark = state.bought.contains(it.ingredientId) ? '☑' : '☐';
      b
        ..writeln()
        ..write('$mark ${it.name} — ${itemQty(it)}');
    }
  }
  final t = totalsOf(list, state);
  b
    ..writeln()
    ..writeln()
    ..write(l.shopShareTotal('${formatVnd(t.tillCost)} ₫'));
  final date = fullDate(surveyDate);
  if (date.isNotEmpty) b.write(' · ${l.shopSurveyDate(date)}');
  return b.toString();
}
