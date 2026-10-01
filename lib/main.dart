import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'app.dart';
import 'data/api.dart';
import 'data/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  // Rise-in starts promptly when a frame scrolls into view.
  VisibilityDetectorController.instance.updateInterval = const Duration(milliseconds: 100);
  final pb = pocketBase();
  final store = ContentStore(await ContentStore.loadBundled(), api: pb == null ? null : GalleryApi(pb));
  runApp(Content(store: store, child: const CollectionApp()));
  // Paint the bundled rooms first, then hang the CMS content when it arrives.
  store.refresh();
}
