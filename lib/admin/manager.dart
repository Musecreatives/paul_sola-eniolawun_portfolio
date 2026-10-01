import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../data/paintings.dart';
import '../data/platform/picker_stub.dart' if (dart.library.js_interop) '../data/platform/picker_web.dart';
import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/gallery.dart';
import '../widgets/pressable.dart';
import 'kit.dart';
import 'specs.dart';

/// Table + edit drawer for one collection. Drag rows to reorder.
class AdminManager extends StatefulWidget {
  const AdminManager({super.key, required this.spec, this.initialId, this.startNew = false});
  final CollectionSpec spec;
  final String? initialId;
  final bool startNew;

  @override
  State<AdminManager> createState() => _AdminManagerState();
}

class _AdminManagerState extends State<AdminManager> {
  List<RecordModel>? _rows;
  Object? _error;
  String _filter = '';
  String? _selected;
  bool _creating = false;
  String? _notice;

  CollectionSpec get spec => widget.spec;
  RecordService get _col => Curator.pb!.collection(spec.collection);

  @override
  void initState() {
    super.initState();
    _selected = widget.initialId;
    _creating = widget.startNew;
    _load();
  }

  @override
  void didUpdateWidget(AdminManager old) {
    super.didUpdateWidget(old);
    if (old.spec != spec) {
      _rows = null;
      _selected = widget.initialId;
      _creating = widget.startNew;
      _filter = '';
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final rows = await _col.getFullList(sort: spec.sort, batch: 500);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _error = null;
        if (spec.single && rows.isNotEmpty && !_creating) _selected ??= rows.first.id;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  List<RecordModel> get _visible {
    final rows = _rows ?? const [];
    if (_filter.isEmpty) return rows;
    final q = _filter.toLowerCase();
    return rows.where((r) => spec.columns.any((c) => c.cell(r).toLowerCase().contains(q))).toList();
  }

  Future<void> _reorder(int from, int to) async {
    final rows = [..._rows!];
    rows.insert(to, rows.removeAt(from));
    setState(() => _rows = rows);
    try {
      await Future.wait([
        for (final (i, r) in rows.indexed)
          if (r.getIntValue('order') != i + 1) _col.update(r.id, body: {'order': i + 1}).then((u) => r.data['order'] = i + 1),
      ]);
      _say('Order saved. The site follows this list.');
    } catch (e) {
      _say(explain(e));
      _load();
    }
  }

  Future<void> _toggle(RecordModel r, bool v) async {
    final key = spec.toggle!;
    setState(() => r.data[key] = v);
    try {
      await _col.update(r.id, body: {key: v});
      refreshBadges();
    } catch (e) {
      setState(() => r.data[key] = !v);
      _say(explain(e));
    }
  }

  void _setFilter(String v) => setState(() => _filter = v.trim());

  void _say(String m) {
    if (mounted) setState(() => _notice = m);
  }

  void _open(RecordModel r) {
    if (spec.rowsOpenEditor) {
      context.go('${spec.path}/${r.id}');
      return;
    }
    setState(() {
      _selected = r.id;
      _creating = false;
    });
  }

  void _close() => setState(() {
        _selected = null;
        _creating = false;
      });

  void _add() {
    if (spec.rowsOpenEditor) {
      context.go('${spec.path}/new');
      return;
    }
    setState(() {
      _selected = null;
      _creating = true;
    });
  }

  RecordModel? get _current => _rows?.where((r) => r.id == _selected).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final narrow = context.width < 900;
    final editing = _creating || _current != null;
    final drawer = editing
        ? RecordEditor(
            key: ValueKey('${spec.collection}/${_selected ?? 'new'}'),
            spec: spec,
            record: _creating ? null : _current,
            nextOrder: (_rows?.length ?? 0) + 1,
            onClose: spec.single ? null : _close,
            onSaved: (r) {
              setState(() {
                _creating = false;
                _selected = r.id;
              });
              _load();
              refreshBadges();
            },
            onDeleted: () {
              _close();
              _load();
              refreshBadges();
            },
          )
        : null;
    final table = _Table(this);
    return AdminShell(
      current: spec.path,
      drawer: narrow ? null : drawer,
      child: narrow && drawer != null ? drawer : table,
    );
  }
}

class _Table extends StatelessWidget {
  const _Table(this.s);
  final _AdminManagerState s;

