import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/gallery.dart';
import 'kit.dart';

class _Overview {
  _Overview(this.published, this.drafts, this.unread, this.pending, this.recent, this.letters);
  final int published, drafts, unread, pending;
  final List<RecordModel> recent, letters;
}

/// Counts, recent writing, the latest letters and quick add.
class AdminOverview extends StatefulWidget {
  const AdminOverview({super.key});

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
  late Future<_Overview> _load = _fetch();
  final _search = TextEditingController();
  String _query = '';
  Future<List<(String, String, String)>>? _results;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<_Overview> _fetch() async {
    final pb = Curator.pb!;
    Future<int> count(String c, String filter) async => (await pb.collection(c).getList(perPage: 1, filter: filter)).totalItems;
    refreshBadges();
    final r = await Future.wait<Object>([
      count('posts', 'status = "published"'),
      count('posts', 'status = "draft"'),
      count('letters', 'read = false'),
      count('visitor_notes', 'approved = false'),
      pb.collection('posts').getList(perPage: 5, sort: '-updated'),
      pb.collection('letters').getList(perPage: 2, sort: '-created', filter: 'read = false'),
    ]);
    return _Overview(r[0] as int, r[1] as int, r[2] as int, r[3] as int, (r[4] as ResultList<RecordModel>).items,
        (r[5] as ResultList<RecordModel>).items);
  }

  /// Title search across entries, works and roles.
  Future<List<(String, String, String)>> _find(String q) async {
    final pb = Curator.pb!;
    final f = q.replaceAll('"', r'\"');
    final r = await Future.wait([
      pb.collection('posts').getList(perPage: 8, filter: 'title ~ "$f" || body ~ "$f"'),
      pb.collection('works').getList(perPage: 8, filter: 'title ~ "$f" || summary ~ "$f"'),
      pb.collection('roles').getList(perPage: 8, filter: 'role ~ "$f" || org ~ "$f"'),
    ]);
    return [
      for (final p in r[0].items) ('Journal', p.getStringValue('title'), '/admin/journal/${p.id}'),
      for (final w in r[1].items) ('Works', w.getStringValue('title'), '/admin/works?id=${w.id}'),
      for (final x in r[2].items) ('Chronicle', '${x.getStringValue('role')} · ${x.getStringValue('org')}', '/admin/chronicle?id=${x.id}'),
    ];
  }

  String get _greeting {
    final h = DateTime.now().hour;
    final part = h < 12 ? 'morning' : (h < 18 ? 'afternoon' : 'evening');
    return 'Good $part, ${Curator.firstName}';
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.width < 1100;
    return AdminShell(
      current: '/admin/overview',
      child: FutureBuilder(
        future: _load,
        builder: (context, snap) {
          if (snap.hasError) return AdmMessage(explain(snap.error!), retry: () => setState(() => _load = _fetch()));
          final o = snap.data;
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: context.isCompact ? 16 : 40, vertical: 32),
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 16,
                spacing: 24,
                children: [
                  AdmHeading(eyebrow: 'Overview', title: _greeting),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 320,
                        child: GalleryField(
                          label: 'Search content',
                          hideLabel: true,
                          hint: 'Search entries, works, roles…',
                          controller: _search,
                          onSubmit: () => setState(() {
                            _query = _search.text.trim();
                            _results = _query.isEmpty ? null : _find(_query);
                          }),
                        ),
                      ),
                      GalleryButton(label: '+ New entry', height: 48, fontSize: 15, onPressed: () => context.go('/admin/journal/new')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _Counts(o),
              const SizedBox(height: 28),
              if (_results != null) ...[
                _SearchResults(query: _query, results: _results!, onClear: () => setState(() {
                      _search.clear();
                      _results = null;
                    })),
                const SizedBox(height: 20),
              ],
              if (compact)
                Column(spacing: 20, crossAxisAlignment: CrossAxisAlignment.stretch, children: [_Recent(o), _Letters(o), const _QuickAdd()])
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Expanded(flex: 3, child: _Recent(o)),
                    Expanded(flex: 2, child: Column(spacing: 20, crossAxisAlignment: CrossAxisAlignment.stretch, children: [_Letters(o), const _QuickAdd()])),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Counts extends StatelessWidget {
  const _Counts(this.o);
  final _Overview? o;

  @override
  Widget build(BuildContext context) {
    Widget card(String label, int? n, Color c) => AdmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Mono(label, color: Adm.muted),
              Text(n == null ? '…' : '$n', style: T.display(36, height: 1.1, color: c)),
            ],
          ),
        );
    final cards = [
      card('Published entries', o?.published, Palette.royal),
      card('Drafts', o?.drafts, Palette.royal),
      card('Unread letters', o?.unread, Palette.tyrian),
      card('Notes awaiting approval', o?.pending, Palette.tyrian),
    ];
    return AutoGrid(minWidth: 200, gap: 16, maxColumns: 4, children: cards);
  }
}

class _Recent extends StatelessWidget {
  const _Recent(this.o);
  final _Overview? o;

  @override
  Widget build(BuildContext context) => AdmCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Palette.admLine))),
              child: Row(children: [const Expanded(child: CardTitle('Recent writing')), AdmLink('All entries', onTap: () => context.go('/admin/journal'))]),
            ),
            if (o == null)
              const Padding(padding: EdgeInsets.all(20), child: LinearProgressIndicator(color: Palette.royalAction))
            else if (o!.recent.isEmpty)
              Padding(padding: const EdgeInsets.all(20), child: Text('Nothing written yet.', style: T.body(14, color: Adm.muted)))
            else
              for (final p in o!.recent)
                AdmRow(
                  onTap: () => context.go('/admin/journal/${p.id}'),
                  label: 'Edit ${p.getStringValue('title')}',
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(child: Text(p.getStringValue('title').isEmpty ? '[Untitled entry]' : p.getStringValue('title'), style: T.body(15, height: 1.4, color: Adm.ink, weight: FontWeight.w500))),
                      if (!context.isCompact)
                        SizedBox(width: 120, child: Mono(relativeTime(DateTime.tryParse(p.getStringValue('updated'))), color: Adm.muted)),
                      SizedBox(width: 110, child: Align(alignment: Alignment.centerLeft, child: Chip2.status(p.getStringValue('status')))),
                    ],
                  ),
                ),
          ],
        ),
      );
}

