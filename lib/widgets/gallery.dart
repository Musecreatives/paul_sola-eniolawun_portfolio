// Design-system primitives: frames, placards, plates, buttons, links, headers.
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'icons.dart';
import 'motion.dart';
import 'pressable.dart';

const kEase = Cubic(.2, .7, .1, 1);

/// Mono uppercase label (JetBrains Mono, 12px, 0.16em).
class Mono extends StatelessWidget {
  const Mono(this.text, {super.key, this.color, this.size = 12, this.align, this.tracking = .16});
  final String text;
  final Color? color;
  final double size;
  final TextAlign? align;
  final double tracking;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), textAlign: align, style: T.mono(size: size, color: color ?? context.g.giltLight, tracking: tracking));
}

/// Walls. The imperial blend is reserved for the Foyer, 404 and admin entrance.
abstract final class Walls {
  static const imperial = BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: Palette.imperial),
  );
  static const salon = BoxDecoration(color: Palette.wallSalon);
}

/// The warm picture light at ~10% that sits on imperial and salon walls.
class PictureLight extends StatelessWidget {
  const PictureLight({super.key, required this.child, this.center = const Alignment(.44, -.32), this.radius = .55, this.opacity = .10});
  final Widget child;
  final Alignment center;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: center,
            radius: radius,
            colors: [const Color(0xFFE2C57F).withValues(alpha: opacity), const Color(0x00E2C57F)],
          ),
        ),
        child: child,
      );
}

/// The PSE seal: a tyrian disc with a gilt ring. Replaces any avatar or logo.
class Seal extends StatelessWidget {
  const Seal({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.tyrian,
          border: Border.all(color: Palette.gilt, width: 1.5),
        ),
        child: Text('PSE', style: T.display(size * .29, color: const Color(0xFFF3EEE3))),
      );
}

/// Picture lamp: 7px gilt bar with a warm spill, centred above a hero frame.
class Lamp extends StatelessWidget {
  const Lamp({super.key, this.width = 200, this.height = 7});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => LampFlicker(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Palette.gilt,
            borderRadius: BorderRadius.circular(4),
            boxShadow: Shadows.lamp,
          ),
        ),
      );
}

/// A gilt museum frame: 14px moulding, 1px fillet inset 9px, matte, shadow.
/// Lifts 6px on hover.
class GiltFrame extends StatefulWidget {
  const GiltFrame({
    super.key,
    required this.child,
    this.small = false,
    this.padding,
    this.matte = Palette.matte,
    this.shadow = Shadows.frame,
    this.hoverShadow = Shadows.frameHover,
    this.lift = true,
  });

  final Widget child;
  final bool small;
  final double? padding;
  final Color matte;
  final List<BoxShadow> shadow;
  final List<BoxShadow> hoverShadow;
  final bool lift;

  @override
  State<GiltFrame> createState() => _GiltFrameState();
}

class _GiltFrameState extends State<GiltFrame> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.small ? 10.0 : 14.0;
    final inset = widget.small ? 6.5 : 8.5;
    final pad = widget.padding ?? (widget.small ? 12.0 : 18.0);
    final up = _hover && widget.lift;
    final d = context.reduceMotion ? Duration.zero : const Duration(milliseconds: 500);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: d,
        curve: kEase,
        transform: Matrix4.translationValues(0, up ? -6 : 0, 0),
        decoration: BoxDecoration(color: Palette.frameMoulding, boxShadow: up ? widget.hoverShadow : widget.shadow),
        padding: EdgeInsets.all(border),
        child: CustomPaint(
          foregroundPainter: _FilletPainter(border - inset),
          child: Container(color: widget.matte, padding: EdgeInsets.all(pad), child: widget.child),
        ),
      ),
    );
  }
}

class _FilletPainter extends CustomPainter {
  _FilletPainter(this.outset);
  final double outset;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawRect(
        (Offset.zero & size).inflate(outset),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Palette.frameFillet,
      );

  @override
  bool shouldRepaint(_FilletPainter old) => old.outset != outset;
}

/// An image inside a frame window. Paintings crop with cover at 1.32 (the
/// current scans have a skew baked in) and drift slowly; photos anchor high.
class ArtImage extends StatelessWidget {
  const ArtImage({
    super.key,
    required this.src,
    required this.alt,
    this.aspect = 16 / 10,
    this.painting = true,
    this.align = Alignment.center,
    this.fit = BoxFit.cover,
    this.background,
  });

  final String src;
  final String alt;
  final double aspect;
  final bool painting;
  final Alignment align;
  final BoxFit fit;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final image = src.startsWith('http')
        ? Image.network(src, fit: fit, alignment: align, semanticLabel: alt, errorBuilder: (_, _, _) => const SizedBox())
        : Image.asset(src, fit: fit, alignment: align, semanticLabel: alt);
    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRect(
        child: Container(
          color: background,
          child: SizedBox.expand(child: painting ? Drift(child: image) : image),
        ),
      ),
    );
  }
}

