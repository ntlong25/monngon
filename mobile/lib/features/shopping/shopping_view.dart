import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/app_state.dart';
import '../plan/plan_view.dart' show dayHeading, dayIndexOf, parseIsoDate;

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

// --- D-SHP-06: hai chế độ Theo tuần / Theo ngày -------------------------------------

/// Kế hoạch có dữ liệu nhóm mua (server T-116). Kế hoạch lưu từ bản cũ không có → chỉ hiện danh sách tuần như trước.
bool hasBuyModes(ShoppingList s) => s.items.any((i) => i.buyGroup != null);

/// Có thịt cá tươi cấp đông được để bật công tắc "Mua thịt cá cả tuần rồi cấp đông" không.
bool hasFreezable(ShoppingList s) =>
    s.items.any((i) => i.freezableMeat == true);

/// Dòng thịt/cá đang được mua cả tuần rồi cấp đông (công tắc bật).
bool isFrozenMeat(ShoppingItem it, ShopViewPrefs v) =>
    v.freezeMeat && it.freezableMeat == true;

/// Dòng thuộc danh sách Theo tuần: nhóm tuần, hoặc thịt cá cấp đông được khi công tắc bật. Không có dữ liệu nhóm → tuần.
bool inWeekly(ShoppingItem it, ShopViewPrefs v) =>
    it.buyGroup != 'day' || isFrozenMeat(it, v);

/// Khóa "đã mua" của một dòng trong đợt (mỗi đợt mua riêng, cùng nguyên liệu ở hai đợt là hai lần mua).
String tripBoughtKey(int dayIndex, String ingredientId) =>
    'trip:$dayIndex:$ingredientId';

/// Làm tròn tiền 1.000 ₫ như engine.
double roundVnd(double x) => (x / 1000).round() * 1000.0;

/// Một đợt mua theo ngày sau khi bỏ dòng nhà có sẵn và dòng đã chuyển sang Theo tuần (cấp đông).
class TripView {
  const TripView({
    required this.dayIndex,
    required this.items,
    required this.tillCost,
    required this.bought,
  });

  final int dayIndex;
  final List<ShoppingItem> items;
  final double tillCost;
  final int bought;
}

List<TripView> visibleTrips(ShoppingList s, ShoppingState st, ShopViewPrefs v) {
  final out = <TripView>[];
  for (final t in s.trips ?? const <ShoppingTrip>[]) {
    final items = [
      for (final it in t.items)
        if (!isFrozenMeat(it, v) && !isPantry(it, st)) it,
    ];
    if (items.isEmpty) continue;
    out.add(
      TripView(
        dayIndex: t.dayIndex,
        items: items,
        tillCost: roundVnd(items.fold(0.0, (a, it) => a + it.tillCostVnd)),
        bought: items
            .where(
              (it) => st.bought.contains(
                tripBoughtKey(t.dayIndex, it.ingredientId),
              ),
            )
            .length,
      ),
    );
  }
  return out;
}

/// Số liệu theo chế độ: tổng tiền tại quầy, số dòng, số dòng đã mua.
class ModeTotals {
  const ModeTotals({
    required this.weeklyTill,
    required this.dailyTill,
    required this.weeklyCount,
    required this.dailyCount,
    required this.weeklyBought,
    required this.dailyBought,
    required this.delta,
    required this.baseline,
  });

  final double weeklyTill;
  final double dailyTill;
  final int weeklyCount;
  final int dailyCount;
  final int weeklyBought;
  final int dailyBought;

  /// Chênh so với mua một lần cả tuần (`till_cost` cũ, đã bỏ nhà có sẵn): dương = đắt hơn do mua theo đợt,
  /// âm = rẻ hơn nhờ mua theo cân ở chợ (T-116b).
  final double delta;

  /// Tổng tiền tại quầy nếu mua một lần cả tuần (làm tròn 1.000 ₫), mốc để tính phần trăm chênh.
  final double baseline;

  /// Chênh theo phần trăm của [baseline] (0 khi không có mốc).
  double get deltaRatio => baseline > 0 ? delta / baseline : 0;

  double get total => weeklyTill + dailyTill;
  int get count => weeklyCount + dailyCount;
  int get bought => weeklyBought + dailyBought;
}

