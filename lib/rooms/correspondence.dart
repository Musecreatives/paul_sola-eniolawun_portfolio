import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/site.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/gallery.dart';
import '../widgets/motion.dart';

const purposes = ['Commission a project', 'Collaboration', 'Speaking or interview', 'Just saying hello'];

/// Room VIII: a contact form that really sends, and the visitor book.
class CorrespondencePage extends StatelessWidget {
  const CorrespondencePage({super.key});

  @override
  Widget build(BuildContext context) => const GalleryPage(
        title: 'Correspondence',
        room: Room.correspondence,
        sections: [Section(child: _Correspondence())],
      );
}

class _Correspondence extends StatelessWidget {
  const _Correspondence();

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 28,
      children: [
        RoomHeader(
          eyebrow: 'Room VIII',
          title: 'Correspondence',
          rule: false,
          subtitle: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              'Commissions, collaborations, speaking or a simple hello. Letters are read by me, not a bot.',
              style: T.body(18, color: g.inkBody),
            ),
          ),
        ),
        Rise(
          step: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              TextLink(Site.email, href: 'mailto:${Site.email}', mono: false, size: 16, color: g.royalLight),
              // TODO(paul): confirm your usual reply time.
              Text('Usually replies within [2 working days]', style: T.body(16, height: 1.5, color: g.inkMuted)),
            ],
          ),
        ),
        Rise(step: 4, child: Socials(color: g.tyrianLight)),
      ],
    );
    return RoomBody(
      rightExtra: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 80,
        children: [
          TwoUp(gap: 64, breakpoint: 840, align: CrossAxisAlignment.start, left: intro, right: const Rise(step: 2, child: _LetterForm())),
          const _VisitorBook(),
        ],
      ),
    );
  }
}

class _LetterForm extends StatefulWidget {
  const _LetterForm();

  @override
  State<_LetterForm> createState() => _LetterFormState();
}

class _LetterFormState extends State<_LetterForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  final _trap = TextEditingController();
  final _status = SendStatus();
  String _purpose = purposes.first;

  @override
  void dispose() {
    for (final c in [_name, _email, _message, _trap]) {
      c.dispose();
    }
    _status.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_status.value.busy || !_form.currentState!.validate()) return;
    await _status.run(
      () => Content.store(context).sendLetter(
        name: _name.text.trim(),
        email: _email.text.trim(),
        purpose: _purpose,
        message: _message.text.trim(),
        website: _trap.text,
      ),
      done: 'Sealed and sent. I read every letter myself and will reply to ${_email.text.trim()}.',
      fallback: "The letter couldn't be sent just now. Please email ${Site.email} directly; nothing was lost, your text is still here.",
    );
    if (_status.value.ok) {
      _name.clear();
      _email.clear();
      _message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 40),
      decoration: const BoxDecoration(color: Palette.placard, boxShadow: Shadows.letter),
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              Semantics(header: true, child: Text('Write to the curator', style: T.display(26, height: 1.2, color: Palette.royal))),
              LayoutBuilder(builder: (context, c) {
                final half = c.maxWidth < 420 ? c.maxWidth : (c.maxWidth - 16) / 2;
                return Wrap(spacing: 16, runSpacing: 16, children: [
                  SizedBox(
                    width: half,
                    child: GalleryField(label: 'Name', controller: _name, autofill: const [AutofillHints.name], validator: needs('your name')),
                  ),
                  SizedBox(
                    width: half,
                    child: GalleryField(
                      label: 'Email',
                      controller: _email,
                      keyboard: TextInputType.emailAddress,
                      autofill: const [AutofillHints.email],
                      validator: validateEmail,
                    ),
                  ),
                ]);
              }),
              GallerySelect(label: 'Purpose', value: _purpose, options: purposes, onChanged: (v) => setState(() => _purpose = v)),
              GalleryField(label: 'Letter', controller: _message, lines: 6, maxLength: 5000, validator: needs('a few words')),
              Honeypot(_trap),
              StatusLine(_status),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text('Protected from spam; your address is only used to reply.', style: T.body(13, height: 1.5, color: Palette.placardMuted)),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _status,
                    builder: (_, s, _) => GalleryButton(
                      label: 'Seal & send',
                      kind: ButtonKind.seal,
                      busy: s.busy,
                      onPressed: _send,
                      leading: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Palette.sealRed,
                          border: Border.all(color: const Color(0xFFE2C57F)),
                        ),
                      ),
                    ),
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

class _VisitorBook extends StatefulWidget {
  const _VisitorBook();

  @override
  State<_VisitorBook> createState() => _VisitorBookState();
}

class _VisitorBookState extends State<_VisitorBook> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _note = TextEditingController();
  final _status = SendStatus();

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    _status.dispose();
    super.dispose();
  }

  Future<void> _sign() async {
    if (_status.value.busy || !_form.currentState!.validate()) return;
    await _status.run(
      () => Content.store(context).signBook(name: _name.text.trim(), city: '', note: _note.text.trim()),
      done: 'Thank you. Your note will appear once it is approved.',
      fallback: "The book couldn't be signed just now. Please try again later.",
    );
    if (_status.value.ok) {
      _name.clear();
      _note.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final notes = Content.of(context).notes;
    final form = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(border: Border.all(color: g.tyrianLight.withValues(alpha: .3))),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            GalleryField(label: 'Your name', controller: _name, labelColor: g.tyrianLight, validator: needs('your name')),
            GalleryField(
              label: 'Note · 140 characters',
              controller: _note,
              lines: 3,
              maxLength: 140,
              labelColor: g.tyrianLight,
              validator: needs('a note'),
            ),
            StatusLine(_status, onDark: !g.isDay),
            ValueListenableBuilder(
              valueListenable: _status,
              builder: (_, s, _) => GalleryButton(label: 'Sign the book', busy: s.busy, onPressed: _sign),
            ),
          ],
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.only(top: 56),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: g.hairline))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 24,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Mono('The visitor book', color: g.giltLight),
                  Text('Leave a note on your way out', style: T.display(context.isCompact ? 28 : 36, weight: FontWeight.w500, height: 1.15, color: g.ink)),
                ],
              ),
              Text('Notes appear once approved.', style: T.body(14, height: 1.5, color: g.inkMuted)),
            ],
          ),
          TwoUp(
            gap: 40,
            flex: const (1, 2),
            breakpoint: 840,
            align: CrossAxisAlignment.start,
            left: form,
            right: AutoGrid(
              minWidth: 240,
              gap: 20,
              maxColumns: 2,
              children: [for (final (i, n) in notes.indexed) Rise(step: i % 2, child: _Note(n))],
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.n);
  final VisitorNote n;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final d = n.created;
    final date = d == null ? '[Date]' : '${d.day}/${d.month}/${d.year}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: g.ink.withValues(alpha: .05),
        border: Border.all(color: g.tyrianLight.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(n.note, style: T.body(16, height: 1.6, italic: true, color: g.isDay ? g.inkBody : const Color(0xFFE4D6F2))),
          Mono([n.name, if (n.city.isNotEmpty) n.city, date].join(' · '), color: g.giltLight),
        ],
      ),
    );
  }
}
