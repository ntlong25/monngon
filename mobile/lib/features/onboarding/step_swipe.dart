import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import '../common/reference_gate.dart';
import 'onboarding_scaffold.dart';

/// Bước 11 — thẻ vuốt khẩu vị (US-1.5 AC1, AC2). Vuốt phải = thích, trái = ít hơn.
/// Có nút ✕ / ♥ / hoàn tác / thay thế cho người không vuốt được.
/// Kết quả ghi vào `cuisine_likes` / `cuisine_less` (trọng số mềm) theo `tag` của thẻ.
class SwipeStep extends ConsumerStatefulWidget {
  const SwipeStep({super.key});

  @override
  ConsumerState<SwipeStep> createState() => _SwipeStepState();
}

class _SwipeStepState extends ConsumerState<SwipeStep> {
  /// Thứ tự thẻ chưa vuốt có thể bị đẩy xuống cuối bởi "Thay thế" (chỉ trong phiên này).
  final List<String> _deferred = [];

  /// Lịch sử quyết định trong phiên, để hoàn tác.
  final List<String> _history = [];

  List<SwipeCardDto> _remaining(ReferenceResponse r, List<String> swiped) {
    final pending = r.swipeCards.where((c) => !swiped.contains(c.id)).toList();
    final first = pending.where((c) => !_deferred.contains(c.id)).toList();
    final later = [
      for (final id in _deferred) ...pending.where((c) => c.id == id),
    ];
    return [...first, ...later];
  }

  void _decide(SwipeCardDto card, {required bool like}) {
    final prefs = ref.read(preferencesProvider.notifier);
    prefs.update(
      (p) => p.copyWith(
        cuisineLikes: like
            ? [...p.cuisineLikes.where((t) => t != card.tag), card.tag]
            : p.cuisineLikes.where((t) => t != card.tag).toList(),
        cuisineLess: like
            ? p.cuisineLess.where((t) => t != card.tag).toList()
            : [...p.cuisineLess.where((t) => t != card.tag), card.tag],
      ),
    );
    ref.read(onboardingProvider.notifier).markSwiped(card.id);
    setState(() {
      _deferred.remove(card.id);
      _history.add(card.id);
    });
  }

  void _undo(ReferenceResponse r) {
    if (_history.isEmpty) return;
    final id = _history.removeLast();
    final card = r.swipeCards.firstWhere(
      (c) => c.id == id,
      orElse: () => const SwipeCardDto(),
    );
    ref
        .read(preferencesProvider.notifier)
        .update(
          (p) => p.copyWith(
            cuisineLikes: p.cuisineLikes.where((t) => t != card.tag).toList(),
            cuisineLess: p.cuisineLess.where((t) => t != card.tag).toList(),
          ),
        );
    ref.read(onboardingProvider.notifier).unmarkSwiped(id);
    setState(() {});
  }

  void _replace(SwipeCardDto card) {
    setState(() {
      _deferred
        ..remove(card.id)
        ..add(card.id);
    });
  }

  void _again() {
    ref
        .read(preferencesProvider.notifier)
        .update(
          (p) => p.copyWith(cuisineLikes: const [], cuisineLess: const []),
        );
    ref.read(onboardingProvider.notifier).resetSwiped();
    setState(() {
      _history.clear();
      _deferred.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final swiped = ref.watch(onboardingProvider.select((s) => s.swipedCardIds));
    final prefs = ref.watch(preferencesProvider);

    return OnboardingScaffold(
      title: l.onboardingSwipeTitle,
      subtitle: l.onboardingSwipeHint,
      children: [
        ReferenceGate(
          builder: (context, r) {
            final remaining = _remaining(r, swiped);
            final total = r.swipeCards.length;
            if (remaining.isEmpty) {
              return [_Results(reference: r, prefs: prefs, onAgain: _again)];
            }
            final card = remaining.first;
            final index = total - remaining.length + 1;
            return [
              Text(
                l.onboardingSwipeProgress(index, total),
                key: const Key('swipe-progress'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Dismissible(
                key: ValueKey('swipe-${card.id}'),
                // Chỉ cho vuốt ngang; vuốt phải = thích.
                direction: DismissDirection.horizontal,
                onDismissed: (d) =>
                    _decide(card, like: d == DismissDirection.startToEnd),
                child: _SwipeCard(card: card),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                runAlignment: WrapAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _RoundAction(
                    key: const Key('swipe-undo'),
                    icon: Icons.undo,
                    label: l.onboardingSwipeUndo,
                    onTap: _history.isEmpty ? null : () => _undo(r),
                  ),
                  _RoundAction(
                    key: const Key('swipe-dislike'),
                    icon: Icons.close,
                    label: l.onboardingSwipeDislike,
                    onTap: () => _decide(card, like: false),
                  ),
                  _RoundAction(
                    key: const Key('swipe-replace'),
                    icon: Icons.autorenew,
                    label: l.onboardingSwipeSkip,
                    onTap: remaining.length > 1 ? () => _replace(card) : null,
                  ),
                  _RoundAction(
                    key: const Key('swipe-like'),
                    icon: Icons.favorite,
                    label: l.onboardingSwipeLike,
                    onTap: () => _decide(card, like: true),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.onboardingSwipeSoft,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ];
          },
        ),
      ],
    );
  }
}

/// Hình minh họa theo nhóm cho thẻ vuốt (không có ảnh thật).
ImageGroup _groupOfTag(String tag) => switch (tag) {
  'xao' || 'chay' => ImageGroup.xao,
  'kho' || 'sot' || 'chien' => ImageGroup.kho,
  'canh' => ImageGroup.canh,
  'hap' || 'luoc' || 'thanh_dam' || 'nhe' => ImageGroup.luocHap,
  'an_sang' => ImageGroup.sang,
  'an_vat' || 'ngot' => ImageGroup.phu,
  _ => ImageGroup.com,
};

class _SwipeCard extends StatelessWidget {
  const _SwipeCard({required this.card});

  final SwipeCardDto card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: Key('swipe-card-${card.id}'),
      child: ConstrainedBox(
        // Chữ lớn thì thẻ cao thêm, không cắt nội dung.
        constraints: const BoxConstraints(minHeight: 220),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: DishImage(
                  group: _groupOfTag(card.tag),
                  size: 96,
                  borderRadius: AppRadius.lg,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                card.title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                card.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton.filledTonal(
        tooltip: label,
        iconSize: 28,
        constraints: const BoxConstraints.tightFor(width: 56, height: 56),
        onPressed: onTap,
        icon: Icon(icon),
      ),
      const SizedBox(height: 2),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 80),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}

class _Results extends StatelessWidget {
  const _Results({
    required this.reference,
    required this.prefs,
    required this.onAgain,
  });

  final ReferenceResponse reference;
  final Preferences prefs;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    String names(List<String> tags) => reference.swipeCards
        .where((c) => tags.contains(c.tag))
        .map((c) => c.title)
        .join(', ');
    Widget section(String title, List<String> tags, Key key) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            tags.isEmpty ? l.onboardingSwipeNone : names(tags),
            key: key,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l.onboardingSwipeResultTitle,
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        section(
          l.onboardingSwipeLiked,
          prefs.cuisineLikes,
          const Key('swipe-liked'),
        ),
        section(
          l.onboardingSwipeLess,
          prefs.cuisineLess,
          const Key('swipe-less'),
        ),
        Text(
          l.onboardingSwipeSoft,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          key: const Key('swipe-again'),
          label: l.onboardingSwipeAgain,
          kind: AppButtonKind.secondary,
          onPressed: onAgain,
        ),
      ],
    );
  }
}
