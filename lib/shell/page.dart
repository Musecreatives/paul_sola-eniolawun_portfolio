import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/site.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/pressable.dart';
import 'menu.dart';
import 'rooms.dart';

/// One wall-coloured band of a page.
class Section {
  const Section({
    required this.child,
    this.decoration,
    this.light = false,
    this.lightCenter = const Alignment(.44, -.32),
    this.lightRadius = .55,
    this.lightOpacity = .10,
  });
  final Widget child;

  /// Null uses the theme's `wall`.
  final Decoration? decoration;

  /// Adds the warm picture light used on imperial and salon walls.
  final bool light;
  final Alignment lightCenter;
  final double lightRadius;
  final double lightOpacity;
}

/// The frame every public page hangs in: header, sections, room map, footer.
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.title,
    required this.sections,
    this.room,
    this.day = false,
    this.footer = true,
    this.scrollController,
    this.footerRoom,
    this.overlay,
  });

  /// Pinned to the top of the viewport (the journal's reading progress).
  final Widget? overlay;

  /// The room whose "next room" the footer points to (defaults to [room]).
  final Room? footerRoom;

  /// Browser tab title.
  final String title;
  final List<Section> sections;
  final Room? room;

  /// Long-reading rooms (Chronicle, Journal) always use the day palette.
  final bool day;
  final bool footer;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final page = Builder(builder: (context) {
      final g = context.g;
      return Title(
        title: '$title · Paul Sola-Eniolawun',
        color: Palette.royal,
        child: Scaffold(
          backgroundColor: g.ground,
          body: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < sections.length; i++)
                        _band(
                          sections[i],
                          i == 0 ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [NavBar(room: room), sections[i].child]) : sections[i].child,
                          g,
                        ),
                      if (footer) TourFooter(room: footerRoom ?? room),
                    ],
                  ),
                ),
              ),
              if (overlay != null) Positioned(top: 0, left: 0, right: 0, child: overlay!),
              if (room != null && context.isWide)
                Positioned(right: 32, top: 0, bottom: 0, child: Center(child: RoomMap(current: room!))),
            ],
          ),
        ),
      );
    });
    return day ? Theme(data: buildTheme(GalleryColors.day), child: page) : page;
  }

  Widget _band(Section s, Widget child, GalleryColors g) {
    Widget band = s.light ? PictureLight(center: s.lightCenter, radius: s.lightRadius, opacity: s.lightOpacity, child: child) : child;
    return DecoratedBox(decoration: s.decoration ?? BoxDecoration(color: g.wall), child: band);
  }
}

/// Seal (home), day/night toggle and the menu button.
class NavBar extends StatelessWidget {
  const NavBar({super.key, this.room});
  final Room? room;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final g = context.g;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.gutter, vertical: compact ? 16 : 28),
      child: Row(
        children: [
          Pressable(
            href: '/',
            label: 'Home',
            ringOffset: 3,
            builder: (_, _, _) => Seal(size: compact ? 44 : 48),
          ),
          const Spacer(),
          ValueListenableBuilder<bool>(
            valueListenable: dayGallery,
            builder: (context, day, _) => IconCircle(
              label: day ? 'Switch to night gallery' : 'Switch to day gallery',
              onTap: () => dayGallery.value = !day,
              child: Glyph(day ? GlyphKind.sun : GlyphKind.moon, color: g.ink),
            ),
          ),
          const SizedBox(width: 16),
          Pressable(
            label: 'Open menu',
            onTap: () => openMenu(context, room),
            builder: (context, hover, _) => SizedBox(
              width: compact ? 48 : 56,
              height: 44,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: compact ? 7 : 8,
                children: [
                  Container(width: compact ? 40 : 52, height: 2, color: Palette.gilt),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: hover ? (compact ? 40 : 52) : (compact ? 26 : 34),
                    height: 2,
                    color: Palette.gilt,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 44px round icon button with a hairline ring.
class IconCircle extends StatelessWidget {
  const IconCircle({super.key, required this.label, required this.onTap, required this.child, this.size = 44, this.fill});
  final String label;
  final VoidCallback onTap;
  final Widget child;
  final double size;
  final Color? fill;

  @override
  Widget build(BuildContext context) => Pressable(
        label: label,
        onTap: onTap,
        builder: (context, hover, _) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hover ? context.g.tyrianLight.withValues(alpha: .12) : fill,
            border: Border.all(color: context.g.tyrianLight.withValues(alpha: .35)),
          ),
          child: child,
        ),
      );
}

/// The tour-progress map on the right edge.
class RoomMap extends StatelessWidget {
  const RoomMap({super.key, required this.current});
  final Room current;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final idle = g.isDay ? g.inkMuted.withValues(alpha: .7) : const Color(0x73F3EEE3);
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 14,
        children: [
          for (final r in Room.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text(r.numeral, style: T.mono(size: 11, tracking: .14, color: r == current ? g.giltLight : idle)),
                Container(width: r == current ? 40 : 18, height: 1, color: r == current ? g.giltLight : idle),
              ],
            ),
        ],
      ),
    );
  }
}

/// Bottom of every room: the next room on the tour, the email and socials.
class TourFooter extends StatelessWidget {
  const TourFooter({super.key, this.room});
  final Room? room;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final next = room?.next ?? Room.foyer;
    return Container(
      color: g.ground,
      padding: EdgeInsets.symmetric(horizontal: context.gutter, vertical: Space.s5),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          // Fill the column so spaceBetween pushes the contacts right.
          child: SizedBox(width: double.infinity, child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 32,
            runSpacing: 28,
            children: [
              Pressable(
                href: next.path,
                label: 'Next room: ${next.title}',
                builder: (context, hover, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Mono(next == Room.foyer ? 'Back to the start · Room I' : 'Next room · Room ${next.numeral}', color: g.giltLight),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 14,
                      children: [
                        Flexible(child: Text(next.title, style: T.display(context.isCompact ? 26 : 32, color: g.ink))),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 180),
                          offset: Offset(hover ? .2 : 0, 0),
                          child: Glyph(GlyphKind.arrowRight, size: 28, color: g.royalLight, stroke: 1.4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14,
                children: [
                  TextLink(Site.email, href: 'mailto:${Site.email}', mono: false, size: 15, color: g.royalLight),
                  const Socials(),
                ],
              ),
            ],
          )),
        ),
      ),
    );
  }
}

/// GitHub, LinkedIn, Figma, X, Discord as mono text links.
class Socials extends StatelessWidget {
  const Socials({super.key, this.color, this.withEmail = false});
  final Color? color;
  final bool withEmail;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.g.inkMuted;
    return Wrap(
      spacing: 22,
      runSpacing: 12,
      children: [
        for (final (name, url) in Site.socials) TextLink(name, href: url, external: true, color: c, label: '$name (opens in a new tab)'),
        if (withEmail) TextLink(Site.email, href: 'mailto:${Site.email}', color: c),
      ],
    );
  }
}

/// Copies [text] and confirms with a snackbar.
Future<void> copyToClipboard(BuildContext context, String text, String message) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
