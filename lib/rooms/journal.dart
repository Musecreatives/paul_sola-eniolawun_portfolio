import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/paintings.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/motion.dart';
import '../widgets/pressable.dart';

const paper = BoxDecoration(color: Color(0xFFFAF7F0));
const journalCategories = ['Engineering', 'Design', 'Leadership', 'Notes'];

/// The cover of a post: an uploaded image or one of the gallery's paintings.
Widget postCover(Post p, {double aspect = 16 / 10}) {
  if (p.cover.isNotEmpty) return ArtImage(src: p.cover, alt: 'Cover for ${p.title}', aspect: aspect, painting: false);
  final art = Painting.byKey(p.coverPainting);
  return ArtImage(src: art.asset, alt: art.alt, aspect: aspect, align: art.align);
}

/// Room VI: the journal index.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String? _filter;

  @override
  Widget build(BuildContext context) => GalleryPage(
        title: 'Journal',
        room: Room.journal,
        day: true,
        sections: [Section(decoration: paper, child: Builder(builder: _room))],
      );

  Widget _room(BuildContext context) {
    final g = context.g;
    final posts = Content.of(context).posts.where((p) => _filter == null || p.category == _filter).toList();
    final featured = posts.firstOrNull;
    final rest = posts.skip(1).toList();
    Widget chip(String label, String? value) {
      final on = _filter == value;
      return Pressable(
        label: 'Show $label entries',
        onTap: () => setState(() => _filter = value),
        builder: (_, hover, _) => Semantics(
          selected: on,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? Palette.royal : (hover ? const Color(0x0F1C1830) : null),
              border: Border.all(color: on ? Palette.royal : const Color(0x4D1C1830)),
            ),
            child: Mono(label, color: on ? Colors.white : g.ink),
          ),
        ),
      );
    }

    return RoomBody(
      rightExtra: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 64,
        children: [
          RoomHeader(
            eyebrow: 'Room VI',
            title: 'Journal',
            rule: false,
            subtitle: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text('Essays and field notes on engineering, design and the examined life.', style: T.body(17, height: 1.6, color: g.inkMuted)),
            ),
            trailing: Semantics(
              label: 'Filter entries',
              container: true,
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                chip('All', null),
                for (final c in journalCategories) chip(c, c),
              ]),
            ),
          ),
          if (featured == null)
            Text('No entries in this category yet.', style: T.body(17, color: g.inkMuted))
          else
            Rise(step: 2, child: _Featured(featured)),
          if (rest.isNotEmpty) Column(children: [for (final (i, p) in rest.indexed) Rise(step: i % 4, child: _Row(p))]),
          const _Subscribe(),
        ],
      ),
    );
  }
}

class _Featured extends StatelessWidget {
  const _Featured(this.p);
  final Post p;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    return Pressable(
      href: '/journal/${p.slug}',
      label: 'Featured essay: ${p.title}',
      builder: (context, hover, _) => TwoUp(
        gap: 48,
        breakpoint: 720,
        left: GiltFrame(shadow: Shadows.frameDay, child: postCover(p)),
        right: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Mono('Featured essay · ${p.date} · ${p.readTime}', color: Palette.tyrian),
            Text(p.title, style: T.display(context.isCompact ? 30 : 40, height: 1.1, color: g.ink)),
            Text(p.excerpt, style: T.body(17, color: g.inkBody)),
            Mono('Read the essay →', size: 13, color: Palette.royal),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.p);
  final Post p;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final compact = context.isCompact;
    return Pressable(
      href: '/journal/${p.slug}',
      label: p.title,
      builder: (context, hover, _) => Container(
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: g.hairline))),
        child: compact
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
                Mono('${p.date} · ${p.category}', color: g.inkMuted),
                Text(p.title, style: T.display(20, weight: FontWeight.w500, height: 1.25, color: g.ink)),
              ])
            : Row(spacing: 24, children: [
                SizedBox(width: 160, child: Mono(p.date, color: g.inkMuted)),
                Expanded(child: Text(p.title, style: T.display(22, weight: FontWeight.w500, height: 1.25, color: g.ink))),
                SizedBox(width: 140, child: Mono(p.category, color: Palette.tyrian)),
                AnimatedSlide(
                  offset: Offset(hover ? .25 : 0, 0),
                  duration: const Duration(milliseconds: 180),
                  child: const Glyph(GlyphKind.arrowRight, size: 20, color: Palette.royal),
                ),
              ]),
      ),
    );
  }
}

/// "By letter": email subscription and the RSS feed.
class _Subscribe extends StatefulWidget {
  const _Subscribe();

  @override
  State<_Subscribe> createState() => _SubscribeState();
}

class _SubscribeState extends State<_Subscribe> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _status = SendStatus();

  @override
  void dispose() {
    _email.dispose();
    _status.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await _status.run(() => Content.store(context).subscribe(_email.text.trim()), done: 'Subscribed. New entries will arrive by letter.');
    if (_status.value.ok) _email.clear();
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return DecoratedBox(
      decoration: Walls.imperial,
      child: PictureLight(
        child: Padding(
          padding: EdgeInsets.all(compact ? 24 : 40),
          child: TwoUp(
            gap: 32,
            breakpoint: 680,
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Mono('By letter', color: Color(0xFFE2C57F)),
                Text('Receive new entries', style: T.display(28, height: 1.2, color: const Color(0xFFF3EEE3))),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('One email per entry. No noise. Or follow the ', style: T.body(15, height: 1.6, color: const Color(0xFFD6D0EA))),
                    const TextLink('RSS feed', href: '/api/journal/rss.xml', external: true, mono: false, size: 15, color: Color(0xFFA8B9FF)),
                    Text('.', style: T.body(15, height: 1.6, color: const Color(0xFFD6D0EA))),
                  ],
                ),
              ],
            ),
            right: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 220, maxWidth: 360),
                        child: GalleryField(
                          label: 'Email address',
                          hideLabel: true,
                          controller: _email,
                          hint: 'you@example.com',
                          keyboard: TextInputType.emailAddress,
                          autofill: const [AutofillHints.email],
                          validator: validateEmail,
                          onSubmit: _submit,
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _status,
                        builder: (_, s, _) => GalleryButton(label: 'Subscribe', busy: s.busy, onPressed: _submit, height: 48),
                      ),
                    ],
                  ),
                  StatusLine(_status, onDark: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
