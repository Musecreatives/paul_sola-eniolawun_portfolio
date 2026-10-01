import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muse_creatives_portfolio/data/api.dart';
import 'package:muse_creatives_portfolio/data/store.dart';
import 'package:pocketbase/pocketbase.dart';

http.Response _page(List<Map<String, dynamic>> items) => http.Response(
      jsonEncode({'page': 1, 'perPage': 200, 'totalItems': items.length, 'totalPages': 1, 'items': items}),
      200,
      headers: {'content-type': 'application/json'},
    );

GalleryApi _api(Future<http.Response> Function(http.Request) handler) =>
    GalleryApi(PocketBase('http://cms.test', httpClientFactory: () => MockClient(handler)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps records to the bundled JSON shape', () async {
    final api = _api((req) async {
      final c = req.url.pathSegments[2];
      return switch (c) {
        'works' => _page([
            {'id': 'w1', 'collectionId': 'cw', 'collectionName': 'works', 'slug': 'brainplay', 'title': 'BrainPlay', 'images': ['a.webp'], 'visible': true},
          ]),
        'roles' => _page([
            {'id': 'r1', 'role': 'Lead', 'linked_work': 'w1', 'visible': true},
          ]),
        'collection_items' => _page([
            {'id': 'c1', 'collectionId': 'cc', 'collectionName': 'collection_items', 'title': 'Athens', 'painting': 'school_of_athens', 'image': ''},
          ]),
        _ => http.Response('{"message":"down"}', 500),
      };
    });
    final out = await api.fetchPublic();
    expect(out['works'][0]['images'], ['http://cms.test/api/files/cw/w1/a.webp']);
    expect(out['roles'][0]['linked_work'], 'brainplay');
    expect(out['collection_items'][0]['image'], 'school_of_athens');
    // Failed collections are left out so the bundled copy stays.
    expect(out.containsKey('certificates'), isFalse);
    expect(out.containsKey('posts'), isFalse);
  });

  test('store keeps bundled content when the API is down', () async {
    final bundled = await ContentStore.loadBundled();
    final store = ContentStore(bundled, api: _api((_) async => http.Response('down', 503)));
    final before = store.data.works.length;
    await store.refresh();
    expect(store.live, isFalse);
    expect(store.data.works.length, before);
    await expectLater(store.sendLetter(name: 'a', email: 'a@b.co', purpose: 'p', message: 'm'), throwsA(isA<ContentOffline>()));
  });

  test('store swaps in live collections and keeps the rest bundled', () async {
    final bundled = await ContentStore.loadBundled();
    final store = ContentStore(bundled, api: _api((req) async => req.url.pathSegments[2] == 'now'
        ? _page([
            {'id': 'n1', 'building': 'Something new', 'reading': 'Meditations'},
          ])
        : http.Response('down', 503)));
    await store.refresh();
    expect(store.live, isTrue);
    expect(store.data.now.reading, 'Meditations');
    expect(store.data.works, isNotEmpty);
  });

  test('store without an API refuses to pretend a letter was sent', () async {
    final store = ContentStore(await ContentStore.loadBundled());
    await expectLater(store.subscribe('a@b.co'), throwsA(isA<ContentOffline>()));
  });

  test('rate limiting reads as busy, not offline', () async {
    final store = ContentStore(await ContentStore.loadBundled(), api: _api((_) async => http.Response('{"status":429}', 429)));
    await expectLater(store.signBook(name: 'a', city: '', note: 'hi'), throwsA(isA<ContentBusy>()));
  });

  test('subscribing twice counts as subscribed', () async {
    final api = _api((_) async => http.Response(
        jsonEncode({
          'status': 400,
          'message': 'Failed',
          'data': {
            'email': {'code': 'validation_not_unique', 'message': 'dup'},
          },
        }),
        400));
    await api.subscribe('a@b.co');
  });

  test('apiBaseUrl is null off the web', () => expect(apiBaseUrl(), isNull));
}
