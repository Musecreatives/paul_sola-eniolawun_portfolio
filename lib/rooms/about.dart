import 'package:flutter/material.dart';

import '../data/site.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/motion.dart';

/// Room V: the portrait and a short first-person introduction.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const GalleryPage(title: 'About', room: Room.about, sections: [Section(child: _About())]);
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final compact = context.isCompact;
    final portrait = Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            children: [
              const Lamp(width: 180),
              const SizedBox(height: 22),
              FadeIn(
                child: GiltFrame(
                  padding: compact ? 12 : 20,
                  child: const ArtImage(
                    src: 'assets/img/paul_portrait.webp',
                    alt: 'Portrait of Paul Sola-Eniolawun in a white shirt and tie, arms crossed',
                    aspect: 3 / 4,
                    painting: false,
                    align: Alignment(0, -.76),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: compact ? 0 : -16,
          bottom: 0,
          child: const Rise(
            step: 3,
            child: Placard(
              width: 280,
              label: 'Inv. PSE–0002',
              title: 'Portrait of the Engineer',
              sub: 'Paul Sola-Eniolawun · Photograph',
            ),
          ),
        ),
      ],
    );

    Widget cell(String label, String value) => Container(
          color: g.wall,
          padding: const EdgeInsets.all(18),
          child: Fact(label, value, labelColor: g.giltLight, valueStyle: T.body(15, height: 1.4, color: g.ink)),
        );

    final text = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Rise(child: Mono('Room V · About', color: g.giltLight)),
              Rise(
                step: 1,
                child: Semantics(
                  header: true,
                  child: Text("Hey, I'm Paul.", style: T.display((context.width * .05).clamp(44.0, 64.0), color: g.title)),
                ),
              ),
            ],
          ),
          Rise(
            step: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 18,
              children: [
                for (final p in const [
                  "I'm a full-stack engineer and designer from Nigeria. I lead engineering at Synkkafrica, where my team builds a multi-service marketplace on Next.js, Node.js and Flutter.",
                  'I started in design, sketching interfaces in Figma before building them in Dart, and I still work where the two meet: careful interfaces, clean architecture, and software that holds up. I also co-founded Innovated Digital.',
                  "Whether I'm sketching flows, writing Dart or reviewing an architecture, I enjoy collaborating, solving problems and bringing ideas to life.",
                ])
                  Text(p, style: T.body(18, height: 1.7, color: g.inkBody)),
              ],
            ),
          ),
          Rise(
            step: 3,
            child: Container(
              decoration: BoxDecoration(color: g.tyrianLight.withValues(alpha: .22), border: Border.all(color: g.tyrianLight.withValues(alpha: .22))),
              child: LayoutBuilder(builder: (context, c) {
                final w = (c.maxWidth - 1) / 2;
                return Wrap(spacing: 1, runSpacing: 1, children: [
                  for (final (k, v) in const [
                    ('At the board', 'Chess'),
                    ('On the stand', 'Saxophone'),
                    ('At the desk', 'Reading and writing'),
                    ('At play', 'Gaming and sport'),
                  ])
                    SizedBox(width: w, child: cell(k, v)),
                ]);
              }),
            ),
          ),
          const Rise(
            step: 4,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GalleryButton(
                  label: 'Send a letter',
                  href: '/correspondence',
                  kind: ButtonKind.seal,
                  trailing: Glyph(GlyphKind.envelope, color: Colors.white),
                ),
                GalleryButton(label: 'Download CV', href: Site.cvUrl, external: true, kind: ButtonKind.outline, semanticLabel: 'Download CV (PDF)'),
              ],
            ),
          ),
          Rise(step: 5, child: Socials(color: g.royalLight)),
        ],
      ),
    );

    return RoomBody(
      rightExtra: 40,
      child: TwoUp(gap: 80, breakpoint: 820, align: CrossAxisAlignment.start, left: portrait, right: text),
    );
  }
}
