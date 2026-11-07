import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'onboarding_edit.dart';
import 'onboarding_nav.dart';

/// Khung chung của một bước wizard: nút quay lại, thanh tiến độ, tiêu đề, nội dung cuộn và nút CTA cố định.
class OnboardingScaffold extends ConsumerWidget {
  const OnboardingScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    this.canContinue = true,
    this.onContinue,
    this.ctaLabel,
    this.caption,
    this.loading = false,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool canContinue;

  /// Mặc định: sang bước kế tiếp.
  final VoidCallback? onContinue;
  final String? ctaLabel;
  final String? caption;
  final bool loading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final step = ref.watch(onboardingProvider.select((s) => s.step));
    final total = OnboardingStep.values.length;
    final nav = OnboardingNav(ref);
    final editing = OnboardingEditScope.of(context);
    final save = onContinue;
    return Scaffold(
      appBar: editing
          ? AppBar(
              leading: IconButton(
                key: const Key('edit-back'),
                tooltip: l.commonBack,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            )
          : AppBar(
              automaticallyImplyLeading: false,
              leading: step > 0
                  ? IconButton(
                      key: const Key('onboarding-back'),
                      tooltip: l.commonBack,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: nav.back,
                    )
                  : null,
              title: ProgressSegments(
                total: total,
                current: step + 1,
                semanticLabel: l.onboardingProgressOf(step + 1, total),
              ),
              titleSpacing: step > 0 ? 0 : AppSpacing.lg,
              actions: const [SizedBox(width: AppSpacing.lg)],
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          ...children,
        ],
      ),
      bottomNavigationBar: BottomCTA(
        label: editing ? l.profileEditSave : (ctaLabel ?? l.commonContinue),
        caption: caption,
        loading: loading,
        onPressed: !canContinue
            ? null
            : editing
            ? () {
                save?.call();
                Navigator.of(context).maybePop(true);
              }
            : (save ?? nav.next),
        secondaryLabel: editing ? null : secondaryLabel,
        onSecondary: editing ? null : onSecondary,
      ),
    );
  }
}
