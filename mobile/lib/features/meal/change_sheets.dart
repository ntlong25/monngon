import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/api_client.dart';
import '../../api/generated/models.dart';
import '../../core/format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/week_changes.dart';
import '../../ui/ui.dart';
import '../plan/plan_view.dart';

/// Số có dấu để nói "chênh lệch": `+12`, `−5` (dấu trừ U+2212), `0`.
String signed(num v) {
  final r = v.round();
  if (r > 0) return '+${formatInt(r)}';
  if (r < 0) return '−${formatInt(-r)}';
  return '0';
}

/// Chạy một thay đổi tuần: lỗi → thanh thông báo thân thiện; thành công → thông báo kèm nút Hoàn tác.
/// Dùng [ProviderContainer] (không dùng `ref` của widget) vì sheet/trang có thể đã đóng khi xong.
Future<bool> runChange(
  BuildContext context,
  Future<void> Function() action, {
  required String done,
  bool undoable = true,
}) async {
  final l = AppL10n.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context);
  try {
    await action();
  } on Object catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException && e.isNetwork
                ? l.errorsNetworkBody
                : l.changeFailed,
          ),
        ),
      );
    return false;
  }
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        key: const Key('change-snackbar'),
        content: Text(done),
        action: undoable
            ? SnackBarAction(
                label: l.commonUndo,
                onPressed: () {
                  if (container.read(weekChangesProvider).undo()) {
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l.changeUndone)));
                  }
                },
              )
            : null,
      ),
    );
  return true;
}

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: builder,
    );

// --- Đổi món (US-5.1) -----------------------------------------------------------------

Future<void> showSwapSheet(
  BuildContext context, {
  required String date,
  required String slot,
}) => _showSheet<void>(context, (_) => SwapSheet(date: date, slot: slot));

class SwapSheet extends ConsumerStatefulWidget {
  const SwapSheet({required this.date, required this.slot, super.key});

  final String date;
  final String slot;

  @override
  ConsumerState<SwapSheet> createState() => _SwapSheetState();
}

class _SwapSheetState extends ConsumerState<SwapSheet> {
  late Future<SwapSuggestions> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = ref
      .read(weekChangesProvider)
      .suggestSwaps(widget.date, widget.slot);

