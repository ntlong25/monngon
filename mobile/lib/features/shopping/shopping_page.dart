import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/share.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/providers.dart';
import '../../state/week_changes.dart' show clockProvider;
import '../../ui/ui.dart';
import '../plan/plan_view.dart' show dayIndexOf;
import 'shopping_view.dart';

/// Tab Đi chợ (US-4.1): danh sách gộp theo quầy, số gói, hai con số chi phí, đánh dấu đã mua / nhà có sẵn, chia sẻ.
class ShoppingPage extends ConsumerWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final saved = ref.watch(currentPlanProvider);
    if (saved == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.tabShopping)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.shoppingEmptyTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l.shoppingEmptyBody, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }
    final list = saved.plan.shopping;
    final state = ref.watch(shoppingStateProvider);
    final prefs = ref.watch(preferencesProvider);
    final reference = ref.watch(referenceProvider).value;
    final aisleNames = reference?.aisles ?? const <String, String>{};
    String? surveyDate;
    // L-16 (D-DATA-01): cửa hàng đã biết mà chưa có dòng giá khảo sát → ghi rõ "giá ước lượng", không để trống.
    var notSurveyed = false;
    for (final s in reference?.stores ?? const <StoreDto>[]) {
      if (s.id == prefs.storeId) {
        surveyDate = s.priceSurveyDate;
        notSurveyed = s.priceSurveyDate == null;
      }
    }
    final view = ref.watch(shopViewProvider);
    final modes = hasBuyModes(list);
    final now = ref.watch(clockProvider)();
    final totals = totalsOf(list, state);
    final mt = modes ? modeTotals(list, state, view) : null;
    final aisles = orderedAisles(list);
    final pantry = [
      for (final it in list.items)
        if (isPantry(it, state)) it,
    ];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabShopping),
        actions: [
          IconButton(
            key: const Key('shop-share'),
            tooltip: l.shopShare,
            icon: const Icon(Icons.ios_share),
            onPressed: () => ref
                .read(shareProvider)
                .shareText(
                  shareText(
                    l: l,
                    list: list,
                    state: state,
                    aisleNames: aisleNames,
                    startDate: saved.plan.startDate,
                    surveyDate: surveyDate,
                    view: view,
                    now: now,
                  ),
                  subject: l.shopShare,
                ),
          ),
        ],
      ),
      body: ListView(
        key: const Key('shop-list'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _CostCards(
            foodCost: totals.foodCost,
            tillCost: mt?.total ?? totals.tillCost,
            batchExtra: mt?.batchExtra ?? 0,
            budget: saved.plan.budgetVnd,
            surveyDate: surveyDate,
            notSurveyed: notSurveyed,
          ),
          const SizedBox(height: AppSpacing.md),
          _Progress(
            bought: mt?.bought ?? totals.bought,
            toBuy: mt?.count ?? totals.toBuy,
          ),
          if (modes && mt != null)
            _ModeBar(view: view, totals: mt, showFreeze: hasFreezable(list)),
          if (modes && view.mode == ShopMode.daily)
            ..._dailySections(
              context,
              list,
              state,
              view,
              saved.plan.startDate,
              now,
            )
          else ...[
            for (final g in aisles)
              _AisleSection(
                aisle: g.aisle,
                name: aisleNames[g.aisle] ?? g.aisle,
                items: [
                  for (final it in g.items)
                    if (!isPantry(it, state) && (!modes || inWeekly(it, view)))
                      it,
                ],
                freezeTip: (it) => modes && isFrozenMeat(it, view),
              ),
            if (modes && mt!.weeklyCount == 0 && pantry.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Text(
                  l.shopWeeklyEmpty,
                  key: const Key('shop-weekly-empty'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            if (pantry.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  l.shopPantrySection(formatInt(pantry.length)),
                  key: const Key('pantry-section'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.shopPantryNote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final it in pantry) _PantryTile(item: it),
            ],
          ],
        ],
      ),
    );
  }
}

