import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin_gate.dart';
import 'rooms/about.dart';
import 'rooms/case_study.dart';
import 'rooms/certificates.dart';
import 'rooms/chronicle.dart';
import 'rooms/collection.dart';
import 'rooms/correspondence.dart';
import 'rooms/foyer.dart';
import 'rooms/journal.dart';
import 'rooms/journal_post.dart';
import 'rooms/not_found.dart';
import 'rooms/works.dart';
import 'shell/page.dart';
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
    _route('/', (_) => const FoyerPage(below: [Section(child: WorksRoom())])),
    _route('/works', (_) => const WorksPage()),
    _route('/works/:slug', (s) => CaseStudyPage(slug: s.pathParameters['slug']!)),
    _route('/chronicle', (_) => const ChroniclePage()),
    _route('/certificates', (_) => const CertificatesPage()),
    _route('/about', (_) => const AboutPage()),
    _route('/journal', (_) => const JournalPage()),
    _route('/journal/:slug', (s) => JournalPostPage(slug: s.pathParameters['slug']!)),
    _route('/collection', (_) => const CollectionPage()),
    _route('/correspondence', (_) => const CorrespondencePage()),
    // The Curator's office, deferred-loaded.
    _route('/admin', AdminGate.new),
    _route('/admin/:section', AdminGate.new),
    _route('/admin/:section/:id', AdminGate.new),
  ],
);