/// Museum wall label: inventory line, title, then medium and date.
class Placard extends StatelessWidget {
  const Placard({super.key, required this.label, required this.title, this.sub, this.width, this.padding, this.gap = 4, this.titleSize = 17});
  final String label;
  final String title;
  final String? sub;
  final double? width;
  final EdgeInsets? padding;
  final double gap;
  final double titleSize;

  @override
  Widget build(BuildContext context) => PlacardBox(
        width: width,
        padding: padding,
        gap: gap,
        children: [
          Mono(label, color: Palette.tyrian),
          Text(title, style: T.display(titleSize, height: 1.3, color: Palette.placardInk)),
          if (sub != null) Text(sub!, style: T.body(13, height: 1.5, color: Palette.placardMuted)),
        ],
      );
}

class PlacardBox extends StatelessWidget {
  const PlacardBox({super.key, required this.children, this.width, this.padding, this.gap = 4});
  final List<Widget> children;
  final double? width;
  final EdgeInsets? padding;
  final double gap;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(color: Palette.placard, boxShadow: Shadows.placard),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Palette.placardInk),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: gap,
            children: children,
          ),
        ),
      );
}

/// A blueprint plate for work without imagery.
class Plate extends StatelessWidget {
  const Plate({super.key, required this.child, this.dark = false, this.aspect = 4 / 3, this.padding = const EdgeInsets.all(22)});
  final Widget child;
  final bool dark;
  final double? aspect;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget plate = CustomPaint(
      painter: _GridPainter(
        bg: dark ? Palette.plateDark : Palette.plate,
        line: dark ? const Color(0x1FA8B9FF) : const Color(0x1A1F3A93),
        step: dark ? 28 : 22,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (aspect != null) plate = AspectRatio(aspectRatio: aspect!, child: plate);
    return plate;
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.bg, required this.line, required this.step});
  final Color bg;
  final Color line;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final p = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x + .5, 0), Offset(x + .5, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y + .5), Offset(size.width, y + .5), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.bg != bg || old.line != line || old.step != step;
}

enum ButtonKind { primary, seal, ink, outline }

/// Square-cornered action. One primary per view.
class GalleryButton extends StatelessWidget {
  const GalleryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.href,
    this.external = false,
    this.kind = ButtonKind.primary,
    this.trailing,
    this.leading,
    this.height = 52,
    this.fontSize = 16,
    this.expand = false,
    this.padding = 28,
    this.outlineInk,
    this.outlineBorder,
    this.busy = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? href;
  final bool external;
  final ButtonKind kind;
  final Widget? trailing;
  final Widget? leading;
  final double height;
  final double fontSize;
  final bool expand;
  final double padding;
  final Color? outlineInk;
  final Color? outlineBorder;
  final bool busy;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final d = context.reduceMotion ? Duration.zero : const Duration(milliseconds: 180);
    return Pressable(
      href: href,
      external: external,
      onTap: busy ? null : (onPressed ?? (href != null ? () {} : null)),
      label: semanticLabel,
      builder: (context, hover, focus) {
        final (bg, bgHover, fg) = switch (kind) {
          ButtonKind.primary => (Palette.royalAction, Palette.royalActionHover, Colors.white),
          ButtonKind.seal => (Palette.tyrianAction, Palette.tyrianActionHover, Colors.white),
          ButtonKind.ink => (Palette.inkButton, Palette.inkButtonHover, Colors.white),
          ButtonKind.outline => (Colors.transparent, g.tyrianLight.withValues(alpha: .12), outlineInk ?? g.ink),
        };
        final lift = hover && kind != ButtonKind.outline;
        return AnimatedContainer(
          duration: d,
          transform: Matrix4.translationValues(0, lift ? -2 : 0, 0),
          constraints: BoxConstraints(minHeight: height),
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: hover ? bgHover : bg,
            border: kind == ButtonKind.outline ? Border.all(color: outlineBorder ?? g.tyrianLight) : null,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: fg),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: fg),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  ?leading,
                  Flexible(
                    child: Text(
                      busy ? 'Sending…' : label,
                      textAlign: TextAlign.center,
                      style: T.display(fontSize,
                          weight: kind == ButtonKind.outline ? FontWeight.w500 : FontWeight.w600, height: 1.2, color: fg),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

const arrow = Glyph(GlyphKind.arrowRight);

/// A text link whose underline draws in on hover.
class TextLink extends StatelessWidget {
  const TextLink(this.text, {super.key, this.href, this.onTap, this.color, this.mono = true, this.size, this.external = false, this.label});
  final String text;
  final String? href;
  final VoidCallback? onTap;
  final Color? color;
  final bool mono;
  final double? size;
  final bool external;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.g.royalLight;
    final style = mono ? T.mono(size: size ?? 12, color: c) : T.body(size ?? 16, height: 1.5, color: c);
    final d = context.reduceMotion ? Duration.zero : const Duration(milliseconds: 350);
    return Pressable(
      href: href,
      onTap: onTap,
      external: external,
      label: label,
      builder: (context, hover, focus) => TweenAnimationBuilder<double>(
        tween: Tween(end: hover ? 1 : 0),
        duration: d,
        curve: kEase,
        builder: (_, v, child) => CustomPaint(foregroundPainter: _Underline(v, c), child: child),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(mono ? text.toUpperCase() : text, style: style),
        ),
      ),
    );
  }
}

class _Underline extends CustomPainter {
  _Underline(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    canvas.drawRect(Rect.fromLTWH(0, size.height - 1, size.width * t, 1), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Underline old) => old.t != t || old.color != color;
}

/// A 120x2 gilt rule that draws in from the left.
class GiltRule extends StatelessWidget {
  const GiltRule({super.key, this.width = 120});
  final double width;

  @override
  Widget build(BuildContext context) =>
      DrawIn(child: Container(width: width, height: 2, color: Palette.gilt));
}

/// The opening of every room: numeral eyebrow, title, gilt rule, epigraph.
class RoomHeader extends StatelessWidget {
  const RoomHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.rule = true,
    this.subtitle,
    this.epigraph,
    this.source,
    this.trailing,
    this.center = false,
  });

  final String eyebrow;
  final String title;
  final bool rule;
  final Widget? subtitle;
  final String? epigraph;
  final String? source;
  final Widget? trailing;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final g = context.g;
    final titleSize = (context.width * .05).clamp(44.0, 68.0);
    final heading = Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Rise(child: Mono(eyebrow, color: g.eyebrow)),
        Rise(
          step: 1,
          child: Semantics(
            header: true,
            child: FitWords(title,
                textAlign: center ? TextAlign.center : TextAlign.start,
                style: T.display(titleSize, weight: FontWeight.w500, color: g.title)),
          ),
        ),
        if (rule) const GiltRule(),
        if (subtitle != null) Rise(step: 2, child: subtitle!),
      ],
    );
    final side = trailing ??
        (epigraph == null
            ? null
            : Rise(
                step: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text('“$epigraph”', style: T.body(16, height: 1.6, italic: true, color: g.inkMuted)),
                      if (source != null) Mono(source!, color: g.isDay ? Palette.placardMuted : const Color(0xFF8F88B0)),
                    ],
                  ),
                ),
              ));
    if (center || side == null) return heading;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 32,
      runSpacing: 32,
      children: [heading, side],
    );
  }
}

