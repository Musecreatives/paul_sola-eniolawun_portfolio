// Content models. Field names match the PocketBase collections in
// pb_migrations/ and the bundled fallback in assets/content/content.json.

List<String> _strings(Object? v) => v is List ? v.map((e) => '$e').toList() : const [];
String _s(Map<String, dynamic> j, String k) => (j[k] ?? '').toString();
int _i(Map<String, dynamic> j, String k) => j[k] is num ? (j[k] as num).toInt() : int.tryParse('${j[k]}') ?? 0;
bool _b(Map<String, dynamic> j, String k, [bool or = false]) => j[k] is bool ? j[k] as bool : or;
Map<String, dynamic> _m(Object? v) => v is Map ? v.cast<String, dynamic>() : const {};

class LinkRef {
  const LinkRef(this.label, this.url);
  final String label;
  final String url;
  static List<LinkRef> list(Object? v) =>
      v is List ? [for (final e in v.whereType<Map>()) LinkRef('${e['label'] ?? ''}', '${e['url'] ?? ''}')] : const [];
}

class Work {
  Work(this.j)
      : id = _s(j, 'id'),
        title = _s(j, 'title'),
        slug = _s(j, 'slug'),
        numeral = _s(j, 'numeral'),
        inventory = _s(j, 'inventory'),
        headline = _s(j, 'headline'),
        summary = _s(j, 'summary'),
        lede = _s(j, 'lede'),
        body = _s(j, 'body'),
        medium = _s(j, 'medium'),
        tags = _s(j, 'tags'),
        role = _s(j, 'role'),
        year = _s(j, 'year'),
        dated = _s(j, 'dated'),
        team = _s(j, 'team'),
        platforms = _s(j, 'platforms'),
        links = LinkRef.list(j['links']),
        images = _strings(j['images']),
        featured = _b(j, 'featured'),
        visible = _b(j, 'visible', true),
        order = _i(j, 'order'),
        extra = _m(j['extra']);

  final Map<String, dynamic> j;
  final String id, title, slug, numeral, inventory, headline, summary, lede, body, medium, tags, role, year, dated, team, platforms;
  final List<LinkRef> links;
  final List<String> images;
  final bool featured, visible;
  final int order;

  /// Case-study extras: wall_label, architecture, metrics, gallery.
  final Map<String, dynamic> extra;
}

class Role {
  Role(this.j)
      : id = _s(j, 'id'),
        role = _s(j, 'role'),
        org = _s(j, 'org'),
        location = _s(j, 'location'),
        start = _s(j, 'start'),
        end = _s(j, 'end'),
        current = _b(j, 'current'),
        dates = _s(j, 'dates'),
        year = _s(j, 'year'),
        summary = _s(j, 'summary'),
        highlights = _strings(j['highlights']),
        linkedWork = _s(j, 'linked_work'),
        order = _i(j, 'order'),
        visible = _b(j, 'visible', true);

  final Map<String, dynamic> j;
  final String id, role, org, location, start, end, dates, year, summary, linkedWork;
  final bool current, visible;
  final List<String> highlights;
  final int order;
}

class Certificate {
  Certificate(this.j)
      : id = _s(j, 'id'),
        title = _s(j, 'title'),
        issuer = _s(j, 'issuer'),
        year = _s(j, 'year'),
        image = _s(j, 'image'),
        verifyUrl = _s(j, 'verify_url'),
        status = _s(j, 'status').isEmpty ? 'earned' : _s(j, 'status'),
        progress = _i(j, 'progress'),
        target = _s(j, 'target'),
        order = _i(j, 'order');

  final Map<String, dynamic> j;
  final String id, title, issuer, year, image, verifyUrl, status, target;
  final int progress, order;
  bool get earned => status == 'earned';
}

class CollectionItem {
  CollectionItem(this.j)
      : id = _s(j, 'id'),
        kind = _s(j, 'kind'),
        title = _s(j, 'title'),
        subtitle = _s(j, 'subtitle'),
        image = _s(j, 'image'),
        note = _s(j, 'note'),
        order = _i(j, 'order');

  final Map<String, dynamic> j;
  final String id, kind, title, subtitle, image, note;
  final int order;
}

class NowPlacard {
  NowPlacard(this.j)
      : building = _s(j, 'building'),
        reading = _s(j, 'reading');
  final Map<String, dynamic> j;
  final String building, reading;
}

class Post {
  Post(this.j)
      : id = _s(j, 'id'),
        title = _s(j, 'title'),
        slug = _s(j, 'slug'),
        body = _s(j, 'body'),
        excerpt = _s(j, 'excerpt'),
        category = _s(j, 'category'),
        tags = _strings(j['tags']),
        cover = _s(j, 'cover'),
        coverPainting = _s(j, 'cover_painting'),
        status = _s(j, 'status'),
        publishAt = DateTime.tryParse(_s(j, 'publish_at')),
        dateLabel = _s(j, 'date_label'),
        sample = _b(j, 'sample');

  final Map<String, dynamic> j;
  final String id, title, slug, body, excerpt, category, cover, coverPainting, status;
  final List<String> tags;
  final DateTime? publishAt;

  /// Placeholder date shown for bundled sample posts ("[Date]").
  final String dateLabel;
  final bool sample;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  String get date {
    final d = publishAt;
    if (dateLabel.isNotEmpty || d == null) return dateLabel.isEmpty ? '[Date]' : dateLabel;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// 220 words a minute; "[N]" while the body is a sample.
  String get readTime {
    if (sample) return '[N] min read';
    final words = body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return '${(words / 220).ceil().clamp(1, 999)} min read';
  }
}

class VisitorNote {
  VisitorNote(this.j)
      : name = _s(j, 'name'),
        city = _s(j, 'city'),
        note = _s(j, 'note'),
        created = DateTime.tryParse(_s(j, 'created'));
  final Map<String, dynamic> j;
  final String name, city, note;
  final DateTime? created;
}

/// Everything the public rooms render.
class Bundle {
  Bundle({
    required this.works,
    required this.roles,
    required this.certificates,
    required this.collection,
    required this.now,
    required this.posts,
    required this.notes,
  });

  factory Bundle.fromJson(Map<String, dynamic> j) {
    List<Map<String, dynamic>> rows(String k) => [for (final r in (j[k] as List? ?? const [])) _m(r)];
    int byOrder(dynamic a, dynamic b) => (a.order as int).compareTo(b.order as int);
    return Bundle(
      works: rows('works').map(Work.new).where((w) => w.visible).toList()..sort(byOrder),
      roles: rows('roles').map(Role.new).where((r) => r.visible).toList()..sort(byOrder),
      certificates: rows('certificates').map(Certificate.new).toList()..sort(byOrder),
      collection: rows('collection_items').map(CollectionItem.new).toList()..sort(byOrder),
      now: NowPlacard(_m(j['now'])),
      posts: rows('posts').map(Post.new).toList(),
      notes: rows('visitor_notes').map(VisitorNote.new).toList(),
    );
  }

  final List<Work> works;
  final List<Role> roles;
  final List<Certificate> certificates;
  final List<CollectionItem> collection;
  final NowPlacard now;
  final List<Post> posts;
  final List<VisitorNote> notes;

  Work? work(String slug) => works.where((w) => w.slug == slug).firstOrNull;
  Post? post(String slug) => posts.where((p) => p.slug == slug).firstOrNull;
}
