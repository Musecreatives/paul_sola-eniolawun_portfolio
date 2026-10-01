import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'data/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final store = ContentStore(await ContentStore.loadBundled());
  runApp(Content(store: store, child: const CollectionApp()));
}
