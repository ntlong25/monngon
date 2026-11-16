import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;

import '../../api/generated/models.dart';
import '../../ui/ui.dart';

/// Chồng thẻ vuốt khẩu vị kiểu "quẹt thẻ" (T-106, D-ONB-07). Tự viết bằng cử chỉ + `AnimationController` + `Transform`,
/// không thêm gói ngoài. Chỉ lấy cơ chế quẹt; giao diện, màu, câu chữ là của FitPro - Mâm đủ.
///
/// - Thẻ căn giữa, rộng = chiều rộng cho phép (≤ [kSwipeCardMaxWidth]); bo góc 20 dp, có bóng.
/// - Sau thẻ đang xem thấy tối đa 2 thẻ kế tiếp (scale 0,95 / 0,90, lệch xuống 8 / 16 dp), "tiến lên" theo độ kéo.
/// - Kéo theo cả hai trục, xoay tối đa ±12°; nhãn "Thích" / "Ít hơn" hiện dần theo độ kéo.
/// - Quyết định khi kéo ngang ≥ 35% chiều rộng thẻ hoặc vận tốc ngang ≥ 700 dp/s; chưa tới thì bật về (300 ms),
///   vượt thì bay ra (280 ms) rồi gọi [SwipeDeck.onDecide].
/// - Bật giảm chuyển động: không xoay, không scale, không bay; đổi thẻ ngay.
const double kSwipeCardMaxWidth = 400;
const double kSwipeCardRadius = 20;

/// Kéo ngang tối thiểu để quyết định (tỉ lệ chiều rộng thẻ).
const double kSwipeDistanceFraction = 0.35;

/// Vận tốc ngang tối thiểu để quyết định (dp/s).
const double kSwipeFlingVelocity = 700;

/// Góc xoay tối đa (độ).
const double kSwipeMaxTiltDeg = 12;

const Duration kSwipeFlyDuration = Duration(milliseconds: 280);
const Duration kSwipeReturnDuration = Duration(milliseconds: 300);
const Duration kSwipeUndoDuration = Duration(milliseconds: 250);

/// Điều khiển từ ngoài (nút ♥ / ✕ / hoàn tác) để chạy cùng hoạt ảnh với vuốt tay.
class SwipeDeckController {
  _SwipeDeckState? _state;

  /// Đang chạy hoạt ảnh (bay ra, bật về, thẻ quay lại) hoặc đang kéo.
  bool get busy => _state?._busy ?? false;

  /// Thẻ trên cùng bay ra theo hướng thích (`true`) / ít hơn (`false`), xong thì gọi `onDecide`.
  void swipe({required bool like}) => _state?._swipeByButton(like);

  /// Thẻ vừa bị bỏ quay lại từ phía nó đã bay ra (gọi ngay sau khi trả thẻ về đầu danh sách).
  void enterFrom({required bool like}) => _state?._enterFrom(like);
}

class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    required this.cards,
    required this.onDecide,
    required this.controller,
    required this.faceBuilder,
    required this.likeLabel,
    required this.lessLabel,
    super.key,
  });

  /// Thẻ chưa xem, thẻ đầu tiên nằm trên cùng.
  final List<SwipeCardDto> cards;

  /// Gọi sau khi thẻ bay ra xong (hoặc ngay khi giảm chuyển động).
  final void Function(SwipeCardDto card, {required bool like}) onDecide;

  final SwipeDeckController controller;

  /// Mặt thẻ (chỉ nội dung; khung, bo góc, bóng do chồng thẻ vẽ).
  final Widget Function(BuildContext context, SwipeCardDto card) faceBuilder;

  final String likeLabel;
  final String lessLabel;

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

/// Nhận kéo từ khoảng 18 dp (như cuộn dọc) thay vì 36 dp của `PanGestureRecognizer`, để kéo thẻ thắng
/// khi trang đang cuộn được (thẻ nằm trong `ListView`).
class _DeckPan extends PanGestureRecognizer {
  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) =>
      globalDistanceMoved.abs() >
      computeHitSlop(pointerDeviceKind, gestureSettings);
}

