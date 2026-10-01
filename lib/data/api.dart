import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import 'platform/origin_stub.dart' if (dart.library.js_interop) 'platform/origin_web.dart';
import 'platform/session_stub.dart' if (dart.library.js_interop) 'platform/session_web.dart';

/// The PocketBase base URL: `--dart-define=PB_URL=...` wins (local dev),
/// otherwise the site's own origin on the web, where nginx proxies `/api/`.
/// Null off the web, so tests and desktop runs use the bundled content.
String? apiBaseUrl() {
  const override = String.fromEnvironment('PB_URL');
  if (override.isNotEmpty) return override;
  return siteOrigin();
}

/// The one PocketBase client, shared by the public rooms and the admin.
/// The curator's session is kept in localStorage on the web.
PocketBase? _client;

/// Lets tests hand in a client backed by a mock HTTP server.
@visibleForTesting
set pocketBaseForTesting(PocketBase? pb) => _client = pb;

PocketBase? pocketBase() {
  if (_client != null) return _client;
  final base = apiBaseUrl();
  if (base == null) return null;
  return _client = PocketBase(
    base,
    authStore: AsyncAuthStore(save: (v) async => writeSession(v), initial: readSession(), clear: () async => writeSession('')),
  );
}

/// Talks to the CMS for the public site and turns records into the same JSON
/// shape as `assets/content/content.json`, so [Bundle.fromJson] reads both.
class GalleryApi {
  GalleryApi(this.pb);
  final PocketBase pb;

  static const _timeout = Duration(seconds: 8);

  String fileUrl(RecordModel r, String name) => name.isEmpty ? '' : pb.files.getURL(r, name).toString();

  Future<List<RecordModel>> _all(String collection, {String sort = 'order'}) =>
      pb.collection(collection).getFullList(batch: 200, sort: sort).timeout(_timeout);

  /// Every public collection, in content.json shape. A collection that fails
  /// to load is left out, so the store keeps its bundled copy of it.
  Future<Map<String, dynamic>> fetchPublic() async {
    final out = <String, dynamic>{};
    Future<void> load(String key, Future<Object?> Function() f) async {
      try {
        final v = await f();
        if (v != null) out[key] = v;
      } catch (_) {
        // Keep the bundled copy for this collection.
      }
    }

    final works = <String, String>{}; // id -> slug, for roles.linked_work
    await load('works', () async {
      final rows = await _all('works');
      return [
        for (final r in rows)
          {
            ...r.data,
            'images': [for (final f in _list(r.data['images'])) fileUrl(r, f)],
          },
      ]..forEach((w) => works['${w['id']}'] = '${w['slug']}');
    });
    await Future.wait([
      load('roles', () async => [
            for (final r in await _all('roles')) {...r.data, 'linked_work': works[r.data['linked_work']] ?? ''},
          ]),
      load('certificates', () async => [
            for (final r in await _all('certificates')) {...r.data, 'image': fileUrl(r, '${r.data['image'] ?? ''}')},
          ]),
      load('collection_items', () async => [
            for (final r in await _all('collection_items'))
              {
                ...r.data,
                'image': '${r.data['painting'] ?? ''}'.isNotEmpty ? r.data['painting'] : fileUrl(r, '${r.data['image'] ?? ''}'),
              },
          ]),
      load('posts', () async => [
            for (final r in await _all('posts', sort: '-publish_at,-created')) {...r.data, 'cover': fileUrl(r, '${r.data['cover'] ?? ''}')},
          ]),
      load('visitor_notes', () async => [for (final r in await _all('visitor_notes', sort: '-created')) r.data]),
      load('now', () async {
        final rows = await _all('now', sort: '-updated');
        return rows.isEmpty ? null : rows.first.data;
      }),
    ]);
    return out;
  }

  Future<void> sendLetter({required String name, required String email, required String purpose, required String message, String website = ''}) =>
      pb.collection('letters').create(body: {'name': name, 'email': email, 'purpose': purpose, 'message': message, 'website': website}).timeout(_timeout);

  Future<void> signBook({required String name, required String city, required String note}) =>
      pb.collection('visitor_notes').create(body: {'name': name, 'city': city, 'note': note}).timeout(_timeout);

  /// Subscribing twice is not an error: the address is already on the list.
  Future<void> subscribe(String email) async {
    try {
      await pb.collection('subscribers').create(body: {'email': email}).timeout(_timeout);
    } on ClientException catch (e) {
      final code = (e.response['data'] as Map?)?['email']?['code'];
      if (code != 'validation_not_unique') rethrow;
    }
  }

  static List<String> _list(Object? v) => v is List ? [for (final e in v) '$e'] : v is String && v.isNotEmpty ? [v] : const [];
}
