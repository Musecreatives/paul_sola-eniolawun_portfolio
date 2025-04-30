// lib/presentation/widgets/footer_section.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:atlas_icons/atlas_icons.dart';

class FooterSection extends StatefulWidget {
  const FooterSection({Key? key}) : super(key: key);

  @override
  _FooterSectionState createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasAnimated && info.visibleFraction > 0.2) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'paulsolaeniolawun@gmail.com');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: '+2348110553809');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    const textWhite = Color(0xFFFFFFFF);
    const textSub = Color(0xFFCCCCCC);
    const accentBlue = Color(0xFF3695E5);

    return VisibilityDetector(
      key: const Key('footer-section'),
      onVisibilityChanged: _onVisibilityChanged,
      child: SlideTransition(
        position: _slideAnim,
        child: LayoutBuilder(
          builder: (ctx, bc) {
            final w = bc.maxWidth;
            final isWide = w >= 800;

            // adaptive padding & spacing
            final horizPad = isWide ? 80.0 : 24.0;
            final vertPad = isWide ? 40.0 : 24.0;
            final sectionGap = isWide ? 0.0 : 24.0;

            // Left: headline & availability
            Widget left = Column(
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  'Let’s work together!',
                  style: TextStyle(
                    fontSize: isWide ? 34 : 28,
                    fontWeight: FontWeight.bold,
                    color: accentBlue,
                  ),
                  textAlign: isWide ? TextAlign.left : TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'I’m available for freelancing',
                  style: TextStyle(
                    fontSize: isWide ? 24 : 18,
                    color: textWhite,
                  ),
                  textAlign: isWide ? TextAlign.left : TextAlign.center,
                ),
              ],
            );

            // Right: contact info
            Widget right = Column(
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.end : CrossAxisAlignment.center,
              children: [
                Text(
                  '— Contact Info',
                  style: TextStyle(
                    fontSize: isWide ? 20 : 18,
                    fontWeight: FontWeight.w500,
                    color: textWhite,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _launchEmail,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Atlas.mailbox, color: textWhite, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'paulsolaeniolawun@gmail.com',
                        style: TextStyle(
                          color: textSub,
                          fontSize: isWide ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _launchPhone,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Atlas.phone, color: textWhite, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+234 8110553809',
                        style: TextStyle(
                          color: textSub,
                          fontSize: isWide ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      isWide ? MainAxisAlignment.end : MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.xTwitter,
                        color: textWhite,
                        size: isWide ? 24 : 20,
                      ),
                      onPressed:
                          () =>
                              _launchUrl('https://twitter.com/PaulPauLosTic '),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.discord,
                        color: textWhite,
                        size: isWide ? 24 : 20,
                      ),
                      onPressed:
                          () => _launchUrl('https://discord.gg/paulostic_dev'),
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.figma,
                        color: textWhite,
                        size: isWide ? 24 : 20,
                      ),
                      onPressed:
                          () => _launchUrl('https://www.figma.com/@paulostic1'),
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.linkedin,
                        color: textWhite,
                        size: isWide ? 24 : 20,
                      ),
                      onPressed:
                          () => _launchUrl(
                            'https://linkedin.com/in/oluwatisehunla-sola-eniolawun-1670501b1',
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.github,
                        color: textWhite,
                        size: isWide ? 24 : 20,
                      ),
                      onPressed:
                          () => _launchUrl('https://github.com/musecreatives'),
                    ),
                  ],
                ),
              ],
            );

            return Container(
              width: double.infinity,
              color: Colors.black,
              padding: EdgeInsets.symmetric(
                vertical: vertPad,
                horizontal: horizPad,
              ),
              child: Column(
                children: [
                  // Top row or column
                  isWide
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          Expanded(child: right),
                        ],
                      )
                      : Column(
                        children: [left, SizedBox(height: sectionGap), right],
                      ),

                  const SizedBox(height: 40),

                  // Bottom built-with & copyright
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Built using ',
                            style: TextStyle(
                              color: textWhite,
                              fontSize: isWide ? 16 : 14,
                            ),
                          ),
                          const FlutterLogo(size: 18),
                          Text(
                            ' with much ',
                            style: TextStyle(
                              color: textWhite,
                              fontSize: isWide ? 16 : 14,
                            ),
                          ),
                          const Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '© $year Paul Sola-Eniolawun',
                        style: TextStyle(
                          color: textSub,
                          fontSize: isWide ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
