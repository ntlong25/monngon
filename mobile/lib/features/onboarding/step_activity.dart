import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'onboarding_scaffold.dart';

/// Bước 3 — mức vận động (5 mức).
class ActivityStep extends ConsumerWidget {
  const ActivityStep({super.key});

  static const levels = ['sedentary', 'light', 'moderate', 'high', 'athlete'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final activity = ref.watch(profileProvider.select((p) => p.activity));
    return OnboardingScaffold(
      title: l.onboardingBodyActivityTitle,
      children: [
        for (final id in levels) ...[
          SelectCard(
            title: Labels.activity(l, id),
            selected: activity == id,
            onTap: () => ref
                .read(profileProvider.notifier)
                .update((p) => p.copyWith(activity: id)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
