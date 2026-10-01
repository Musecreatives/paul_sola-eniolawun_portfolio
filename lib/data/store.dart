import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pocketbase/pocketbase.dart';

import 'api.dart';
import 'models.dart';

/// Holds the content the rooms render. Starts with the bundled JSON so the
/// site paints immediately, then swaps in the CMS content collection by
/// collection. If the API is down the bundled copy stays.
class ContentStore extends ChangeNotifier {
  ContentStore(Map<String, dynamic> bundled, {this.api})
      : _bundled = bundled,
        _data = Bundle.fromJson(bundled);

  final Map<String, dynamic> _bundled;
  final GalleryApi? api;
  Bundle _data;
  Bundle get data => _data;

  /// True once the CMS answered at least one collection.
  bool live = false;

  static Future<Map<String, dynamic>> loadBundled() async =>
      jsonDecode(await rootBundle.loadString('assets/content/content.json')) as Map<String, dynamic>;

  /// Fetches the public collections. Never throws.
  Future<void> refresh() async {
    final a = api;
    if (a == null) return;
    final fresh = await a.fetchPublic();
    if (fresh.isEmpty) return;
    live = true;
    _data = Bundle.fromJson({..._bundled, ...fresh});
    notifyListeners();
  }

  Future<void> sendLetter({required String name, required String email, required String purpose, required String message, String website = ''}) =>
      _call((a) => a.sendLetter(name: name, email: email, purpose: purpose, message: message, website: website));

  Future<void> signBook({required String name, required String city, required String note}) =>
      _call((a) => a.signBook(name: name, city: city, note: note));

  Future<void> subscribe(String email) => _call((a) => a.subscribe(email));

  Future<void> _call(Future<void> Function(GalleryApi a) f) async {
    final a = api;
    if (a == null) throw const ContentOffline();
    try {
      await f(a);
    } on ClientException catch (e) {
      throw e.statusCode == 429 ? const ContentBusy() : const ContentOffline();
    } catch (_) {
      throw const ContentOffline();
    }
  }
}

class ContentOffline implements Exception {
  const ContentOffline();
  @override
  String toString() => 'The gallery office is closed right now.';
}

class ContentBusy implements Exception {
  const ContentBusy();
  @override
  String toString() => 'Too many requests in a short time.';
}

/// Makes the store available to every room.
class Content extends InheritedNotifier<ContentStore> {
  const Content({super.key, required ContentStore store, required super.child}) : super(notifier: store);

  static ContentStore store(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Content>()!.notifier!;
  static Bundle of(BuildContext context) => store(context).data;
}
