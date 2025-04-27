// lib/presentation/views/contact/contact_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
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

  Widget _buildSocialColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.xTwitter, size: 32),
          onPressed:
              () => launchUrl(Uri.parse('https://twitter.com/yourhandle')),
        ),
        const SizedBox(height: 24),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.figma, size: 28),
          onPressed:
              () => launchUrl(Uri.parse('https://www.figma.com/@yourprofile')),
        ),
        const SizedBox(height: 24),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.linkedin, size: 28),
          onPressed:
              () => launchUrl(Uri.parse('https://linkedin.com/in/yourprofile')),
        ),
        const SizedBox(height: 24),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.github, size: 28),
          onPressed:
              () => launchUrl(Uri.parse('https://github.com/yourprofile')),
        ),
      ],
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
          final form = Form(
            key: _formKey,
            child: SizedBox(
              child: Column(
                crossAxisAlignment:
                    isWide
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
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

                  // Name
                  TextFormField(
                    controller: _nameCtrl,
                    validator:
                        (v) =>
                            (v?.trim().isEmpty ?? true)
                                ? 'Enter your name'
                                : null,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: Colors.transparent,
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
                  const SizedBox(height: 24),

                  // Email
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
                      filled: true,
                      fillColor: Colors.transparent,
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
                  const SizedBox(height: 24),

                  // Message
                  TextFormField(
                    controller: _msgCtrl,
                    validator:
                        (v) =>
                            (v?.trim().isEmpty ?? true)
                                ? 'Enter a message'
                                : null,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.transparent,
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
                  const SizedBox(height: 32),

                  // Submit
                  SizedBox(
                    width: isWide ? 700 : double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
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
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(FontAwesomeIcons.telegram, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          );

          if (isWide) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 80),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // left: form
                  Expanded(flex: 2, child: form),

                  const SizedBox(width: 60),

                  // right: socials
                  _buildSocialColumn(),
                ],
              ),
            );
          }

          // mobile: scrollable form, then social icons bottom
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                form,
                const SizedBox(height: 40),
                _buildSocialColumn(),
              ],
            ),
          );
        },
      ),
    );
  }
}
