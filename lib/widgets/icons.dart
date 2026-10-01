import 'package:flutter/widgets.dart';

/// The design system's inline stroke icons (24x24 viewBox, 1.8 stroke,
/// currentColor). Drawn as paths so no icon font ships.
enum GlyphKind { arrowRight, arrowLeft, moon, sun, close, envelope, download, link, image, medal, external }

class Glyph extends StatelessWidget {
  const Glyph(this.kind, {super.key, this.size = 18, this.color, this.stroke = 1.8});

  final GlyphKind kind;
  final double size;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFFFFFFFF);
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _GlyphPainter(kind, c, stroke)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.kind, this.color, this.stroke);
  final GlyphKind kind;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    switch (kind) {
      case GlyphKind.arrowRight:
        path
          ..moveTo(5, 12)
          ..lineTo(19, 12)
          ..moveTo(13, 6)
          ..lineTo(19, 12)
          ..lineTo(13, 18);
      case GlyphKind.arrowLeft:
        path
          ..moveTo(19, 12)
          ..lineTo(5, 12)
          ..moveTo(11, 6)
          ..lineTo(5, 12)
          ..lineTo(11, 18);
      case GlyphKind.moon:
        path
          ..moveTo(20, 14.5)
          ..arcToPoint(const Offset(9.5, 4), radius: const Radius.circular(8))
          ..arcToPoint(const Offset(20, 14.5), radius: const Radius.circular(8), largeArc: true, clockwise: false)
          ..close();
      case GlyphKind.sun:
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 4));
        for (final (a, b) in const [
          (Offset(12, 2), Offset(12, 4)),
          (Offset(12, 20), Offset(12, 22)),
          (Offset(2, 12), Offset(4, 12)),
          (Offset(20, 12), Offset(22, 12)),
          (Offset(4.9, 4.9), Offset(6.3, 6.3)),
          (Offset(17.7, 17.7), Offset(19.1, 19.1)),
          (Offset(4.9, 19.1), Offset(6.3, 17.7)),
          (Offset(17.7, 6.3), Offset(19.1, 4.9)),
        ]) {
          path
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy);
        }
      case GlyphKind.close:
        path
          ..moveTo(6, 6)
          ..lineTo(18, 18)
          ..moveTo(18, 6)
          ..lineTo(6, 18);
      case GlyphKind.envelope:
        path
          ..addRect(const Rect.fromLTRB(4, 6, 20, 18))
          ..moveTo(4, 7)
          ..lineTo(12, 13)
          ..lineTo(20, 7);
      case GlyphKind.download:
        path
          ..moveTo(12, 4)
          ..lineTo(12, 15)
          ..moveTo(7, 10)
          ..lineTo(12, 15)
          ..lineTo(17, 10)
          ..moveTo(5, 20)
          ..lineTo(19, 20);
      case GlyphKind.link:
        path
          ..moveTo(10, 14)
          ..arcToPoint(const Offset(15.7, 14), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(18.7, 11)
          ..arcToPoint(const Offset(13, 5.3), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(12, 6.3)
          ..moveTo(14, 10)
          ..arcToPoint(const Offset(8.3, 10), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(5.3, 13)
          ..arcToPoint(const Offset(11, 18.7), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(12, 17.7);
      case GlyphKind.image:
        path
          ..addRect(const Rect.fromLTRB(3, 5, 21, 19))
          ..moveTo(3, 16)
          ..lineTo(8, 11)
          ..lineTo(12, 15)
          ..lineTo(15, 12)
          ..lineTo(21, 18);
      case GlyphKind.medal:
        path
          ..addOval(Rect.fromCircle(center: const Offset(12, 9), radius: 5))
          ..moveTo(8.5, 13)
          ..lineTo(7, 21)
          ..lineTo(12, 18)
          ..lineTo(17, 21)
          ..lineTo(15.5, 13);
      case GlyphKind.external:
        path
          ..moveTo(7, 17)
          ..lineTo(17, 7)
          ..moveTo(8, 7)
          ..lineTo(17, 7)
          ..lineTo(17, 16);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.kind != kind || old.color != color || old.stroke != stroke;
}
