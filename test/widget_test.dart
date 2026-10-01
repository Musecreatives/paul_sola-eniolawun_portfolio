import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muse_creatives_portfolio/app.dart';
import 'package:muse_creatives_portfolio/data/store.dart';
import 'package:muse_creatives_portfolio/router.dart';
import 'package:muse_creatives_portfolio/shell/menu.dart';

Future<void> boot(WidgetTester tester, String path, {Size size = const Size(1440, 900)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final bundle = await tester.runAsync(ContentStore.loadBundled);
  await tester.pumpWidget(Content(store: ContentStore(bundle!), child: const CollectionApp()));
  router.go(path);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('foyer renders the hero line', (tester) async {
    await boot(tester, '/');
    expect(find.text('Developer'), findsOneWidget);
    expect(find.text('Computer Scientist'), findsOneWidget);
  });

  testWidgets('unknown paths land in Room 404', (tester) async {
    await boot(tester, '/no-such-room');
    expect(find.text('Closed for restoration.'), findsOneWidget);
  });

  testWidgets('menu opens from the labelled button and closes with Esc', (tester) async {
    await boot(tester, '/');
    await tester.tap(find.bySemanticsLabel('Open menu'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuOverlay), findsOneWidget);
    expect(find.textContaining('Correspondence', findRichText: true), findsWidgets);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(MenuOverlay), findsNothing);
  });

  testWidgets('mobile foyer has no overflow', (tester) async {
    await boot(tester, '/', size: const Size(375, 812));
    expect(tester.takeException(), isNull);
  });

  const routes = ['/', '/works', '/works/synkkafrica', '/works/brainplay', '/chronicle', '/certificates', '/about',
    '/journal', '/journal/stoicism-on-call', '/collection', '/correspondence'];
  for (final size in const [Size(375, 812), Size(768, 1024), Size(1280, 800), Size(1440, 900)]) {
    for (final r in routes) {
      testWidgets('$r renders at ${size.width.toInt()}px without layout errors', (tester) async {
        await boot(tester, r, size: size);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
