import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/paintings.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/markdown.dart';
import '../widgets/motion.dart';
import '../widgets/pressable.dart';
import 'journal.dart';
import 'not_found.dart';

/// /journal/:slug: a single entry in reading typography.
class JournalPostPage extends StatefulWidget {
  const JournalPostPage({super.key, required this.slug});
  final String slug;

  @override
  State<JournalPostPage> createState() => _JournalPostPageState();
}

class _JournalPostPageState extends State<JournalPostPage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = Content.of(context).posts;
    final p = posts.where((p) => p.slug == widget.slug).firstOrNull;
    if (p == null) return const NotFoundRoom();
    final i = posts.indexOf(p);
    return GalleryPage(
      title: p.title,
      room: Room.journal,
      day: true,
      scrollController: _scroll,
      overlay: _Progress(_scroll),
      sections: [
        Section(
          decoration: paper,
          child: Builder(
            builder: (context) => _Post(
              p,
              prev: i + 1 < posts.length ? posts[i + 1] : null,
              next: i > 0 ? posts[i - 1] : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reading progress along the top edge.
class _Progress extends StatelessWidget {
  const _Progress(this.scroll);
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: AnimatedBuilder(
          animation: scroll,
          builder: (_, _) {
            var t = 0.0;
            if (scroll.hasClients && scroll.position.hasContentDimensions && scroll.position.maxScrollExtent > 0) {
              t = (scroll.offset / scroll.position.maxScrollExtent).clamp(0, 1);
            }
            return Container(
              height: 3,
              color: const Color(0x141C1830),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: t,
                child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Palette.royalAction, Palette.progressEnd]))),
              ),
            );
          },
        ),
      );
}

class _Post extends StatelessWidget {
  const _Post(this.p, {this.prev, this.next});
  final Post p;
  final Post? prev;
  final Post? next;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final width = context.width;
    final pieces = renderMarkdown(context, p.body);
    final headings = pieces.where((x) => x.anchor != null).toList();
    final art = p.cover.isEmpty ? Painting.byKey(p.coverPainting) : null;

    Widget marginNote(String text) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            const Mono('Marginalia', color: Palette.tyrian),
            Text(text, style: T.body(14, height: 1.6, italic: true, color: g.inkMuted)),
          ],
        );

    // Mockup grid: 200px contents | up to 680px article | 200px margin, 40px gaps.
    Widget article(double articleWidth, {required bool threeCol}) => SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 22,
            children: [
              for (final piece in pieces)
                if (threeCol)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 40,
                    children: [
                      SizedBox(width: articleWidth, child: piece.widget),
                      SizedBox(width: 200, child: piece.margin == null ? null : marginNote(piece.margin!)),
                    ],
                  )
                else ...[
                  piece.widget,
                  if (piece.margin != null) _inlineMargin(context, piece.margin!),
                ],
            ],
          ),
        );

    final toc = headings.isEmpty
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              const Mono('Contents', color: Palette.tyrian),
              for (final (i, h) in headings.indexed)
                TextLink(
                  h.anchor!,
                  mono: false,
                  size: 14,
                  color: i == 0 ? g.ink : g.inkMuted,
                  onTap: () {
                    final ctx = h.key?.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(ctx, duration: context.reduceMotion ? Duration.zero : const Duration(milliseconds: 500), alignment: .1);
                    }
                  },
                ),
            ],
          );

    return RoomBody(
      top: 64,
      maxWidth: 1100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 56,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                spacing: 18,
                children: [
                  const TextLink('← Room VI · Journal', href: '/journal', color: Palette.royal),
                  Rise(
                    child: Mono([p.category, p.date, p.readTime, if (p.sample) '[Sample post]'].join(' · '),
                        color: Palette.tyrian, align: TextAlign.center),
                  ),
                  Rise(
                    step: 1,
                    child: Semantics(
                      header: true,
                      child: Text(p.title,
                          textAlign: TextAlign.center, style: T.display((width * .05).clamp(32.0, 60.0), height: 1.08, color: g.ink)),
                    ),
                  ),
                  const Center(child: GiltRule(width: 80)),
                ],
              ),
            ),
          ),
          FadeIn(
            step: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                GiltFrame(shadow: Shadows.frameDay, padding: context.isCompact ? 10 : 18, child: postCover(p, aspect: context.isCompact ? 16 / 10 : 21 / 9)),
                if (art != null) Mono('${art.title} · ${art.artist.split(' · ').first}', color: g.inkMuted, align: TextAlign.right),
              ],
            ),
          ),
          LayoutBuilder(builder: (context, c) {
            final articleWidth = (c.maxWidth - 480).clamp(0.0, 680.0);
            if (articleWidth >= 520) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 40,
                children: [SizedBox(width: 200, child: toc), SizedBox(width: articleWidth + 240, child: article(articleWidth, threeCol: true))],
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 40, children: [?toc, article(680, threeCol: false)]),
              ),
            );
          }),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                spacing: 24,
                children: [
                  _Author(p),
                  if (context.isCompact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        if (prev != null) _Neighbour(prev!, previous: true),
                        if (next != null) _Neighbour(next!, previous: false),
                      ],
                    )
                  else
                    Row(
                      spacing: 24,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: prev == null ? const SizedBox() : _Neighbour(prev!, previous: true)),
                        Expanded(child: next == null ? const SizedBox() : _Neighbour(next!, previous: false)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineMargin(BuildContext context, String text) => Container(
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: Palette.gilt.withValues(alpha: .6)))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            const Mono('Marginalia', color: Palette.tyrian),
            Text(text, style: T.body(14, height: 1.6, italic: true, color: context.g.inkMuted)),
          ],
        ),
      );
}

class _Author extends StatelessWidget {
  const _Author(this.p);
  final Post p;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: g.hairline))),
      child: Row(
        spacing: 20,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Palette.gilt, width: 2)),
            child: ClipOval(child: Image.asset('assets/img/paul_avatar.webp', fit: BoxFit.cover, semanticLabel: 'Paul Sola-Eniolawun')),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text('Paul Sola-Eniolawun', style: T.display(17, height: 1.3, color: g.ink)),
                Text('VP of Engineering, Synkkafrica. Writes about engineering, design and Stoicism.',
                    style: T.body(14, height: 1.5, color: g.inkMuted)),
              ],
            ),
          ),
          GalleryButton(
            label: 'Share',
            kind: ButtonKind.ink,
            height: 44,
            fontSize: 14,
            padding: 18,
            semanticLabel: 'Copy a link to this entry',
            onPressed: () => copyToClipboard(context, '${Uri.base.origin}/journal/${p.slug}', 'Link copied.'),
          ),
        ],
      ),
    );
  }
}

class _Neighbour extends StatelessWidget {
  const _Neighbour(this.p, {required this.previous});
  final Post p;
  final bool previous;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    return Pressable(
      href: '/journal/${p.slug}',
      label: '${previous ? 'Previous' : 'Next'} entry: ${p.title}',
      builder: (_, hover, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: hover ? const Color(0x081C1830) : null,
          border: Border.all(color: g.hairline),
        ),
        child: Column(
          crossAxisAlignment: previous ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          spacing: 6,
          children: [
            Mono(previous ? '← Previous' : 'Next →', color: Palette.tyrian),
            Text(p.title, textAlign: previous ? TextAlign.left : TextAlign.right, style: T.display(18, height: 1.3, color: g.ink)),
          ],
        ),
      ),
    );
  }
}
