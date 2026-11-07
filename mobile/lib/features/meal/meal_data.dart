import '../../api/generated/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../plan/plan_view.dart';

/// Hệ số khẩu phần của trẻ em so với người lớn (chốt ở Q6).
const double kChildPortion = 0.6;

PlanMeal? findMeal(PlanResponse plan, String date, String slot) {
  for (final d in plan.plan.days) {
    if (d.date != date) continue;
    for (final m in d.meals) {
      if (m.slot == slot) return m;
    }
  }
  return null;
}

MealTrace? findTrace(PlanResponse plan, String date, String slot) {
  for (final t in plan.trace) {
    if (t.date == date && t.slot == slot) return t;
  }
  return null;
}

/// Các món (thẻ) của một bữa ghép mâm: món chính, canh, rau, cơm, tráng miệng — bỏ món 0 g và "món thêm".
List<Dish> mamDishes(PlanMeal m) {
  const order = ['main', 'soup', 'side_veg', 'carb_base', 'dessert'];
  final dishes = (m.dishes ?? const <Dish>[])
      .where((d) => order.contains(d.role) && d.recipeId != null && isServed(d))
      .toList();
  int rank(Dish d) => order.indexOf(d.role);
  dishes.sort((a, b) => rank(a).compareTo(rank(b)));
  return dishes;
}

/// Bữa ghép mâm (nhiều món) hay bữa một món.
bool isMam(PlanMeal m) =>
    (m.recipeId?.startsWith('mam:') ?? false) || mamDishes(m).length > 1;

/// Một dòng nguyên liệu: phần của bạn và cả nồi (hộ > 1 người).
class IngredientRow {
  const IngredientRow({
    required this.id,
    required this.name,
    required this.yours,
    required this.whole,
    this.unit,
  });

  final String id;
  final String name;
  final double yours;
  final double whole;

  /// Quy đổi đơn vị bếp, vd `≈ 2 quả` (null nếu không có).
  final String? unit;
}

/// Cả nồi = phần của bạn + (người lớn − 1) × khẩu phần chuẩn + trẻ em × 0,6 × khẩu phần chuẩn.
double wholePot({
  required double yours,
  required double standard,
  required int adults,
  required int children,
}) =>
    yours +
    (adults - 1).clamp(0, 99) * standard +
    children * kChildPortion * standard;

/// "Gạo tẻ (sống)" → "gạo tẻ": bỏ phần ghi chú trong ngoặc và viết thường chữ đầu cho câu "≈ 80 g gạo tẻ".
String riceName(String name) {
  final n = name.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
  return n.isEmpty ? name : n[0].toLowerCase() + n.substring(1);
}

/// Dựng dòng nguyên liệu; bỏ dòng 0 g. [standard] là khẩu phần chuẩn theo mã nguyên liệu (từ công thức).
List<IngredientRow> buildRows({
  required AppL10n l,
  required List<GramLine> yours,
  required Map<String, double> standard,
  required Map<String, IngredientInfoDto> info,
  required int adults,
  required int children,
  required String Function(double) formatCount,
}) {
  // Gộp các dòng trùng mã nguyên liệu.
  final merged = <String, double>{};
  for (final g in yours) {
    merged[g.ingredientId] = (merged[g.ingredientId] ?? 0) + g.grams;
  }
  final rows = <IngredientRow>[];
  merged.forEach((id, grams) {
    final std = standard[id] ?? grams;
    final whole = wholePot(
      yours: grams,
      standard: std,
      adults: adults,
      children: children,
    );
    if (grams < 0.5 && whole < 0.5) return;
    final i = info[id];
    String? unit;
    final pa = i?.purchaseAs;
    if (pa != null && grams > 0) {
      // D-SHP-02: cơm chín → "≈ 80 g gạo tẻ" để người tự nấu biết đong gạo.
      final target = info[pa.ingredientId]?.name;
      if (target != null) {
        unit = l.recipeUnitApprox(
          formatCount(grams * pa.factor),
          'g ${riceName(target)}',
        );
      }
    } else if (i != null && i.householdUnits.isNotEmpty && grams > 0) {
      final u = i.householdUnits.first;
      if (u.grams > 0) {
        unit = l.recipeUnitApprox(formatCount(grams / u.grams), u.unit);
      }
    }
    rows.add(
      IngredientRow(
        id: id,
        name: i?.name ?? id,
        yours: grams,
        whole: whole,
        unit: unit,
      ),
    );
  });
  return rows;
}

/// Nguyên liệu (mã hiện tại trong bữa) thuộc dòng có nhóm thay thế `swap_group` — dòng nào nhấn "đổi" được (US-5.2).
/// [grams] cùng thứ tự với nguyên liệu của công thức.
Set<String> swappableIngredients(Recipe? r, List<GramLine> grams) {
  final out = <String>{};
  final lines = r?.ingredients ?? const <RecipeIngredient>[];
  for (var i = 0; i < lines.length && i < grams.length; i++) {
    final g = lines[i].swapGroup;
    if (g != null && g.isNotEmpty && grams[i].grams >= 0.5) {
      out.add(grams[i].ingredientId);
    }
  }
  return out;
}

/// Khẩu phần chuẩn theo mã nguyên liệu của một công thức.
Map<String, double> standardOf(Recipe? r) {
  final out = <String, double>{};
  for (final i in r?.ingredients ?? const <RecipeIngredient>[]) {
    out[i.ingredientId] = (out[i.ingredientId] ?? 0) + i.grams;
  }
  return out;
}

/// Một mục trong danh sách các bước: tiêu đề phần ("— Canh cải —") hoặc một bước nấu.
class StepItem {
  const StepItem.header(this.text) : index = null;
  const StepItem.step(this.text, int this.index);

  final String text;

  /// Chỉ số bước (từ 0, bỏ qua tiêu đề); null nếu là tiêu đề.
  final int? index;

  bool get isHeader => index == null;
}

final RegExp _header = RegExp(r'^—\s*(.+?)\s*—$');

List<StepItem> parseSteps(List<String> steps) {
  final out = <StepItem>[];
  var n = 0;
  for (final s in steps) {
    final m = _header.firstMatch(s.trim());
    if (m != null) {
      out.add(StepItem.header(m.group(1)!));
    } else {
      out.add(StepItem.step(s, n++));
    }
  }
  return out;
}

/// Nguồn dữ liệu dinh dưỡng của một dòng: "Bảng TPDD VN 2007 · mã …" hoặc "USDA FDC #…".
String formatSource(AppL10n l, String db, String code) {
  final d = db.toUpperCase();
  if (d.startsWith('USDA')) return 'USDA FDC #$code';
  if (d.contains('VN') || d.contains('TPDD')) return l.calcSourceVn(code);
  return l.calcSourceFallback(db, code);
}
