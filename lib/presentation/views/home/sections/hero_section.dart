// lib/presentation/views/sections/hero_section.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/hireMe_Button.dart';
import 'package:muse_creatives_portfolio/presentation/views/project/project_page.dart';

enum Breakpoint { mobile, tablet, desktop }

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl, _crossCtrl;
  late final Animation<Offset> _devOffset, _plusOffset, _designerOffset;
  late final Animation<double> _devOpacity, _plusOpacity, _designerOpacity;

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
    _crossCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _devOffset = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _devOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4)));

    _plusOffset = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _plusOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 0.7)));

    _designerOffset = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    _designerOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.7, 1.0)));

    _roleTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _cycleRole(),
    );
  }

  void _cycleRole() {
    setState(() {
      _roleIndex = (_roleIndex + 1) % _roles.length;
    });
  }

  @override
  void dispose() {
    _crossCtrl.dispose();
    _ctrl.dispose();
    _roleTimer.cancel();
    super.dispose();
  }

  Breakpoint _breakpoint(double w) {
    if (w < 600) return Breakpoint.mobile;
    if (w < 1024) return Breakpoint.tablet;
    return Breakpoint.desktop;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, bc) {
        final w = bc.maxWidth;
        final bp = _breakpoint(w);

        // sizes by breakpoint
        final circleSize = bp == Breakpoint.desktop ? 60.0 : 40.0;
        final fontSizeMain =
            bp == Breakpoint.desktop
                ? 96.0
                : bp == Breakpoint.tablet
                ? 72.0
                : 48.0;
        final roleFontSize =
            bp == Breakpoint.desktop
                ? 96.0
                : bp == Breakpoint.tablet
                ? 60.0
                : 36.0;
        final padding =
            bp == Breakpoint.desktop
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(vertical: 80);

        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Half-and-half background
              Positioned.fill(
                left: 0,
                right: w / 2,
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                left: w / 2,
                right: 0,
                child: Container(color: const Color(0xFFF4F4EF)),
              ),

              // Only show decorations on tablet+desktop
              if (bp != Breakpoint.mobile) ...[
                // simple circles and lines with percentage offsets
                Positioned(
                  top: w * 0.1,
                  left: w * 0.2,
                  child: _buildCircle(circleSize, Colors.white),
                ),
                Positioned(
                  bottom: w * 0.05,
                  right: w * 0.15,
                  child: _buildCircle(circleSize, Colors.black),
                ),
                // rotating cross
                Positioned(
                  bottom: w * 0.05,
                  left: w * 0.1,
                  child: AnimatedBuilder(
                    animation: _crossCtrl,
                    builder:
                        (_, child) => Transform.rotate(
                          angle: _crossCtrl.value * 2 * math.pi,
                          child: child,
                        ),
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: bp == Breakpoint.desktop ? 96 : 64,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // slide-in accent plus
              ],

              // central content
              Center(
                child: Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // “Deve” / “loper”
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
                                  ),
                                ),
                                TextSpan(
                                  text: 'loper',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fontSizeMain,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
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
                              color: const Color(0xFF3DA9FC),
                              fontSize: bp == Breakpoint.desktop ? 100 : 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // rotating role
                      SlideTransition(
                        position: _designerOffset,
                        child: FadeTransition(
                          opacity: _designerOpacity,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              _roles[_roleIndex],
                              key: ValueKey(_roles[_roleIndex]),
                              style: TextStyle(
                                color: const Color(0xFF3DA9FC),
                                fontSize: roleFontSize,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // button
                      PopButton(
                        label: 'See my work',
                        width:
                            bp == Breakpoint.desktop
                                ? 350
                                : bp == Breakpoint.tablet
                                ? 280
                                : 200,
                        height:
                            bp == Breakpoint.desktop
                                ? 80
                                : bp == Breakpoint.tablet
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 2),
    ),
  );
}
