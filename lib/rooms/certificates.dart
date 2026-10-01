import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/motion.dart';
import '../widgets/pressable.dart';

/// Room IV: earned certificates (click to examine) and those in progress.
class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) => const GalleryPage(
        title: 'Certificates',
        room: Room.certificates,
        sections: [Section(child: _Certificates())],
      );
}

class _Certificates extends StatelessWidget {
  const _Certificates();

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final all = Content.of(context).certificates;
    final earned = all.where((c) => c.earned).toList();
    final pending = all.where((c) => !c.earned).toList();
    return RoomBody(
      rightExtra: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 72,
        children: [
          const RoomHeader(
            eyebrow: 'Room IV',
            title: 'Certificates',
            epigraph: 'No man is free who is not master of himself.',
            source: 'Epictetus · Discourses',
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 28,
            children: [
              Mono('Earned · ${earned.length} pieces · click to examine', color: g.royalLight),
              AutoGrid(
                minWidth: 280,
                gap: 36,
                runGap: 48,
                maxColumns: 3,
                children: [
                  for (final (i, c) in earned.indexed)
                    Rise(
                      step: i % 3,
                      child: Pressable(
                        label: 'Preview ${c.title}',
                        cursor: SystemMouseCursors.zoomIn,
                        onTap: () => _openLightbox(context, earned, i),
                        builder: (context, hover, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 18,
                          children: [
                            GiltFrame(small: true, child: _CertArt(c)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Mono('${c.issuer} · ${c.year}', color: g.giltLight),
                                Text(c.title, style: T.display(18, height: 1.3, color: g.ink)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (pending.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 24,
              children: [
                Mono('In the studio · in progress', color: g.tyrianLight),
                // TODO(paul): replace the three in-progress placeholders with real certifications in the CMS.
                Column(children: [for (final p in pending) _InProgress(p)]),
              ],
            ),
        ],
      ),
    );
  }
}

class _CertArt extends StatelessWidget {
  const _CertArt(this.c, {this.large = false});
  final Certificate c;
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (c.image.isNotEmpty) {
      return ArtImage(src: c.image, alt: '${c.title} certificate', aspect: 4 / 3, painting: false, fit: BoxFit.contain, background: Colors.white);
    }
    return Plate(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            if (!large) const Glyph(GlyphKind.medal, size: 34, stroke: 1.4, color: Palette.tyrian),
            Text(c.title, textAlign: TextAlign.center, style: T.display(large ? 26 : 18, height: 1.2, color: Palette.royal)),
            // TODO(paul): upload scans for certificates that show "[Scan to upload]".
            if (!large) const Mono('[Scan to upload]', color: Palette.placardMuted),
          ],
        ),
      ),
    );
  }
}

class _InProgress extends StatelessWidget {
  const _InProgress(this.p);
  final Certificate p;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [Text(p.title, style: T.display(19, height: 1.25, color: g.ink)), Mono(p.issuer, color: g.inkMuted)],
    );
    final bar = Semantics(
      label: '${p.progress}% complete',
      child: Container(
        height: 6,
        color: g.tyrianLight.withValues(alpha: .18),
        alignment: Alignment.centerLeft,
        child: DrawIn(
          child: FractionallySizedBox(
            widthFactor: (p.progress / 100).clamp(0, 1),
            child: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Palette.royalAction, Palette.progressEnd])),
            ),
          ),
        ),
      ),
    );
    final target = Mono('Target ${p.target}', color: g.inkMuted);
    final pct = Mono('${p.progress}%', color: g.tyrianLight, align: TextAlign.right);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: g.tyrianLight.withValues(alpha: .2)))),
      child: context.isCompact
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [
              title,
              Row(children: [Expanded(child: target), pct]),
              bar,
            ])
          : Row(spacing: 24, children: [
              Expanded(flex: 2, child: title),
              Expanded(child: target),
              Expanded(flex: 2, child: bar),
              SizedBox(width: 60, child: pct),
            ]),
    );
  }
}

void _openLightbox(BuildContext context, List<Certificate> certs, int index) => showDialog<void>(
      context: context,
      barrierColor: const Color(0xEB080616),
      barrierLabel: 'Close certificate preview',
      builder: (_) => Theme(data: Theme.of(context), child: Material(type: MaterialType.transparency, child: _Lightbox(certs, index))),
    );

/// Certificate preview: prev/next/close, arrow keys, Esc; focus stays inside.
class _Lightbox extends StatefulWidget {
  const _Lightbox(this.certs, this.index);
  final List<Certificate> certs;
  final int index;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late int i = widget.index;
  void _step(int d) => setState(() => i = (i + d) % widget.certs.length);

  @override
  Widget build(BuildContext context) {
    final c = widget.certs[i];
    final compact = context.isCompact;
    Widget square(String label, GlyphKind kind, int d) => Pressable(
          label: label,
          onTap: () => _step(d),
          builder: (_, hover, _) => Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hover ? const Color(0x0F1C1830) : null,
              border: Border.all(color: const Color(0x4D1C1830)),
            ),
            child: Glyph(kind, size: 18, color: Palette.placardInk),
          ),
        );
    final placard = PlacardBox(
      gap: 14,
      padding: const EdgeInsets.all(26),
      children: [
        Mono('${c.issuer} · ${c.year}', color: Palette.tyrian),
        Text(c.title, style: T.display(24, height: 1.15, color: Palette.placardInk)),
        if (c.verifyUrl.isNotEmpty)
          TextLink('Verify credential ↗', href: c.verifyUrl, external: true, color: Palette.royal)
        else
          // TODO(paul): add verification URLs for certificates in the CMS.
          const Mono('Verify credential ↗ [URL]', color: Palette.placardMuted),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            spacing: 10,
            children: [
              square('Previous certificate', GlyphKind.arrowLeft, -1),
              square('Next certificate', GlyphKind.arrowRight, 1),
              const Spacer(),
              GalleryButton(
                label: 'Close',
                kind: ButtonKind.ink,
                height: 44,
                fontSize: 14,
                padding: 18,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _step(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _step(1),
      },
      child: Focus(
        autofocus: true,
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: 'Certificate preview',
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 40, vertical: compact ? 24 : 80),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: TwoUp(
                  gap: 40,
                  flex: const (2, 1),
                  breakpoint: 760,
                  left: GiltFrame(padding: 20, lift: false, child: _CertArt(c, large: true)),
                  right: placard,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
