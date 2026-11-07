import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/reference_gate.dart';
import 'onboarding_providers.dart';
import 'onboarding_scaffold.dart';

/// Bước 10 — nguyên liệu không bao giờ muốn thấy (US-1.4). Tìm không dấu qua `GET /v1/ingredients`,
/// kèm chip gợi ý nhanh lấy từ `reference.dislike_suggestions`.
class DislikeStep extends ConsumerStatefulWidget {
  const DislikeStep({super.key});

  @override
  ConsumerState<DislikeStep> createState() => _DislikeStepState();
}

class _DislikeStepState extends ConsumerState<DislikeStep> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(IngredientDto i) {
    ref.read(ingredientNamesProvider.notifier).remember([i]);
    ref
        .read(preferencesProvider.notifier)
        .update(
          (p) => p.dislikedIngredientIds.contains(i.id)
              ? p
              : p.copyWith(
                  dislikedIngredientIds: [...p.dislikedIngredientIds, i.id],
                ),
        );
  }

  void _remove(String id) => ref
      .read(preferencesProvider.notifier)
      .update(
        (p) => p.copyWith(
          dislikedIngredientIds: p.dislikedIngredientIds
              .where((e) => e != id)
              .toList(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final selected = ref.watch(
      preferencesProvider.select((p) => p.dislikedIngredientIds),
    );
    final names = ref.watch(ingredientNamesProvider);
    final search = _query.trim().isEmpty
        ? null
        : ref.watch(ingredientSearchProvider(_query));

    Widget results() {
      if (search == null) return const SizedBox.shrink();
      return search.when(
        data: (items) {
          final shown = items.where((i) => !selected.contains(i.id)).toList();
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                l.onboardingDislikeNoResult,
                key: const Key('dislike-no-result'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Column(
              children: [
                for (final i in shown)
                  ListRow(
                    key: Key('result-${i.id}'),
                    title: i.name,
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      _add(i);
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => e is SupersededRequest
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  l.errorsNetworkBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
      );
    }

    return OnboardingScaffold(
      title: l.onboardingDislikeTitle,
      children: [
        TextField(
          key: const Key('dislike-search'),
          controller: _controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: l.onboardingDislikeSearch,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        results(),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text(
            l.onboardingDislikeSelected,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (selected.isEmpty)
          Text(
            l.onboardingDislikeNone,
            key: const Key('dislike-empty'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final id in selected)
                AppChip(
                  key: Key('picked-$id'),
                  label: names[id] ?? id,
                  selected: true,
                  onDeleted: () => _remove(id),
                  deleteLabel: l.onboardingDislikeRemove(names[id] ?? id),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text(
            l.onboardingDislikeSuggestions,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ReferenceGate(
          builder: (context, r) => [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final i in r.dislikeSuggestions)
                  if (!selected.contains(i.id))
                    AppChip(
                      key: Key('suggest-${i.id}'),
                      label: i.name,
                      onTap: () => _add(i),
                    ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