class _Letters extends StatelessWidget {
  const _Letters(this.o);
  final _Overview? o;

  @override
  Widget build(BuildContext context) => AdmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Row(children: [const Expanded(child: CardTitle('Letters')), AdmLink('All letters', onTap: () => context.go('/admin/letters'))]),
            if (o != null && o!.letters.isEmpty) Text('No unread letters.', style: T.body(14, color: Adm.muted)),
            for (final l in o?.letters ?? const <RecordModel>[])
              AdmRow(
                padding: const EdgeInsets.symmetric(vertical: 6),
                onTap: () => context.go('/admin/letters?id=${l.id}'),
                label: 'Letter from ${l.getStringValue('name')}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      children: [
                        Semantics(
                          label: 'Unread',
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Palette.progressEnd),
                          ),
                        ),
                        Expanded(
                          child: Text('${l.getStringValue('name')} · ${l.getStringValue('purpose')}',
                              style: T.body(14, height: 1.4, color: Adm.ink, weight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    Text(l.getStringValue('message').split('\n').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.body(13, height: 1.4, color: Adm.muted)),
                  ],
                ),
              ),
          ],
        ),
      );
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('+ Journal entry', '/admin/journal/new'),
      ('+ Role', '/admin/chronicle?new=1'),
      ('+ Work', '/admin/works?new=1'),
      ('+ Certificate', '/admin/certificates?new=1'),
      ('+ Collection piece', '/admin/collection?new=1'),
      ('Update Now placard', '/admin/now'),
    ];
    return AdmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const CardTitle('Quick add'),
          AutoGrid(
            minWidth: 150,
            gap: 10,
            maxColumns: 2,
            children: [
              for (final (label, path) in items)
                AdmRow(
                  onTap: () => context.go(path),
                  padding: const EdgeInsets.all(12),
                  child: Text(label, style: T.body(14, height: 1.3, color: Palette.royal, weight: FontWeight.w500)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.query, required this.results, required this.onClear});
  final String query;
  final Future<List<(String, String, String)>> results;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AdmCard(
        padding: EdgeInsets.zero,
        child: FutureBuilder(
          future: results,
          builder: (context, snap) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(children: [Expanded(child: CardTitle('Results for “$query”')), AdmLink('Clear', onTap: onClear)]),
              ),
              if (snap.hasError) Padding(padding: const EdgeInsets.all(20), child: Text(explain(snap.error!), style: T.body(14, color: Adm.danger))),
              if (snap.hasData && snap.data!.isEmpty) Padding(padding: const EdgeInsets.all(20), child: Text('Nothing matches.', style: T.body(14, color: Adm.muted))),
              for (final (room, title, path) in snap.data ?? const <(String, String, String)>[])
                AdmRow(
                  onTap: () => context.go(path),
                  child: Row(spacing: 16, children: [SizedBox(width: 100, child: Mono(room, color: Palette.tyrian)), Expanded(child: Text(title, style: T.body(15, height: 1.4, color: Adm.ink)))]),
                ),
            ],
          ),
        ),
      );
}
