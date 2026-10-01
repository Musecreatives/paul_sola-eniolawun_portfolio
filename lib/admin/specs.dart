// What each collection manager shows and edits. Field names match
// pb_migrations/ and lib/data/models.dart.
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import 'kit.dart';

enum FieldKind { text, multiline, markdown, number, toggle, select, list, json, image, images, relation, painting, readonly }

class FieldSpec {
  const FieldSpec(this.key, this.label, {this.kind = FieldKind.text, this.options = const [], this.required = false, this.hint, this.relation});
  final String key;
  final String label;
  final FieldKind kind;
  final List<String> options;
  final bool required;
  final String? hint;

  /// For [FieldKind.relation]: the target collection.
  final String? relation;
}

class ColumnSpec {
  const ColumnSpec(this.label, this.cell, {this.flex = 2, this.width, this.mono = false});
  final String label;
  final String Function(RecordModel r) cell;
  final int flex;
  final double? width;
  final bool mono;
}

class CollectionSpec {
  const CollectionSpec({
    required this.path,
    required this.collection,
    required this.eyebrow,
    required this.title,
    required this.noun,
    required this.columns,
    required this.fields,
    this.sort = 'order,created',
    this.orderable = true,
    this.toggle,
    this.toggleLabel = 'Visible',
    this.canAdd = true,
    this.single = false,
    this.slugFrom,
    this.rowsOpenEditor = false,
    this.extra,
    this.unreadDot,
  });

  final String path;
  final String collection;
  final String eyebrow;
  final String title;

  /// Singular noun for buttons: "role" gives "+ Add role" and "Edit role".
  final String noun;
  final List<ColumnSpec> columns;
  final List<FieldSpec> fields;
  final String sort;
  final bool orderable;

  /// A bool field shown as an inline checkbox in the table.
  final String? toggle;
  final String toggleLabel;
  final bool canAdd;

  /// One record only (the Now placard).
  final bool single;

  /// Fill `slug` from this field until the slug is edited by hand.
  final String? slugFrom;

  /// Journal rows open the full editor instead of the drawer.
  final bool rowsOpenEditor;

  /// Extra widgets under the form (e.g. "Reply by email").
  final Widget Function(BuildContext context, RecordModel r)? extra;

  /// Field that marks a row unread (letters).
  final String? unreadDot;
}

String _s(RecordModel r, String k) => r.getStringValue(k);
String _date(RecordModel r, String k) {
  final d = DateTime.tryParse(_s(r, k));
  return d == null ? '' : relativeTime(d);
}

