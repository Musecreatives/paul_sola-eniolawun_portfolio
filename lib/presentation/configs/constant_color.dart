import 'package:flutter/material.dart';

/// Your app’s Color kpalette
class AppColors {
  AppColors._();

  // ── Neutrals ────────────────────────────────────────────────────────────────
  static const Color kwhite = Colors.white;
  static const Color kblack = Colors.black;
  static const Color kbackground = kblack;

  static final Color kgrey50 = Colors.grey.shade50;
  static final Color kgrey100 = Colors.grey.shade100;
  static final Color kgrey300 = Colors.grey.shade300;
  static final Color kgrey500 = Colors.grey.shade500;
  static final Color kgrey700 = Colors.grey.shade700;
  static const Color kgrey = Colors.grey;

  static const Color kdivider = Colors.white12;
  static const Color kdisabled = Colors.white38;

  // ── Primary & Accent ───────────────────────────────────────────────────────
  static const Color kprimary = Color(0xFF3695E5); // your blue
  static const Color kprimaryLight = Color(0xFF6EB5F7);
  static const Color kprimaryDark = Color(0xFF005AB4);

  static const Color kaccent = Color(0xFF00E676); // e.g. green accent
  static const Color kaccentLight = Color(0xFF5FF5A0);
  static const Color kaccentDark = Color(0xFF00C851);

  // ── Feedback ────────────────────────────────────────────────────────────────
  static const Color ksuccess = Color(0xFF4CAF50);
  static const Color kwarning = Color(0xFFFFA000);
  static const Color kerror = Color(0xFFB00020);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color ktextPrimary = kwhite;
  static const Color ktextSecondary = Colors.white70;
  static const Color ktextHint = Colors.white54;

  // ── Example grouped palettes ───────────────────────────────────────────────
  /// Sidebar/menu Color kswatches
  static List<Color> menuColors = [
    kprimary,
    kgrey500,
    kwarning,
    kdivider,
    kgrey700,
  ];

  /// Tool/icon Color kswatches
  static const List<Color> toolColors = [kaccent, kerror, ksuccess, kwarning];
}
