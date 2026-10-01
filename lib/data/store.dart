import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'models.dart';

/// Holds the content the rooms render. Starts with the bundled JSON so the
/// site paints immediately (and still works if the API is down).
class ContentStore extends ChangeNotifier {
  ContentStore(this._data);

  final Bundle _data;
  Bundle get data => _data;

  static Future<Bundle> loadBundled() async =>
      Bundle.fromJson(jsonDecode(await rootBundle.loadString('assets/content/content.json')) as Map<String, dynamic>);

  Future<void> sendLetter({required String name, required String email, required String purpose, required String message}) =>
      throw const ContentOffline();

  Future<void> signBook({required String name, required String city, required String note}) => throw const ContentOffline();

  Future<void> subscribe(String email) => throw const ContentOffline();
}

class ContentOffline implements Exception {
  const ContentOffline();
  @override
  String toString() => 'The gallery office is closed right now.';
}

/// Makes the store available to every room.
class Content extends InheritedNotifier<ContentStore> {
  const Content({super.key, required ContentStore store, required super.child}) : super(notifier: store);

  static ContentStore store(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Content>()!.notifier!;
  static Bundle of(BuildContext context) => store(context).data;
}
