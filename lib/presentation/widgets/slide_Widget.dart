import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/routes/route_transitions.dart';

/// A Fade+Slide entrance animation from any edge.
/// Wrap any widget in this, drive it with an [AnimationController].
class SlideWidget extends AnimatedWidget {
  /// The child to show
  final Widget child;

  /// The animation controller’s animation
  final Animation<double> animation;

  /// Which edge to slide in from
  final SlidePosition slidePosition;

  const SlideWidget({
    Key? key,
    required this.child,
    required this.animation,
    this.slidePosition = SlidePosition.left,
  }) : super(key: key, listenable: animation);

  CurvedAnimation get _curved =>
      CurvedAnimation(parent: animation, curve: Curves.easeInOut);

  Animation<Offset> get _leftSlide => Tween<Offset>(
    begin: const Offset(-0.5, 0),
    end: Offset.zero,
  ).animate(_curved);

  Animation<Offset> get _rightSlide => Tween<Offset>(
    begin: const Offset(0.5, 0),
    end: Offset.zero,
  ).animate(_curved);

  Animation<Offset> get _topSlide => Tween<Offset>(
    begin: const Offset(0, -0.5),
    end: Offset.zero,
  ).animate(_curved);

  Animation<Offset> get _bottomSlide => Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(_curved);

  Animation<Offset> get _slideAnimation {
    switch (slidePosition) {
      case SlidePosition.left:
        return _leftSlide;
      case SlidePosition.right:
        return _rightSlide;
      case SlidePosition.top:
        return _topSlide;
      case SlidePosition.bottom:
      default:
        return _bottomSlide;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(position: _slideAnimation, child: child),
    );
  }
}
