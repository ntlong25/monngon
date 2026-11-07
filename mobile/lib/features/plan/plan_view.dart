import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';

/// Thứ tự bữa trong ngày.
const List<String> kSlotOrder = [
  'breakfast',
  'snack_am',
  'lunch',
  'snack_pm',
  'dinner',
];

/// Vai trò món được ghép vào tên mâm (không gồm tráng miệng và "món thêm").
const Set<String> _mamTitleRoles = {'main', 'soup', 'side_veg', 'carb_base'};

/// Các bữa của một ngày, theo thứ tự trong ngày.
List<PlanMeal> sortedMeals(PlanDay day) {
  int rank(String s) {
    final i = kSlotOrder.indexOf(s);
    return i < 0 ? kSlotOrder.length : i;
  }

  return [...day.meals]..sort((a, b) => rank(a.slot).compareTo(rank(b.slot)));
}

/// Bữa có món (không phải "tự lo", "ăn ngoài" hay chưa lên được).
bool isCooked(PlanMeal m) => m.status == 'planned' && m.recipeId != null;

/// Dữ liệu món ghép mâm gắn hậu tố "(món chính)" vào tên; bỏ đi cho gọn (đây là làm sạch dữ liệu, không phải chuỗi UI).
final RegExp _mainNote = RegExp(
  '\\s*\\(m${String.fromCharCode(0xF3)}n ch${String.fromCharCode(0xED)}nh\\)\\s*\$',
);

String _stripNote(String name) => name.replaceAll(_mainNote, '').trim();

String _lowerFirst(String s) =>
    s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

/// Món có phần ăn thật (engine đôi khi co phần cơm/khoai về 0 g để vừa kcal; không hiển thị món 0 g).
bool isServed(Dish d) => d.grams.fold<double>(0, (a, g) => a + g.grams) >= 1;

/// Ghép tên các món thành tên mâm: "Cá kho + canh cải + cơm".
String dishNamesTitle(Iterable<String> names) {
  final parts = names.map(_stripNote).where((n) => n.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  return [
    parts.first,
    for (final p in parts.skip(1)) _lowerFirst(p),
  ].join(' + ');
}

/// Tên hiển thị của bữa. Mâm: "Cá kho + canh cải + cơm"; món đơn: tên món.
String mealTitle(PlanMeal m, Map<String, Recipe> recipes) {
  final dishes = m.dishes ?? const <Dish>[];
  final parts = dishes
      .where((d) => _mamTitleRoles.contains(d.role) && isServed(d))
      .map((d) => d.name)
      .toList();
  final joined = dishNamesTitle(parts);
  if (joined.isNotEmpty) return joined;
  final full = dishes.where((d) => d.role == 'full_meal');
  if (full.isNotEmpty && full.first.name.isNotEmpty) return full.first.name;
  return recipes[m.recipeId]?.name ?? m.recipeId ?? '';
}

/// Tên món tráng miệng của bữa (nếu có).
String? dessertName(PlanMeal m) {
  for (final d in m.dishes ?? const <Dish>[]) {
    if (d.role == 'dessert' && d.name.isNotEmpty) return d.name;
  }
  return null;
}

/// Số bữa dùng chung một mẻ nấu (`batch_group_id`), để hiện "Nấu 1 lần cho N bữa".
Map<String, int> batchCounts(WeekPlan plan) {
  final out = <String, int>{};
  for (final d in plan.days) {
    for (final m in d.meals) {
      final g = m.batchGroupId;
      if (g != null && isCooked(m)) out[g] = (out[g] ?? 0) + 1;
    }
  }
  return out;
}

DateTime parseIsoDate(String iso) {
  final p = iso.split('-');
  if (p.length < 3) return DateTime.fromMillisecondsSinceEpoch(0);
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String _two(int n) => n.toString().padLeft(2, '0');

/// `dd/MM`.
String shortDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

/// "Thứ Hai · 26/10".
String dayHeading(AppL10n l, String iso) {
  final d = parseIsoDate(iso);
  return '${Labels.weekday(l, d.weekday)} · ${shortDate(d)}';
}

/// Lời chào theo giờ máy.
String greeting(AppL10n l, DateTime now) => now.hour < 12
    ? l.planGreetingMorning
    : (now.hour < 18 ? l.planGreetingAfternoon : l.planGreetingEvening);

/// Chỉ số ngày hôm nay trong tuần (0–6); âm = chưa bắt đầu; ≥ 7 = đã qua.
int dayIndexOf(String startDate, DateTime now) {
  final start = parseIsoDate(startDate);
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(start).inDays;
}

/// "Tuần của bạn bắt đầu từ ngày mai" / "Hôm nay là ngày 3" …
String weekStatus(AppL10n l, String startDate, DateTime now) {
  final i = dayIndexOf(startDate, now);
  if (i == -1) return l.planStartsTomorrow;
  if (i < -1) return l.planStartsOn(shortDate(parseIsoDate(startDate)));
  if (i <= 6) return l.planDayNumber(i + 1);
  return l.planWeekEnded;
}

/// Kết quả validator cho banner đầu trang.
class PlanBanner {
  const PlanBanner({required this.ok, required this.message});

  /// true: mọi ngày đạt; false: `partial`.
  final bool ok;
  final String message;
}

/// Banner theo kết quả validator: đạt 7/7, hoặc `partial` nêu đúng ngày + mức thiếu.
PlanBanner planBanner(AppL10n l, WeekPlan plan) {
  final b = _validatorBanner(l, plan);
  // Engine đã nới xu hướng nấu ăn (sức khỏe/ẩm thực) để đạt chỉ tiêu: nói rõ, một dòng nhẹ.
  if (plan.relaxedPreferences?.isNotEmpty ?? false) {
    return PlanBanner(ok: b.ok, message: '${b.message} ${l.planRelaxed}');
  }
  return b;
}

PlanBanner _validatorBanner(AppL10n l, WeekPlan plan) {
  final v = plan.validation;
  final unfilled = plan.unfilledSlots.length;
  if (plan.status == 'ready' && v.ok && unfilled == 0) {
    return PlanBanner(ok: true, message: l.planBannerOk);
  }
  final details = <String>[];
  for (final s in v.shortfalls) {
    final day = Labels.weekday(l, parseIsoDate(s.date).weekday);
    final amount = formatInt(s.amount);
    switch (s.kind) {
      case 'protein_low':
        details.add(l.planShortfallProtein(day, amount));
      case 'kcal_low':
        details.add(l.planShortfallKcalLow(day, amount));
      case 'kcal_high':
        details.add(l.planShortfallKcalHigh(day, amount));
    }
  }
  if (unfilled > 0) details.add(l.planShortfallMissingSlot(unfilled));
  if (v.budgetOverVnd > 0) {
    details.add(l.planBudgetOver(l.commonVnd(formatVnd(v.budgetOverVnd))));
  }
  final badDays = {
    ...v.days.where((d) => !d.ok && !d.exempt).map((d) => d.date),
    ...v.shortfalls.map((s) => s.date),
  }.length;
  return PlanBanner(
    ok: false,
    message: l.planBannerPartial(badDays, details.join('. ')),
  );
}
