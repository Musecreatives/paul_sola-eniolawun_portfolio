// The Curator's office: shared shell, session and small widgets.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

import '../data/api.dart';
import '../theme/tokens.dart';
import '../widgets/gallery.dart';
import '../widgets/pressable.dart';

/// The curator's PocketBase session.
abstract final class Curator {
  static PocketBase? get pb => pocketBase();

  static bool get signedIn {
    final a = pb?.authStore;
    return a != null && a.isValid && a.record?.collectionName == 'curators';
  }

  static String get firstName {
    final r = pb?.authStore.record;
    final name = r?.getStringValue('name') ?? '';
    return name.isNotEmpty ? name.split(' ').first : 'Paul';
  }

  static void signOut() => pb?.authStore.clear();
}

/// A readable message from a PocketBase error, never a stack trace.
String explain(Object e) {
  if (e is ClientException) {
    if (e.statusCode == 0) return 'The CMS is unreachable. Check that the pocketbase container is running.';
    if (e.statusCode == 401 || e.statusCode == 403) return 'Your session has ended or lacks permission. Sign in again.';
    final data = e.response['data'];
    if (data is Map && data.isNotEmpty) {
      return data.entries.map((f) => '${f.key}: ${(f.value as Map?)?['message'] ?? f.value}').join(' · ');
    }
    final m = e.response['message'];
    if (m is String && m.isNotEmpty) return m;
  }
  return 'Something went wrong: $e';
}

abstract final class Adm {
  static const ink = Palette.placardInk;
  static const body = Palette.placardBody;
  static const muted = Palette.placardMuted;
  static const card = Colors.white;
  static const handle = Color(0xFFB9B3D0);
  static const danger = Color(0xFF8A1C2C);
  static const selected = Color(0xFFEEF1FF);
}

/// "in_progress" reads as "In progress".
String humanize(String v) => v.isEmpty ? v : v[0].toUpperCase() + v.substring(1).replaceAll('_', ' ');

/// The drag handle: two columns of three dots, drawn so no font is needed.
class Grip extends StatelessWidget {
  const Grip({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 12,
        height: 18,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 3,
          crossAxisSpacing: 4,
          children: [
            for (var i = 0; i < 6; i++) const DecoratedBox(decoration: BoxDecoration(color: Adm.handle, shape: BoxShape.circle)),
          ],
        ),
      );
}

/// Status chip colours from the admin mockups.
(Color, Color) chipColors(String status) => switch (status.toLowerCase()) {
      'draft' => (const Color(0xFFEEE9F8), Palette.tyrian),
      'scheduled' => (const Color(0xFFE3E9FF), Palette.royal),
      'published' => (const Color(0xFFE2F5EA), const Color(0xFF1D6B40)),
      'earned' => (const Color(0xFFE2F5EA), const Color(0xFF1D6B40)),
      _ => (const Color(0xFFEEE9F8), Palette.tyrian),
    };

class Chip2 extends StatelessWidget {
  const Chip2(this.text, {super.key, this.bg, this.fg, this.dashed = false});
  final String text;
  final Color? bg;
  final Color? fg;
  final bool dashed;

  factory Chip2.status(String status) {
    final (bg, fg) = chipColors(status);
    return Chip2(humanize(status), bg: bg, fg: fg);
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          border: dashed ? Border.all(color: Adm.handle) : null,
        ),
        child: Text(text.toUpperCase(), style: T.mono(size: 11, tracking: .1, color: fg ?? Adm.muted)),
      );
}

class AdmCard extends StatelessWidget {
  const AdmCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: Adm.card, border: Border.all(color: Palette.admLine)),
        child: child,
      );
}

/// Section title in a card: Alternates 17/600.
class CardTitle extends StatelessWidget {
  const CardTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: T.display(17, height: 1.3, color: Adm.ink));
}

/// Page heading: mono eyebrow in tyrian, then Alternates 30/600.
class AdmHeading extends StatelessWidget {
  const AdmHeading({super.key, required this.eyebrow, required this.title});
  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Mono(eyebrow, color: Palette.tyrian),
            Text(title, style: T.display(context.isCompact ? 24 : 30, height: 1.2, color: Adm.ink)),
          ],
        ),
      );
}

