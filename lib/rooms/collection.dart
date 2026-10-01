import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/paintings.dart';
import '../data/store.dart';
import '../shell/page.dart';
import '../shell/rooms.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/motion.dart';

const _gilt = Color(0xFFE2C57F);
const _ink = Color(0xFFF3EEE3);
const _soft = Color(0xFFE4D6F2);

/// Room VII: tastes, hung salon-style on the Tyrian wall.
class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) => const GalleryPage(
        title: 'The Collection',
        room: Room.collection,
        sections: [
          // The light falls from the top of the wall, behind the nav bar too.
          Section(decoration: Walls.salon, light: true, lightCenter: Alignment(0, -1), lightRadius: .7, lightOpacity: .08, child: _Collection()),
        ],
      );
}

class _Collection extends StatelessWidget {
  const _Collection();

  @override
  Widget build(BuildContext context) {
    final items = Content.of(context).collection;
    CollectionItem? kind(String k) => items.where((i) => i.kind == k).firstOrNull;
    final art = kind('art'), book = kind('book'), chess = kind('chess'), record = kind('record'), sport = kind('sport'), game = kind('game');
    // Anything beyond the six salon slots hangs in a row underneath.
    final extra = items.where((i) => ![art, book, chess, record, sport, game].contains(i)).toList();

    return Theme(
      data: buildTheme(GalleryColors.night),
      child: RoomBody(
        rightExtra: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 64,
          children: [
            RoomHeader(
              eyebrow: 'Room VII',
              title: 'The Collection',
              rule: false,
              center: true,
              subtitle: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  'Things I keep coming back to: books, records, openings and the odd painting. Hung salon-style and rehung often.',
                  textAlign: TextAlign.center,
                  style: T.body(17, height: 1.6, color: _soft),
                ),
              ),
            ),
            LayoutBuilder(builder: (context, c) {
              final one = c.maxWidth < 760;
              final col = (c.maxWidth - 32 * 11) / 12;
              double span(int n) => one ? c.maxWidth : col * n + 32 * (n - 1);
              Widget piece(CollectionItem? i, int n, int step) =>
                  i == null ? const SizedBox.shrink() : SizedBox(width: span(n), child: Rise(step: step, child: _Piece(i)));
              return Wrap(
                spacing: 32,
                runSpacing: 40,
                children: [
                  piece(art, 7, 2),
                  SizedBox(
                    width: span(5),
                    child: Column(spacing: 40, children: [
                      if (book != null) Rise(step: 3, child: _Piece(book)),
                      if (chess != null) Rise(step: 4, child: _Piece(chess)),
                    ]),
                  ),
                  piece(record, 4, 0),
                  piece(sport, 4, 1),
                  piece(game, 4, 2),
                  for (final (k, i) in extra.indexed) piece(i, 4, k % 3),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Piece extends StatelessWidget {
  const _Piece(this.i);
  final CollectionItem i;

  @override
  Widget build(BuildContext context) {
    final caption = i.note.isEmpty ? i.kind : i.note;
    final Widget frame;
    Widget? title;
    switch (i.kind) {
      case 'art':
        frame = GiltFrame(padding: 20, child: _image(i, 16 / 9));
        title = Text(i.title, style: T.display(18, height: 1.3, color: _ink));
      case 'book':
        frame = GiltFrame(
          small: true,
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Container(
              color: Palette.placard,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(i.title, textAlign: TextAlign.center, style: T.display(26, height: 1.15, color: Palette.royal)),
                  if (i.subtitle.isNotEmpty) Mono(i.subtitle, color: Palette.tyrian),
                ],
              ),
            ),
          ),
        );
      case 'chess':
        frame = GiltFrame(
          small: true,
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: CustomPaint(
              painter: _Checker(),
              child: Center(
                child: Container(
                  color: Palette.plateDark,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(i.title.toUpperCase(), style: T.mono(size: 14, tracking: .08, color: _gilt)),
                ),
              ),
            ),
          ),
        );
      case 'record':
        frame = GiltFrame(
          small: true,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Palette.nightWall,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  if (i.image.isNotEmpty)
                    ClipOval(child: SizedBox.square(dimension: 120, child: _image(i, 1)))
                  else
                    const SizedBox.square(dimension: 120, child: CustomPaint(painter: _Vinyl())),
                  Text(i.title, textAlign: TextAlign.center, style: T.display(20, height: 1.2, color: _ink)),
                  if (i.subtitle.isNotEmpty) Mono(i.subtitle, color: const Color(0xFFA9A3C4)),
                ],
              ),
            ),
          ),
        );
      case 'sport':
        frame = GiltFrame(small: true, padding: 0, matte: Palette.nightGround, child: _image(i, 1));
        title = Text(i.title, style: T.body(14, height: 1.5, color: _soft));
      default:
        frame = GiltFrame(
          small: true,
          child: i.image.isNotEmpty
              ? _image(i, 1)
              : Plate(
                  aspect: 1,
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, spacing: 8, children: [
                      Text(i.title, textAlign: TextAlign.center, style: T.display(24, height: 1.15, color: Palette.royal)),
                      if (i.subtitle.isNotEmpty) Mono(i.subtitle, color: Palette.tyrian),
                    ]),
                  ),
                ),
        );
    }
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          frame,
          Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: [Mono(caption, color: _gilt), ?title]),
        ],
      ),
    );
  }

  /// `image` is either an uploaded file URL or a painting key.
  Widget _image(CollectionItem i, double aspect) {
    if (i.image.startsWith('http')) return ArtImage(src: i.image, alt: i.title, aspect: aspect, painting: false);
    final p = Painting.byKey(i.image);
    return ArtImage(src: p.asset, alt: p.alt, aspect: aspect, align: p.align);
  }
}

class _Checker extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.plateDark);
    final p = Paint()..color = const Color(0xFF221B52);
    const s = 20.0;
    for (var y = 0; y * s < size.height; y++) {
      for (var x = 0; x * s < size.width; x++) {
        if ((x + y).isEven) canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);
      }
    }
  }

  @override
  bool shouldRepaint(_Checker old) => false;
}

class _Vinyl extends CustomPainter {
  const _Vinyl();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;
    canvas.drawCircle(c, r, Paint()..color = Palette.nightGround);
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Palette.menuActive;
    for (var g = 22.0; g < r; g += 5) {
      canvas.drawCircle(c, g, groove);
    }
    canvas.drawCircle(c, 18, Paint()..color = Palette.tyrian);
    canvas.drawCircle(
      c,
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Palette.gilt,
    );
  }

  @override
  bool shouldRepaint(_Vinyl old) => false;
}
