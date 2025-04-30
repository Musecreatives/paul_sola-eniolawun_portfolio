// lib/presentation/views/menu/menu_page.dart

import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';
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
    ProjectPage(),
    ExperiencePage(),
    CertificatesPage(),
    AboutPage(),
    ContactPage(),
  ];

  int _hoveredIndex = -1;

  // slide+fade-in for the close button
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

  Widget _buildMenuItem(int i, TextStyle baseStyle) {
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: labels[i], style: baseStyle),
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Transform.translate(
                    offset: const Offset(4, -8),
                    child: Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: baseStyle.copyWith(
                        fontSize: baseStyle.fontSize! * 0.4,
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

  /// ≥1024px: two-panel desktop layout
  Widget _desktopLayout(BoxConstraints bc) {
    final leftWidth = bc.maxWidth / 2.5;
    final baseFontSize = 30.0;

    return Stack(
      children: [
        Row(
          children: [
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
                  ),
                ),
              ),
            ),
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

        // cancel button
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

  /// <1024px: unified tablet & mobile list
  Widget _mobileLayout(BoxConstraints bc) {
    final baseFontSize = 24.0;
    //bg
    return SafeArea(
      child: Column(
        children: [
          // top-right cancel
          Align(
            alignment: Alignment.topRight,
            child: SlideTransition(
              position: _btnSlide,
              child: FadeTransition(
                opacity: _btnFade,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.kblack),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // full screen list of menu items
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: labels.length,
              separatorBuilder:
                  (_, __) => const Divider(
                    color: AppColors.kbackground,
                    height: 1,
                    thickness: 1,
                  ),
              itemBuilder:
                  (_, i) => _buildMenuItem(
                    i,
                    TextStyle(fontSize: baseFontSize, color: AppColors.kblack),
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
          // only desktop (≥1024) uses the split‐pane with preview;
          // all narrower widths use the single‐column list
          if (bc.maxWidth >= 1024) {
            return _desktopLayout(bc);
          } else {
            return _mobileLayout(bc);
          }
        },
      ),
    );
  }
}
