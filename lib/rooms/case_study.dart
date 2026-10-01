import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/markdown.dart';
import '../widgets/motion.dart';
import '../widgets/pressable.dart';
import 'not_found.dart';

/// /works/:slug, the case-study template.
class CaseStudyPage extends StatelessWidget {
  const CaseStudyPage({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context) {
    final data = Content.of(context);
    final w = data.work(slug);
    if (w == null) return const NotFoundRoom();
    final i = data.works.indexOf(w);
    final next = data.works[(i + 1) % data.works.length];
    return GalleryPage(
      title: w.title,
      room: Room.works,
      sections: [
        Section(child: RoomBody(top: 72, maxWidth: 1180, rightExtra: 40, child: _CaseStudy(w, next))),
      ],
    );
  }
}

class _CaseStudy extends StatelessWidget {
  const _CaseStudy(this.w, this.next);
  final Work w;
  final Work next;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final compact = context.isCompact;
    final x = w.extra;
    final arch = x['architecture'] is Map ? (x['architecture'] as Map).cast<String, dynamic>() : null;
    final metrics = (x['metrics'] as List? ?? const []).whereType<Map>().toList();
    final gallery = w.images.length > 1 ? w.images.skip(1).toList() : (x['gallery'] as List? ?? const []).map((e) => '$e').toList();
    final live = w.links.where((l) => l.label.toLowerCase().contains('live')).firstOrNull;
    // TODO(paul): write the case study for each work in the CMS (brief, what you did, screenshots, metrics).
    final body = w.body.isNotEmpty
        ? w.body
        : '## The brief\n\n${w.summary}\n\n## What I did\n\n[Case study to write in the CMS.]';
    final facts = [
      ('Role', w.role.isEmpty ? '[Role]' : w.role),
      ('Dated', w.dated.isNotEmpty ? w.dated : w.year),
      ('Medium', w.medium.replaceAll(', ', ' · ')),
      ('Team', w.team.isEmpty ? '[Team size]' : w.team),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: compact ? 48 : 72,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            TextLink('← Room II · Selected Works', href: '/works', color: g.royalLight),
            Rise(child: Mono(['Plate ${w.numeral}', if (w.inventory.isNotEmpty) 'Inv. ${w.inventory}'].join(' · '), color: g.giltLight)),
            Rise(
              step: 1,
              child: Semantics(
                header: true,
                child: Text(w.title, style: T.display((context.width * .07).clamp(44.0, 96.0), height: .95, color: g.ink)),
              ),
            ),
            Rise(
              step: 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(w.lede.isNotEmpty ? w.lede : w.summary, style: T.body(compact ? 18 : 20, height: 1.6, color: g.inkBody)),
              ),
            ),
          ],
        ),
        Rise(
          step: 3,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: g.hairline)),
            child: LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth < 640 ? 2 : 4;
              Widget cell((String, String) f) => Container(
                    color: g.wall,
                    padding: const EdgeInsets.all(20),
                    child: Fact(f.$1, f.$2, labelColor: g.giltLight, valueStyle: T.body(16, height: 1.4, color: g.ink)),
                  );
              // Rows of equal-height cells with 1px hairlines between them.
              return Container(
                color: g.hairline,
                child: Column(spacing: 1, children: [
                  for (var r = 0; r < facts.length; r += cols)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 1,
                        children: [for (final f in facts.skip(r).take(cols)) Expanded(child: cell(f))],
                      ),
                    ),
                ]),
              );
            }),
          ),
        ),
        FadeIn(
          step: 4,
          child: GiltFrame(
            padding: compact ? 12 : 24,
            child: w.images.isNotEmpty
                ? ArtImage(src: w.images.first, alt: '${w.title} screenshot', aspect: 16 / 8, painting: false)
                : Plate(
                    dark: true,
                    aspect: 16 / 8,
                    child: Center(child: Mono(x['hero']?.toString() ?? '[Hero screenshot]', color: const Color(0xFFA8B9FF), align: TextAlign.center)),
                  ),
          ),
        ),
        TwoUp(
          gap: 56,
          flex: const (2, 1),
          breakpoint: 860,
          align: CrossAxisAlignment.start,
          left: MarkdownColumn(body, mode: MdMode.caseStudy, gap: 14),
          right: PlacardBox(
            gap: 14,
            padding: const EdgeInsets.all(24),
            children: [
              const Mono('Wall label', color: Palette.tyrian),
              Text(
                x['wall_label']?.toString() ?? [w.medium, if (w.role.isNotEmpty) w.role, w.year].join(' · '),
                style: T.body(14, height: 1.6, color: Palette.placardBody),
              ),
              if (live != null)
                live.url.isEmpty
                    // TODO(paul): add the live site URL for this work in the CMS.
                    ? const Mono('Visit live site ↗ [URL]', color: Palette.placardMuted)
                    : TextLink('Visit live site ↗', href: live.url, external: true, color: Palette.royal),
            ],
          ),
        ),
        if (arch != null) _Architecture(arch),
        if (metrics.isNotEmpty)
          AutoGrid(
            minWidth: 220,
            gap: 24,
            maxColumns: 3,
            children: [
              for (final m in metrics)
                Container(
                  padding: const EdgeInsets.only(top: 18),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Palette.gilt, width: 2))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text('${m['value']}', style: T.display(44, color: g.royalLight)),
                      Text('${m['label']}', style: T.body(15, height: 1.5, color: g.inkMuted)),
                    ],
                  ),
                ),
            ],
          ),
        if (gallery.isNotEmpty)
          AutoGrid(
            minWidth: 240,
            gap: 32,
            maxColumns: 3,
            children: [
              for (final item in gallery)
                GiltFrame(
                  small: true,
                  child: item.startsWith('http')
                      ? ArtImage(src: item, alt: '${w.title} screenshot', aspect: 4 / 3, painting: false)
                      : Plate(child: Center(child: Mono(item, color: Palette.tyrian, align: TextAlign.center))),
                ),
            ],
          ),
        if (next.slug != w.slug)
          Pressable(
            href: '/works/${next.slug}',
            label: 'Next work: ${next.title}',
            builder: (context, hover, _) => Container(
              padding: const EdgeInsets.only(top: 32),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: g.tyrianLight.withValues(alpha: .3)))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Mono('Next work · Plate ${next.numeral}', color: g.giltLight),
                        Text(next.title, style: T.display(compact ? 28 : 36, color: g.ink)),
                      ],
                    ),
                  ),
                  AnimatedSlide(
                    offset: Offset(hover ? .15 : 0, 0),
                    duration: const Duration(milliseconds: 180),
                    child: Glyph(GlyphKind.arrowRight, size: 40, stroke: 1.4, color: g.royalLight),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Clients → services → data, drawn as outlined boxes with gilt arrows.
class _Architecture extends StatelessWidget {
  const _Architecture(this.a);
  final Map<String, dynamic> a;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    Widget box(String label, String title, {String? note, bool service = false}) => Container(
          constraints: const BoxConstraints(minWidth: 200),
          padding: EdgeInsets.symmetric(horizontal: service ? 22 : 18, vertical: service ? 18 : 14),
          decoration: BoxDecoration(
            color: service ? Palette.tyrian.withValues(alpha: .35) : null,
            border: Border.all(color: service ? g.tyrianLight : g.royalLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Mono(label, color: service ? g.tyrianLight : g.royalLight),
              Text(title, style: T.display(17, height: 1.3, color: g.ink)),
              if (note != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(note, style: T.body(13, height: 1.4, color: g.inkMuted))),
            ],
          ),
        );
    // Below ~900px the row would overflow, so the diagram reads top to bottom.
    final compact = context.width < 900;
    final arrowW = RotatedBox(
      quarterTurns: compact ? 1 : 0,
      child: Glyph(GlyphKind.arrowRight, size: 40, stroke: 1.2, color: g.giltLight),
    );
    final clients = [for (final c in (a['clients'] as List? ?? const [])) box('Client', '$c')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        Mono('Architecture', color: g.giltLight),
        ExcludeSemantics(
          excluding: false,
          child: Flex(
            direction: compact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: clients),
              arrowW,
              box('Services', '${a['service'] ?? ''}', note: a['service_note']?.toString(), service: true),
              arrowW,
              box('Data', '${a['data'] ?? ''}'),
            ],
          ),
        ),
      ],
    );
  }
}
