import 'package:flutter/material.dart';

import '../data/paintings.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/motion.dart';

const _ink = Color(0xFFF3EEE3);
const _gilt = Color(0xFFE2C57F);

/// Room I, the Foyer. The home page continues into Room II below it.
class FoyerPage extends StatelessWidget {
  const FoyerPage({super.key, this.below = const []});

  /// Rooms hung below the Foyer on the home page.
  final List<Section> below;

  @override
  Widget build(BuildContext context) => GalleryPage(
        title: 'Developer + Computer Scientist',
        room: Room.foyer,
        footer: below.isNotEmpty,
        footerRoom: Room.works,
        sections: [
          Section(decoration: Walls.imperial, light: true, child: const _Foyer()),
          ...below,
        ],
      );
}

class _Foyer extends StatelessWidget {
  const _Foyer();

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final screen = MediaQuery.sizeOf(context);
    final now = Content.of(context).now;
    const p = Painting.schoolOfAthens;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: compact ? 16 : 28,
      children: [
        Rise(child: Mono(compact ? 'The Sola-Eniolawun Collection' : 'The Sola-Eniolawun Collection · Est. 2019', color: _gilt)),
        Semantics(
          header: true,
          label: 'Developer + Computer Scientist',
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: compact ? 4 : 8,
              children: [
                Rise(step: 1, child: _fit(Text('Developer', style: T.display(compact ? 54 : (screen.width * .08).clamp(60.0, 108.0), height: .95, color: _ink)))),
                Rise(
                  step: 2,
                  child: Text('+',
                      style: T.display(compact ? 30 : (screen.width * .04).clamp(36.0, 56.0),
                          weight: FontWeight.w500, height: .95, color: const Color(0xFFCDB3EE))),
                ),
                Rise(
                  step: 3,
                  child: _fit(Text('Computer Scientist',
                      style: T.display(compact ? 38 : (screen.width * .054).clamp(44.0, 76.0), height: .95, color: const Color(0xFFA8B9FF)))),
                ),
              ],
            ),
          ),
        ),
        Rise(
          step: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              compact
                  ? 'Full-stack engineer in Flutter, Node.js and Python. VP of Engineering at Synkkafrica.'
                  : 'Full-stack engineer in Flutter, Node.js and Python. VP of Engineering at Synkkafrica, building marketplace and admin platforms that scale.',
              style: T.body(compact ? 16 : 18, height: compact ? 1.6 : 1.65, color: const Color(0xFFD6D0EA)),
            ),
          ),
        ),
        Rise(
          step: 5,
          child: compact
              ? const GalleryButton(label: 'Enter the gallery', href: '/works', trailing: arrow, expand: true)
              : const Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    GalleryButton(label: 'Enter the gallery', href: '/works', trailing: arrow),
                    GalleryButton(label: 'Read the journal', href: '/journal', kind: ButtonKind.outline, outlineInk: _ink, outlineBorder: Color(0xFFCDB3EE)),
                  ],
                ),
        ),
      ],
    );

    final frame = GiltFrame(
      small: compact,
      padding: compact ? null : 22,
      child: ArtImage(src: p.asset, alt: p.alt, aspect: compact ? 4 / 3 : 16 / 10),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
            child: Column(spacing: 14, children: [const Lamp(width: 120, height: 5), FadeIn(child: frame)]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(16, 28, 16, 32), child: text),
          _NowStrip(now.building, now.reading),
        ],
      );
    }

    final painting = Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 56),
          child: Column(children: [const Lamp(), const SizedBox(height: 22), FadeIn(step: 2, child: Tilt(child: frame))]),
        ),
        const Positioned(
          right: -12,
          bottom: 0,
          child: Rise(
            step: 6,
            child: Placard(
              width: 270,
              label: 'Inv. PSE–0001',
              title: 'Paul Sola-Eniolawun',
              sub: 'Nigeria · Flutter, Node.js and Python on marble',
            ),
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: (screen.height - 104).clamp(560.0, 796.0)),
      // The hero sits centred in the first viewport, the Now strip at its foot.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Padding(
                padding: EdgeInsets.fromLTRB(40, 16, context.isWide ? 96 : 40, 48),
                child: TwoUp(left: text, right: painting, breakpoint: 784),
              ),
            ),
          ),
          _NowStrip(now.building, now.reading),
        ],
      ),
    );
  }
}

/// The "Now" placard and the cue into Room II.
class _NowStrip extends StatelessWidget {
  const _NowStrip(this.building, this.reading);
  final String building;
  final String reading;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x40CDB3EE)))),
        padding: EdgeInsets.symmetric(horizontal: context.gutter, vertical: 16),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x0FF3EEE3),
                border: Border.all(color: const Color(0x33CDB3EE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 14,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Palette.nowDot)),
                  const Mono('Now', color: _gilt),
                  // TODO(paul): set the Now placard's "reading" in the CMS (currently "[book]").
                  Flexible(
                    child: Text('Building $building · Reading $reading',
                        style: T.body(13, height: 1.4, color: const Color(0xFFD6D0EA))),
                  ),
                ],
              ),
            ),
            const TextLink('Scroll to enter Room II ↓', href: '/works', color: Color(0xFFA9A3C4)),
          ],
        ),
      );
}

/// One-line display words scale down instead of breaking mid-word.
Widget _fit(Widget text) => FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: text);
