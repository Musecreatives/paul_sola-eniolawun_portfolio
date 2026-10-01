import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/pressable.dart';
import 'page.dart';
import 'rooms.dart';

/// Opens the full-screen menu. Esc, the close button or a room closes it.
Future<void> openMenu(BuildContext context, Room? current) => showGeneralDialog(
      context: context,
      barrierLabel: 'Close menu',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: context.reduceMotion ? Duration.zero : const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => Theme(data: buildTheme(GalleryColors.night), child: MenuOverlay(current: current)),
      transitionBuilder: (_, anim, _, child) => FadeTransition(opacity: CurvedAnimation(parent: anim, curve: kEase), child: child),
    );

class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key, this.current});
  final Room? current;

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  late int _sel = (widget.current ?? Room.chronicle).index;

  void _go(Room r) {
    Navigator.of(context).pop();
    GoRouter.of(context).go(r.path);
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final nav = Container(
      color: Palette.nightGround,
      padding: EdgeInsets.fromLTRB(compact ? 16 : 56, compact ? 16 : 28, compact ? 16 : 56, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconCircle(
            label: 'Close menu',
            size: 48,
            fill: Palette.nightWall,
            onTap: () => Navigator.of(context).pop(),
            child: const Glyph(GlyphKind.close, stroke: 2, color: Color(0xFFF3EEE3)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 24 : 32),
            child: FocusTraversalGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  for (final r in Room.values)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Pressable(
                        label: 'Room ${r.numeral}, ${r.title}',
                        onHover: (v) {
                          if (v) setState(() => _sel = r.index);
                        },
                        onTap: () => _go(r),
                        builder: (context, hover, focus) {
                          final on = r.index == _sel;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color: on ? Palette.menuActive : Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: r.title),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.top,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(r.numeral, style: T.mono(color: const Color(0xFFE2C57F))),
                                  ),
                                ),
                              ]),
                              style: T.display(compact ? 30 : 38,
                                  weight: FontWeight.w500, height: 1.25, color: on ? const Color(0xFFE2C57F) : const Color(0xFFF3EEE3)),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 24),
            child: Socials(color: Color(0xFFA9A3C4), withEmail: true),
          ),
        ],
      ),
    );

    final room = Room.values[_sel];
    final painting = DecoratedBox(
      decoration: Walls.salon,
      child: PictureLight(
        center: const Alignment(0, -1),
        radius: .8,
        opacity: .08,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 56, vertical: Space.s6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 28,
                children: [
                  const Lamp(width: 180),
                  GiltFrame(
                    padding: 20,
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          for (final r in Room.values)
                            AnimatedOpacity(
                              opacity: r.index == _sel ? 1 : 0,
                              duration: context.reduceMotion ? Duration.zero : const Duration(milliseconds: 900),
                              child: ArtImage(src: r.painting.asset, alt: r.painting.alt, align: r.painting.align),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Placard(
                      width: 300,
                      label: 'Room ${room.numeral} · ${room.title}',
                      // TODO(paul): replace the placeholder art for rooms VII and VIII.
                      title: room.placeholderArt ? '[New artwork needed]' : room.painting.title,
                      sub: room.placeholderArt ? 'Public-domain piece to source' : room.painting.artist,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Material(
      color: Palette.nightGround,
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 760) {
          return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [nav, painting]));
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: SingleChildScrollView(child: ConstrainedBox(constraints: BoxConstraints(minHeight: c.maxHeight), child: IntrinsicHeight(child: nav)))),
            Expanded(child: painting),
          ],
        );
      }),
    );
  }
}
