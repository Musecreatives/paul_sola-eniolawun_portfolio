import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/paintings.dart';
import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/gallery.dart';
import 'kit.dart';

/// The Curator's entrance: imperial wall with a framed painting, form on the right.
class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _status = SendStatus();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _status.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    if (_status.value.busy || !_form.currentState!.validate()) return;
    final pb = Curator.pb;
    if (pb == null) {
      _status.value = const SendState(message: 'The CMS is only reachable from the deployed site.');
      return;
    }
    _status.value = const SendState(busy: true);
    try {
      await pb.collection('curators').authWithPassword(_email.text.trim(), _pass.text);
      _status.value = const SendState();
      if (mounted) context.go('/admin/overview');
    } catch (e) {
      _status.value = SendState(message: e.toString().contains('400') ? 'That email and password don\'t match a curator.' : explain(e));
    }
  }

  Future<void> _forgot() async {
    final pb = Curator.pb;
    final email = _email.text.trim();
    if (validateEmail(email) != null) {
      _status.value = const SendState(message: 'Enter your email above first, then ask for a reset link.');
      return;
    }
    if (pb == null) return;
    try {
      await pb.collection('curators').requestPasswordReset(email);
      _status.value = const SendState(ok: true, message: 'If that address belongs to a curator, a reset link is on its way.');
    } catch (e) {
      _status.value = SendState(message: explain(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.width < 900;
    final art = Container(
      decoration: Walls.imperial,
      child: PictureLight(
        child: Padding(
          padding: EdgeInsets.all(compact ? 24 : 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 24,
            children: [
              Row(spacing: 14, children: [const Seal(size: 48), Mono("Curator's office", color: const Color(0xFFE2C57F))]),
              if (!compact)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      spacing: 20,
                      children: [
                        const Lamp(width: 160),
                        GiltFrame(child: ArtImage(src: Painting.schoolOfAthens.asset, alt: Painting.schoolOfAthens.alt)),
                      ],
                    ),
                  ),
                ),
              Mono('Staff only · the public galleries are at the front door', color: const Color(0xFFA9A3C4)),
            ],
          ),
        ),
      ),
    );
    final form = Container(
      color: Palette.admBg,
      alignment: Alignment.center,
      padding: EdgeInsets.all(compact ? 24 : 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AutofillGroup(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 22,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Semantics(header: true, child: Text("Curator's entrance", style: T.display(36, height: 1.15, color: Adm.ink))),
                    Text('Sign in to manage the Journal, Works, Chronicle, Certificates and Collection.',
                        style: T.body(15, height: 1.5, color: Adm.muted)),
                  ],
                ),
                GalleryField(label: 'Email', controller: _email, keyboard: TextInputType.emailAddress, autofill: const [AutofillHints.username], validator: validateEmail),
                GalleryField(
                  label: 'Password',
                  controller: _pass,
                  obscure: true,
                  autofill: const [AutofillHints.password],
                  validator: needs('your password'),
                  onSubmit: _enter,
                ),
                ValueListenableBuilder(
                  valueListenable: _status,
                  builder: (_, s, _) => GalleryButton(label: s.busy ? 'Opening…' : 'Enter the office', onPressed: s.busy ? null : _enter, expand: true),
                ),
                StatusLine(_status),
                Align(alignment: Alignment.centerLeft, child: AdmLink('Forgot password?', onTap: _forgot, size: 14)),
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Palette.admBg,
      body: compact
          ? SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [art, form]))
          : Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: art), Expanded(child: form)]),
    );
  }
}