  Future<void> _pick(SwapSuggestion s) async {
    final l = AppL10n.of(context);
    final nav = Navigator.of(context);
    final changes = ref.read(weekChangesProvider);
    setState(() => _busy = true);
    final ok = await runChange(
      context,
      () => changes.applySwap(widget.date, widget.slot, s.recipeId),
      done: l.changeSwapped,
    );
    if (!mounted) return;
    if (ok) {
      nav.pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return _SheetFrame(
      title: l.changeSwapSheetTitle,
      child: FutureBuilder<SwapSuggestions>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Padding(
              key: const Key('swap-loading'),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(l.changeSwapLoading),
                ],
              ),
            );
          }
          if (snap.hasError) {
            return _SheetError(
              error: snap.error!,
              onRetry: () => setState(() {
                _load();
              }),
            );
          }
          final r = snap.data!;
          if (r.items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(l.changeSwapEmpty, key: const Key('swap-empty')),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!r.anyKeepsDay) ...[
                AppBanner(
                  key: const Key('swap-none-keep'),
                  kind: BannerKind.warning,
                  message: l.changeSwapNoneKeep,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              for (final s in r.items) ...[
                _SwapCard(
                  suggestion: s,
                  recipes: r.recipes,
                  busy: _busy,
                  onPick: () => _pick(s),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                l.changeSwapHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SwapCard extends StatelessWidget {
  const _SwapCard({
    required this.suggestion,
    required this.recipes,
    required this.busy,
    required this.onPick,
  });

  final SwapSuggestion suggestion;
  final Map<String, Recipe> recipes;
  final bool busy;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final s = suggestion;
    final title = s.dishes.length > 1
        ? dishNamesTitle(
            s.dishes
                .where((d) => d.role != 'dessert' && d.role != 'extra')
                .map((d) => d.name),
          )
        : s.name;
    final image = recipes[s.recipeId]?.image;
    final group = recipes[s.recipeId]?.imageGroup;
    return Card(
      key: Key('swap-card-${s.recipeId}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DishImage(
                  image: image,
                  group: ImageGroup.fromWire(group),
                  size: 56,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                MacroChip(
                  kind: MacroKind.protein,
                  label: l.macroProtein,
                  value: l.changeDeltaProtein(signed(s.deltaProteinG)),
                ),
                MacroChip(
                  kind: MacroKind.kcal,
                  label: l.macroKcal,
                  value: l.changeDeltaKcal(signed(s.deltaKcal)),
                ),
                Text(
                  l.changeDeltaCost(signed(s.deltaCostVnd)),
                  key: Key('swap-cost-${s.recipeId}'),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  s.keepsDayOk
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  size: 18,
                  color: s.keepsDayOk
                      ? AppColors.primary
                      : AppColors.warningIcon,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.keepsDayOk ? l.changeKeepsDay : l.changeBreaksDay,
                    key: Key('swap-day-${s.recipeId}'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton(
                key: Key('swap-pick-${s.recipeId}'),
                label: l.changePick,
                kind: s.keepsDayOk
                    ? AppButtonKind.primary
                    : AppButtonKind.secondary,
                loading: busy,
                onPressed: busy ? null : onPick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Đổi một nguyên liệu (US-5.2) ----------------------------------------------------------

Future<void> showIngredientSwapSheet(
  BuildContext context, {
  required String date,
  required String slot,
  required String ingredientId,
  required String ingredientName,
}) => _showSheet<void>(
  context,
  (_) => IngredientSwapSheet(
    date: date,
    slot: slot,
    ingredientId: ingredientId,
    ingredientName: ingredientName,
  ),
);

class IngredientSwapSheet extends ConsumerStatefulWidget {
  const IngredientSwapSheet({
    required this.date,
    required this.slot,
    required this.ingredientId,
    required this.ingredientName,
    super.key,
  });

  final String date;
  final String slot;
  final String ingredientId;
  final String ingredientName;

  @override
  ConsumerState<IngredientSwapSheet> createState() =>
      _IngredientSwapSheetState();
}

class _IngredientSwapSheetState extends ConsumerState<IngredientSwapSheet> {
  late Future<IngredientOptions> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = ref
      .read(weekChangesProvider)
      .ingredientOptions(widget.date, widget.slot, widget.ingredientId);

  Future<void> _pick(IngredientOption o) async {
    final l = AppL10n.of(context);
    final nav = Navigator.of(context);
    final changes = ref.read(weekChangesProvider);
    setState(() => _busy = true);
    final ok = await runChange(
      context,
      () => changes.swapIngredient(
        widget.date,
        widget.slot,
        widget.ingredientId,
        o.ingredientId,
      ),
      done: l.changeIngSwapped,
    );
    if (!mounted) return;
    if (ok) {
      nav.pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return _SheetFrame(
      title: l.changeIngSwapTitle(widget.ingredientName),
      child: FutureBuilder<IngredientOptions>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              key: Key('ing-swap-loading'),
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            );
          }
          if (snap.hasError) {
            return _SheetError(
              error: snap.error!,
              onRetry: () => setState(() {
                _load();
              }),
            );
          }
          final options = snap.data!.options;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.changeIngSwapHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (options.isEmpty)
                Text(l.changeIngSwapEmpty, key: const Key('ing-swap-empty')),
              for (final o in options)
                Card(
                  key: Key('ing-opt-${o.ingredientId}'),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: _busy ? null : () => _pick(o),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o.name,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                      l.commonGram(formatInt(o.grams)),
                                      l.changeDeltaProtein(
                                        signed(o.deltaProteinG),
                                      ),
                                      l.changeDeltaKcal(signed(o.deltaKcal)),
                                      l.changeDeltaCost(signed(o.deltaCostVnd)),
                                    ].join(' · '),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_busy)
                              const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            else
                              const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// --- Ăn ngoài / bỏ bữa (US-5.3) ---------------------------------------------------------------

/// Trả về `true` nếu đã đánh dấu xong.
Future<bool> showOutSheet(
  BuildContext context, {
  required String date,
  required String slot,
}) async =>
    (await _showSheet<bool>(
      context,
      (_) => OutSheet(date: date, slot: slot),
    )) ??
    false;

class OutSheet extends ConsumerStatefulWidget {
  const OutSheet({required this.date, required this.slot, super.key});

  final String date;
  final String slot;

  @override
  ConsumerState<OutSheet> createState() => _OutSheetState();
}

class _OutSheetState extends ConsumerState<OutSheet> {
  bool _busy = false;

  Future<void> _mark(String mode) async {
    final l = AppL10n.of(context);
    final nav = Navigator.of(context);
    final changes = ref.read(weekChangesProvider);
    setState(() => _busy = true);
    final ok = await runChange(
      context,
      () => changes.setOut(widget.date, widget.slot, mode),
      done: l.changeOutDone,
    );
    if (!mounted) return;
    if (ok) {
      nav.pop(true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return _SheetFrame(
      title: l.changeOutSheetTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_busy) const LinearProgressIndicator(),
          ListTile(
            key: const Key('out-eat_out'),
            enabled: !_busy,
            minVerticalPadding: AppSpacing.md,
            leading: const Icon(Icons.restaurant_outlined),
            title: Text(l.planEatOut),
            subtitle: Text(l.changeOutEatHint),
            onTap: () => _mark('eat_out'),
          ),
          ListTile(
            key: const Key('out-skip'),
            enabled: !_busy,
            minVerticalPadding: AppSpacing.md,
            leading: const Icon(Icons.not_interested_outlined),
            title: Text(l.changeOutSkip),
            subtitle: Text(l.changeOutSkipHint),
            onTap: () => _mark('skip'),
          ),
        ],
      ),
    );
  }
}

// --- Không hợp với tôi → chặn (+ lên lại) (US-5.4, 5.5) ---------------------------------------------

enum BlockChoice { replan, blockOnly }

/// Hỏi người dùng muốn chặn món và (nếu còn ngày sau hôm nay) lên lại phần còn lại của tuần.
Future<BlockChoice?> askBlock(BuildContext context, {required bool canReplan}) {
  final l = AppL10n.of(context);
  return showDialog<BlockChoice>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.changeBlockTitle),
      content: Text(canReplan ? l.changeBlockBody : l.recipeBlocked),
      actions: [
        TextButton(
          key: const Key('block-cancel'),
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.commonCancel),
        ),
        TextButton(
          key: const Key('block-only'),
          onPressed: () => Navigator.pop(ctx, BlockChoice.blockOnly),
          child: Text(l.changeBlockOnly),
        ),
        if (canReplan)
          FilledButton(
            key: const Key('block-replan'),
            onPressed: () => Navigator.pop(ctx, BlockChoice.replan),
            child: Text(l.changeBlockAndReplan),
          ),
      ],
    ),
  );
}

// --- Khung chung ------------------------------------------------------------------------------------

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SheetError extends StatelessWidget {
  const _SheetError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final network = error is ApiException && (error as ApiException).isNetwork;
    return AppBanner(
      key: const Key('sheet-error'),
      kind: BannerKind.error,
      message: network ? l.errorsNetworkBody : l.changeFailed,
      actionLabel: l.commonRetry,
      onAction: onRetry,
    );
  }
}

/// Hỏi xác nhận rồi lên lại các ngày sau hôm nay (US-5.5). [onDone] chạy khi thành công.
Future<void> confirmReplan(BuildContext context, {VoidCallback? onDone}) async {
  final l = AppL10n.of(context);
  final yes = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.planReplanConfirmTitle),
      content: Text(l.planReplanConfirmBody),
      actions: [
        TextButton(
          key: const Key('replan-cancel'),
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          key: const Key('replan-confirm'),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.planReplanConfirm),
        ),
      ],
    ),
  );
  if (yes != true || !context.mounted) return;
  final changes = ProviderScope.containerOf(context).read(weekChangesProvider);
  final ok = await runChange(
    context,
    () => changes.regenerateRest(),
    done: l.planReplanTitle,
  );
  if (ok) onDone?.call();
}
