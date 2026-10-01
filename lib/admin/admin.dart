// The Curator's office. Loaded with a deferred import from router.dart, so
// visitors never download it.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import 'editor.dart';
import 'kit.dart';
import 'login.dart';
import 'manager.dart';
import 'overview.dart';
import 'specs.dart';

/// Picks the admin screen for a `/admin...` location. Signed-out visitors
/// always get the entrance.
Widget adminScreen(GoRouterState s) {
  final parts = s.uri.pathSegments.skip(1).toList();
  final q = s.uri.queryParameters;
  Widget screen;
  if (!Curator.signedIn) {
    screen = const AdminLogin();
  } else if (parts.isEmpty || parts.first == 'overview') {
    screen = const AdminOverview();
  } else if (parts.first == 'journal' && parts.length > 1) {
    screen = JournalEditor(key: ValueKey(parts[1]), id: parts[1]);
  } else if (specs[parts.first] case final spec?) {
    screen = AdminManager(key: ValueKey('${parts.first}?${s.uri.query}'), spec: spec, initialId: q['id'], startNew: q['new'] == '1');
  } else {
    screen = const AdminOverview();
  }
  if (Curator.signedIn) refreshBadges();
  // The office is always lit: day palette for Material controls.
  return Theme(data: buildTheme(GalleryColors.day), child: Title(title: "Curator's office · The Collection", color: Palette.royal, child: screen));
}
