import 'package:flutter_test/flutter_test.dart';
import 'package:muse_creatives_portfolio/main.dart';
import 'package:muse_creatives_portfolio/widgets/gallery.dart';

void main() {
  testWidgets('app boots with the seal', (tester) async {
    await tester.pumpWidget(const CollectionApp());
    expect(find.byType(Seal), findsOneWidget);
  });
}
