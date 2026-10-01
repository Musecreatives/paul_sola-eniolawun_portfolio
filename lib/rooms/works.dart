import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/motion.dart';
import '../widgets/pressable.dart';

/// Room II as its own page.
class WorksPage extends StatelessWidget {
  const WorksPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const GalleryPage(title: 'Selected Works', room: Room.works, sections: [Section(child: WorksRoom())]);
}

/// Room II: the featured work and a grid of plates.
class WorksRoom extends StatelessWidget {
  const WorksRoom({super.key});

  @override
  Widget build(BuildContext context) {
    final works = Content.of(context).works;
    final featured = works.where((w) => w.featured).firstOrNull ?? works.firstOrNull;
    final rest = works.where((w) => w != featured).toList();
    return RoomBody(
      rightExtra: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 80,
        children: [
          const RoomHeader(
            eyebrow: 'Room II',
            title: 'Selected Works',
            epigraph: 'Waste no more time arguing what a good man should be. Be one.',
            source: 'Marcus Aurelius · Meditations X.16',
          ),
          if (featured != null) _Featured(featured),
          AutoGrid(
            minWidth: 320,
            gap: 40,
            runGap: 56,
            children: [for (final (i, w) in rest.indexed) Rise(step: i % 3, child: _PlateCard(w))],
          ),
        ],
      ),
    );
  }
}

class _Featured extends StatelessWidget {
  const _Featured(this.w);
  final Work w;

  @override
  Widget build(BuildContext context) {
    final href = '/works/${w.slug}';
    final compact = context.isCompact;
    final frame = Pressable(
      href: href,
      label: 'Plate ${w.numeral}: ${w.title}',
      builder: (_, _, _) => GiltFrame(
        padding: compact ? 12 : 22,
        child: Plate(
          dark: true,
          aspect: 16 / 10,
          padding: EdgeInsets.all(compact ? 18 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Mono('Plate ${w.numeral}', color: const Color(0xFFE2C57F)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(w.title, style: T.display(compact ? 36 : 56, color: const Color(0xFFF3EEE3))),
                  ),
                  if (w.tags.isNotEmpty) Mono(w.tags, color: const Color(0xFFA8B9FF)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final placard = PlacardBox(
      gap: 20,
      padding: EdgeInsets.all(compact ? 22 : 32),
      children: [
        Mono([if (w.inventory.isNotEmpty) 'Inv. ${w.inventory}', 'Featured'].join(' · '), color: Palette.tyrian),
        Text(w.headline.isEmpty ? w.title : w.headline, style: T.display(compact ? 24 : 30, height: 1.1, color: Palette.placardInk)),
        Text(w.summary, style: T.body(16, color: Palette.placardBody)),
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x261C1830)))),
          child: LayoutBuilder(builder: (context, c) {
            final half = (c.maxWidth - 16) / 2;
            return Wrap(spacing: 16, runSpacing: 16, children: [
              for (final (k, v) in [('Medium', w.medium), ('Role', w.role), ('Dated', w.year), ('Platforms', w.platforms)])
                if (v.isNotEmpty) SizedBox(width: half, child: Fact(k, v)),
            ]);
          }),
        ),
        GalleryButton(label: 'View case study', href: href, height: 48, fontSize: 15, trailing: const Glyph(GlyphKind.arrowRight, size: 16)),
      ],
    );
    return TwoUp(
      gap: 56,
      breakpoint: 720,
      left: Rise(step: 3, child: frame),
      right: Rise(step: 4, child: placard),
    );
  }
}

class _PlateCard extends StatelessWidget {
  const _PlateCard(this.w);
  final Work w;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    return Pressable(
      href: '/works/${w.slug}',
      label: 'Plate ${w.numeral}: ${w.title}',
      builder: (context, hover, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 22,
        children: [
          GiltFrame(
            small: true,
            child: Plate(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Mono('Plate ${w.numeral}', color: Palette.tyrian),
                  FitWords(w.title, style: T.display(30, height: 1.05, color: Palette.royal)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Mono('${w.year} · ${w.medium}', color: g.giltLight),
                Text(w.summary, style: T.body(15, height: 1.55, color: g.inkBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
