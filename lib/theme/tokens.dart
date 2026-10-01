// Design tokens for "The Collection", transcribed from
// docs/redesign/design/design-system/tokens.json. Change values there first,
// then mirror them here.
import 'package:flutter/material.dart';

/// Theme-independent colours (same value in night and day).
abstract final class Palette {
  static const wallSalon = Color(0xFF3A1650);
  static const royal = Color(0xFF1F3A93);
  static const royalAction = Color(0xFF2D4FC4);
  static const royalActionHover = Color(0xFF3B5EE3);
  static const tyrian = Color(0xFF4B1F5E);
  static const tyrianAction = Color(0xFF5B2A78);
  static const tyrianActionHover = Color(0xFF6D3590);
  static const gilt = Color(0xFFC9A24A);
  static const frameMoulding = Color(0xFF8A6A2F);
  static const frameFillet = Color(0xFFD9B872);
  static const matte = Color(0xFFEDE6D6);
  static const placard = Color(0xFFF6F2EA);
  static const placardInk = Color(0xFF1C1830);
  static const placardBody = Color(0xFF403A5C);
  static const placardMuted = Color(0xFF575170);
  static const inkButton = Color(0xFF1C1830);
  static const inkButtonHover = Color(0xFF2A2450);
  static const input = Color(0xFFFFFDF8);
  static const plate = Color(0xFFEFEAF6);
  static const plateDark = Color(0xFF0E0C26);
  static const nightGround = Color(0xFF0B0A1C);
  static const nightWall = Color(0xFF16123A);
  static const menuActive = Color(0xFF1E1850);
  static const nowDot = Color(0xFF7BE0A8);
  static const sealRed = Color(0xFF7A2A3A);
  static const progressEnd = Color(0xFF7A3FA0);

  // Imperial blend: the Foyer, 404 and admin entrance only.
  static const imperial = [Color(0xFF132766), Color(0xFF1E1752), Color(0xFF341552)];

  // Admin (Curator's office) surfaces.
  static const admBg = Color(0xFFF7F5FB);
  static const admSide = Color(0xFF141033);
  static const admSideText = Color(0xFFC9C2E6);
  static const admSideHover = Color(0xFF221B52);
  static const admLine = Color(0xFFE4E0F0);
  static const admLineSoft = Color(0xFFF0EDF7);
}

/// Colours that change between the night and day galleries.
@immutable
class GalleryColors extends ThemeExtension<GalleryColors> {
  const GalleryColors({
    required this.isDay,
    required this.ground,
    required this.wall,
    required this.royalLight,
    required this.tyrianLight,
    required this.giltLight,
    required this.ink,
    required this.inkBody,
    required this.inkMuted,
    required this.hairline,
  });

  final bool isDay;
  final Color ground;
  final Color wall;
  final Color royalLight;
  final Color tyrianLight;
  final Color giltLight;
  final Color ink;
  final Color inkBody;
  final Color inkMuted;
  final Color hairline;

  static const night = GalleryColors(
    isDay: false,
    ground: Color(0xFF0B0A1C),
    wall: Color(0xFF16123A),
    royalLight: Color(0xFFA8B9FF),
    tyrianLight: Color(0xFFCDB3EE),
    giltLight: Color(0xFFE2C57F),
    ink: Color(0xFFF3EEE3),
    inkBody: Color(0xFFD6D0EA),
    inkMuted: Color(0xFFA9A3C4),
    hairline: Color(0x40CDB3EE),
  );

  static const day = GalleryColors(
    isDay: true,
    ground: Color(0xFFFAF7F0),
    wall: Color(0xFFF3EEE3),
    royalLight: Color(0xFF1F3A93),
    tyrianLight: Color(0xFF4B1F5E),
    giltLight: Color(0xFF7A5A1E),
    ink: Color(0xFF1C1830),
    inkBody: Color(0xFF403A5C),
    inkMuted: Color(0xFF575170),
    hairline: Color(0x261C1830),
  );