final specs = <String, CollectionSpec>{
  'journal': CollectionSpec(
    path: '/admin/journal',
    collection: 'posts',
    eyebrow: 'Room VI',
    title: 'Journal',
    noun: 'entry',
    sort: '-updated',
    orderable: false,
    rowsOpenEditor: true,
    columns: [
      ColumnSpec('Title', (r) => _s(r, 'title').isEmpty ? '[Untitled entry]' : _s(r, 'title'), flex: 4),
      ColumnSpec('Category', (r) => _s(r, 'category'), width: 140, mono: true),
      ColumnSpec('Status', (r) => _s(r, 'status'), width: 120),
      ColumnSpec('Updated', (r) => _date(r, 'updated'), width: 120, mono: true),
    ],
    fields: const [],
  ),
  'works': const CollectionSpec(
    path: '/admin/works',
    collection: 'works',
    eyebrow: 'Room II',
    title: 'Works',
    noun: 'work',
    toggle: 'visible',
    slugFrom: 'title',
    columns: [
      ColumnSpec('Plate', _numeral, width: 70, mono: true),
      ColumnSpec('Title', _title, flex: 3),
      ColumnSpec('Medium', _medium, flex: 3),
      ColumnSpec('Year', _year, width: 90, mono: true),
    ],
    fields: [
      FieldSpec('title', 'Title', required: true),
      FieldSpec('slug', 'Slug', required: true, hint: 'used in /works/<slug>'),
      FieldSpec('numeral', 'Plate numeral', hint: 'I, II, III…'),
      FieldSpec('inventory', 'Inventory line', hint: 'Inv. PSE–2025–01'),
      FieldSpec('headline', 'Headline'),
      FieldSpec('summary', 'Summary', kind: FieldKind.multiline),
      FieldSpec('lede', 'Lede', kind: FieldKind.multiline),
      FieldSpec('body', 'Case study (Markdown)', kind: FieldKind.markdown),
      FieldSpec('medium', 'Medium'),
      FieldSpec('tags', 'Tags'),
      FieldSpec('role', 'My role'),
      FieldSpec('year', 'Year'),
      FieldSpec('dated', 'Dated'),
      FieldSpec('team', 'Team'),
      FieldSpec('platforms', 'Platforms'),
      FieldSpec('links', 'Links (JSON: [{"label": "", "url": ""}])', kind: FieldKind.json),
      FieldSpec('images', 'Images', kind: FieldKind.images),
      FieldSpec('extra', 'Case-study extras (JSON)', kind: FieldKind.json),
      FieldSpec('featured', 'Featured on the Works wall', kind: FieldKind.toggle),
      FieldSpec('visible', 'Visible on site', kind: FieldKind.toggle),
      FieldSpec('order', 'Position', kind: FieldKind.number),
    ],
  ),
  'chronicle': const CollectionSpec(
    path: '/admin/chronicle',
    collection: 'roles',
    eyebrow: 'Room III',
    title: 'Chronicle',
    noun: 'role',
    toggle: 'visible',
    columns: [
      ColumnSpec('Role', _role, flex: 2),
      ColumnSpec('Organisation', _org, flex: 2),
      ColumnSpec('Dates', _dates, width: 150, mono: true),
    ],
    fields: [
      FieldSpec('role', 'Role', required: true),
      FieldSpec('org', 'Organisation', required: true),
      FieldSpec('location', 'Location'),
      FieldSpec('start', 'Start', hint: 'YYYY-MM'),
      FieldSpec('end', 'End', hint: 'YYYY-MM, empty while current'),
      FieldSpec('current', 'I currently work here', kind: FieldKind.toggle),
      FieldSpec('dates', 'Dates as shown', hint: 'Jun 2025 – now'),
      FieldSpec('year', 'Year label'),
      FieldSpec('summary', 'Summary', kind: FieldKind.multiline),
      FieldSpec('highlights', 'Highlights', kind: FieldKind.list),
      FieldSpec('linked_work', 'Linked work', kind: FieldKind.relation, relation: 'works'),
      FieldSpec('visible', 'Visible on site', kind: FieldKind.toggle),
      FieldSpec('order', 'Position', kind: FieldKind.number),
    ],
  ),
  'certificates': const CollectionSpec(
    path: '/admin/certificates',
    collection: 'certificates',
    eyebrow: 'Room IV',
    title: 'Certificates',
    noun: 'certificate',
    columns: [
      ColumnSpec('Title', _title, flex: 3),
      ColumnSpec('Issuer', _issuer, flex: 2),
      ColumnSpec('Year', _year, width: 80, mono: true),
      ColumnSpec('Status', _status, width: 130),
    ],
    fields: [
      FieldSpec('title', 'Title', required: true),
      FieldSpec('issuer', 'Issuer'),
      FieldSpec('year', 'Year'),
      FieldSpec('status', 'Status', kind: FieldKind.select, options: ['earned', 'in_progress']),
      FieldSpec('progress', 'Progress (0–100, in progress only)', kind: FieldKind.number),
      FieldSpec('target', 'Target', hint: 'Expected [Month YYYY]'),
      FieldSpec('verify_url', 'Verify URL'),
      FieldSpec('image', 'Certificate scan', kind: FieldKind.image),
      FieldSpec('order', 'Position', kind: FieldKind.number),
    ],
  ),
  'collection': const CollectionSpec(
    path: '/admin/collection',
    collection: 'collection_items',
    eyebrow: 'Room VII',
    title: 'The Collection',
    noun: 'piece',
    columns: [
      ColumnSpec('Kind', _kind, width: 90, mono: true),
      ColumnSpec('Title', _title, flex: 3),
      ColumnSpec('Subtitle', _subtitle, flex: 2),
    ],
    fields: [
      FieldSpec('kind', 'Kind', kind: FieldKind.select, options: ['book', 'record', 'chess', 'art', 'sport', 'game']),
      FieldSpec('title', 'Title', required: true),
      FieldSpec('subtitle', 'Subtitle'),
      FieldSpec('note', 'Note', kind: FieldKind.multiline),
      FieldSpec('painting', 'Painting (instead of an upload)', kind: FieldKind.painting),
      FieldSpec('image', 'Image', kind: FieldKind.image),
      FieldSpec('order', 'Position', kind: FieldKind.number),
    ],
  ),
  'now': const CollectionSpec(
    path: '/admin/now',
    collection: 'now',
    eyebrow: 'Foyer',
    title: 'Now placard',
    noun: 'placard',
    sort: '-updated',
    orderable: false,
    single: true,
    columns: [
      ColumnSpec('Building', _building, flex: 3),
      ColumnSpec('Reading', _reading, flex: 2),
    ],
    fields: [
      FieldSpec('building', 'Building'),
      FieldSpec('reading', 'Reading'),
    ],
  ),
  'visitor-book': const CollectionSpec(
    path: '/admin/visitor-book',
    collection: 'visitor_notes',
    eyebrow: 'Room VIII',
    title: 'Visitor book',
    noun: 'note',
    sort: 'approved,-created',
    orderable: false,
    toggle: 'approved',
    toggleLabel: 'Approved',
    canAdd: false,
    columns: [
      ColumnSpec('Name', _name, flex: 2),
      ColumnSpec('City', _city, width: 120),
      ColumnSpec('Note', _note, flex: 4),
      ColumnSpec('Signed', _created, width: 110, mono: true),
    ],
    fields: [
      FieldSpec('name', 'Name', required: true),
      FieldSpec('city', 'City'),
      FieldSpec('note', 'Note (140 characters)', kind: FieldKind.multiline),
      FieldSpec('approved', 'Approved for the wall', kind: FieldKind.toggle),
    ],
  ),
  'letters': CollectionSpec(
    path: '/admin/letters',
    collection: 'letters',
    eyebrow: 'Room VIII',
    title: 'Letters',
    noun: 'letter',
    sort: '-created',
    orderable: false,
    toggle: 'read',
    toggleLabel: 'Read',
    canAdd: false,
    unreadDot: 'read',
    columns: const [
      ColumnSpec('From', _name, flex: 2),
      ColumnSpec('Purpose', _purpose, flex: 2),
      ColumnSpec('Received', _created, width: 110, mono: true),
    ],
    fields: const [
      FieldSpec('name', 'From', kind: FieldKind.readonly),
      FieldSpec('email', 'Email', kind: FieldKind.readonly),
      FieldSpec('purpose', 'Purpose', kind: FieldKind.readonly),
      FieldSpec('message', 'Message', kind: FieldKind.readonly),
      FieldSpec('read', 'Read', kind: FieldKind.toggle),
    ],
    extra: (context, r) => Align(
      alignment: Alignment.centerLeft,
      child: GalleryButton(
        label: 'Reply by email',
        kind: ButtonKind.seal,
        height: 44,
        fontSize: 14,
        external: true,
        href: Uri(scheme: 'mailto', path: r.getStringValue('email'), queryParameters: {'subject': 'Re: ${r.getStringValue('purpose')}'})
            .toString()
            .replaceAll('+', '%20'),
      ),
    ),
  ),
  'subscribers': const CollectionSpec(
    path: '/admin/subscribers',
    collection: 'subscribers',
    eyebrow: 'Room VI',
    title: 'Subscribers',
    noun: 'subscriber',
    sort: '-created',
    orderable: false,
    canAdd: false,
    columns: [
      ColumnSpec('Email', _email, flex: 4),
      ColumnSpec('Since', _created, width: 120, mono: true),
    ],
    fields: [FieldSpec('email', 'Email', kind: FieldKind.readonly)],
  ),
};

