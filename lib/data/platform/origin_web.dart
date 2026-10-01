import 'package:web/web.dart' as web;

/// The API lives on the same origin as the site (nginx proxies /api/).
String? siteOrigin() => web.window.location.origin;
