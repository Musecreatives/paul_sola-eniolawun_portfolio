import 'package:flutter/material.dart';

import '../data/paintings.dart';
import '../shell/page.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/motion.dart';

/// Room 404: closed for restoration.
class NotFoundRoom extends StatelessWidget {
  const NotFoundRoom({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    const p = Painting.aureliusFragment;
    return GalleryPage(
      title: 'Closed for restoration',
      footer: false,
      sections: [
        Section(
          decoration: Walls.imperial,
          light: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height - (compact ? 76 : 104)),
            child: Center(
              child: RoomBody(
                maxWidth: 1180,
                top: compact ? 24 : 40,
                bottom: 80,
                child: TwoUp(
                  gap: 72,
                  breakpoint: 760,
                  left: Column(
                    spacing: 22,
                    children: [
                      const Lamp(width: 140),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: GiltFrame(
                          padding: 0,
                          matte: Palette.nightGround,
                          child: ArtImage(src: p.asset, alt: p.alt, aspect: 4 / 3),
                        ),
                      ),
                    ],
                  ),
                  right: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 24,
                    children: [
                      const Rise(child: Mono('Room 404', color: Color(0xFFE2C57F))),
                      Rise(
                        step: 1,
                        child: Semantics(
                          header: true,
                          child: Text('Closed for restoration.',
                              style: T.display((context.width * .06).clamp(44.0, 80.0), color: const Color(0xFFF3EEE3))),
                        ),
                      ),
                      Rise(
                        step: 2,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Text(
                            "The piece you're looking for has been moved, or was never hung here. Like this fragment, some things survive only in part.",
                            style: T.body(18, color: const Color(0xFFD6D0EA)),
                          ),
                        ),
                      ),
                      const Rise(
                        step: 3,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            GalleryButton(label: 'Return to the Foyer', href: '/'),
                            GalleryButton(label: 'Browse Selected Works', href: '/works', kind: ButtonKind.outline),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
