import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';

import '../../routes/route_transitions.dart';
import '../about/about_page.dart';
import '../certificates/certificates_page.dart';
import '../contact/contact_page.dart';
import '../experience/experience_page.dart';
import '../home/homepage.dart';
import '../project/project_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  final labels = [
    'Home',
    'My Projects',
    'My Experience',
    'Certificates',
    'About',
    'Contact Me',
  ];
  final images = [
    'assets/images/menu_image_1.png',
    'assets/images/menu_image2.png',
    'assets/images/menu_image3.png',
    'assets/images/menu_image4.png',
    'assets/images/menu_image5.png',
    'assets/images/menu_image6.png',
  ];
  final pages = const [
    HomePage(),
    ProjectPage(),
    ExperiencePage(),
    CertificatesPage(),
    AboutPage(),
    ContactPage(),
  ];

  int _hoveredIndex = 0;

  late final AnimationController _btnCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();
  late final AnimationController _menuCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<Offset> _btnSlide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOutCubic));
  late final Animation<double> _btnFade = CurvedAnimation(
    parent: _btnCtrl,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _btnCtrl.dispose();
    _menuCtrl.dispose();
    super.dispose();
  }

  void _onItemTap(int index) {
    Navigator.of(context).push(createSlideDownRoute(pages[index]));
  }

  Widget _buildMenuItem({
    required int index,
    required TextStyle baseStyle,
    required bool darkMode,
  }) {
    final isHovered = index == _hoveredIndex;
    final foreground =
        darkMode
            ? (isHovered ? AppColors.kprimaryLight : Colors.white)
            : (isHovered ? AppColors.kprimaryDark : AppColors.kblack);
    final start = (index * 0.08).clamp(0.0, 0.58).toDouble();
    final reveal = CurvedAnimation(
      parent: _menuCtrl,
      curve: Interval(start, start + 0.42, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) {
        return Opacity(
          opacity: reveal.value,
          child: Transform.translate(
            offset: Offset(-26 * (1 - reveal.value), 0),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredIndex = index),
        child: GestureDetector(
          onTap: () => _onItemTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  isHovered
                      ? (darkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white)
                      : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isHovered ? AppColors.kprimary : Colors.transparent,
                  width: 4,
                ),
              ),
              boxShadow: [
                if (!darkMode && isHovered)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Row(
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.58),
                    fontSize: (baseStyle.fontSize ?? 30) * 0.42,
                    fontWeight: FontWeight.w800,
                  ),
                  child: Text((index + 1).toString().padLeft(2, '0')),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: baseStyle.copyWith(
                      color: foreground,
                      fontWeight: isHovered ? FontWeight.w800 : FontWeight.w700,
                    ),
                    child: Text(labels[index]),
                  ),
                ),
                AnimatedSlide(
                  offset: Offset(isHovered ? 0 : -0.35, 0),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: isHovered ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.arrow_forward,
                      color: foreground,
                      size: (baseStyle.fontSize ?? 30) * 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktopLayout(BoxConstraints constraints) {
    final leftWidth = constraints.maxWidth / 2.45;
    const baseFontSize = 30.0;

    return Stack(
      children: [
        Row(
          children: [
            Container(
              width: leftWidth,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(
                vertical: 112,
                horizontal: 72,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _btnFade,
                    child: const Text(
                      'Navigate',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    labels.length,
                    (index) => _buildMenuItem(
                      index: index,
                      baseStyle: const TextStyle(
                        fontSize: baseFontSize,
                        color: Colors.white,
                      ),
                      darkMode: true,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF4F4EF),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 520,
                        height: 520,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.kprimary.withValues(alpha: 0.22),
                            width: 2,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 420),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.94,
                                end: 1,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          key: ValueKey(_hoveredIndex),
                          constraints: const BoxConstraints(
                            maxWidth: 600,
                            maxHeight: 600,
                          ),
                          child: Image.asset(
                            images[_hoveredIndex],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        _closeButton(isDark: true),
      ],
    );
  }

  Widget _mobileLayout(BoxConstraints constraints) {
    const baseFontSize = 24.0;

    return Container(
      color: const Color(0xFFF4F4EF),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _closeButton(isDark: false, inline: true),
              ),
            ),
            SizedBox(
              height: 170,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: Image.asset(
                  images[_hoveredIndex],
                  key: ValueKey('mobile-$_hoveredIndex'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: List.generate(
                  labels.length,
                  (index) => _buildMenuItem(
                    index: index,
                    baseStyle: const TextStyle(
                      fontSize: baseFontSize,
                      color: AppColors.kblack,
                    ),
                    darkMode: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _closeButton({required bool isDark, bool inline = false}) {
    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:
                isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.close,
            color: isDark ? Colors.white : AppColors.kblack,
            size: 28,
          ),
        ),
      ),
    );

    final animatedButton = SlideTransition(
      position: _btnSlide,
      child: FadeTransition(opacity: _btnFade, child: button),
    );

    if (inline) return animatedButton;

    return SafeArea(
      child: Padding(padding: const EdgeInsets.all(16), child: animatedButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1024) {
            return _desktopLayout(constraints);
          }
          return _mobileLayout(constraints);
        },
      ),
    );
  }
}
