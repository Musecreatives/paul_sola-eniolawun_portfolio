// Motion, as specified in the design system README (Motion section) and the
// keyframes in docs/redesign/design/assets/gallery.css. When the platform asks
// for reduced motion (MediaQuery.disableAnimations) everything renders at
// rest, fully visible, with no tickers running.
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../theme/tokens.dart';

const _ease = Cubic(.2, .7, .1, 1);

/// 80ms stagger per step (`.d1`…`.d6` in gallery.css).
Duration _delay(int step) => Duration(milliseconds: 80 * step);

/// Runs [controller] forward once, the first time the child scrolls into view.
mixin _OnceInView<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController controller;
  final _key = UniqueKey();
  bool _started = false;

  Duration get duration;
  int get step => 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) controller.value = 1;
  }

  void _seen(VisibilityInfo info) {
    if (_started || info.visibleFraction <= 0 || !mounted) return;
    _started = true;
    Future<void>.delayed(_delay(step), () {
      if (mounted) controller.forward();
    });
  }

  Widget detect(Widget child) => context.reduceMotion ? child : VisibilityDetector(key: _key, onVisibilityChanged: _seen, child: child);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// Frames and text rise in: 28px, 900ms, cubic-bezier(.2,.7,.1,1), staggered.
class Rise extends StatefulWidget {
  const Rise({super.key, required this.child, this.step = 0});
  final Widget child;
  final int step;

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin, _OnceInView {
  @override
  Duration get duration => const Duration(milliseconds: 900);
  @override
  int get step => widget.step;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    final t = CurvedAnimation(parent: controller, curve: _ease);
    return detect(AnimatedBuilder(
      animation: t,
      builder: (context, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(offset: Offset(0, 28 * (1 - t.value)), child: child),
      ),
      child: widget.child,
    ));
  }
}

/// Plain fade, 900ms ease, staggered.
class FadeIn extends StatefulWidget {
  const FadeIn({super.key, required this.child, this.step = 0});
  final Widget child;
  final int step;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin, _OnceInView {
  @override
  Duration get duration => const Duration(milliseconds: 900);
  @override
  int get step => widget.step;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return detect(FadeTransition(opacity: CurvedAnimation(parent: controller, curve: Curves.ease), child: widget.child));
  }
}

/// Gilt rules draw in from the left: 1.2s.
class DrawIn extends StatefulWidget {
  const DrawIn({super.key, required this.child});
  final Widget child;

  @override
  State<DrawIn> createState() => _DrawInState();
}

class _DrawInState extends State<DrawIn> with SingleTickerProviderStateMixin, _OnceInView {
  @override
  Duration get duration => const Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return detect(AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.diagonal3Values(_ease.transform(controller.value), 1, 1),
        child: child,
      ),
      child: widget.child,
    ));
  }
}

/// The picture lamp flickers on once: 1.6s, ease-out, keyframes from
/// `@keyframes lighton` (0 → .75 → .15 → .9 → 1).
class LampFlicker extends StatefulWidget {
  const LampFlicker({super.key, required this.child});
  final Widget child;

  @override
  State<LampFlicker> createState() => _LampFlickerState();
}

class _LampFlickerState extends State<LampFlicker> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  static final _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: .75), weight: 25),
    TweenSequenceItem(tween: Tween(begin: .75, end: .15), weight: 10),
    TweenSequenceItem(tween: Tween(begin: .15, end: .9), weight: 20),
    TweenSequenceItem(tween: Tween(begin: .9, end: 1), weight: 45),
  ]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return FadeTransition(opacity: _opacity.animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)), child: widget.child);
  }
}

/// Paintings drift (slow Ken Burns): 26s loop, scale 1.32 → 1.38 and a small
/// pan, ease-in-out. Only runs while the painting is on screen.
class Drift extends StatefulWidget {
  const Drift({super.key, required this.child});
  final Widget child;

  @override
  State<Drift> createState() => _DriftState();
}

class _DriftState extends State<Drift> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 26));
  final _key = UniqueKey();

  void _seen(VisibilityInfo info) {
    if (!mounted) return;
    if (info.visibleFraction > 0 && !context.reduceMotion) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const rest = 1.32;
    if (context.reduceMotion) return Transform.scale(scale: rest, child: widget.child);
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _seen,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            // 0 → 1 → 0 over the loop, eased like `ease-in-out`.
            final p = Curves.easeInOut.transform(1 - (2 * _c.value - 1).abs());
            return FractionalTranslation(
              translation: Offset(-.015 * p, -.01 * p),
              child: Transform.scale(scale: rest + (.06 * p), child: child),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// The hero painting tilts with the cursor, up to ±4° on each axis, with a
/// 1400px perspective. Returns to flat when the pointer leaves.
class Tilt extends StatefulWidget {
  const Tilt({super.key, required this.child});
  final Widget child;

  @override
  State<Tilt> createState() => _TiltState();
}

class _TiltState extends State<Tilt> {
  Offset _angle = Offset.zero; // degrees: (rotateY, rotateX)

  void _move(PointerHoverEvent e, Size size) {
    if (size.isEmpty) return;
    final x = e.localPosition.dx / size.width - .5;
    final y = e.localPosition.dy / size.height - .5;
    setState(() => _angle = Offset((x * 8).clamp(-4, 4), (-y * 8).clamp(-4, 4)));
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return LayoutBuilder(
      builder: (context, box) => MouseRegion(
        onHover: (e) => _move(e, box.biggest.isFinite ? box.biggest : (context.size ?? Size.zero)),
        onExit: (_) => setState(() => _angle = Offset.zero),
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(end: _angle),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, a, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 1 / 1400)
              ..rotateY(a.dx * math.pi / 180)
              ..rotateX(a.dy * math.pi / 180),
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