  @override
  Widget build(BuildContext context) {
    final spec = s.spec;
    final rows = s._visible;
    final canReorder = spec.orderable && s._filter.isEmpty && s._rows != null;
    final pad = context.isCompact ? 16.0 : 32.0;
    final canAdd = spec.canAdd && !(spec.single && (s._rows?.isNotEmpty ?? true));
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 32, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              AdmHeading(eyebrow: spec.eyebrow, title: spec.title),
              if (canAdd) GalleryButton(label: '+ Add ${spec.noun}', height: 46, fontSize: 15, onPressed: s._add),
            ],
          ),
          if (!spec.single)
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: GalleryField(
                    label: 'Filter ${spec.title.toLowerCase()}',
                    hideLabel: true,
                    hint: 'Filter ${spec.title.toLowerCase()}…',
                    onChanged: s._setFilter,
                  ),
                ),
                if (spec.orderable)
                  Text(
                    s._filter.isEmpty ? 'Drag rows to reorder · order on the site follows this list' : 'Clear the filter to reorder',
                    style: T.body(13, height: 1.4, color: Adm.muted),
                  ),
              ],
            ),
          if (s._notice != null) Semantics(liveRegion: true, child: Text(s._notice!, style: T.body(13, height: 1.4, color: Palette.royal))),
          Expanded(
            child: s._error != null
                ? AdmMessage(explain(s._error!), retry: s._load)
                : s._rows == null
                    ? const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(color: Palette.royalAction))
                    : Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Palette.admLine)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HeaderRow(spec: spec, handle: spec.orderable),
                            Expanded(
                              child: rows.isEmpty
                                  ? AdmMessage(s._filter.isEmpty ? 'Nothing here yet.' : 'Nothing matches “${s._filter}”.')
                                  : canReorder
                                      ? ReorderableListView.builder(
                                          buildDefaultDragHandles: false,
                                          itemCount: rows.length,
                                          onReorderItem: s._reorder,
                                          itemBuilder: (context, i) => _DataRow(key: ValueKey(rows[i].id), s: s, r: rows[i], index: i),
                                        )
                                      : ListView.builder(
                                          itemCount: rows.length,
                                          itemBuilder: (context, i) => _DataRow(key: ValueKey(rows[i].id), s: s, r: rows[i], index: i),
                                        ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _cells(BuildContext context, CollectionSpec spec, Widget Function(ColumnSpec c) cell) {
  final compact = context.isCompact;
  final cols = compact ? spec.columns.take(2) : spec.columns;
  return [
    for (final c in cols)
      if (c.width != null && !compact) SizedBox(width: c.width, child: cell(c)) else Expanded(flex: c.flex, child: cell(c)),
  ];
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.spec, required this.handle});
  final CollectionSpec spec;
  final bool handle;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Palette.admLine))),
          child: Row(
            spacing: 12,
            children: [
              if (handle) const SizedBox(width: 28),
              ..._cells(context, spec, (c) => Mono(c.label, color: Adm.muted)),
              if (spec.toggle != null) SizedBox(width: 70, child: Mono(spec.toggleLabel, color: Adm.muted)),
            ],
          ),
        ),
      );
}

class _DataRow extends StatelessWidget {
  const _DataRow({super.key, required this.s, required this.r, required this.index});
  final _AdminManagerState s;
  final RecordModel r;
  final int index;

