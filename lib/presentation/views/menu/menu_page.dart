// lib/presentation/views/menu/menu_page.dart

import 'package:flutter/material.dart';
import '../about/about_page.dart';
import '../certificates/certificates_page.dart';
import '../contact/contact_page.dart';
import '../experience/experience_page.dart';
import '../home/homepage.dart';
import '../../routes/route_transitions.dart';
import '../project/project_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
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
    ProjectsPage(),
    ExperiencePage(),
    CertificatesPage(),
    AboutPage(),
    ContactPage(),
  ];

  int _hoveredIndex = -1;

  late final AnimationController _btnCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();
  late final Animation<Offset> _btnSlide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));
  late final Animation<double> _btnFade = CurvedAnimation(
    parent: _btnCtrl,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  void _onItemTap(int i) {
    Navigator.of(context).push(createSlideDownRoute(pages[i]));
  }

  Widget _buildMenuItem(int i, TextStyle baseStyle, bool isMobile) {
    final isHovered = i == _hoveredIndex;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = i),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: () => _onItemTap(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: isHovered ? Colors.white12 : Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 8 : 12,
            horizontal: isMobile ? 16 : 0,
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: labels[i], style: baseStyle),
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Transform.translate(
                    offset: const Offset(2, -8),
                    child: Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: baseStyle.copyWith(
                        fontSize: baseStyle.fontSize! * 0.3,
                        fontWeight: FontWeight.w700,
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
  }

  Widget _desktopTabletLayout(BoxConstraints bc) {
    final isDesktop = bc.maxWidth >= 1024;
    final leftWidth = isDesktop ? bc.maxWidth / 2.5 : bc.maxWidth * 0.4;
    final baseFontSize = isDesktop ? 30.0 : 26.0;

    return Stack(
      children: [
        Row(
          children: [
            // ── LEFT PANEL ─────────────────────────
            Container(
              width: leftWidth,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(
                vertical: 120,
                horizontal: 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  labels.length,
                  (i) => _buildMenuItem(
                    i,
                    TextStyle(fontSize: baseFontSize, color: Colors.white),
                    false,
                  ),
                ),
              ),
            ),

            // ── RIGHT PANEL ─────────────────────────
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                      maxHeight: 600,
                    ),
                    child: Image.asset(
                      images[(_hoveredIndex >= 0) ? _hoveredIndex : 0],
                      key: ValueKey(_hoveredIndex),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── CANCEL BUTTON ─────────────────────────
        SlideTransition(
          position: _btnSlide,
          child: FadeTransition(
            opacity: _btnFade,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout(BoxConstraints bc) {
    final baseFontSize = 24.0;

    return SafeArea(
      child: Column(
        children: [
          // cancel button at top-right
          Align(
            alignment: Alignment.topRight,
            child: SlideTransition(
              position: _btnSlide,
              child: FadeTransition(
                opacity: _btnFade,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // scrollable list of menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: labels.length,
              itemBuilder:
                  (_, i) => _buildMenuItem(
                    i,
                    TextStyle(fontSize: baseFontSize, color: Colors.white),
                    true,
                  ),
            ),
          ),

          // bottom image preview
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            height: bc.maxHeight * 0.35,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                images[(_hoveredIndex >= 0) ? _hoveredIndex : 0],
                key: ValueKey(_hoveredIndex),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, bc) {
          if (bc.maxWidth >= 600) {
            return _desktopTabletLayout(bc);
          } else {
            return _mobileLayout(bc);
          }
        },
      ),
    );
  }
}
