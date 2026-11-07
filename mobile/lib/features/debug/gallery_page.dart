import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../ui/ui.dart';

/// Trang gallery mọi thành phần của design system. Chỉ đăng ký route ở bản debug (xem router.dart).
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  int _adults = 2;
  int _card = 0;
  bool _toggle = true;
  String _lunch = 'hot';
  final _chips = <String>{'low_carb'};

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.galleryTitle)),
      bottomNavigationBar: BottomCTA(
        label: l.commonContinue,
        caption: l.commonEstimateNote,
        onPressed: () {},
        secondaryLabel: l.commonBack,
        onSecondary: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          section(
            'AppButton',
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppButton(label: l.commonContinue, onPressed: () {}),
                AppButton(
                  label: l.commonBack,
                  onPressed: () {},
                  kind: AppButtonKind.secondary,
                ),
                AppButton(
                  label: l.commonRetry,
                  onPressed: () {},
                  kind: AppButtonKind.text,
                  icon: Icons.refresh,
                ),
                AppButton(label: l.commonDone, onPressed: null),
                AppButton(
                  label: l.commonContinue,
                  onPressed: () {},
                  loading: true,
                ),
              ],
            ),
          ),
          section(
            'Chip',
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final c in [
                  ('low_carb', l.onboardingDietLowCarb),
                  ('no_pork', l.onboardingDietNoPork),
                  ('no_dairy', l.onboardingDietNoDairy),
                ])
                  AppChip(
                    label: c.$2,
                    selected: _chips.contains(c.$1),
                    onTap: () => setState(
                      () => _chips.contains(c.$1)
                          ? _chips.remove(c.$1)
                          : _chips.add(c.$1),
                    ),
                  ),
                AppChip(label: 'Rau muống', selected: false, onDeleted: () {}),
              ],
            ),
          ),
          section(
            'MacroChip',
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                MacroChip(
                  kind: MacroKind.protein,
                  value: l.commonGram(45),
                  label: l.macroProtein,
                  large: true,
                ),
                MacroChip(
                  kind: MacroKind.kcal,
                  value: l.commonKcal(620),
                  label: l.macroKcal,
                  large: true,
                ),
                MacroChip(
                  kind: MacroKind.carb,
                  value: l.commonGram(70),
                  label: l.macroCarb,
                  large: true,
                ),
                MacroChip(
                  kind: MacroKind.fat,
                  value: l.commonGram(18),
                  label: l.macroFat,
                  large: true,
                ),
              ],
            ),
          ),
          section(
            'SelectCard',
            Column(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  SelectCard(
                    title: [
                      l.onboardingGoalLose,
                      l.onboardingGoalHold,
                      l.onboardingGoalBuild,
                    ][i],
                    subtitle: i == 0 ? l.onboardingStoreNote : null,
                    selected: _card == i,
                    onTap: () => setState(() => _card = i),
                  ),
                ],
              ],
            ),
          ),
          section(
            'AppStepper',
            Row(
              children: [
                Expanded(child: Text(l.onboardingHouseholdAdults)),
                AppStepper(
                  value: _adults,
                  min: 1,
                  max: 6,
                  label: l.onboardingHouseholdAdults,
                  decrementLabel: l.commonDecrease,
                  incrementLabel: l.commonIncrease,
                  onChanged: (v) => setState(() => _adults = v),
                ),
              ],
            ),
          ),
          section(
            'AppToggle',
            Card(
              child: AppToggle(
                label: l.onboardingMealsBreakfast,
                subtitle: l.onboardingMealsHint,
                value: _toggle,
                onChanged: (v) => setState(() => _toggle = v),
              ),
            ),
          ),
          section(
            'SegmentedControl',
            SegmentedControl<String>(
              value: _lunch,
              onChanged: (v) => setState(() => _lunch = v),
              options: [
                SegmentOption(value: 'hot', label: l.onboardingMealsHot),
                SegmentOption(value: 'packed', label: l.onboardingMealsPacked),
              ],
            ),
          ),
          section(
            'ProgressSegments',
            ProgressSegments(
              total: 10,
              current: 3,
              semanticLabel: l.onboardingProgressLabel(3),
            ),
          ),
          section(
            'AppBanner',
            Column(
              children: [
                AppBanner(message: l.commonEstimateNote),
                const SizedBox(height: AppSpacing.sm),
                AppBanner(
                  kind: BannerKind.warning,
                  message: l.planBannerPartial(2, l.planBannerPartialDetail),
                  actionLabel: l.planBannerEdit,
                  onAction: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppBanner(
                  kind: BannerKind.error,
                  title: l.errorsGenericTitle,
                  message: l.errorsNetworkBody,
                  actionLabel: l.commonRetry,
                  onAction: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppBanner(kind: BannerKind.success, message: l.swapKeepDay),
              ],
            ),
          ),
          section(
            'ListRow',
            Card(
              child: Column(
                children: [
                  ListRow(
                    title: l.shoppingPantryHave,
                    subtitle: l.shoppingShelfLife(3),
                    leading: const Icon(Icons.kitchen_outlined),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListRow(
                    title: l.planEatOut,
                    dimmed: true,
                    leading: const Icon(Icons.restaurant),
                  ),
                ],
              ),
            ),
          ),
          section(
            'DishImage (7 nhóm + ảnh trống)',
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final g in ImageGroup.values)
                  Column(
                    children: [
                      DishImage(group: g, size: 88),
                      const SizedBox(height: 4),
                      Text(g.wire, style: theme.textTheme.labelSmall),
                    ],
                  ),
                Column(
                  children: [
                    const DishImage(size: 88),
                    const SizedBox(height: 4),
                    Text(l.galleryImageNull, style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          section(
            'DishCard',
            Column(
              children: [
                DishCard(
                  roleLabel: l.dishRoleMain,
                  name: 'Cá basa kho tộ',
                  proteinText: l.commonGram(32),
                  kcalText: l.commonKcal(240),
                  proteinLabel: l.macroProtein,
                  kcalLabel: l.macroKcal,
                  group: ImageGroup.kho,
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                DishCard(
                  roleLabel: l.dishRoleSoup,
                  name: 'Canh bí đao nấu tôm',
                  proteinText: l.commonGram(6),
                  kcalLabel: l.macroKcal,
                  proteinLabel: l.macroProtein,
                  kcalText: l.commonKcal(60),
                  group: ImageGroup.canh,
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                DishCard(
                  roleLabel: l.dishRoleDessert,
                  name: 'Chuối',
                  proteinText: l.commonGram(1),
                  kcalText: l.commonKcal(90),
                  proteinLabel: l.macroProtein,
                  kcalLabel: l.macroKcal,
                  group: ImageGroup.phu,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
