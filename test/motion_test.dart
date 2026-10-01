import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muse_creatives_portfolio/widgets/motion.dart';
import 'package:visibility_detector/visibility_detector.dart';

Widget _app(Widget child, {bool reduce = false}) => MediaQuery(
      data: MediaQueryData(size: const Size(800, 600), disableAnimations: reduce),
      child: Directionality(textDirection: TextDirection.ltr, child: Center(child: child)),
    );

double _opacityOf(WidgetTester tester, Finder f) {
  var o = 1.0;
  for (final e in find.ancestor(of: f, matching: find.byType(Opacity)).evaluate()) {
    o *= (e.widget as Opacity).opacity;
  }
  for (final e in find.ancestor(of: f, matching: find.byType(FadeTransition)).evaluate()) {
    o *= (e.widget as FadeTransition).opacity.value;
  }
  return o;
}

void main() {
  setUp(() => VisibilityDetectorController.instance.updateInterval = Duration.zero);

  testWidgets('Rise starts hidden, then rises in with its stagger', (tester) async {
    await tester.pumpWidget(_app(const Rise(step: 2, child: Text('placard'))));
    expect(_opacityOf(tester, find.text('placard')), 0);
    await tester.pump(); // visibility reported
    await tester.pump(const Duration(milliseconds: 160)); // 2 × 80ms stagger
    await tester.pump(const Duration(milliseconds: 950));
    expect(_opacityOf(tester, find.text('placard')), 1);
  });

  testWidgets('reduced motion shows everything at rest with no tickers', (tester) async {
    await tester.pumpWidget(_app(
      const Column(children: [
        Rise(child: Text('a')),
        FadeIn(child: Text('b')),
        DrawIn(child: Text('c')),
        LampFlicker(child: Text('d')),
        SizedBox(width: 100, height: 100, child: Drift(child: Text('e'))),
        Tilt(child: Text('f')),
      ]),
      reduce: true,
    ));
    for (final t in 'abcdef'.split('')) {
      expect(_opacityOf(tester, find.text(t)), 1, reason: t);
    }
    expect(find.byType(VisibilityDetector), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('lamp flickers on once and stays lit', (tester) async {
    await tester.pumpWidget(_app(const LampFlicker(child: Text('lamp'))));
    expect(_opacityOf(tester, find.text('lamp')), 0);
    await tester.pump(const Duration(milliseconds: 1700));
    expect(_opacityOf(tester, find.text('lamp')), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('paintings drift while on screen', (tester) async {
    await tester.pumpWidget(_app(const SizedBox(width: 200, height: 100, child: Drift(child: Text('art')))));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(_app(const SizedBox()));
  });
}