  /// Room titles are `ink` on night walls and `royal` on day walls.
  Color get title => isDay ? Palette.royal : ink;

  /// Eyebrow labels: `gilt-light` at night, `tyrian` by day (Chronicle, Journal).
  Color get eyebrow => isDay ? Palette.tyrian : giltLight;

  @override
  GalleryColors copyWith() => this;

  @override
  GalleryColors lerp(GalleryColors? other, double t) =>
      other == null || t < .5 ? this : other;
}

extension GalleryContext on BuildContext {
  GalleryColors get g => Theme.of(this).extension<GalleryColors>()!;
}

abstract final class Space {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 16.0;
  static const s4 = 24.0;
  static const s5 = 40.0;
  static const s6 = 64.0;
  static const s7 = 96.0;
}

abstract final class Shadows {
  static const frame = [BoxShadow(offset: Offset(0, 40), blurRadius: 80, color: Color(0x99050314))];
  static const frameHover = [BoxShadow(offset: Offset(0, 60), blurRadius: 110, color: Color(0xB8050314))];
  static const frameDay = [BoxShadow(offset: Offset(0, 30), blurRadius: 60, color: Color(0x401C1830))];
  static const placard = [BoxShadow(offset: Offset(0, 12), blurRadius: 28, color: Color(0x73050314))];
  static const lamp = [BoxShadow(offset: Offset(0, 8), blurRadius: 32, color: Color(0x8CFFD68C))];
  static const letter = [BoxShadow(offset: Offset(0, 40), blurRadius: 80, color: Color(0x80050314))];
}

abstract final class Fonts {
  static const display = 'Montserrat Alternates';
  static const body = 'Montserrat';
  static const mono = 'JetBrains Mono';
}

/// Type styles from tokens.json. Colours are left to the caller.
abstract final class T {
  static TextStyle display(double size, {FontWeight weight = FontWeight.w600, double height = 1, Color? color}) =>
      TextStyle(fontFamily: Fonts.display, fontSize: size, fontWeight: weight, height: height, color: color);

  static TextStyle body(double size, {double height = 1.65, Color? color, FontWeight weight = FontWeight.w400, bool italic = false}) =>
      TextStyle(
        fontFamily: Fonts.body,
        fontSize: size,
        height: height,
        color: color,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  /// Mono label: uppercase is applied by [Mono], tracking 0.16em.
  static TextStyle mono({double size = 12, Color? color, double tracking = .16, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
        fontFamily: Fonts.mono,
        fontSize: size,
        height: 1.4,
        letterSpacing: size * tracking,
        fontWeight: weight,
        color: color,
      );

  static TextStyle code({Color? color}) => TextStyle(fontFamily: Fonts.mono, fontSize: 14, height: 1.8, color: color);

  static final placardTitle = display(17, height: 1.3, color: Palette.placardInk);
}

/// Layout breakpoints, used everywhere instead of per-file numbers.
abstract final class Breakpoints {
  static const compact = 720.0;
  static const wide = 1100.0;
}

extension ScreenSize on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  bool get isCompact => width < Breakpoints.compact;
  bool get isWide => width >= Breakpoints.wide;

  /// Room side gutter: space-5 desktop, space-3 mobile.
  double get gutter => isCompact ? Space.s3 : Space.s5;

  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}

ThemeData buildTheme(GalleryColors g) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: g.isDay ? Brightness.light : Brightness.dark,
    fontFamily: Fonts.body,
    scaffoldBackgroundColor: g.wall,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.royal,
      brightness: g.isDay ? Brightness.light : Brightness.dark,
      primary: Palette.royalAction,
      onPrimary: Colors.white,
      secondary: Palette.tyrianAction,
      surface: g.wall,
      onSurface: g.ink,
    ),
    extensions: [g],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: Fonts.body, bodyColor: g.ink, displayColor: g.ink),
    focusColor: Palette.royalAction.withValues(alpha: .25),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Palette.royalAction,
      selectionColor: Palette.royalAction.withValues(alpha: .3),
    ),
  );
}