  @override
  Widget build(BuildContext context) {
    final spec = s.spec;
    final canReorder = spec.orderable && s._filter.isEmpty;
    final unread = spec.unreadDot != null && !r.getBoolValue(spec.unreadDot!);
    final label = spec.columns.map((c) => c.cell(r)).where((t) => t.isNotEmpty).join(', ');
    return AdmRow(
      onTap: () => s._open(r),
      selected: s._selected == r.id,
      label: '${spec.rowsOpenEditor ? 'Edit' : 'Open'} $label',
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          spacing: 12,
          children: [
            if (spec.orderable)
              SizedBox(
                width: 28,
                child: canReorder
                    ? ReorderableDragStartListener(
                        index: index,
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: ExcludeSemantics(child: Text('⋮⋮', style: TextStyle(color: Adm.handle, letterSpacing: -2, fontSize: 16))),
                        ),
                      )
                    : const SizedBox(),
              ),
            ..._cells(context, spec, (c) {
              final v = c.cell(r);
              if (isStatusColumn(c)) return Align(alignment: Alignment.centerLeft, child: v.isEmpty ? const SizedBox() : Chip2.status(v));
              final first = c == spec.columns.first;
              return Row(
                children: [
                  if (first && unread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Palette.progressEnd),
                    ),
                  Expanded(
                    child: c.mono
                        ? Mono(v, color: Adm.muted)
                        : Text(v, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: T.body(14, height: 1.4, color: first ? Adm.ink : Adm.body, weight: first ? FontWeight.w600 : FontWeight.w400)),
                  ),
                ],
              );
            }),
            if (spec.toggle != null)
              SizedBox(
                width: 70,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AdmCheckbox(
                    value: r.getBoolValue(spec.toggle!),
                    label: '${spec.toggleLabel}: $label',
                    onChanged: (v) => s._toggle(r, v),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The edit drawer. Creates when [record] is null.
class RecordEditor extends StatefulWidget {
  const RecordEditor({
    super.key,
    required this.spec,
    required this.record,
    required this.onSaved,
    required this.onDeleted,
    this.onClose,
    this.nextOrder = 1,
  });

  final CollectionSpec spec;
  final RecordModel? record;
  final ValueChanged<RecordModel> onSaved;
  final VoidCallback onDeleted;
  final VoidCallback? onClose;
  final int nextOrder;

  @override
  State<RecordEditor> createState() => _RecordEditorState();
}

class _RecordEditorState extends State<RecordEditor> {
  final _form = GlobalKey<FormState>();
  final _text = <String, TextEditingController>{};
  final _lists = <String, List<TextEditingController>>{};
  final _values = <String, Object?>{};
  final _uploads = <String, List<PickedFile>>{};
  final _removed = <String, List<String>>{};
  final _status = SendStatus();
  List<RecordModel> _relations = const [];
  bool _slugTouched = false;

  CollectionSpec get spec => widget.spec;
  RecordModel? get r => widget.record;

  @override
  void initState() {
    super.initState();
    final d = r?.data ?? const <String, dynamic>{};
    for (final f in spec.fields) {
      final v = d[f.key];
      switch (f.kind) {
        case FieldKind.text || FieldKind.multiline || FieldKind.markdown || FieldKind.readonly:
          _text[f.key] = TextEditingController(text: v?.toString() ?? '');
        case FieldKind.number:
          _text[f.key] = TextEditingController(text: v == null ? (f.key == 'order' ? '${widget.nextOrder}' : '') : '$v');
        case FieldKind.json:
          _text[f.key] = TextEditingController(text: v == null || v == '' ? '' : const JsonEncoder.withIndent('  ').convert(v));
        case FieldKind.list:
          _lists[f.key] = [for (final e in (v is List ? v : const [])) TextEditingController(text: '$e')];
        case FieldKind.toggle:
          _values[f.key] = v is bool ? v : (f.key == 'visible');
        case FieldKind.select:
          _values[f.key] = (v is String && v.isNotEmpty) ? v : f.options.first;
        case FieldKind.relation || FieldKind.painting:
          _values[f.key] = v?.toString() ?? '';
        case FieldKind.image || FieldKind.images:
          _values[f.key] = v is List ? [for (final e in v) '$e'] : (v is String && v.isNotEmpty ? [v] : <String>[]);
      }
    }
    _slugTouched = r != null;
    final from = spec.slugFrom;
    if (from != null && _text['slug'] != null) {
      _text[from]?.addListener(() {
        if (!_slugTouched) _text['slug']!.text = slugify(_text[from]!.text);
      });
    }
    final rel = spec.fields.where((f) => f.kind == FieldKind.relation).firstOrNull;
    if (rel != null) {
      Curator.pb!.collection(rel.relation!).getFullList(sort: 'order').then((v) {
        if (mounted) setState(() => _relations = v);
      }, onError: (_) {});
    }
  }

  @override
  void dispose() {
    for (final c in [..._text.values, for (final l in _lists.values) ...l]) {
      c.dispose();
    }
    _status.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _body() {
    final body = <String, dynamic>{};
    for (final f in spec.fields) {
      switch (f.kind) {
        case FieldKind.readonly:
          break;
        case FieldKind.text || FieldKind.multiline || FieldKind.markdown:
          body[f.key] = _text[f.key]!.text.trim();
        case FieldKind.number:
          final t = _text[f.key]!.text.trim();
          body[f.key] = t.isEmpty ? 0 : num.tryParse(t) ?? 0;
        case FieldKind.json:
          final t = _text[f.key]!.text.trim();
          if (t.isEmpty) {
            body[f.key] = null;
          } else {
            try {
              body[f.key] = jsonDecode(t);
            } on FormatException {
              _status.value = SendState(message: '${f.label} isn\'t valid JSON.');
              return null;
            }
          }
        case FieldKind.list:
          body[f.key] = [for (final c in _lists[f.key]!) if (c.text.trim().isNotEmpty) c.text.trim()];
        case FieldKind.toggle || FieldKind.select || FieldKind.relation || FieldKind.painting:
          body[f.key] = _values[f.key];
        case FieldKind.image:
          if ((_removed[f.key] ?? const []).isNotEmpty && (_uploads[f.key] ?? const []).isEmpty) body[f.key] = '';
        case FieldKind.images:
          final gone = _removed[f.key] ?? const [];
          if (gone.isNotEmpty) body['${f.key}-'] = gone;
      }
    }
    return body;
  }

  List<http.MultipartFile> get _files => [
        for (final f in spec.fields)
          for (final p in _uploads[f.key] ?? const <PickedFile>[])
            http.MultipartFile.fromBytes(f.kind == FieldKind.images ? '${f.key}+' : f.key, p.bytes, filename: p.name),
      ];

  Future<void> _save() async {
    if (_status.value.busy || !_form.currentState!.validate()) return;
    final body = _body();
    if (body == null) return;
    final col = Curator.pb!.collection(spec.collection);
    _status.value = const SendState(busy: true);
    try {
      final saved = r == null ? await col.create(body: body, files: _files) : await col.update(r!.id, body: body, files: _files);
      _status.value = const SendState(ok: true, message: 'Saved.');
      widget.onSaved(saved);
    } catch (e) {
      _status.value = SendState(message: explain(e));
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.white,
        title: Text('Delete this ${spec.noun}?', style: T.display(20, height: 1.3, color: Adm.ink)),
        content: Text('This can\'t be undone.', style: T.body(15, color: Adm.body)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Adm.danger))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Curator.pb!.collection(spec.collection).delete(r!.id);
      widget.onDeleted();
    } catch (e) {
      _status.value = SendState(message: explain(e));
    }
  }

  Future<void> _pick(FieldSpec f) async {
    final p = await pickImage();
    if (p == null) return;
    setState(() {
      if (f.kind == FieldKind.image) {
        _uploads[f.key] = [p];
        _removed[f.key] = [...(_values[f.key] as List<String>)];
      } else {
        (_uploads[f.key] ??= []).add(p);
      }
    });
  }

  Widget _field(FieldSpec f) {
    switch (f.kind) {
      case FieldKind.text || FieldKind.number:
        return GalleryField(
          label: f.label,
          controller: _text[f.key],
          hint: f.hint,
          keyboard: f.kind == FieldKind.number ? TextInputType.number : null,
          validator: f.required ? needs(f.label.toLowerCase()) : null,
          onChanged: f.key == 'slug' ? (_) => _slugTouched = true : null,
        );
      case FieldKind.multiline || FieldKind.markdown || FieldKind.json:
        return GalleryField(
          label: f.label,
          controller: _text[f.key],
          lines: f.kind == FieldKind.multiline ? 3 : 6,
          hint: f.hint,
          textStyle: f.kind == FieldKind.multiline ? null : T.code(color: Adm.ink).copyWith(fontSize: 13),
        );
      case FieldKind.readonly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(f.label.toUpperCase(), style: T.mono(size: 11, tracking: .14, color: Palette.tyrian)),
            SelectableText(_text[f.key]!.text, style: T.body(15, height: 1.6, color: Adm.ink)),
          ],
        );
      case FieldKind.toggle:
        return MergeSemantics(
          child: Row(
            children: [
              AdmCheckbox(value: _values[f.key] as bool, label: f.label, onChanged: (v) => setState(() => _values[f.key] = v)),
              Expanded(child: Text(f.label, style: T.body(14, height: 1.4, color: Adm.ink))),
            ],
          ),
        );
      case FieldKind.select:
        return GallerySelect(label: f.label, value: _values[f.key] as String, options: f.options, onChanged: (v) => setState(() => _values[f.key] = v));
      case FieldKind.relation:
        final options = {'': 'None', for (final w in _relations) w.id: [w.getStringValue('numeral'), w.getStringValue('title')].where((e) => e.isNotEmpty).join(' · ')};
        final value = options.containsKey(_values[f.key]) ? _values[f.key] as String : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            ExcludeSemantics(child: Text(f.label.toUpperCase(), style: T.mono(size: 11, tracking: .14, color: Palette.tyrian))),
            Semantics(
              label: f.label,
              child: DropdownButtonFormField<String>(
                initialValue: value,
                isExpanded: true,
                dropdownColor: Palette.input,
                style: T.body(15, height: 1.4, color: Palette.placardInk),
                decoration: galleryInput(),
                items: [for (final e in options.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                onChanged: (v) => setState(() => _values[f.key] = v ?? ''),
              ),
            ),
          ],
        );
      case FieldKind.painting:
        return PaintingPicker(
          label: f.label,
          value: _values[f.key] as String,
          allowNone: true,
          onChanged: (k) => setState(() => _values[f.key] = k),
        );
      case FieldKind.list:
        final list = _lists[f.key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(f.label.toUpperCase(), style: T.mono(size: 11, tracking: .14, color: Palette.tyrian)),
            for (final (i, c) in list.indexed)
              Row(
                children: [
                  Expanded(child: GalleryField(label: '${f.label} ${i + 1}', hideLabel: true, controller: c)),
                  IconButton(
                    tooltip: 'Remove ${f.label.toLowerCase()} ${i + 1}',
                    onPressed: () => setState(() => list.removeAt(i).dispose()),
                    icon: const Text('×', style: TextStyle(fontSize: 18, color: Adm.muted)),
                  ),
                ],
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: AdmLink('+ Add ${f.label.toLowerCase().replaceAll(RegExp(r's$'), '')}', onTap: () => setState(() => list.add(TextEditingController()))),
            ),
          ],
        );
      case FieldKind.image || FieldKind.images:
        final existing = (_values[f.key] as List<String>).where((n) => !(_removed[f.key] ?? const []).contains(n)).toList();
        final pending = _uploads[f.key] ?? const <PickedFile>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(f.label.toUpperCase(), style: T.mono(size: 11, tracking: .14, color: Palette.tyrian)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in existing)
                  _Thumb(
                    image: Image.network(Curator.pb!.files.getURL(r!, name, thumb: '200x200').toString(), fit: BoxFit.cover),
                    label: name,
                    onRemove: () => setState(() => (_removed[f.key] ??= []).add(name)),
                  ),
                for (final p in pending)
                  _Thumb(image: Image.memory(p.bytes, fit: BoxFit.cover), label: p.name, onRemove: () => setState(() => pending.remove(p))),
                Pressable(
                  onTap: () => _pick(f),
                  label: 'Upload ${f.label.toLowerCase()}',
                  builder: (context, hover, _) => Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: hover ? Palette.admBg : Colors.white, border: Border.all(color: Adm.handle)),
                    child: Text('Upload', style: T.body(12, color: Adm.muted)),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = r == null ? 'New ${spec.noun}' : 'Edit ${spec.noun}';
    final readonly = spec.fields.every((f) => f.kind == FieldKind.readonly);
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          Row(
            children: [
              Expanded(child: Semantics(header: true, child: Text(title, style: T.display(20, height: 1.3, color: Adm.ink)))),
              if (widget.onClose != null)
                IconButton(
                  tooltip: 'Close editor',
                  onPressed: widget.onClose,
                  icon: const Text('×', style: TextStyle(fontSize: 22, color: Adm.ink)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final f in spec.fields) ...[_field(f), const SizedBox(height: 16)],
          if (r != null && spec.extra != null) ...[spec.extra!(context, r!), const SizedBox(height: 16)],
          StatusLine(_status),
          const SizedBox(height: 12),
          Row(
            spacing: 10,
            children: [
              if (!readonly)
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _status,
                    builder: (_, s, _) => GalleryButton(label: s.busy ? 'Saving…' : 'Save', height: 46, fontSize: 15, onPressed: s.busy ? null : _save),
                  ),
                ),
              if (r != null && !spec.single)
                GalleryButton(
                  label: 'Delete',
                  kind: ButtonKind.outline,
                  outlineInk: Adm.danger,
                  outlineBorder: const Color(0xFFE2B8BF),
                  height: 46,
                  fontSize: 15,
                  onPressed: _delete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, required this.label, required this.onRemove});
  final Widget image;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(label: label, image: true, child: image),
            Positioned(
              top: 2,
              right: 2,
              child: Pressable(
                onTap: onRemove,
                label: 'Remove $label',
                builder: (context, hover, _) => Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  color: hover ? Adm.danger : const Color(0xCC1C1830),
                  child: const Text('×', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      );
}

/// A grid of the gallery's paintings. The chosen one gets a 3px royal outline.
class PaintingPicker extends StatelessWidget {
  const PaintingPicker({super.key, required this.label, required this.value, required this.onChanged, this.allowNone = false, this.trailing});
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool allowNone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(label.toUpperCase(), style: T.mono(size: 11, tracking: .14, color: Palette.tyrian)),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final p in Painting.all)
                Pressable(
                  onTap: () => onChanged(p.key),
                  label: '${p.title}${value == p.key ? ', selected' : ''}',
                  builder: (context, hover, _) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: value == p.key ? Palette.royalAction : Colors.transparent, width: 3),
                    ),
                    child: ClipRect(
                      child: Transform.scale(
                        scale: p.key == Painting.boxerAtRest.key ? 1 : 1.3,
                        child: Image.asset(p.asset, fit: BoxFit.cover, alignment: p.align, semanticLabel: p.alt),
                      ),
                    ),
                  ),
                ),
              if (allowNone)
                Pressable(
                  onTap: () => onChanged(''),
                  label: 'No painting${value.isEmpty ? ', selected' : ''}',
                  builder: (context, hover, _) => Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: value.isEmpty ? Palette.royalAction : Adm.handle, width: value.isEmpty ? 3 : 1),
                    ),
                    child: Text('None', style: T.body(12, color: Adm.muted)),
                  ),
                ),
              ?trailing,
            ],
          ),
        ],
      );
}
