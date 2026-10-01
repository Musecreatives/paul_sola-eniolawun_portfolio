import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/paintings.dart';
import '../data/site.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/motion.dart';

/// Room III: experience timeline, education, instruments, volunteering.
/// A long-reading room, so it hangs on the day palette.
class ChroniclePage extends StatelessWidget {
  const ChroniclePage({super.key});

  @override
  Widget build(BuildContext context) => const GalleryPage(
        title: 'Chronicle',
        room: Room.chronicle,
        day: true,
        sections: [Section(child: _Chronicle())],
      );
}

class _Chronicle extends StatelessWidget {
  const _Chronicle();

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final roles = Content.of(context).roles;
    return RoomBody(
      rightExtra: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 64,
        children: [
          RoomHeader(
            eyebrow: 'Room III',
            title: 'Chronicle',
            rule: false,
            subtitle: Text('“While we are postponing, life speeds by.” · Seneca', style: T.body(16, italic: true, color: g.inkMuted)),
            trailing: const GalleryButton(
              label: 'Download CV',
              href: Site.cvUrl,
              external: true,
              kind: ButtonKind.ink,
              leading: Glyph(GlyphKind.download, color: Colors.white),
              semanticLabel: 'Download CV (PDF)',
            ),
          ),
          TwoUp(
            gap: 64,
            flex: const (2, 1),
            breakpoint: 900,
            align: CrossAxisAlignment.start,
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final (i, r) in roles.indexed) Rise(step: i % 4, child: _RoleRow(r))],
            ),
            right: const _Aside(),
          ),
        ],
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow(this.r);
  final Role r;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final compact = context.isCompact;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: g.hairline))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: compact ? 16 : 32,
        children: [
          SizedBox(width: compact ? 72 : 120, child: Text(r.year, style: T.display(compact ? 26 : 36, weight: FontWeight.w500, color: Palette.royal))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(r.role, style: T.display(22, height: 1.2, color: g.ink)),
                Mono('${r.org} · ${r.dates}', color: Palette.tyrian),
                if (r.summary.isNotEmpty) Text(r.summary, style: T.body(15, height: 1.6, color: g.inkBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Aside extends StatelessWidget {
  const _Aside();

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    const p = Painting.aureliusFragment;
    final text = T.body(15, height: 1.6, color: g.ink);
    Widget block(String label, Widget child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [Mono(label, color: Palette.tyrian), child],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 40,
      children: [
        DecoratedBox(
          decoration: Walls.salon,
          child: PictureLight(
            center: const Alignment(0, -1),
            radius: .9,
            opacity: .08,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 18,
                children: [
                  GiltFrame(small: true, padding: 0, matte: Palette.nightGround, child: ArtImage(src: p.asset, alt: p.alt, aspect: 4 / 3)),
                  PlacardBox(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    gap: 2,
                    children: [
                      Text(p.title, style: T.display(15, height: 1.3, color: Palette.placardInk)),
                      Text(p.artist, style: T.body(12, height: 1.5, color: Palette.placardMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        block(
          'Education',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'BSc Computer Science\n', style: TextStyle(fontWeight: FontWeight.w600)),
                  const TextSpan(text: 'University of Benin · 2020–2024\n'),
                  TextSpan(text: 'Thesis: BrainPlay, a gamified learning platform', style: TextStyle(color: g.inkMuted)),
                ]),
                style: text,
              ),
              Text.rich(
                const TextSpan(children: [
                  TextSpan(text: 'Diploma\n', style: TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: 'EdoBits ICT Academy · 2019–2020'),
                ]),
                style: text,
              ),
            ],
          ),
        ),
        block(
          'Instruments',
          Text(
            'Flutter · Dart · Next.js · React · TypeScript · Node.js · Express · NestJS · PostgreSQL · MongoDB · Firebase · Python · Docker · GitHub Actions · Figma',
            style: T.body(15, height: 1.8, color: g.inkBody),
          ),
        ),
        block(
          'Volunteering',
          Text(
            'AIESEC, Software Developer (2023) · Democracy Labs, Front-End Developer (2022) · Young Mind Invasion, Lead Graphics Designer (2019)',
            style: T.body(15, height: 1.7, color: g.inkBody),
          ),
        ),
      ],
    );
  }
}
