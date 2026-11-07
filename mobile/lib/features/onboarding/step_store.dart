import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/reference_gate.dart';
import 'onboarding_scaffold.dart';

/// `2026-11-06` → `06/11/2026`.
String formatSurveyDate(String? iso) {
  if (iso == null || iso.length < 10) return '';
  return '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
}

/// Bước 5 — chọn đúng 1 cửa hàng; thẻ chọn có trạng thái rõ; ghi chú "giá là ước tính" (US-1.2 AC1).
class StoreStep extends ConsumerWidget {
  const StoreStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final storeId = ref.watch(preferencesProvider.select((p) => p.storeId));
    return OnboardingScaffold(
      title: l.onboardingStoreTitle,
      subtitle: l.onboardingStoreNote,
      children: [
        ReferenceGate(
          builder: (context, r) => [
            for (final s in r.stores) ...[
              SelectCard(
                title: s.name,
                subtitle: s.priceSurveyDate == null
                    ? null
                    : l.onboardingStoreSurvey(
                        formatSurveyDate(s.priceSurveyDate),
                      ),
                selected: s.id == storeId,
                onTap: () => ref
                    .read(preferencesProvider.notifier)
                    .update((p) => p.copyWith(storeId: s.id)),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ],
    );
  }
}