/// A room's content column: max 1240 wide, room padding, centred.
class RoomBody extends StatelessWidget {
  const RoomBody({super.key, required this.child, this.maxWidth = 1240, this.top = Space.s7, this.bottom = 120, this.rightExtra = 0});
  final Widget child;
  final double maxWidth;
  final double top;
  final double bottom;
  final double rightExtra;

  @override
  Widget build(BuildContext context) {
    final gutter = context.gutter;
    final compact = context.isCompact;
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, compact ? Space.s6 : top, gutter + (context.isWide ? rightExtra : 0), compact ? Space.s7 : bottom),
      child: Center(
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      ),
    );
  }
}

/// Responsive grid that fills columns like CSS auto-fit minmax(min, 1fr).
class AutoGrid extends StatelessWidget {
  const AutoGrid({super.key, required this.children, required this.minWidth, this.gap = 40, this.runGap, this.maxColumns = 12});
  final List<Widget> children;
  final double minWidth;
  final double gap;
  final double? runGap;
  final int maxColumns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final cols = ((c.maxWidth + gap) / (minWidth + gap)).floor().clamp(1, maxColumns);
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: runGap ?? gap,
          children: [for (final child in children) SizedBox(width: w, child: child)],
        );
      });
}

/// Two side-by-side columns that stack under [breakpoint].
class TwoUp extends StatelessWidget {
  const TwoUp({
    super.key,
    required this.left,
    required this.right,
    this.gap = 64,
    this.flex = const (1, 1),
    this.breakpoint = 760,
    this.align = CrossAxisAlignment.center,
  });
  final Widget left;
  final Widget right;
  final double gap;
  final (int, int) flex;
  final double breakpoint;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < breakpoint) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: gap * .75, children: [left, right]);
        }
        return Row(
          crossAxisAlignment: align,
          spacing: gap,
          children: [Expanded(flex: flex.$1, child: left), Expanded(flex: flex.$2, child: right)],
        );
      });
}

/// Label + value pair used on placards and case-study facts.
class Fact extends StatelessWidget {
  const Fact(this.label, this.value, {super.key, this.labelColor = Palette.tyrian, this.valueStyle});
  final String label;
  final String value;
  final Color labelColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [Mono(label, color: labelColor), Text(value, style: valueStyle ?? T.body(14, height: 1.5))],
      );
}

/// Display text that shrinks its font until its longest word fits the width,
/// so titles like "Correspondence" never break mid-word on phones.
class FitWords extends StatelessWidget {
  const FitWords(this.text, {super.key, required this.style, this.textAlign});
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        var s = style;
        if (c.maxWidth.isFinite) {
          final longest = text.split(RegExp(r'\s+')).fold('', (a, b) => b.length > a.length ? b : a);
          final tp = TextPainter(
            text: TextSpan(text: longest, style: style),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          if (tp.width > c.maxWidth) s = style.copyWith(fontSize: (style.fontSize ?? 14) * c.maxWidth / tp.width * .98);
          tp.dispose();
        }
        return Text(text, style: s, textAlign: textAlign);
      });
}
