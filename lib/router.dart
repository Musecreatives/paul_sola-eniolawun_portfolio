import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'rooms/foyer.dart';
import 'rooms/not_found.dart';
import 'theme/tokens.dart';
import 'widgets/gallery.dart';

CustomTransitionPage<void> _page(GoRouterState s, Widget child) => CustomTransitionPage(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, anim, _, child) => context.reduceMotion
          ? child
          : FadeTransition(opacity: CurvedAnimation(parent: anim, curve: kEase), child: child),
    );

GoRoute _route(String path, Widget Function(GoRouterState s) build) =>
    GoRoute(path: path, pageBuilder: (_, s) => _page(s, build(s)));

final router = GoRouter(
  errorPageBuilder: (_, s) => _page(s, const NotFoundRoom()),
  routes: [
    _route('/', (_) => const FoyerPage()),
  ],
);
