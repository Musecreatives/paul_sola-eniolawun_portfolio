import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/hireMe_Button.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _devOffset, _plusOffset, _designerOffset;
  late Animation<double> _devOpacity, _plusOpacity, _designerOpacity;
  late final AnimationController _crossCtrl;

  final List<String> _roles = [
    'Designer',
    'Prototyper',
    'Computer Scientist',
    'Innovator',
  ];
  int _roleIndex = 0;
  Timer? _roleTimer;

  @override
  void initState() {
    super.initState();
    // 1) Rotation controller (8s per revolution)
    _crossCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _devOffset = Tween<Offset>(
      begin: const Offset(-1, 0),
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
      begin: const Offset(0, 1),
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
      begin: const Offset(1, 0),
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
    // ← NEW: start the rotating‐role timer
    _roleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _roleIndex = (_roleIndex + 1) % _roles.length;
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _crossCtrl.dispose();
    _roleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          // split backgrounds
          Positioned.fill(
            left: 0,
            right: size.width / 2,
            child: Container(color: Colors.black),
          ),
          Positioned.fill(
            left: size.width / 2,
            right: 0,
            child: Container(color: Color(0xFFF4F4EF)),
          ),

          // decorative shapes
          Positioned(
            top: 140,
            left: 260,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            right: 160,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),
          Positioned(
            top: 160,
            right: 60,
            child: Transform.rotate(
              angle: 45 * 3.1416 / 180,
              child: SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 64,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 64,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 625,
            child: Text(
              'PAUL SOLA-ENIOLAWUN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          //Block lines
          Positioned(
            top: 140,
            left: 600,
            child: Container(
              width: 700,
              height: 50,
              decoration: BoxDecoration(color: Color(0xFFF4F4EF)),
            ),
          ),
          Positioned(
            top: 335,
            left: 700,
            child: Container(
              width: 700,
              height: 70,
              decoration: BoxDecoration(color: Color(0xFFF4F4EF)),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 600,
            child: Container(
              width: 700,
              height: 50,
              decoration: BoxDecoration(color: Color(0xFFF4F4EF)),
            ),
          ),
          // line decoration
          Positioned(
            top: 110,
            right: 540,
            child: Container(
              width: 300,
              height: 5,
              decoration: BoxDecoration(color: Colors.black),
            ),
          ),
          // cross decoration
          Positioned(
            bottom: 40,
            left: 140,
            child: AnimatedBuilder(
              animation: _crossCtrl,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _crossCtrl.value * 2 * math.pi,
                  child: child,
                );
              },
              child: const Text(
                '+',
                style: TextStyle(
                  fontSize: 96,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // plus decoration
          Positioned(
            top: 300,
            left: 600,
            child: SlideTransition(
              position: _plusOffset,
              child: FadeTransition(
                opacity: _plusOpacity,
                child: const Text(
                  '+',
                  style: TextStyle(
                    color: Color(0xFF3DA9FC), // accent
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // main text & button
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _devOffset,
                  child: FadeTransition(
                    opacity: _devOpacity,
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Deve',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 96,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'loper',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 96,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                // new rotating role
                SlideTransition(
                  position: _designerOffset,
                  child: FadeTransition(
                    opacity: _designerOpacity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                      child: Text(
                        _roles[_roleIndex],
                        key: ValueKey(_roles[_roleIndex]),
                        style: const TextStyle(
                          color: Color(0xFF3DA9FC),
                          fontSize: 96,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Hire Me Button
                PopButton(
                  label: 'See my work',
                  width: 350,
                  height: 80,
                  onPressed: () {
                    // Handle button press
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