ModeTotals modeTotals(ShoppingList s, ShoppingState st, ShopViewPrefs v) {
  var weekly = 0.0, oldTill = 0.0;
  var wCount = 0, wBought = 0;
  for (final it in s.items) {
    if (isPantry(it, st)) continue;
    oldTill += it.tillCostVnd;
    if (!inWeekly(it, v)) continue;
    weekly += it.tillCostVnd;
    wCount++;
    if (st.bought.contains(it.ingredientId)) wBought++;
  }
  final trips = visibleTrips(s, st, v);
  final daily = trips.fold(0.0, (a, t) => a + t.tillCost);
  final dCount = trips.fold(0, (a, t) => a + t.items.length);
  final dBought = trips.fold(0, (a, t) => a + t.bought);
  final weeklyR = roundVnd(weekly);
  final base = roundVnd(oldTill);
  return ModeTotals(
    weeklyTill: weeklyR,
    dailyTill: daily,
    weeklyCount: wCount,
    dailyCount: dCount,
    weeklyBought: wBought,
    dailyBought: dBought,
    delta: weeklyR + daily - base,
    baseline: base,
  );
}

/// Ngưỡng chênh (so với mua một lần) từ đó gợi ý bật cấp đông (T-116b).
const kFreezeHintRatio = 0.15;

/// Gợi ý "Mua thịt cá cả tuần rồi cấp đông để bớt khoảng Y ₫": công tắc đang tắt, chênh > 15%, có thịt cá cấp đông được ở Theo ngày
/// và bật công tắc thật sự rẻ hơn. Trả về số tiền bớt được (Y), hoặc null khi không gợi ý.
double? freezeSavingHint(ShoppingList s, ShoppingState st, ShopViewPrefs v) {
  if (v.freezeMeat || !hasBuyModes(s)) return null;
  final now = modeTotals(s, st, v);
  if (now.deltaRatio <= kFreezeHintRatio) return null;
  final hasMeat = visibleTrips(
    s,
    st,
    v,
  ).any((t) => t.items.any((it) => it.freezableMeat == true));
  if (!hasMeat) return null;
  final saving =
      now.total - modeTotals(s, st, v.copyWith(freezeMeat: true)).total;
  return saving > 0 ? saving : null;
}

/// Nhãn đợt mua: "Hôm nay · Thứ Ba · 18/11" hoặc "Thứ Tư · 19/11"; đợt của ngày đã qua ghi thêm "Đã qua".
String tripHeading(AppL10n l, String startDate, int dayIndex, DateTime now) {
  final date = parseIsoDate(startDate).add(Duration(days: dayIndex));
  final heading = dayHeading(l, isoDate(date));
  final today = dayIndexOf(startDate, now);
  if (dayIndex == today) return '${l.shopToday} · $heading';
  if (dayIndex < today) return '$heading · ${l.shopTripPast}';
  return heading;
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
/// Có dữ liệu nhóm mua thì chia sẻ đúng chế độ đang xem ([view]): Theo tuần = các dòng Theo tuần; Theo ngày = từng đợt.
String shareText({
  required AppL10n l,
  required ShoppingList list,
  required ShoppingState state,
  required Map<String, String> aisleNames,
  required String startDate,
  String? surveyDate,
  ShopViewPrefs view = const ShopViewPrefs(),
  DateTime? now,
}) {
  final start = parseIsoDate(startDate);
  final end = start.add(const Duration(days: 6));
  String dm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  final b = StringBuffer(l.shopShareTitle(dm(start), dm(end)));
  final modes = hasBuyModes(list);
  void lines(List<ShoppingItem> items, bool Function(ShoppingItem) done) {
    for (final it in items) {
      b
        ..writeln()
        ..write('${done(it) ? '☑' : '☐'} ${it.name} — ${itemQty(it)}');
    }
  }

  if (modes && view.mode == ShopMode.daily) {
    final today = now ?? DateTime.now();
    for (final t in visibleTrips(list, state, view)) {
      b
        ..writeln()
        ..writeln()
        ..write(tripHeading(l, startDate, t.dayIndex, today));
      lines(
        t.items,
        (it) =>
            state.bought.contains(tripBoughtKey(t.dayIndex, it.ingredientId)),
      );
    }
  } else {
    for (final g in orderedAisles(list)) {
      final items = [
        for (final it in g.items)
          if (!isPantry(it, state) && (!modes || inWeekly(it, view))) it,
      ];
      if (items.isEmpty) continue;
      b
        ..writeln()
        ..writeln()
        ..write(aisleNames[g.aisle] ?? g.aisle);
      lines(items, (it) => state.bought.contains(it.ingredientId));
    }
  }
  final total = modes ? modeTotals(list, state, view) : null;
  final amount = modes
      ? (view.mode == ShopMode.daily ? total!.dailyTill : total!.weeklyTill)
      : totalsOf(list, state).tillCost;
  b
    ..writeln()
    ..writeln()
    ..write(l.shopShareTotal('${formatVnd(amount)} ₫'));
  final date = fullDate(surveyDate);
  if (date.isNotEmpty) b.write(' · ${l.shopSurveyDate(date)}');
  return b.toString();
}
