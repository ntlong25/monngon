import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../state/week_changes.dart';
import '../../ui/ui.dart';
import '../onboarding/onboarding_edit.dart';
import '../onboarding/onboarding_flow.dart';
import '../onboarding/onboarding_nav.dart';
import '../plan/plan_view.dart' show parseIsoDate;

/// Sửa một bước onboarding từ tab Bạn: dùng lại đúng màn của wizard, ở chế độ sửa.
class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({required this.step, super.key});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) =>
      OnboardingEditScope(child: buildOnboardingStep(step));
}

/// Danh sách món đã chặn, bỏ chặn từng món (US-6.2).
class BlockedPage extends ConsumerWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final ids = ref.watch(blockedRecipesProvider);
    final names = ref.watch(blockedNamesProvider);
    final plan = ref.watch(currentPlanProvider);
    final saved = ref.watch(savedPlansProvider);

    String nameOf(String id) =>
        names[id] ??
        plan?.recipes[id]?.name ??
        saved
            .map((s) => s.plan.recipes[id]?.name)
            .firstWhere((n) => n != null, orElse: () => null) ??
        id.replaceAll('_', ' ');

    return Scaffold(
      appBar: AppBar(title: Text(l.profileSectionBlocked)),
      body: ListView(
        key: const Key('blocked-list'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l.profileBlockedHint,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (ids.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                l.profileBlockedEmpty,
                key: const Key('blocked-empty'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          for (final id in ids) ...[
            Card(
              key: Key('blocked-$id'),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                  right: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        nameOf(id),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Semantics(
                      label: l.profileUnblockLabel(nameOf(id)),
                      excludeSemantics: true,
                      button: true,
                      child: AppButton(
                        key: Key('unblock-$id'),
                        label: l.profileUnblock,
                        kind: AppButtonKind.text,
                        onPressed: () {
                          final name = nameOf(id);
                          ref
                              .read(preferencesProvider.notifier)
                              .unblockRecipe(id);
                          ref.read(choicesDirtyProvider.notifier).mark();
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text(l.profileUnblocked(name))),
                            );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Tuần đã lưu (US-5.5 AC3): xem lại khoảng ngày và ngày lưu.
class SavedWeeksPage extends ConsumerWidget {
  const SavedWeeksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final saved = ref.watch(savedPlansProvider);
    String dm(String iso) => '${iso.substring(8, 10)}/${iso.substring(5, 7)}';
    return Scaffold(
      appBar: AppBar(title: Text(l.accountSavedPlans)),
      body: saved.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  l.accountSavedPlansEmpty,
                  key: const Key('saved-empty'),
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              key: const Key('saved-list'),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final s in saved.reversed) ...[
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListRow(
                      title: l.profileSavedWeek(
                        dm(s.plan.plan.startDate),
                        dm(
                          isoDate(
                            parseIsoDate(s.plan.plan.startDate)
                                .add(const Duration(days: 6)),
                          ),
                        ),
                      ),
                      subtitle: l.profileSavedAt(
                        '${s.savedAt.day.toString().padLeft(2, '0')}/${s.savedAt.month.toString().padLeft(2, '0')}/${s.savedAt.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
    );
  }
}

/// Văn bản: miễn trừ y tế, nguồn dữ liệu, giá ước tính, riêng tư (US-6.3).
class InfoPage extends StatelessWidget {
  const InfoPage({required this.doc, super.key});

  final String doc;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final (title, body) = switch (doc) {
      'disclaimer' => (l.profileDisclaimerTitle, l.profileDisclaimerBody),
      'sources' => (l.accountSources, l.profileSourcesBody),
      'prices' => (l.profilePricesTitle, l.profilePricesBody),
      _ => (l.profilePrivacyTitle, l.profilePrivacyBody),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        key: Key('info-$doc'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (final para in body.split('\n\n')) ...[
            SelectableText(para, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
