// lib/presentation/views/contact/contact_page.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment scheduled!')));
      _formKey.currentState?.reset();
    }
  }

  Widget _socialIcon(IconData icon, String url) {
    return _HoverScale(
      child: IconButton(
        icon: Icon(icon, size: 40, color: AppColors.kblack),
        onPressed: () => launchUrl(Uri.parse(url)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kwhite,
      appBar: const NavbarWidget(),
      body: LayoutBuilder(
        builder: (ctx, bc) {
          final isWide = bc.maxWidth >= 800;

          // 1) build the raw form column
          Widget rawForm = Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  'Get in Touch',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.kblack,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Schedule an Appointment',
                  style: TextStyle(
                    fontSize: 32,
                    color: AppColors.kblack,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _nameCtrl,
                  validator:
                      (v) =>
                          (v?.trim().isEmpty ?? true)
                              ? 'Enter your name'
                              : null,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.kprimary,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.kprimary,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.kprimary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailCtrl,
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Enter your email';
                    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!pattern.hasMatch(v!.trim())) return 'Invalid email';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.kprimary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _msgCtrl,
                  maxLines: 6,
                  validator:
                      (v) =>
                          (v?.trim().isEmpty ?? true)
                              ? 'Enter a message'
                              : null,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.kprimary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(
                      FontAwesomeIcons.telegram,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Schedule Appointment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ktextPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kblack,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          // 2) wrap in Slide+Fade
          Widget animatedForm = FadeTransition(
            opacity: _fade,
            child: SlideTransition(position: _slide, child: rawForm),
          );

          // 3) desktop-only maxWidth
          if (isWide) {
            animatedForm = Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: animatedForm,
              ),
            );
          }

          // 4) choose layout
          if (isWide) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 80),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: animatedForm),
                  const SizedBox(width: 60),
                  // socials
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _socialIcon(
                        FontAwesomeIcons.xTwitter,
                        'https://twitter.com/yourhandle',
                      ),
                      const SizedBox(height: 24),
                      _socialIcon(
                        FontAwesomeIcons.figma,
                        'https://www.figma.com/@yourprofile',
                      ),
                      const SizedBox(height: 24),
                      _socialIcon(
                        FontAwesomeIcons.linkedin,
                        'https://linkedin.com/in/yourprofile',
                      ),
                      const SizedBox(height: 24),
                      _socialIcon(
                        FontAwesomeIcons.github,
                        'https://github.com/yourprofile',
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  animatedForm,
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    children: [
                      _socialIcon(
                        FontAwesomeIcons.xTwitter,
                        'https://twitter.com/yourhandle',
                      ),
                      _socialIcon(
                        FontAwesomeIcons.figma,
                        'https://www.figma.com/@yourprofile',
                      ),
                      _socialIcon(
                        FontAwesomeIcons.linkedin,
                        'https://linkedin.com/in/yourprofile',
                      ),
                      _socialIcon(
                        FontAwesomeIcons.github,
                        'https://github.com/yourprofile',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

/// Wraps its child in a little scale-up on hover (desktop/web).
class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});
  @override
  __HoverScaleState createState() => __HoverScaleState();
}

class __HoverScaleState extends State<_HoverScale> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}
