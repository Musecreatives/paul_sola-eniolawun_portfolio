// lib/presentation/widgets/footer_section.dart

import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: '+2348110553809');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final textWhite = const Color(0xFFFFFFFF);
    final textSub = const Color(0xFFCCCCCC);
    final accentBlue = const Color(0xFF3695E5);

    return VisibilityDetector(
      key: const Key('footer-section'),
      onVisibilityChanged: _onVisibilityChanged,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            children: [
              // ── Top Row: Headline & Contact ─────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Headline
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Let’s work together!',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: accentBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'I’m available for freelancing',
                          style: TextStyle(fontSize: 24, color: textWhite),
                        ),
                      ],
                    ),
                  ),

                  // Right: Contact Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '— Contact Info',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: textWhite,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        InkWell(
                          onTap: _launchEmail,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Atlas.mailbox, color: textWhite, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'paulsolaeniolawun@gmail.com',
                                style: TextStyle(color: textSub),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Phone
                        InkWell(
                          onTap: _launchPhone,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Atlas.phone, color: textWhite, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '+234 8110553809',
                                style: TextStyle(color: textSub),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Socials
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.xTwitter,
                                color: textWhite,
                              ),
                              onPressed:
                                  () => _launchUrl(
                                    'https://twitter.com/yourhandle',
                                  ),
                            ),
                            IconButton(
                              icon: Icon(Icons.discord, color: textWhite),
                              onPressed:
                                  () => _launchUrl(
                                    'https://discord.gg/yourserver',
                                  ),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.figma,
                                color: textWhite,
                              ),
                              onPressed:
                                  () => _launchUrl(
                                    'https://www.figma.com/@yourprofile',
                                  ),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.linkedin,
                                color: textWhite,
                              ),
                              onPressed:
                                  () => _launchUrl(
                                    'https://linkedin.com/in/yourprofile',
                                  ),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.github,
                                color: textWhite,
                              ),
                              onPressed:
                                  () => _launchUrl(
                                    'https://github.com/yourprofile',
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Bottom Center: Built-with + Copyright ────────────────
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Built using ', style: TextStyle(color: textWhite)),
                      const FlutterLogo(size: 18),
                      Text(' with much ', style: TextStyle(color: textWhite)),
                      const Icon(Icons.favorite, size: 18, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© $year Paul Sola-Eniolawun',
                    style: TextStyle(color: textSub),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
