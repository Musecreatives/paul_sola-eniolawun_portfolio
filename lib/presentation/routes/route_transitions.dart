import 'package:flutter/material.dart';

// sliding animation
Route createSlideDownRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // from y = -1 (off-screen above) to y = 0
      final tween = Tween(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

Route createSlideUpRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // from y = +1 (off-screen below) to y = 0
      final tween = Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
