import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_providers.dart';
import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../core/rice.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../state/week_changes.dart';
import '../../ui/ui.dart';
import '../common/api_error_view.dart';
import '../meal/change_sheets.dart';
import '../onboarding/onboarding_nav.dart';
import '../onboarding/onboarding_providers.dart';

/// Tab Bạn (Epic 6): sửa chỉ tiêu và lựa chọn, món đã chặn, tuần đã lưu, miễn trừ/nguồn dữ liệu, xóa dữ liệu.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final prefs = ref.watch(preferencesProvider);
    final targetsAsync = ref.watch(targetsProvider);
    // Offline/đang tính: dùng chỉ tiêu đã lưu trên máy cho đúng hồ sơ này (D-QA-09).
    final targets = targetsAsync.value ?? ref.watch(savedTargetsProvider);
    final targetsError =
        targets == null &&
            targetsAsync.hasError &&
            targetsAsync.error is! SupersededRequest
        ? targetsAsync.error
        : null;
    final reference = ref.watch(referenceProvider).value;
    final plan = ref.watch(currentPlanProvider);
    final saved = ref.watch(savedPlansProvider);
    final dirty = ref.watch(choicesDirtyProvider);
    final swiped = ref.watch(onboardingProvider.select((s) => s.swipedCardIds));
    final now = ref.watch(clockProvider)();
    final health = ref.watch(healthProvider);

    final storeName = reference?.stores
        .where((s) => s.id == prefs.storeId)
        .map((s) => s.name)
        .firstOrNull;

    List<Widget> rows(List<(String, String, String, OnboardingStep)> items) => [
      for (final (key, title, value, step) in items)
        _NavRow(
          key: Key('edit-$key'),
          title: title,
          value: value,
          onTap: () => _edit(context, ref, step),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.tabProfile)),
      body: ListView(
        key: const Key('profile-list'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _Header(l.profileSectionChoices),
          Text(
            l.profileChoicesHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (targetsError != null) ...[
            Container(
              key: const Key('profile-targets-error'),
              child: ApiErrorView(
                error: targetsError,
                onRetry: () => ref.invalidate(targetsProvider),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (dirty) ...[
            AppBanner(
              key: const Key('profile-dirty'),
              kind: BannerKind.warning,
              title: l.profileDirtyTitle,
              message: l.profileDirtyBody,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _Group(
            children: rows([
              (
                'goal',
                l.onboardingSummaryGoal,
                Labels.goal(l, profile.goal),
                OnboardingStep.goal,
              ),
              (
                'body',
                l.profileRowBody,
                l.profileBodyValue(
                  Labels.sex(l, profile.sex),
                  formatInt(profile.age),
                  formatInt(profile.heightCm),
                  formatInt(profile.weightKg),
                ),
                OnboardingStep.body,
              ),
              (
                'activity',
                l.profileRowActivity,
                Labels.activity(l, profile.activity),
                OnboardingStep.activity,
              ),
              (
                'targets',
                l.profileRowTargets,
                targets == null
                    ? (targetsError == null
                          ? l.commonLoading
                          : l.errorsNetworkTitle)
                    : '${l.profileTargetsValue(formatInt(targets.proteinG), formatInt(targets.kcalTarget))}'
                          '${profile.targetMode == 'manual' ? ' (${l.profileTargetsManual})' : ''}',
                OnboardingStep.targets,
              ),
              (
                'store',
                l.profileRowStore,
                storeName ?? prefs.storeId,
                OnboardingStep.store,
              ),
              (
                'household',
                l.profileRowHousehold,
                l.profileHouseholdValue(prefs.adults, prefs.children),
                OnboardingStep.household,
              ),
              (
                'budget',
                l.onboardingSummaryBudget,
                prefs.weeklyBudgetVnd <= 0
                    ? '…'
                    : '${l.commonVnd(formatVnd(prefs.weeklyBudgetVnd))} ${l.onboardingBudgetPerWeek}',
                OnboardingStep.budget,
              ),
              (
                'meals',
                l.onboardingSummaryMeals,
                l.onboardingSummaryMealsValue(
                  [
                    prefs.slots.breakfast,
                    prefs.slots.lunch,
                    prefs.slots.dinner,
                    prefs.slots.snackAm,
                    prefs.slots.snackPm,
                  ].where((m) => m == 'on').length,
                ),
                OnboardingStep.meals,
              ),
              (
                'diet',
                l.onboardingSummaryLeanings,
                _leanings(l, prefs, reference),
                OnboardingStep.diet,
              ),
              (
                'rice',
                l.profileRiceHabitTitle,
                RiceHabit.summary(l, prefs),
                OnboardingStep.rice,
              ),
              (
                'dislike',
                l.onboardingSummaryExcluded,
                _excluded(l, prefs, reference, ref),
                OnboardingStep.dislike,
              ),
              (
                'swipe',
                l.profileRowTaste,
                l.profileTasteValue(swiped.length),
                OnboardingStep.swipe,
              ),
              (
                'equipment',
                l.onboardingSummaryKitchen,
                _kitchen(l, prefs, reference),
                OnboardingStep.equipment,
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (plan != null && hasDaysAfter(plan.plan, now))
            AppButton(
              key: const Key('profile-replan'),
              label: l.profileReplanButton,
              icon: Icons.autorenew,
              expand: true,
              onPressed: () => confirmReplan(
                context,
                onDone: () {
                  if (context.mounted) context.go(Routes.plan);
                },
              ),
            )
          else if (plan != null) ...[
            Text(
              l.profileNextWeekHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              key: const Key('profile-next-week'),
              label: l.profileNextWeekButton,
              icon: Icons.add,
              expand: true,
              onPressed: () => _createNextWeek(context, ref),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          _Header(l.profileSectionBlocked),
          _Group(
            children: [
              _NavRow(
                key: const Key('open-blocked'),
                title: l.profileSectionBlocked,
                value: l.profileBlockedValue(prefs.blockedRecipeIds.length),
                onTap: () => context.push(Routes.profileBlocked),
              ),
              _NavRow(
                key: const Key('open-saved'),
                title: l.accountSavedPlans,
                value: l.profileSavedValue(saved.length),
                onTap: () => context.push(Routes.profileSaved),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _Header(l.profileSectionAbout),
          _Group(
            children: [
              for (final (doc, title) in [
                ('disclaimer', l.profileDisclaimerTitle),
                ('sources', l.accountSources),
                ('prices', l.profilePricesTitle),
                ('privacy', l.profilePrivacyTitle),
              ])
                _NavRow(
                  key: Key('open-info-$doc'),
                  title: title,
                  onTap: () => context.push(Routes.profileInfo(doc)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _Header(l.profileSectionData),
          Text(
            l.profileClearHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            key: const Key('clear-data'),
            label: l.accountClearData,
            icon: Icons.delete_outline,
            kind: AppButtonKind.secondary,
            expand: true,
            onPressed: () => _clearData(context, ref),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Header(l.connectionTitle),
          ListTile(
            key: const Key('connection-status'),
            contentPadding: EdgeInsets.zero,
            leading: health.when(
              loading: () => const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) =>
                  Icon(Icons.cloud_off, color: theme.colorScheme.error),
              data: (ok) => Icon(
                ok ? Icons.cloud_done : Icons.cloud_off,
                color: ok ? AppColors.primary : theme.colorScheme.error,
              ),
            ),
            title: Text(
              health.when(
                loading: () => l.connectionChecking,
                error: (_, _) => l.connectionFail,
                data: (ok) => ok ? l.connectionOk : l.connectionFail,
              ),
            ),
            subtitle: Text(l.apiBaseUrl(ref.watch(apiBaseUrlProvider))),
            trailing: TextButton(
              onPressed: () => ref.invalidate(healthProvider),
              child: Text(l.commonRetry),
            ),
          ),
          if (kDebugMode)
            ListTile(
              key: const Key('open-gallery'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.widgets_outlined),
              title: Text(l.galleryOpen),
              onTap: () => context.push(Routes.gallery),
            ),
        ],
      ),
    );
  }

  static String _name(
    List<OptionDto> list,
    String id,
    String Function(OptionDto) label,
  ) {
    final o = list.where((e) => e.id == id);
    return o.isEmpty ? id : label(o.first);
  }

  static String _join(AppL10n l, List<String> v) =>
      v.isEmpty ? l.onboardingSummaryNone : v.join(', ');

  static String _leanings(AppL10n l, Preferences p, ReferenceResponse? r) =>
      _join(l, [
        if (p.lowCarb) l.onboardingSummaryLowCarb,
        for (final id in p.healthLeanings)
          _name(r?.healthLeanings ?? const [], id, (o) => Labels.leaning(l, o)),
      ]);

  static String _excluded(
    AppL10n l,
    Preferences p,
    ReferenceResponse? r,
    WidgetRef ref,
  ) {
    final names = ref.read(ingredientNamesProvider);
    return _join(l, [
      if (p.diet.isNotEmpty && p.diet != 'none')
        _name(r?.diets ?? const [], p.diet, (o) => Labels.diet(l, o)),
      for (final id in p.exclusions)
        _name(r?.exclusions ?? const [], id, (o) => Labels.exclusion(l, o)),
      for (final id in p.dislikedIngredientIds) names[id] ?? id,
    ]);
  }

  static String _kitchen(AppL10n l, Preferences p, ReferenceResponse? r) =>
      _join(l, [
        for (final id in p.equipment)
          _name(r?.equipment ?? const [], id, (o) => Labels.equipment(l, o)),
      ]);

  /// Mở màn sửa một bước; đổi gì thì đánh dấu "chưa áp dụng cho tuần hiện tại".
  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    OnboardingStep step,
  ) async {
    final l = AppL10n.of(context);
    String snap() => jsonEncode([
      ref.read(profileProvider).toJson(),
      ref.read(preferencesProvider).toJson(),
    ]);
    final before = snap();
    await context.push(Routes.profileEdit(step.name));
    if (!context.mounted || snap() == before) return;
    ref.read(choicesDirtyProvider.notifier).mark();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.profileEditSaved)));
  }

  Future<void> _createNextWeek(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.changeBusy)));
    try {
      final plan = await ref
          .read(apiProvider)
          .createPlan(
            PlanRequest(
              profile: ref.read(profileProvider),
              preferences: ref.read(preferencesProvider),
              startDate: isoDate(tomorrow(ref.read(clockProvider)())),
              mealStyle: 'auto',
              includeDessert: true,
            ),
          );
      ref.read(appActionsProvider).startNewWeek(plan);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.profileNextWeekDone)));
      if (context.mounted) context.go(Routes.plan);
    } on Object {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.changeFailed)));
    }
  }

  /// Xóa toàn bộ dữ liệu: xác nhận 2 bước (US-6.3).
  Future<void> _clearData(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    Future<bool> ask(
      String title,
      String? body,
      String yes,
      String keyYes,
    ) async =>
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: body == null ? null : Text(body),
            actions: [
              TextButton(
                key: const Key('clear-cancel'),
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.commonCancel),
              ),
              FilledButton(
                key: Key(keyYes),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(yes),
              ),
            ],
          ),
        ) ??
        false;
    if (!await ask(
      l.accountClearDataConfirm1,
      l.profileClearHint,
      l.profileClearContinue,
      'clear-step1',
    )) {
      return;
    }
    if (!context.mounted) return;
    if (!await ask(
      l.accountClearDataConfirm2,
      null,
      l.profileClearConfirm,
      'clear-step2',
    )) {
      return;
    }
    // Xóa xong, onboarding về chưa hoàn tất → router tự đưa về màn onboarding.
    await ref.read(appActionsProvider).clearAll();
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.divider),
          children[i],
        ],
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.onTap,
    this.value,
    super.key,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListRow(
    title: title,
    subtitle: value,
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