/// Chế độ Theo ngày: các đợt mua; đợt gần nhất (hôm nay hoặc sắp tới) mở sẵn, đợt của ngày đã qua xếp cuối.
List<Widget> _dailySections(
  BuildContext context,
  ShoppingList list,
  ShoppingState state,
  ShopViewPrefs view,
  String startDate,
  DateTime now,
) {
  final l = AppL10n.of(context);
  final trips = visibleTrips(list, state, view);
  if (trips.isEmpty) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Text(
          l.shopDailyEmpty,
          key: const Key('shop-daily-empty'),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textMuted),
        ),
      ),
    ];
  }
  final today = dayIndexOf(startDate, now);
  final upcoming = [
    for (final t in trips)
      if (t.dayIndex >= today) t,
  ];
  final past = [
    for (final t in trips)
      if (t.dayIndex < today) t,
  ];
  return [
    for (var i = 0; i < upcoming.length; i++)
      _TripSection(
        trip: upcoming[i],
        title: tripHeading(l, startDate, upcoming[i].dayIndex, now),
        initiallyExpanded: i == 0,
      ),
    for (final t in past)
      _TripSection(
        trip: t,
        title: tripHeading(l, startDate, t.dayIndex, now),
        initiallyExpanded: false,
      ),
  ];
}

class _ModeBar extends ConsumerWidget {
  const _ModeBar({
    required this.view,
    required this.totals,
    required this.showFreeze,
  });

