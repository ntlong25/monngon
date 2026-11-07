import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/share.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
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
    for (final s in reference?.stores ?? const <StoreDto>[]) {
      if (s.id == prefs.storeId) surveyDate = s.priceSurveyDate;
    }
    final totals = totalsOf(list, state);
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
            totals: totals,
            budget: saved.plan.budgetVnd,
            surveyDate: surveyDate,
          ),
          const SizedBox(height: AppSpacing.md),
          _Progress(totals: totals),
          for (final g in aisles)
            _AisleSection(
              aisle: g.aisle,
              name: aisleNames[g.aisle] ?? g.aisle,
              items: [
                for (final it in g.items)
                  if (!isPantry(it, state)) it,
              ],
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
      ),
    );
  }
}

class _CostCards extends StatelessWidget {
  const _CostCards({
    required this.totals,
    required this.budget,
    required this.surveyDate,
  });

  final ShoppingTotals totals;
  final double budget;
  final String? surveyDate;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final date = fullDate(surveyDate);
    // Ngân sách tuần so với chi phí món ăn (cùng thước đo với validator của engine), không so với tiền mua theo gói.
    final diff = budget - totals.foodCost;
    final over = diff < 0;
    final status = over
        ? l.shoppingBudgetFoodOver('${formatVnd(-diff)} ₫')
        : l.shoppingBudgetFoodUnder('${formatVnd(diff)} ₫');
    // D-QA-02: tiền tại quầy cao hơn ngân sách chỉ là thông tin trung tính (mua nguyên gói), không phải cảnh báo.
    final tillHigher = budget > 0 && totals.tillCost > budget;
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
                value: '${formatVnd(totals.foodCost)} ₫',
                hint: l.shopFoodCostHint,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _CostCard(
                cardKey: const Key('shop-till-cost'),
                title: l.shopTillCost,
                value: '${formatVnd(totals.tillCost)} ₫',
                hint: l.shopTillCostHint,
              ),
            ),
          ],
        ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.shopSurveyDate(date),
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
              l.shoppingBudgetTillInfo('${formatVnd(totals.tillCost)} ₫'),
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
  });

  final Key cardKey;
  final String title;
  final String value;
  final String hint;

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
  const _Progress({required this.totals});

  final ShoppingTotals totals;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final done = totals.toBuy > 0 && totals.bought >= totals.toBuy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          done
              ? l.shopAllDone
              : l.shopProgress(
                  formatInt(totals.bought),
                  formatInt(totals.toBuy),
                ),
          key: const Key('shop-progress'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: totals.toBuy == 0 ? 0 : totals.bought / totals.toBuy,
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
  });

  final String aisle;
  final String name;
  final List<ShoppingItem> items;

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
        for (final it in items) _ItemTile(item: it),
      ],
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final id = item.ingredientId;
    final bought = ref.watch(
      shoppingStateProvider.select((s) => s.bought.contains(id)),
    );
    void toggle() =>
        ref.read(shoppingStateProvider.notifier).setBought(id, bought: !bought);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textMuted,
    );
    final strike = bought ? TextDecoration.lineThrough : null;
    final shelf = item.leftoverDays >= 1
        ? ' · ${l.shoppingShelfLife(formatInt(item.leftoverDays))}'
        : '';
    final leftover = item.leftoverG >= 1
        ? ' · ${l.shoppingLeftover(formatInt(item.leftoverG))}$shelf'
        : '';
    return Card(
      key: Key('item-$id'),
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
                  key: Key('item-$id-check'),
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
                        key: Key('item-$id-qty'),
                        style: muted?.copyWith(decoration: strike),
                      ),
                      Text(
                        '${l.shopNeedG(formatInt(item.needG))}$leftover',
                        style: muted?.copyWith(fontSize: 13),
                      ),
                      TextButton(
                        key: Key('item-$id-pantry'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(kMinTouch, kMinTouch),
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () => ref
                            .read(shoppingStateProvider.notifier)
                            .setPantry(id, have: true),
                        child: Text(l.shopPantryToggle),
                      ),
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
                      key: Key('item-$id-price'),
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