/// A small text link in royal with an underline on hover.
class AdmLink extends StatelessWidget {
  const AdmLink(this.text, {super.key, this.href, this.onTap, this.color = Palette.royal, this.size = 13, this.external = false});
  final String text;
  final String? href;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final bool external;

  @override
  Widget build(BuildContext context) => Pressable(
        href: href,
        onTap: onTap,
        external: external,
        builder: (context, hover, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            text,
            style: T.body(size, height: 1.3, color: color).copyWith(
              decoration: hover ? TextDecoration.underline : TextDecoration.none,
              decorationColor: color,
            ),
          ),
        ),
      );
}

/// A row that is a button (or a link) with a hover tint.
class AdmRow extends StatelessWidget {
  const AdmRow({super.key, required this.child, this.onTap, this.href, this.label, this.selected = false, this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14)});
  final Widget child;
  final VoidCallback? onTap;
  final String? href;
  final String? label;
  final bool selected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        href: href,
        label: label,
        ringOffset: -2,
        builder: (context, hover, _) => Container(
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? Adm.selected : (hover ? Palette.admBg : Colors.white),
            border: const Border(bottom: BorderSide(color: Palette.admLineSoft)),
          ),
          child: child,
        ),
      );
}

class AdmCheckbox extends StatelessWidget {
  const AdmCheckbox({super.key, required this.value, required this.onChanged, required this.label});
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Checkbox(
            value: value,
            onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
            activeColor: Palette.royalAction,
            side: const BorderSide(color: Adm.handle, width: 1.5),
            shape: const RoundedRectangleBorder(),
          ),
        ),
      );
}

/// One entry in the admin sidebar.
class NavEntry {
  const NavEntry(this.label, this.path, {this.external = false});
  final String label;
  final String path;
  final bool external;
}

const adminNav = [
  NavEntry('Overview', '/admin/overview'),
  NavEntry('Journal', '/admin/journal'),
  NavEntry('Works', '/admin/works'),
  NavEntry('Chronicle', '/admin/chronicle'),
  NavEntry('Certificates', '/admin/certificates'),
  NavEntry('Collection', '/admin/collection'),
  NavEntry('Now placard', '/admin/now'),
  NavEntry('Visitor book', '/admin/visitor-book'),
  NavEntry('Letters', '/admin/letters'),
  NavEntry('Subscribers', '/admin/subscribers'),
  // Uploaded files and server settings live in the PocketBase dashboard.
  NavEntry('Media library', '/_/#/collections', external: true),
  NavEntry('Settings', '/_/#/settings', external: true),
];

/// Badge counts shown next to sidebar entries, keyed by path.
final navBadges = ValueNotifier<Map<String, (String, Color?, Color?)>>({});

/// Loads the sidebar counts. Cheap: one `perPage=1` request per collection.
Future<void> refreshBadges() async {
  final pb = Curator.pb;
  if (pb == null || !Curator.signedIn) return;
  Future<int> count(String c, [String? filter]) async =>
      (await pb.collection(c).getList(perPage: 1, filter: filter, skipTotal: false)).totalItems;
  try {
    final r = await Future.wait([
      count('posts'),
      count('works'),
      count('roles'),
      count('certificates'),
      count('collection_items'),
      count('visitor_notes', 'approved = false'),
      count('letters', 'read = false'),
    ]);
    navBadges.value = {
      '/admin/journal': ('${r[0]}', null, null),
      '/admin/works': ('${r[1]}', null, null),
      '/admin/chronicle': ('${r[2]}', null, null),
      '/admin/certificates': ('${r[3]}', null, null),
      '/admin/collection': ('${r[4]}', null, null),
      if (r[5] > 0) '/admin/visitor-book': ('${r[5]}', const Color(0xFFE2C57F), Adm.ink),
      if (r[6] > 0) '/admin/letters': ('${r[6]}', Palette.progressEnd, Colors.white),
    };
  } catch (_) {
    // Badges are a nicety; the pages show their own errors.
  }
}

