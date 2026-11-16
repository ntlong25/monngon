import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/providers.dart';
import '../../ui/ui.dart';
import 'onboarding_nav.dart';
import 'onboarding_scaffold.dart';
import 'swipe_deck.dart';

/// Thứ tự cố định của ba mục tiêu (cũng là thứ tự ba chấm).
const kGoalIds = ['lose', 'hold', 'build'];

/// Sau khi chọn, đợi chừng này rồi tự sang bước Khẩu vị (không tự sang khi bật giảm chuyển động).
const kGoalAutoNextDelay = Duration(milliseconds: 400);

String _illustrationOf(String goal) => switch (goal) {
  'hold' => 'goal-giu-can',
  'build' => 'goal-tang-co',
  _ => 'goal-giam-mo',
};

IconData _fallbackIconOf(String goal) => switch (goal) {
  'hold' => Icons.balance,
  'build' => Icons.fitness_center,
  _ => Icons.trending_down,
};

/// Bước 1 — mục tiêu: bộ 3 thẻ quẹt, chọn 1 (US-1.1 AC1, D-ONB-08, T-107).
/// Dùng chung chồng thẻ [SwipeDeck] với bước Khẩu vị nhưng ở chế độ "chọn 1 / xoay vòng":
/// quẹt phải (hoặc "Chọn mục tiêu này") chọn thẻ trên cùng rồi tự sang bước kế sau 400 ms;
/// quẹt trái (hoặc "Xem mục tiêu khác") đưa thẻ xuống cuối bộ nên không bao giờ hết thẻ.
class GoalStep extends ConsumerStatefulWidget {
  const GoalStep({super.key});

  @override
  ConsumerState<GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends ConsumerState<GoalStep> {
  final _deck = SwipeDeckController();
  late List<String> _order;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final chosen = ref.read(onboardingProvider).goalChosen;
    final goal = ref.read(profileProvider).goal;
    // Mở lại bước: thẻ đã chọn nằm trên cùng; chưa chọn thì bắt đầu từ thẻ đầu.
    _order = chosen && kGoalIds.contains(goal)
        ? [goal, ...kGoalIds.where((g) => g != goal)]
        : [...kGoalIds];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _select(String id) {
    _timer?.cancel();
    ref.read(profileProvider.notifier).update((p) => p.copyWith(goal: id));
    ref.read(onboardingProvider.notifier).markGoalChosen();
    if (_reduceMotion) return;
    _timer = Timer(kGoalAutoNextDelay, () {
      if (!mounted) return;
      OnboardingNav(ref).next();
    });
  }

  void _rotate() {
    _timer?.cancel();
    setState(() => _order = [..._order.skip(1), _order.first]);
  }

  void _decide(String id, {required bool like}) =>
      like ? _select(id) : _rotate();

  void _bringToFront(String id) {
    if (_order.first == id || _deck.busy) return;
    _timer?.cancel();
    setState(() => _order = [id, ..._order.where((g) => g != id)]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final goal = ref.watch(profileProvider.select((p) => p.goal));
    final chosen = ref.watch(onboardingProvider.select((s) => s.goalChosen));
    final hints = {
      'lose': l.onboardingGoalLoseHint,
      'hold': l.onboardingGoalHoldHint,
      'build': l.onboardingGoalBuildHint,
    };
    final top = _order.first;
    return OnboardingScaffold(
      title: l.onboardingGoalTitle,
      subtitle: l.onboardingGoalSwipeHint,
      canContinue: chosen,
      children: [
        SwipeDeck<String>(
          cards: _order,
          idOf: (id) => id,
          controller: _deck,
          onDecide: _decide,
          keepOnLike: true,
          onGrab: () => _timer?.cancel(),
          faceBuilder: (context, id) => _GoalFace(
            goal: id,
            title: Labels.goal(l, id),
            hint: hints[id] ?? '',
            selected: chosen && goal == id,
            selectedLabel: l.onboardingGoalSelected,
          ),
          likeLabel: l.onboardingGoalChoose,
          lessLabel: l.onboardingGoalOther,
          likeIcon: Icons.check_circle_outline,
          lessIcon: Icons.swap_horiz,
        ),
        const SizedBox(height: AppSpacing.md),
        _Dots(
          current: top,
          label: (i) => l.onboardingGoalDot(
            i + 1,
            kGoalIds.length,
            Labels.goal(l, kGoalIds[i]),
          ),
          onTap: _bringToFront,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          key: const Key('goal-choose'),
          onPressed: () => _deck.swipe(like: true),
          icon: const Icon(Icons.check),
          label: Text(l.onboardingGoalChoose),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          key: const Key('goal-other'),
          onPressed: () {
            _timer?.cancel();
            _deck.swipe(like: false);
          },
          icon: const Icon(Icons.swap_horiz),
          label: Text(l.onboardingGoalOther),
        ),
      ],
    );
  }
}

/// Mặt thẻ mục tiêu: hình ở trên, tên + mô tả ở dưới, dấu "Đã chọn" khi thẻ này là mục tiêu đã chọn.
class _GoalFace extends StatelessWidget {
  const _GoalFace({
    required this.goal,
    required this.title,
    required this.hint,
    required this.selected,
    required this.selectedLabel,
  });

  final String goal;
  final String title;
  final String hint;
  final bool selected;
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      selected: selected,
      label: selected ? '$title. $hint. $selectedLabel' : '$title. $hint',
      excludeSemantics: true,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.surfaceVariant,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, c) => Center(
                  child: Illustration(
                    name: _illustrationOf(goal),
                    fallback: _fallbackIconOf(goal),
                    size: (c.maxHeight - AppSpacing.lg).clamp(48.0, 200.0),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (selected) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    key: const Key('goal-selected-badge'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        selectedLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hàng 3 chấm: chạm chấm đưa thẻ đó lên trên. Vùng chạm 48 × 48 dp, chấm vẽ nhỏ ở giữa.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.current,
    required this.label,
    required this.onTap,
  });

  final String current;
  final String Function(int index) label;
  final void Function(String goal) onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < kGoalIds.length; i++)
          Semantics(
            button: true,
            selected: kGoalIds[i] == current,
            label: label(i),
            excludeSemantics: true,
            onTap: () => onTap(kGoalIds[i]),
            child: InkResponse(
              key: Key('goal-dot-${kGoalIds[i]}'),
              onTap: () => onTap(kGoalIds[i]),
              radius: 24,
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: kGoalIds[i] == current ? 14 : 10,
                    height: kGoalIds[i] == current ? 14 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kGoalIds[i] == current
                          ? AppColors.primary
                          : AppColors.outline,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
