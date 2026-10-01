import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muse_creatives_portfolio/app.dart';
import 'package:muse_creatives_portfolio/data/api.dart';
import 'package:muse_creatives_portfolio/data/store.dart';
import 'package:muse_creatives_portfolio/router.dart';
import 'package:pocketbase/pocketbase.dart';

/// An unsigned JWT that expires far in the future; enough for authStore.isValid.
String _token() {
  String b64(Map<String, dynamic> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${b64({'alg': 'HS256'})}.${b64({'exp': 4102444800, 'id': 'cur1', 'type': 'auth'})}.sig';
}

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

http.Response _page(List<Map<String, dynamic>> items) =>
    _json({'page': 1, 'perPage': 500, 'totalItems': items.length, 'totalPages': 1, 'items': items});

final _roles = [
  for (final (i, r) in const [
    ('VP of Engineering', 'Synkkafrica Ltd', 'Jun 2025 – now'),
    ('Co-Founder · COO', 'Innovated Digital', 'Apr 2025 – now'),
    ('Frontend Developer', 'RapidRobo Ltd', 'Feb – Apr 2025'),
  ].indexed)
    {'id': 'r$i', 'collectionId': 'roles', 'collectionName': 'roles', 'role': r.$1, 'org': r.$2, 'dates': r.$3, 'visible': true, 'order': i + 1, 'highlights': <String>[]},
];

final _posts = [
  {
    'id': 'p1',
    'collectionId': 'posts',
    'collectionName': 'posts',
    'title': 'Stoicism on call',
    'slug': 'stoicism-on-call',
    'status': 'draft',
    'category': 'Engineering',
    'body': 'Every system eventually wakes someone at night.\n\n## The dichotomy of control',
    'tags': ['stoicism'],
    'cover_painting': 'death_of_socrates',
    'updated': '2026-09-30 10:00:00.000Z',
  },
];

Future<void> _boot(WidgetTester tester, String path, {bool signedIn = true, Size size = const Size(1440, 1000)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final pb = PocketBase('http://cms.test', httpClientFactory: () => MockClient((req) async {
        final seg = req.url.pathSegments;
        if (seg.length >= 4 && seg[3] == 'records') {
          final rows = switch (seg[2]) { 'roles' => _roles, 'posts' => _posts, _ => <Map<String, dynamic>>[] };
          if (seg.length == 5) return _json(rows.firstWhere((r) => r['id'] == seg[4]));
          return _page(rows);
        }
        return _json({'message': 'not found'}, 404);
      }));
  if (signedIn) pb.authStore.save(_token(), RecordModel({'id': 'cur1', 'collectionName': 'curators', 'email': 'paul@example.com'}));
  pocketBaseForTesting = pb;
  addTearDown(() => pocketBaseForTesting = null);
  final bundle = await tester.runAsync(ContentStore.loadBundled);
  await tester.pumpWidget(Content(store: ContentStore(bundle!), child: const CollectionApp()));
  router.go(path);
  await _settle(tester);
}

/// Lets the mock HTTP calls (real futures) finish between frames. Progress
/// indicators animate forever, so pumpAndSettle can't be used.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('signed-out visitors get the curator entrance', (tester) async {
    await _boot(tester, '/admin/overview', signedIn: false);
    expect(find.text("Curator's entrance"), findsOneWidget);
    expect(find.text('Enter the office'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('entrance fits a phone', (tester) async {
    await _boot(tester, '/admin', signedIn: false, size: const Size(375, 812));
    expect(find.text("Curator's entrance"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overview shows counts, recent writing and quick add', (tester) async {
    await _boot(tester, '/admin/overview');
    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('Recent writing'), findsOneWidget);
    expect(find.text('Stoicism on call'), findsOneWidget);
    expect(find.text('+ Journal entry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chronicle manager lists roles and opens the drawer', (tester) async {
    await _boot(tester, '/admin/chronicle');
    expect(find.text('VP of Engineering'), findsOneWidget);
    expect(find.text('Drag rows to reorder · order on the site follows this list'), findsOneWidget);
    await tester.tap(find.text('VP of Engineering'));
    await _settle(tester);
    expect(find.text('Edit role'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manager works on a phone', (tester) async {
    await _boot(tester, '/admin/chronicle', size: const Size(375, 812));
    expect(find.text('VP of Engineering'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('journal editor shows the live preview', (tester) async {
    await _boot(tester, '/admin/journal/p1');
    expect(find.text('LIVE PREVIEW'), findsOneWidget);
    // Title in the field and in the preview; heading rendered from Markdown.
    expect(find.text('Stoicism on call'), findsNWidgets(2));
    expect(find.text('The dichotomy of control'), findsOneWidget);
    expect(find.text('Publish'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
