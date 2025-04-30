import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/navbar.dart';

import '../../widgets/openlink.dart';
import '../contact/contact_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeText, _fadeImage;
  late Animation<Offset> _slideText, _slideImage;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // text anim: first half of timeline
    _fadeText = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _slideText = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // image anim: second half
    _fadeImage = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );
    _slideImage = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // kick off
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // the text column
  Widget _buildTextColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey, there',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.ktextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Hey, I’m Paul Sola-Eniolawun — a multidisciplinary designer '
          'and developer passionate about building clean, human-centered '
          'digital experiences.\n\n'
          'I work at the intersection of design and code, using tools like '
          'Figma to prototype interfaces and Flutter to bring them to life. '
          'With a strong eye for detail and respect for UX, I craft products '
          'that are both beautiful and functional.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.ktextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Currently, I lead the development team at Moveables, shaping reliable '
          'software for smarter logistics. I co-founded Orderlit to build vendor '
          'tools that automate ordering.\n\n'
          'hether sketching flows, writing Dart, or refining Figma mocks, I '
          'thrive on collaboration, problem-solving, and bringing ideas to life.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.ktextSecondary,
          ),
        ),
        const SizedBox(height: 32),
        InkWell(
          onTap: () {
            //contact me
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ContactPage()),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send, color: AppColors.kprimary),
              const SizedBox(width: 8),
              Text(
                'Send me a message',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.kprimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // the right image + header
  Widget _buildImageColumn(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 40, height: 4, color: AppColors.kprimary),
            const SizedBox(width: 12),
            Text(
              'About me',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.kprimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(
            'assets/images/paul_photo.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: isWide ? 700 : 300,
          ),
        ),
      ],
    );
  }

  // your floating sidebar icons on desktop
  Widget _buildSidebarIcons() {
    return Positioned(
      top: 200,
      left: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(FontAwesomeIcons.figma, color: AppColors.ktextPrimary),
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.linkedin,
              color: AppColors.ktextPrimary,
            ),
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(FontAwesomeIcons.github, color: AppColors.ktextPrimary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kbackground,
      appBar: const NavbarWidget(),
      body: LayoutBuilder(
        builder: (ctx, bc) {
          final w = bc.maxWidth;
          final isDesktop = w >= 1024;
          final isTablet = w >= 600 && w < 1024;

          // on desktop/tablet we use a Stack to layer sidebar + centered row
          if (isDesktop || isTablet) {
            return Stack(
              children: [
                // desktop-only sidebar
                if (isDesktop) _buildSidebarIcons(),

                // center content
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 35),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // left text panel
                            Expanded(
                              flex: isDesktop ? 5 : 7,
                              child: FadeTransition(
                                opacity: _fadeText,
                                child: SlideTransition(
                                  position: _slideText,
                                  child: _buildTextColumn(),
                                ),
                              ),
                            ),

                            const SizedBox(width: 40),

                            // right image panel
                            Expanded(
                              flex: isDesktop ? 5 : 7,
                              child: FadeTransition(
                                opacity: _fadeImage,
                                child: SlideTransition(
                                  position: _slideImage,
                                  child: _buildImageColumn(isDesktop),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // ─── Mobile: single column ───────────────────────────────
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Hey, there',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ktextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ClipOval(
                  child: Image.asset(
                    'assets/images/paul_avatar.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeText,
                  child: SlideTransition(
                    position: _slideText,
                    child: Text(
                      'Hey, I’m Paul Sola-Eniolawun — a multidisciplinary designer '
                      'and developer passionate about building clean, '
                      'human-centered digital experiences.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.ktextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeImage,
                  child: SlideTransition(
                    position: _slideImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/paul_photo.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.figma,
                        color: AppColors.ktextPrimary,
                      ),
                      onPressed:
                          () => openLink(
                            'https://www.figma.com/@paulsolaeniolawun',
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.linkedin,
                        color: AppColors.ktextPrimary,
                      ),
                      onPressed:
                          () => openLink(
                            'https://www.linkedin.com/in/paul-sola-eniolawun',
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.github,
                        color: AppColors.ktextPrimary,
                      ),
                      onPressed:
                          () => openLink('https://github.com/Musecreatives'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
