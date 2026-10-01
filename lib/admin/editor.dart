import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../data/paintings.dart';
import '../data/platform/picker_stub.dart' if (dart.library.js_interop) '../data/platform/picker_web.dart';
import '../rooms/journal.dart' show journalCategories;
import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/gallery.dart';
import '../widgets/icons.dart';
import '../widgets/markdown.dart';
import '../widgets/pressable.dart';
import 'kit.dart';
import 'manager.dart' show PaintingPicker;
import 'specs.dart' show slugify;

const _statuses = ['draft', 'scheduled', 'published'];

/// Markdown editor with a live preview and the entry's settings.
class JournalEditor extends StatefulWidget {
  const JournalEditor({super.key, required this.id});

  /// A record id, or `new`.
  final String id;

  @override
  State<JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<JournalEditor> {
  final _title = TextEditingController();
  final _slug = TextEditingController();
  final _body = TextEditingController();
  final _excerpt = TextEditingController();
  final _publishAt = TextEditingController();
  final _tag = TextEditingController();
  final _bodyFocus = FocusNode();
  final _status = SendStatus();

  RecordModel? _record;
  Object? _error;
  bool _loading = true;
  String _state = 'draft';
  String _category = journalCategories.first;
  List<String> _tags = [];
  String _painting = Painting.deathOfSocrates.key;
  String _coverFile = '';
  PickedFile? _upload;
  bool _removeCover = false;
  bool _slugTouched = false;
  bool _dirty = false;
  bool _previewOnly = false;
  DateTime? _savedAt;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _title.addListener(() {
      if (!_slugTouched) _slug.text = slugify(_title.text);
    });
    for (final c in [_title, _slug, _body, _excerpt, _publishAt]) {
      c.addListener(_touch);
    }
    _tick = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && _savedAt != null) setState(() {});
    });
    _load();
  }

  void _touch() {
    if (!_dirty && !_loading) setState(() => _dirty = true);
  }

  Future<void> _load() async {
    if (widget.id == 'new') {
      setState(() => _loading = false);
      return;
    }
    try {
      final r = await Curator.pb!.collection('posts').getOne(widget.id);
      _record = r;
      _title.text = r.getStringValue('title');
      _slug.text = r.getStringValue('slug');
      _slugTouched = true;
      _body.text = r.getStringValue('body');
      _excerpt.text = r.getStringValue('excerpt');
      _state = _statuses.contains(r.getStringValue('status')) ? r.getStringValue('status') : 'draft';
      final c = r.getStringValue('category');
      _category = journalCategories.contains(c) ? c : journalCategories.first;
      _tags = r.getListValue<String>('tags');
      _painting = r.getStringValue('cover_painting');
      _coverFile = r.getStringValue('cover');
      final at = DateTime.tryParse(r.getStringValue('publish_at'));
      _publishAt.text = at == null ? '' : _fmt(at.toLocal());
      _savedAt = DateTime.tryParse(r.getStringValue('updated'));
    } catch (e) {
      _error = e;
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _dirty = false;
      });
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    for (final c in [_title, _slug, _body, _excerpt, _publishAt, _tag]) {
      c.dispose();
    }
    _bodyFocus.dispose();
    _status.dispose();
    super.dispose();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _fmt(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';

  /// Parses "YYYY-MM-DD HH:MM" in local time.
  DateTime? get _when {
    final t = _publishAt.text.trim();
    if (t.isEmpty) return null;
    return DateTime.tryParse(t.replaceFirst(' ', 'T'));
  }

  int get _words => _body.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  Future<void> _save({String? as}) async {
    if (_status.value.busy) return;
    if (_title.text.trim().isEmpty || _slug.text.trim().isEmpty) {
      _status.value = const SendState(message: 'Give the entry a title (and a slug) before saving.');
      return;
    }
    if (_publishAt.text.trim().isNotEmpty && _when == null) {
      _status.value = const SendState(message: 'Publish on must look like 2026-10-01 09:00.');
      return;
    }
    var state = as ?? _state;
    var when = _when;
    if (as == 'published') {
      final now = DateTime.now();
      if (when != null && when.isAfter(now)) {
        state = 'scheduled';
      } else {
        when ??= now;
      }
    }
    final body = <String, dynamic>{
      'title': _title.text.trim(),
      'slug': _slug.text.trim(),
      'body': _body.text,
      'excerpt': _excerpt.text.trim(),
      'status': state,
      'category': _category,
      'tags': _tags,
      'cover_painting': _painting,
      'publish_at': when == null ? '' : when.toUtc().toIso8601String(),
      if (_removeCover && _upload == null) 'cover': '',
    };
    final files = [if (_upload case final u?) http.MultipartFile.fromBytes('cover', u.bytes, filename: u.name)];
    final col = Curator.pb!.collection('posts');
    _status.value = const SendState(busy: true);
    try {
      final r = _record == null ? await col.create(body: body, files: files) : await col.update(_record!.id, body: body, files: files);
      final first = _record == null;
      setState(() {
        _record = r;
        _state = state;
        _coverFile = r.getStringValue('cover');
        _upload = null;
        _removeCover = false;
        _publishAt.text = when == null ? '' : _fmt(when);
        _dirty = false;
        _savedAt = DateTime.now();
      });
      _status.value = SendState(ok: true, message: switch (state) {
        'published' => 'Published. It is live at /journal/${r.getStringValue('slug')}.',
        'scheduled' => 'Scheduled for ${_publishAt.text}.',
        _ => 'Draft saved.',
      });
      refreshBadges();
      if (first && mounted) context.go('/admin/journal/${r.id}');
    } catch (e) {
      _status.value = SendState(message: explain(e));
    }
  }

  /// Wraps the selection (or inserts at the cursor) for the toolbar.
  void _wrap(String before, [String after = '', String placeholder = '']) {
    final t = _body.text;
    final sel = _body.selection;
    final start = sel.isValid ? sel.start : t.length;
    final end = sel.isValid ? sel.end : t.length;
    final inner = start == end ? placeholder : t.substring(start, end);
    _body.value = TextEditingValue(
      text: t.replaceRange(start, end, '$before$inner$after'),
      selection: TextSelection(baseOffset: start + before.length, extentOffset: start + before.length + inner.length),
    );
    _bodyFocus.requestFocus();
  }

  /// Starts a block on its own line.
  void _block(String before, [String after = '', String placeholder = '']) {
    final sel = _body.selection;
    final at = sel.isValid ? sel.start : _body.text.length;
    final nl = at > 0 && _body.text[at - 1] != '\n' ? '\n\n' : '';
    _wrap('$nl$before', after, placeholder);
  }

  String get _savedLabel {
    if (_status.value.busy) return 'Saving…';
    if (_dirty) return 'Unsaved changes';
    if (_savedAt == null) return 'Not saved yet';
    return 'Saved ${relativeTime(_savedAt).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: Palette.admBg, body: Center(child: CircularProgressIndicator(color: Palette.royalAction)));
    if (_error != null) {
      return AdminShell(current: '/admin/journal', child: AdmMessage(explain(_error!), retry: () => setState(() {
            _loading = true;
            _error = null;
            _load();
          })));
    }
    final w = context.width;
    final editor = _editorColumn();
    final preview = _previewColumn();
    final settings = _settingsColumn();
    Widget body;
    if (_previewOnly) {
      body = preview;
    } else if (w >= 1200) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: _bordered(editor)),
          Expanded(flex: 5, child: _bordered(preview)),
          SizedBox(width: 340, child: settings),
        ],
      );
    } else if (w >= 800) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: _bordered(editor)), SizedBox(width: 320, child: settings)],
      );
    } else {
      body = ListView(children: [SizedBox(height: 640, child: editor), SizedBox(height: 900, child: settings)]);
    }
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () => _save(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () => _save(),
      },
      child: Scaffold(
        backgroundColor: Palette.admBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_header(), Expanded(child: body)],
          ),
        ),
      ),
    );
  }

  Widget _bordered(Widget child) => DecoratedBox(
        decoration: const BoxDecoration(border: Border(right: BorderSide(color: Palette.admLine))),
        child: child,
      );

  Widget _header() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Palette.admLine))),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 12,
          children: [
            Wrap(
              spacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AdmLink('← Journal', size: 14, onTap: () => context.go('/admin/journal')),
                Chip2.status(_state),
                ValueListenableBuilder(valueListenable: _status, builder: (_, _, _) => Mono(_savedLabel, color: Adm.muted)),
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                GalleryButton(
                  label: _previewOnly ? 'Edit' : 'Preview',
                  kind: ButtonKind.outline,
                  outlineInk: Adm.ink,
                  outlineBorder: const Color(0x4D1C1830),
                  height: 44,
                  fontSize: 14,
                  onPressed: () => setState(() => _previewOnly = !_previewOnly),
                ),
                GalleryButton(label: 'Save draft', kind: ButtonKind.ink, height: 44, fontSize: 14, onPressed: () => _save(as: 'draft')),
                GalleryButton(
                  label: (_when?.isAfter(DateTime.now()) ?? false) ? 'Schedule' : 'Publish',
                  height: 44,
                  fontSize: 14,
                  onPressed: () => _save(as: 'published'),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _tool(String label, Widget child, VoidCallback onTap, {double? width = 36}) => Tooltip(
        message: label,
        child: Pressable(
          onTap: onTap,
          label: label,
          builder: (context, hover, _) => Container(
            width: width,
            height: 36,
            padding: width == null ? const EdgeInsets.symmetric(horizontal: 8) : null,
            alignment: Alignment.center,
            color: hover ? Palette.admBg : Colors.white,
            child: child,
          ),
        ),
      );

  Widget _editorColumn() => Semantics(
        container: true,
        label: 'Editor',
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Semantics(
                label: 'Title',
                textField: true,
                child: TextField(
                  controller: _title,
                  style: T.display(30, height: 1.2, color: Adm.ink),
                  cursorColor: Palette.royalAction,
                  decoration: InputDecoration.collapsed(hintText: 'Title', hintStyle: T.display(30, height: 1.2, color: Adm.handle)),
                ),
              ),
              Row(
                children: [
                  Mono('/journal/', color: Adm.muted),
                  Expanded(
                    child: Semantics(
                      label: 'Slug',
                      textField: true,
                      child: TextField(
                        controller: _slug,
                        onChanged: (_) => _slugTouched = true,
                        style: T.mono(size: 12, color: Palette.royal),
                        cursorColor: Palette.royalAction,
                        decoration: const InputDecoration.collapsed(hintText: 'slug'),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  container: true,
                  label: 'Formatting',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Palette.admLine)),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        _tool('Bold', const Text('B', style: TextStyle(fontWeight: FontWeight.w700, color: Adm.ink)), () => _wrap('**', '**', 'bold')),
                        _tool('Italic', const Text('I', style: TextStyle(fontStyle: FontStyle.italic, color: Adm.ink)), () => _wrap('_', '_', 'italic')),
                        _tool('Heading', const Text('H2', style: TextStyle(fontWeight: FontWeight.w600, color: Adm.ink)), () => _block('## ', '', 'Heading')),
                        _tool('Quote', const Text('“', style: TextStyle(fontSize: 18, color: Adm.ink)), () => _block('> ', '', 'Quote')),
                        _tool('Code block', Text('</>', style: T.mono(size: 12, tracking: 0, color: Adm.ink)), () => _block('```\n', '\n```', 'code')),
                        _tool('Link', const Glyph(GlyphKind.link, size: 16, color: Adm.ink), () => _wrap('[', '](https://)', 'link text')),
                        _tool('Insert image', const Glyph(GlyphKind.image, size: 16, color: Adm.ink), () => _block('![', '](https://)', 'Describe the image')),
                        _tool('Margin note', Text('MARGINALIA', style: T.mono(size: 12, tracking: .06, color: Adm.ink)), () => _block(':::margin\n', '\n:::', 'Side note'),
                            width: null),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Semantics(
                  label: 'Body (Markdown)',
                  textField: true,
                  child: TextField(
                    controller: _body,
                    focusNode: _bodyFocus,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    style: T.code(color: const Color(0xFF2A2545)),
                    cursorColor: Palette.royalAction,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Palette.admLine)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Palette.royalAction, width: 2)),
                      hintText: 'Write in Markdown. :::margin … ::: puts a note in the margin.',
                      hintStyle: T.code(color: Adm.handle),
                    ),
                  ),
                ),
              ),
              Mono('Markdown · $_words words · ${(_words / 220).ceil().clamp(1, 999)} min read', color: Adm.muted),
              StatusLine(_status),
            ],
          ),
        ),
      );

  Widget _cover({double aspect = 21 / 9}) {
    if (_upload case final u?) return AspectRatio(aspectRatio: aspect, child: Image.memory(u.bytes, fit: BoxFit.cover));
    if (_coverFile.isNotEmpty && !_removeCover && _record != null) {
      return ArtImage(src: Curator.pb!.files.getURL(_record!, _coverFile).toString(), alt: 'Cover', aspect: aspect, painting: false);
    }
    final p = Painting.byKey(_painting);
    return ArtImage(src: p.asset, alt: 'Cover: ${p.title}', aspect: aspect, align: p.align);
  }

  Widget _previewColumn() => Semantics(
        container: true,
        label: 'Live preview',
        child: Theme(
          data: buildTheme(GalleryColors.day),
          child: Container(
            color: const Color(0xFFFAF7F0),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: _previewOnly ? (context.width > 900 ? (context.width - 760) / 2 : 28) : 28, vertical: 28),
              children: [
                Mono('Live preview', color: Palette.tyrian),
                const SizedBox(height: 18),
                GiltFrame(small: true, lift: false, shadow: const [BoxShadow(offset: Offset(0, 16), blurRadius: 32, color: Color(0x331C1830))], child: _cover()),
                const SizedBox(height: 18),
                Text(_title.text.isEmpty ? 'Title' : _title.text, style: T.display(26, height: 1.15, color: Adm.ink)),
                const SizedBox(height: 18),
                MarkdownColumn(_body.text, mode: MdMode.preview, gap: 18),
              ],
            ),
          ),
        ),
      );

  Widget _settingsColumn() => Semantics(
        container: true,
        label: 'Entry settings',
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              GallerySelect(
                label: 'Status',
                value: _state,
                options: _statuses,
                onChanged: (v) => setState(() {
                  _state = v;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: 18),
              GalleryField(label: 'Publish on', controller: _publishAt, hint: 'YYYY-MM-DD HH:MM (your time)'),
              const SizedBox(height: 18),
              GallerySelect(
                label: 'Category',
                value: _category,
                options: journalCategories,
                onChanged: (v) => setState(() {
                  _category = v;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: 18),
              _tagsField(),
              const SizedBox(height: 18),
              PaintingPicker(
                label: 'Cover painting',
                value: _upload != null || (_coverFile.isNotEmpty && !_removeCover) ? '__file' : _painting,
                onChanged: (k) => setState(() {
                  _painting = k;
                  _upload = null;
                  _removeCover = _coverFile.isNotEmpty;
                  _dirty = true;
                }),
                trailing: Pressable(
                  onTap: () async {
                    final p = await pickImage();
                    if (p != null) {
                      setState(() {
                        _upload = p;
                        _dirty = true;
                      });
                    }
                  },
                  label: 'Upload a cover image',
                  builder: (context, hover, _) => Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hover ? Palette.admBg : Colors.white,
                      border: Border.all(
                        color: _upload != null || (_coverFile.isNotEmpty && !_removeCover) ? Palette.royalAction : Adm.handle,
                        width: _upload != null || (_coverFile.isNotEmpty && !_removeCover) ? 3 : 1,
                      ),
                    ),
                    child: Text(_upload != null || (_coverFile.isNotEmpty && !_removeCover) ? 'Uploaded' : 'Upload', style: T.body(12, color: Adm.muted)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GalleryField(label: 'Excerpt', controller: _excerpt, lines: 3, hint: 'Shown on the Journal index and in link previews.'),
              if (_record != null) ...[
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GalleryButton(
                    label: 'Delete entry',
                    kind: ButtonKind.outline,
                    outlineInk: Adm.danger,
                    outlineBorder: const Color(0xFFE2B8BF),
                    height: 44,
                    fontSize: 14,
                    onPressed: _delete,
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _tagsField() {
    void add() {
      final t = _tag.text.trim().toLowerCase();
      if (t.isNotEmpty && !_tags.contains(t)) {
        setState(() {
          _tags = [..._tags, t];
          _dirty = true;
        });
      }
      _tag.clear();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text('TAGS', style: T.mono(size: 11, tracking: .14, color: Palette.tyrian)),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in _tags)
              Pressable(
                onTap: () => setState(() {
                  _tags = [..._tags]..remove(t);
                  _dirty = true;
                }),
                label: 'Remove tag $t',
                builder: (context, hover, _) => Chip2('$t ×', bg: hover ? const Color(0xFFD5DEFF) : const Color(0xFFE3E9FF), fg: Palette.royal),
              ),
          ],
        ),
        GalleryField(label: 'Add a tag', hideLabel: true, hint: '+ add (Enter)', controller: _tag, onSubmit: add),
      ],
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.white,
        title: Text('Delete this entry?', style: T.display(20, height: 1.3, color: Adm.ink)),
        content: Text('This can\'t be undone.', style: T.body(15, color: Adm.body)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Adm.danger))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Curator.pb!.collection('posts').delete(_record!.id);
      refreshBadges();
      if (mounted) context.go('/admin/journal');
    } catch (e) {
      _status.value = SendState(message: explain(e));
    }
  }
}
