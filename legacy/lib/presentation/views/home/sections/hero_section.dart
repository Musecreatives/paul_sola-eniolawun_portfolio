import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/views/project/project_page.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/hireMe_Button.dart';

enum Breakpoint { mobile, tablet, desktop }

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  static const _paper = Color(0xFFF4F4EF);
  static const _accent = Color(0xFF3695E5);
  static const _warmAccent = Color(0xFFFF6B4A);

  late final AnimationController _introCtrl;
  late final AnimationController _ambientCtrl;
  late final Animation<Offset> _devOffset;
  late final Animation<Offset> _plusOffset;
  late final Animation<Offset> _designerOffset;
  late final Animation<double> _devOpacity;
  late final Animation<double> _plusOpacity;
  late final Animation<double> _designerOpacity;

  final List<String> _roles = [
    'Designer',
    'Prototyper',
    'Computer Scientist',
    'Innovator',
  ];
  int _roleIndex = 0;
  late final Timer _roleTimer;

  @override
  void initState() {
    super.initState();

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _devOffset = Tween<Offset>(
      begin: const Offset(-0.25, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.08, 0.44, curve: Curves.easeOutCubic),
      ),
    );
    _devOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.02, 0.4)),
    );

    _plusOffset = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.36, 0.68, curve: Curves.easeOutBack),
      ),
    );
    _plusOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.36, 0.66)),
    );

    _designerOffset = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.64, 1, curve: Curves.easeOutCubic),
      ),
    );
    _designerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.64, 1)),
    );

    _roleTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _cycleRole(),
    );
  }

  void _cycleRole() {
    if (!mounted) return;
    setState(() {
      _roleIndex = (_roleIndex + 1) % _roles.length;
    });
  }

  @override
  void dispose() {
    _roleTimer.cancel();
    _ambientCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  Breakpoint _breakpoint(double width) {
    if (width < 600) return Breakpoint.mobile;
    if (width < 1024) return Breakpoint.tablet;
    return Breakpoint.desktop;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;
        final viewportHeight = MediaQuery.of(context).size.height;
        final breakpoint = _breakpoint(width);
        final heroHeight =
            breakpoint == Breakpoint.mobile
                ? math.max(680.0, viewportHeight * 0.94)
                : viewportHeight;

        final circleSize = breakpoint == Breakpoint.desktop ? 60.0 : 40.0;
        final fontSizeMain =
            breakpoint == Breakpoint.desktop
                ? 96.0
                : breakpoint == Breakpoint.tablet
                ? 72.0
                : 48.0;
        final roleFontSize =
            breakpoint == Breakpoint.desktop
                ? 96.0
                : breakpoint == Breakpoint.tablet
                ? 60.0
                : 36.0;

        return SizedBox(
          height: heroHeight,
          child: Stack(
            children: [
              Positioned.fill(
                left: 0,
                right: width / 2,
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                left: width / 2,
                right: 0,
                child: Container(color: _paper),
              ),
              _buildAmbientLayer(width, heroHeight, breakpoint, circleSize),
              if (breakpoint != Breakpoint.mobile) ...[
                Positioned(
                  top: width * 0.1,
                  left: width * 0.2,
                  child: _buildCircle(circleSize, Colors.white),
                ),
                Positioned(
                  bottom: width * 0.05,
                  right: width * 0.15,
                  child: _buildCircle(circleSize, Colors.black),
                ),
                Positioned(
                  bottom: width * 0.05,
                  left: width * 0.1,
                  child: AnimatedBuilder(
                    animation: _ambientCtrl,
                    builder:
                        (_, child) => Transform.rotate(
                          angle: _ambientCtrl.value * 2 * math.pi,
                          child: child,
                        ),
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: _warmAccent,
                        fontSize: breakpoint == Breakpoint.desktop ? 96 : 64,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _buildFloatingTag(
                  left: width * 0.08,
                  top: heroHeight * 0.26,
                  label: 'Flutter Web',
                  delay: 0,
                ),
                _buildFloatingTag(
                  right: width * 0.08,
                  bottom: heroHeight * 0.2,
                  label: 'Product UI',
                  delay: 0.5,
                ),
              ],
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: breakpoint == Breakpoint.mobile ? 20 : 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _devOpacity,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.35),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _introCtrl,
                                curve: const Interval(
                                  0,
                                  0.35,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                            child: _buildKicker(breakpoint),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SlideTransition(
                          position: _devOffset,
                          child: FadeTransition(
                            opacity: _devOpacity,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Deve',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSizeMain,
                                      fontWeight: FontWeight.w700,
                                      height: 0.95,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'loper',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: fontSizeMain,
                                      fontWeight: FontWeight.w700,
                                      height: 0.95,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _plusOffset,
                          child: FadeTransition(
                            opacity: _plusOpacity,
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: _accent,
                                fontSize:
                                    breakpoint == Breakpoint.desktop ? 100 : 64,
                                fontWeight: FontWeight.bold,
                                height: 0.82,
                              ),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _designerOffset,
                          child: FadeTransition(
                            opacity: _designerOpacity,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final offset = Tween<Offset>(
                                  begin: const Offset(0, 0.35),
                                  end: Offset.zero,
                                ).animate(animation);
                                final scale = Tween<double>(
                                  begin: 0.96,
                                  end: 1,
                                ).animate(animation);

                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offset,
                                    child: ScaleTransition(
                                      scale: scale,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                _roles[_roleIndex],
                                key: ValueKey(_roles[_roleIndex]),
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: roleFontSize,
                                  fontWeight: FontWeight.w900,
                                  height: 0.98,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: breakpoint == Breakpoint.mobile ? 28 : 34,
                        ),
                        PopButton(
                          label: 'See my work',
                          width:
                              breakpoint == Breakpoint.desktop
                                  ? 350
                                  : breakpoint == Breakpoint.tablet
                                  ? 280
                                  : 200,
                          height:
                              breakpoint == Breakpoint.desktop
                                  ? 80
                                  : breakpoint == Breakpoint.tablet
                                  ? 64
                                  : 48,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProjectPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: breakpoint == Breakpoint.mobile ? 24 : 34,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _introCtrl,
                    curve: const Interval(0.7, 1),
                  ),
                  child: _buildScrollCue(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmbientLayer(
    double width,
    double height,
    Breakpoint breakpoint,
    double circleSize,
  ) {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (_, __) {
        final wave = math.sin(_ambientCtrl.value * 2 * math.pi);
        final counterWave = math.cos(_ambientCtrl.value * 2 * math.pi);

        return Stack(
          children: [
            Positioned(
              top: height * 0.18 + wave * 16,
              right: width * 0.16,
              child: Transform.rotate(
                angle: _ambientCtrl.value * math.pi,
                child: Container(
                  width: breakpoint == Breakpoint.mobile ? 80 : 132,
                  height: 3,
                  color: _warmAccent,
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.18 + counterWave * 12,
              left: width * 0.46,
              child: Opacity(
                opacity: 0.35,
                child: Container(
                  width: circleSize * 2.1,
                  height: circleSize * 2.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _accent, width: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              top: height * 0.42,
              left: width * 0.5 - 1,
              child: Container(width: 2, height: height * 0.18, color: _accent),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingTag({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required String label,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (_, __) {
        final lift = math.sin((_ambientCtrl.value + delay) * 2 * math.pi) * 10;

        return Positioned(
          left: left,
          right: right,
          top: top == null ? null : top + lift,
          bottom: bottom == null ? null : bottom - lift,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKicker(Breakpoint breakpoint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        'Paul Sola-Eniolawun',
        style: TextStyle(
          color: Colors.white,
          fontSize: breakpoint == Breakpoint.desktop ? 16 : 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildScrollCue() {
    return Center(
      child: AnimatedBuilder(
        animation: _ambientCtrl,
        builder: (_, __) {
          final dy = math.sin(_ambientCtrl.value * 2 * math.pi) * 5;

          return Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: 24,
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 4,
                  height: 8,
                  margin: const EdgeInsets.only(top: 9),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