String _numeral(RecordModel r) => _s(r, 'numeral');
String _title(RecordModel r) => _s(r, 'title');
String _medium(RecordModel r) => _s(r, 'medium');
String _year(RecordModel r) => _s(r, 'year');
String _role(RecordModel r) => _s(r, 'role');
String _org(RecordModel r) => _s(r, 'org');
String _dates(RecordModel r) => _s(r, 'dates').isNotEmpty ? _s(r, 'dates') : [_s(r, 'start'), _s(r, 'end')].where((e) => e.isNotEmpty).join(' – ');
String _issuer(RecordModel r) => _s(r, 'issuer');
String _status(RecordModel r) => _s(r, 'status');
String _kind(RecordModel r) => _s(r, 'kind');
String _subtitle(RecordModel r) => _s(r, 'subtitle');
String _building(RecordModel r) => _s(r, 'building');
String _reading(RecordModel r) => _s(r, 'reading');
String _name(RecordModel r) => _s(r, 'name');
String _city(RecordModel r) => _s(r, 'city');
String _note(RecordModel r) => _s(r, 'note');
String _purpose(RecordModel r) => _s(r, 'purpose');
String _email(RecordModel r) => _s(r, 'email');
String _created(RecordModel r) => _date(r, 'created');

/// Status columns render as chips.
bool isStatusColumn(ColumnSpec c) => c.label == 'Status';

String slugify(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

const cellStyleColor = Palette.placardBody;