/// Sidebar + main column (+ an optional drawer on wide screens).
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.current, required this.child, this.drawer});
  final String current;
  final Widget child;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final narrow = context.width < 900;
    final main = Material(color: Palette.admBg, child: child);
    if (narrow) {
      return Scaffold(
        backgroundColor: Palette.admBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopNav(current: current),
              Expanded(child: main),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Palette.admBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 260, child: _SideNav(current: current)),
          Expanded(child: main),
          if (drawer != null)
            Container(
              width: 420,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: Palette.admLine)),
                boxShadow: [BoxShadow(offset: Offset(-20, 0), blurRadius: 40, color: Color(0x141C1830))],
              ),
              child: drawer,
            ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(
        spacing: 12,
        children: [
          const Seal(size: 40),
          Flexible(child: Text("Curator's office", style: T.display(16, height: 1.2, color: const Color(0xFFE6E1F5)))),
        ],
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.e, {required this.on, this.badge, this.inStrip = false});
  final NavEntry e;
  final bool on;

  /// In the horizontal strip there is no width to expand into.
  final bool inStrip;
  final (String, Color?, Color?)? badge;

  @override
  Widget build(BuildContext context) => Pressable(
        href: e.external ? e.path : null,
        external: e.external,
        onTap: e.external ? null : () => context.go(e.path),
        label: e.external ? '${e.label} (opens the PocketBase dashboard)' : e.label,
        ringOffset: -2,
        builder: (context, hover, _) => Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: on ? Palette.royalAction : (hover ? Palette.admSideHover : Colors.transparent),
          child: Row(
            spacing: 10,
            mainAxisSize: inStrip ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (inStrip)
                Text(e.label, style: T.body(14, height: 1.3, color: on || hover ? Colors.white : Palette.admSideText))
              else
                Expanded(
                  child: Text(e.label + (e.external ? ' ↗' : ''),
                      style: T.body(14, height: 1.3, color: on || hover ? Colors.white : Palette.admSideText)),
                ),
              if (badge case (final text, final bg, final fg))
                bg == null
                    ? Text(text, style: T.mono(size: 12, tracking: .16, color: on ? Colors.white : Palette.admSideText))
                    : Chip2(text, bg: bg, fg: fg),
            ],
          ),
        ),
      );
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: 'Admin',
        child: Container(
          color: Palette.admSide,
          padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
          child: ValueListenableBuilder(
            valueListenable: navBadges,
            builder: (context, badges, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: _Brand()),
                const SizedBox(height: 28),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 2,
                      children: [for (final e in adminNav) _NavItem(e, on: current == e.path, badge: badges[e.path])],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      const AdmLink('View live site ↗', href: '/', color: Color(0xFFA8B9FF), external: true),
                      Row(
                        children: [
                          Expanded(child: Text('${Curator.firstName} · Curator', style: T.body(13, height: 1.3, color: const Color(0xFF8F88B0)))),
                          AdmLink('Sign out', color: const Color(0xFFA8B9FF), onTap: () {
                            Curator.signOut();
                            context.go('/admin');
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// On narrow screens the sidebar becomes a scrolling strip.
class _TopNav extends StatelessWidget {
  const _TopNav({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) => Container(
        color: Palette.admSide,
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                const Expanded(child: _Brand()),
                AdmLink('Sign out', color: const Color(0xFFA8B9FF), onTap: () {
                  Curator.signOut();
                  context.go('/admin');
                }),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder(
                valueListenable: navBadges,
                builder: (context, badges, _) => Row(
                  children: [for (final e in adminNav.where((e) => !e.external)) _NavItem(e, on: current == e.path, badge: badges[e.path], inStrip: true)],
                ),
              ),
            ),
          ],
        ),
      );
}

/// Centered message for loading and error states.
class AdmMessage extends StatelessWidget {
  const AdmMessage(this.text, {super.key, this.retry});
  final String text;
  final VoidCallback? retry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Semantics(liveRegion: true, child: Text(text, textAlign: TextAlign.center, style: T.body(15, height: 1.5, color: Adm.body))),
              if (retry != null) GalleryButton(label: 'Try again', onPressed: retry, height: 44, fontSize: 14, kind: ButtonKind.ink),
            ],
          ),
        ),
      );
}

/// Relative time in the overview ("2h ago", "Tomorrow").
String relativeTime(DateTime? d, {DateTime? now}) {
  if (d == null) return '';
  final n = now ?? DateTime.now();
  final diff = n.difference(d.toLocal());
  if (diff.isNegative) {
    final ahead = -diff.inDays;
    if (ahead == 0) return 'Later today';
    if (ahead == 1) return 'Tomorrow';
    return 'In $ahead days';
  }
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 14) return 'Last week';
  return '${d.day}/${d.month}/${d.year}';
}