  final ShopViewPrefs view;
  final ModeTotals totals;
  final bool showFreeze;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final daily = view.mode == ShopMode.daily;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ShopMode>(
            key: const Key('shop-mode'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ShopMode.weekly,
                label: Text(
                  l.shopModeWeekly,
                  key: const Key('shop-mode-weekly'),
                ),
              ),
              ButtonSegment(
                value: ShopMode.daily,
                label: Text(l.shopModeDaily, key: const Key('shop-mode-daily')),
              ),
            ],
            selected: {view.mode},
            onSelectionChanged: (v) =>
                ref.read(shopViewProvider.notifier).setMode(v.first),
          ),
        ),
        if (showFreeze)
          SwitchListTile(
            key: const Key('shop-freeze'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.shopFreezeMeatSwitch),
            value: view.freezeMeat,
            onChanged: (v) =>
                ref.read(shopViewProvider.notifier).setFreezeMeat(on: v),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          daily
              ? l.shopModeTotalDaily(formatVnd(totals.dailyTill))
              : l.shopModeTotalWeekly(formatVnd(totals.weeklyTill)),
          key: const Key('shop-mode-total'),
          style: theme.textTheme.titleSmall,
        ),
        Text(
          l.shopProgress(
            formatInt(daily ? totals.dailyBought : totals.weeklyBought),
            formatInt(daily ? totals.dailyCount : totals.weeklyCount),
          ),
          key: const Key('shop-mode-progress'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _TripSection extends StatelessWidget {
  const _TripSection({
    required this.trip,
    required this.title,
    required this.initiallyExpanded,
  });

  final TripView trip;
  final String title;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final day = trip.dayIndex;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Card(
        key: Key('trip-$day'),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey('trip-$day'),
            initiallyExpanded: initiallyExpanded,
            title: Text(
              title,
              key: Key('trip-$day-title'),
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              '${l.shopProgress(formatInt(trip.bought), formatInt(trip.items.length))} · ${l.shopTripTotal(formatVnd(trip.tillCost))}',
              key: Key('trip-$day-summary'),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              0,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            children: [
              for (final it in trip.items)
                _ItemTile(
                  item: it,
                  boughtKey: tripBoughtKey(day, it.ingredientId),
                  keyBase: 'trip-$day-${it.ingredientId}',
                  showPantry: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostCards extends StatelessWidget {
  const _CostCards({
    required this.foodCost,
    required this.tillCost,
    this.batchExtra = 0,
    required this.budget,
    required this.surveyDate,
    this.notSurveyed = false,
  });

  final double foodCost;

  /// Tổng "ước tính trả tại quầy" cả tuần (cả hai chế độ nếu có).
  final double tillCost;

  /// Phần cao hơn mua một lần do mua theo đợt (0 = không hiện).
  final double batchExtra;
  final double budget;
  final String? surveyDate;

  /// Cửa hàng đang chọn chưa có giá khảo sát (`price_survey_date` rỗng).
  final bool notSurveyed;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final date = fullDate(surveyDate);
    // Ngân sách tuần so với chi phí món ăn (cùng thước đo với validator của engine), không so với tiền mua theo gói.
    final diff = budget - foodCost;
    final over = diff < 0;
    final status = over
        ? l.shoppingBudgetFoodOver('${formatVnd(-diff)} ₫')
        : l.shoppingBudgetFoodUnder('${formatVnd(diff)} ₫');
    // D-QA-02: tiền tại quầy cao hơn ngân sách chỉ là thông tin trung tính (mua nguyên gói), không phải cảnh báo.
    final tillHigher = budget > 0 && tillCost > budget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CostCard(
                cardKey: const Key('shop-food-cost'),
                title: l.shopFoodCost,
                value: '${formatVnd(foodCost)} ₫',
                hint: l.shopFoodCostHint,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _CostCard(
                cardKey: const Key('shop-till-cost'),
                title: l.shopTillCost,
                value: '${formatVnd(tillCost)} ₫',
                hint: l.shopTillCostHint,
                extra: batchExtra > 0
                    ? l.shopBatchExtra(formatVnd(batchExtra))
                    : null,
                extraKey: const Key('shop-batch-extra'),
              ),
            ),
          ],
        ),
        if (date.isNotEmpty || notSurveyed) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            date.isNotEmpty
                ? l.shopSurveyDate(date)
                : l.priceEstimateNotSurveyed,
            key: const Key('shop-survey'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
        if (budget > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.shopBudgetLine('${formatVnd(budget)} ₫'),
            key: const Key('shop-budget'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            status,
            key: const Key('shop-budget-status'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: over ? AppColors.error : AppColors.text,
            ),
          ),
          if (tillHigher) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.shoppingBudgetTillInfo('${formatVnd(tillCost)} ₫'),
              key: const Key('shop-till-info'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({
    required this.cardKey,
    required this.title,
    required this.value,
    required this.hint,
    this.extra,
    this.extraKey,
  });

  final Key cardKey;
  final String title;
  final String value;
  final String hint;
  final String? extra;
  final Key? extraKey;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Card(
      key: cardKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l.shopEstimateTag,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (extra != null)
              Text(
                extra!,
                key: extraKey,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.bought, required this.toBuy});

  final int bought;
  final int toBuy;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final done = toBuy > 0 && bought >= toBuy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          done
              ? l.shopAllDone
              : l.shopProgress(formatInt(bought), formatInt(toBuy)),
          key: const Key('shop-progress'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: toBuy == 0 ? 0 : bought / toBuy,
            minHeight: 6,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class _AisleSection extends StatelessWidget {
  const _AisleSection({
    required this.aisle,
    required this.name,
    required this.items,
    this.freezeTip,
  });

  final String aisle;
  final String name;
  final List<ShoppingItem> items;

  /// Dòng nào hiện hướng dẫn cấp đông / rã đông (công tắc "mua cả tuần rồi cấp đông").
  final bool Function(ShoppingItem)? freezeTip;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      key: Key('aisle-$aisle'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          header: true,
          child: Text(
            name,
            key: Key('aisle-title-$aisle'),
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final it in items)
          _ItemTile(item: it, freezeTip: freezeTip?.call(it) ?? false),
      ],
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({
    required this.item,
    this.boughtKey,
    this.keyBase,
    this.showPantry = true,
    this.freezeTip = false,
  });

  final ShoppingItem item;

  /// Khóa trong `bought`: mặc định mã nguyên liệu; dòng trong đợt mua dùng [tripBoughtKey].
  final String? boughtKey;

  /// Tiền tố khóa widget: mặc định `item-<mã>`.
  final String? keyBase;

  /// Hiện nút "Nhà có sẵn" (chỉ ở danh sách Theo tuần, D-SHP-06).
  final bool showPantry;

  /// Hiện hướng dẫn cấp đông / rã đông (thịt cá mua cả tuần).
  final bool freezeTip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final id = item.ingredientId;
    final base = keyBase ?? 'item-$id';
    final stateKey = boughtKey ?? id;
    final bought = ref.watch(
      shoppingStateProvider.select((s) => s.bought.contains(stateKey)),
    );
    void toggle() => ref
        .read(shoppingStateProvider.notifier)
        .setBought(stateKey, bought: !bought);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textMuted,
    );
    final strike = bought ? TextDecoration.lineThrough : null;
    // Nhãn hạn dùng theo storage.json (cận dưới); kế hoạch cũ chưa có thì dùng hạn của phần dư như trước.
    final hasShelfData = item.freshDays != null || item.noShelfInfo == true;
    final shelf = !hasShelfData && item.leftoverDays >= 1
        ? ' · ${l.shoppingShelfLife(formatInt(item.leftoverDays))}'
        : '';
    final leftover = item.leftoverG >= 1
        ? ' · ${l.shoppingLeftover(formatInt(item.leftoverG))}$shelf'
        : '';
    return Card(
      key: Key(base),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: toggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: l.shopBoughtSemantics(item.name),
                child: Checkbox(
                  key: Key('$base-check'),
                  value: bought,
                  onChanged: (_) => toggle(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: strike,
                          color: bought ? AppColors.textMuted : AppColors.text,
                        ),
                      ),
                      Text(
                        itemQty(item),
                        key: Key('$base-qty'),
                        style: muted?.copyWith(decoration: strike),
                      ),
                      Text(
                        '${l.shopNeedG(formatInt(item.needG))}$leftover',
                        style: muted?.copyWith(fontSize: 13),
                      ),
                      if (item.freshDays != null)
                        Text(
                          l.shoppingShelfLife(formatInt(item.freshDays!)),
                          key: Key('$base-fresh'),
                          style: muted?.copyWith(fontSize: 13),
                        )
                      else if (item.noShelfInfo == true)
                        Text(
                          l.shopNoShelfInfo,
                          key: Key('$base-noinfo'),
                          style: muted?.copyWith(fontSize: 13),
                        ),
                      if (freezeTip)
                        Text(
                          l.shopFreezeTip,
                          key: Key('$base-freeze'),
                          style: muted?.copyWith(fontSize: 13),
                        ),
                      if (showPantry)
                        TextButton(
                          key: Key('$base-pantry'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(kMinTouch, kMinTouch),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () => ref
                              .read(shoppingStateProvider.notifier)
                              .setPantry(id, have: true),
                          child: Text(l.shopPantryToggle),
                        )
                      else
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${formatVnd(item.tillCostVnd)} ₫',
                      key: Key('$base-price'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: strike,
                      ),
                    ),
                    if (item.priceFallback)
                      Text(
                        l.shopFallbackPrice,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantryTile extends ConsumerWidget {
  const _PantryTile({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final id = item.ingredientId;
    return Padding(
      key: Key('pantry-$id'),
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.name} · ${l.shopNeedG(formatInt(item.needG))}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                // D-SHP-01: nếu phải mua thì tốn thêm bao nhiêu (không nằm trong "trả tại quầy" khi còn đánh dấu có sẵn).
                Text(
                  l.shopPantryIfBuy(formatVnd(item.tillCostVnd)),
                  key: Key('pantry-$id-ifbuy'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            key: Key('pantry-$id-need'),
            style: TextButton.styleFrom(
              minimumSize: const Size(kMinTouch, kMinTouch),
            ),
            onPressed: () => ref
                .read(shoppingStateProvider.notifier)
                .setPantry(id, have: false),
            child: Text(l.shopPantryNeed),
          ),
        ],
      ),
    );
  }
}
