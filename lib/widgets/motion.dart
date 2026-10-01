import 'package:flutter/widgets.dart';

/// Motion primitives. Static for now; the motion pass fills them in.
class Rise extends StatelessWidget {
  const Rise({super.key, required this.child, this.step = 0});
  final Widget child;
  final int step;

  @override
  Widget build(BuildContext context) => child;
}

class LampFlicker extends StatelessWidget {
  const LampFlicker({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class Drift extends StatelessWidget {
  const Drift({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform.scale(scale: 1.32, child: child);
}

class DrawIn extends StatelessWidget {
  const DrawIn({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class Tilt extends StatelessWidget {
  const Tilt({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child, this.step = 0});
  final Widget child;
  final int step;

  @override
  Widget build(BuildContext context) => child;
}