class _SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this)
    ..addListener(_tick)
    ..addStatusListener(_status);

  Offset _offset = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  Curve _curve = Curves.easeOutCubic;
  VoidCallback? _onDone;
  bool _dragging = false;
  bool _animating = false;

  double _cardWidth = kSwipeCardMaxWidth;

  bool get _busy => _dragging || _animating;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void didUpdateWidget(SwipeDeck old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller._state = null;
      widget.controller._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _anim.dispose();
    super.dispose();
  }

  // --- Hoạt ảnh ----------------------------------------------------------------

  void _tick() {
    if (!_animating) return;
    setState(
      () => _offset = Offset.lerp(_from, _to, _curve.transform(_anim.value))!,
    );
  }

  void _status(AnimationStatus s) {
    if (s != AnimationStatus.completed || !_animating) return;
    final done = _onDone;
    _animating = false;
    _onDone = null;
    done?.call();
  }

  void _animateTo(
    Offset to,
    Duration duration,
    Curve curve, {
    VoidCallback? onDone,
  }) {
    _from = _offset;
    _to = to;
    _curve = curve;
    _onDone = onDone;
    _animating = true;
    _anim
      ..duration = duration
      ..forward(from: 0);
  }

  double get _screenWidth => MediaQuery.sizeOf(context).width;

  /// Ra khỏi màn hình hoàn toàn theo hướng vuốt.
  Offset _farOffset(bool like, {double dy = 0}) =>
      Offset((like ? 1 : -1) * (_screenWidth + _cardWidth), dy);

  void _flyOut(bool like, {double dy = 0}) {
    if (widget.cards.isEmpty) return;
    final card = widget.cards.first;
    void decide() {
      setState(() => _offset = Offset.zero);
      widget.onDecide(card, like: like);
    }

    if (_reduceMotion) {
      decide();
      return;
    }
    _animateTo(
      _farOffset(like, dy: dy),
      kSwipeFlyDuration,
      Curves.easeOutCubic,
      onDone: decide,
    );
  }

  void _swipeByButton(bool like) {
    if (_busy || widget.cards.isEmpty) return;
    _flyOut(like, dy: -24);
  }

  void _enterFrom(bool like) {
    if (_reduceMotion) return;
    setState(() => _offset = _farOffset(like));
    _animateTo(Offset.zero, kSwipeUndoDuration, Curves.easeOutCubic);
  }

  // --- Cử chỉ ------------------------------------------------------------------

  void _onStart(DragStartDetails d) {
    if (_animating) return;
    _dragging = true;
  }

  void _onUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    setState(() => _offset += d.delta);
  }

  void _onEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;
    final dx = _offset.dx;
    final vx = d.velocity.pixelsPerSecond.dx;
    final threshold = kSwipeDistanceFraction * _cardWidth;
    bool? like;
    if (dx.abs() >= threshold) {
      like = dx > 0;
    } else if (vx.abs() >= kSwipeFlingVelocity) {
      like = vx > 0;
    }
    if (like != null) {
      _flyOut(like, dy: _offset.dy);
    } else {
      _backToCenter();
    }
  }

  void _onCancel() {
    if (!_dragging) return;
    _dragging = false;
    _backToCenter();
  }

  void _backToCenter() {
    if (_reduceMotion) {
      setState(() => _offset = Offset.zero);
      return;
    }
    _animateTo(Offset.zero, kSwipeReturnDuration, Curves.easeOutCubic);
  }

  // --- Vẽ ----------------------------------------------------------------------

  /// 0 → 1 theo độ kéo ngang tới ngưỡng quyết định.
  double get _progress =>
      (_offset.dx.abs() / (kSwipeDistanceFraction * _cardWidth)).clamp(
        0.0,
        1.0,
      );

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    if (cards.isEmpty) return const SizedBox.shrink();
    final reduce = _reduceMotion;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return LayoutBuilder(
      builder: (context, c) {
        final w = math.min(
          c.maxWidth.isFinite ? c.maxWidth : kSwipeCardMaxWidth,
          kSwipeCardMaxWidth,
        );
        _cardWidth = w;
        // Thấp vừa đủ để hàng nút nằm trong màn hình đầu tiên trên điện thoại thường; chữ lớn thì cao thêm.
        final h = math.max(300.0, w * 0.9) * scale;
        final p = reduce ? 0.0 : _progress;
        final angle = reduce
            ? 0.0
            : (_offset.dx / (0.5 * w) * kSwipeMaxTiltDeg).clamp(
                    -kSwipeMaxTiltDeg,
                    kSwipeMaxTiltDeg,
                  ) *
                  math.pi /
                  180;

        Widget back(int depth) {
          final card = cards[depth];
          // depth 1: 0,95 → 1,0 và 8 → 0 dp; depth 2: 0,90 → 0,95 và 16 → 8 dp.
          final s = reduce ? 1.0 : 1.0 - 0.05 * depth + 0.05 * p;
          final dy = 8.0 * depth - 8.0 * p;
          return Positioned.fill(
            key: ValueKey('swipe-back-${card.id}'),
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: Transform.translate(
                  offset: Offset(0, dy),
                  // Neo ở đáy để thẻ sau thu nhỏ mà vẫn lộ ra một dải 8 / 16 dp dưới thẻ trước.
                  child: Transform.scale(
                    scale: s,
                    alignment: Alignment.bottomCenter,
                    child: _CardFrame(
                      width: w,
                      height: h,
                      child: widget.faceBuilder(context, card),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final top = cards.first;
        final like = _offset.dx > 0;
        return SizedBox(
          width: double.infinity,
          child: Padding(
            // chỗ cho hai thẻ phía sau lệch xuống
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: SizedBox(
                width: w,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (cards.length > 2) back(2),
                    if (cards.length > 1) back(1),
                    RawGestureDetector(
                      key: ValueKey('swipe-${top.id}'),
                      behavior: HitTestBehavior.opaque,
                      gestures: {
                        _DeckPan:
                            GestureRecognizerFactoryWithHandlers<_DeckPan>(
                              _DeckPan.new,
                              (r) {
                                r
                                  ..dragStartBehavior = DragStartBehavior.down
                                  ..onStart = _onStart
                                  ..onUpdate = _onUpdate
                                  ..onEnd = _onEnd
                                  ..onCancel = _onCancel;
                              },
                            ),
                      },
                      child: Transform.translate(
                        offset: _offset,
                        child: Transform.rotate(
                          angle: angle,
                          child: Semantics(
                            container: true,
                            customSemanticsActions: {
                              CustomSemanticsAction(
                                label: widget.likeLabel,
                              ): () =>
                                  _swipeByButton(true),
                              CustomSemanticsAction(
                                label: widget.lessLabel,
                              ): () =>
                                  _swipeByButton(false),
                            },
                            child: Stack(
                              children: [
                                _CardFrame(
                                  key: Key('swipe-card-${top.id}'),
                                  width: w,
                                  height: h,
                                  child: widget.faceBuilder(context, top),
                                ),
                                Positioned(
                                  top: AppSpacing.lg,
                                  left: AppSpacing.lg,
                                  child: _DragLabel(
                                    key: const Key('swipe-label-like'),
                                    text: widget.likeLabel,
                                    icon: Icons.favorite,
                                    opacity: like ? p : 0,
                                    background: AppColors.primaryContainer,
                                    foreground: AppColors.onPrimaryContainer,
                                  ),
                                ),
                                Positioned(
                                  top: AppSpacing.lg,
                                  right: AppSpacing.lg,
                                  child: _DragLabel(
                                    key: const Key('swipe-label-less'),
                                    text: widget.lessLabel,
                                    icon: Icons.thumb_down_alt_outlined,
                                    opacity: !like ? p : 0,
                                    background: AppColors.warningContainer,
                                    foreground: AppColors.onWarningContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Khung thẻ: bo góc 20 dp, có bóng, rộng đúng [width].
class _CardFrame extends StatelessWidget {
  const _CardFrame({
    required this.width,
    required this.height,
    required this.child,
    super.key,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Material(
      color: AppColors.surface,
      elevation: 6,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(kSwipeCardRadius),
      clipBehavior: Clip.antiAlias,
      child: child,
    ),
  );
}

/// Nhãn "Thích" / "Ít hơn": độ mờ tăng dần theo độ kéo; có chữ, không chỉ dựa vào màu.
class _DragLabel extends StatelessWidget {
  const _DragLabel({
    required this.text,
    required this.icon,
    required this.opacity,
    required this.background,
    required this.foreground,
    super.key,
  });

  final String text;
  final IconData icon;
  final double opacity;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: foreground, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: AppSpacing.xs),
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
