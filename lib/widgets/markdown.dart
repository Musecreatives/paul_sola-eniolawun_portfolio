// A small Markdown renderer in the gallery's reading typography.
// Supports GFM blocks plus two directives:
//   :::margin ... :::   a side note (marginalia) attached to the block above
//   :::sample ... :::   the yellow "sample text" tag
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import 'gallery.dart';

enum MdMode { article, caseStudy, preview }

class MdPiece {
  MdPiece(this.widget, {this.anchor, this.key});
  final Widget widget;

  /// Heading text if this piece is an h2 (for the table of contents).
  final String? anchor;
  final GlobalKey? key;

  /// Marginalia attached to this piece.
  String? margin;
}

final _directive = RegExp(r'^:::(\w+)[ \t]*\r?\n([\s\S]*?)\r?\n:::[ \t]*$', multiLine: true);

/// Splits [src] into pieces. The caller lays them out (and the marginalia).
List<MdPiece> renderMarkdown(BuildContext context, String src, {MdMode mode = MdMode.article}) {
  final r = _Renderer(context, mode);
  var last = 0;
  for (final m in _directive.allMatches(src)) {
    r.markdown(src.substring(last, m.start));
    final text = m.group(2)!.trim();
    switch (m.group(1)) {
      case 'margin':
        if (r.out.isNotEmpty) {
          r.out.last.margin = text;
        } else {
          r.out.add(MdPiece(r.marginInline(text)));
        }
      case 'sample':
        r.out.add(MdPiece(Align(
          alignment: Alignment.centerLeft,
          child: Container(
            color: const Color(0xFFFFF4D6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Mono(text, color: const Color(0xFF8A5A00)),
          ),
        )));
      default:
        r.markdown(m.group(0)!);
    }
    last = m.end;
  }
  r.markdown(src.substring(last));
  return r.out;
}

/// Renders [src] as a simple column (marginalia inline). Used by previews.
class MarkdownColumn extends StatelessWidget {
  const MarkdownColumn(this.src, {super.key, this.mode = MdMode.article, this.gap = 22});
  final String src;
  final MdMode mode;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final r = _Renderer(context, mode);
    final pieces = renderMarkdown(context, src, mode: mode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        for (final p in pieces) ...[p.widget, if (p.margin != null) r.marginInline(p.margin!)],
      ],
    );
  }
}

class _Renderer {
  _Renderer(this.context, this.mode) : g = context.g;
  final BuildContext context;
  final MdMode mode;
  final GalleryColors g;
  final out = <MdPiece>[];
  bool _firstParagraph = true;

  bool get preview => mode == MdMode.preview;
  double get bodySize => switch (mode) { MdMode.article => 18, MdMode.caseStudy => 17, MdMode.preview => 15 };
  TextStyle get body => T.body(bodySize,
      height: mode == MdMode.article ? 1.8 : 1.75, color: g.isDay ? const Color(0xFF2A2545) : g.inkBody);

  void markdown(String src) {
    if (src.trim().isEmpty) return;
    final nodes = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored, encodeHtml: false).parse(src);
    for (final n in nodes) {
      final p = block(n);
      if (p != null) out.add(p);
    }
  }

  Widget marginInline(String text) => Container(
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: Palette.gilt.withValues(alpha: .6)))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Mono('Marginalia', color: g.isDay ? Palette.tyrian : g.giltLight),
            Text(text, style: T.body(14, height: 1.6, italic: true, color: g.inkMuted)),
          ],
        ),
      );

  MdPiece? block(md.Node n) {
    if (n is md.Text) return MdPiece(Text(n.text, style: body));
    if (n is! md.Element) return null;
    switch (n.tag) {
      case 'p':
        final first = _firstParagraph && mode == MdMode.article;
        _firstParagraph = false;
        if (n.children?.length == 1 && n.children!.first is md.Element && (n.children!.first as md.Element).tag == 'img') {
          return MdPiece(image(n.children!.first as md.Element));
        }
        if (first && (n.children ?? []).every((c) => c is md.Text) && n.textContent.length > 80 && !n.textContent.startsWith('[')) {
          return MdPiece(_DropCap(n.textContent, body));
        }
        return MdPiece(Text.rich(TextSpan(children: inline(n.children, body)), style: body));
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        final text = n.textContent;
        final key = GlobalKey();
        final Widget w;
        if (mode == MdMode.caseStudy) {
          // Sections sit 40px apart; the label sits 14px above its text.
          w = Padding(padding: EdgeInsets.only(top: out.isEmpty ? 0 : 26), child: Mono(text, color: g.giltLight));
        } else {
          final size = switch ((n.tag, preview)) { ('h2', false) => 28.0, ('h2', true) => 20.0, (_, false) => 22.0, _ => 17.0 };
          w = Padding(
            padding: EdgeInsets.only(top: preview ? 0 : 16),
            child: Semantics(header: true, child: Text(text, style: T.display(size, height: 1.2, color: g.ink))),
          );
        }
        return MdPiece(KeyedSubtree(key: key, child: w), anchor: n.tag == 'h2' ? text : null, key: key);
      case 'blockquote':
        return MdPiece(quote(n));
      case 'pre':
        final code = n.children?.firstOrNull;
        final lang = code is md.Element ? (code.attributes['class'] ?? '').replaceFirst('language-', '') : '';
        return MdPiece(codeBlock(n.textContent.trimRight(), lang));
      case 'ul' || 'ol':
        final ordered = n.tag == 'ol';
        final items = n.children?.whereType<md.Element>().toList() ?? [];
        return MdPiece(Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              for (final (i, li) in items.indexed)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 22, child: Text(ordered ? '${i + 1}.' : '•', style: body)),
                    Expanded(child: Text.rich(TextSpan(children: inline(_flatten(li.children), body)), style: body)),
                  ],
                ),
            ],
          ),
        ));
      case 'hr':
        return MdPiece(Center(
          child: Text('· · ·', style: TextStyle(color: Palette.gilt, fontSize: 20, letterSpacing: 12, fontFamily: Fonts.body)),
        ));
      case 'table':
        return MdPiece(Text(n.textContent, style: body));
      default:
        return MdPiece(Text.rich(TextSpan(children: inline(n.children, body)), style: body));
    }
  }

  // List items may wrap their content in <p>; inline it.
  List<md.Node>? _flatten(List<md.Node>? nodes) => nodes
      ?.expand((c) => c is md.Element && c.tag == 'p' ? [...?c.children, md.Text(' ')] : [c])
      .toList();

  Widget quote(md.Element n) {
    final lines = n.textContent.trim().split('\n');
    String? source;
    if (lines.length > 1 && RegExp(r'^\s*[—–-]').hasMatch(lines.last)) {
      source = lines.removeLast().replaceFirst(RegExp(r'^\s*[—–-]\s*'), '');
    }
    final tyrian = g.isDay ? Palette.tyrian : g.tyrianLight;
    return Container(
      margin: EdgeInsets.symmetric(vertical: preview ? 0 : 8),
      padding: EdgeInsets.only(left: preview ? 18 : 28, top: 8, bottom: 8),
      decoration: const BoxDecoration(border: Border(left: BorderSide(color: Palette.gilt, width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(lines.join(' ').replaceAll('"', '').trim().let((t) => '“$t”'),
              style: T.body(preview ? 16 : 22, height: 1.6, italic: true, color: tyrian)),
          if (source != null) Mono(source, color: g.inkMuted),
        ],
      ),
    );
  }

  Widget codeBlock(String code, String lang) {
    final key = RegExp(r'^(\s*)([\w.-]+)(\s*[:=])');
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: Palette.plateDark,
          padding: EdgeInsets.fromLTRB(preview ? 16 : 24, preview ? 14 : 22, preview ? 16 : 24, preview ? 14 : 22),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text.rich(
              TextSpan(children: [
                for (final (i, line) in code.split('\n').indexed) ...[
                  if (i > 0) const TextSpan(text: '\n'),
                  if (key.firstMatch(line) case final m?) ...[
                    TextSpan(text: m.group(1)),
                    TextSpan(text: m.group(2), style: const TextStyle(color: Color(0xFFA8B9FF))),
                    TextSpan(text: line.substring(m.group(1)!.length + m.group(2)!.length)),
                  ] else
                    TextSpan(text: line),
                ],
              ]),
              style: T.code(color: const Color(0xFFD6D0EA)).copyWith(fontSize: preview ? 12 : 14),
            ),
          ),
        ),
        if (lang.isNotEmpty) Positioned(top: 10, right: 14, child: Mono(lang, color: const Color(0xFFE2C57F))),
      ],
    );
  }

  Widget image(md.Element img) {
    final src = img.attributes['src'] ?? '';
    final alt = img.attributes['alt'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Image.network(src, semanticLabel: alt, fit: BoxFit.cover, errorBuilder: (_, _, _) => Text('[$alt]', style: body)),
        if (alt.isNotEmpty) Mono(alt, color: g.inkMuted, align: TextAlign.right),
      ],
    );
  }

  List<InlineSpan> inline(List<md.Node>? nodes, TextStyle style) {
    final spans = <InlineSpan>[];
    for (final n in nodes ?? const <md.Node>[]) {
      if (n is md.Text) {
        spans.add(TextSpan(text: n.text.replaceAll('&quot;', '"').replaceAll('&amp;', '&')));
      } else if (n is md.Element) {
        switch (n.tag) {
          case 'strong':
            spans.add(TextSpan(children: inline(n.children, style), style: const TextStyle(fontWeight: FontWeight.w600)));
          case 'em':
            spans.add(TextSpan(children: inline(n.children, style), style: const TextStyle(fontStyle: FontStyle.italic)));
          case 'del':
            spans.add(TextSpan(children: inline(n.children, style), style: const TextStyle(decoration: TextDecoration.lineThrough)));
          case 'code':
            spans.add(TextSpan(
              text: n.textContent,
              style: TextStyle(fontFamily: Fonts.mono, fontSize: bodySize * .85, backgroundColor: g.tyrianLight.withValues(alpha: .12)),
            ));
          case 'a':
            final href = n.attributes['href'] ?? '';
            spans.add(TextSpan(
              children: inline(n.children, style),
              style: TextStyle(color: g.royalLight, decoration: TextDecoration.underline, decorationColor: g.royalLight),
              mouseCursor: SystemMouseCursors.click,
              recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(href)),
            ));
          case 'br':
            spans.add(const TextSpan(text: '\n'));
          case 'img':
            spans.add(TextSpan(text: '[${n.attributes['alt'] ?? 'image'}]'));
          default:
            spans.add(TextSpan(children: inline(n.children, style)));
        }
      }
    }
    return spans;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

/// A two-line drop cap in royal Alternates, with text wrapping back to full
/// width underneath (like CSS float).
class _DropCap extends StatelessWidget {
  const _DropCap(this.text, this.style);
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final cap = text.characters.first;
    final rest = text.substring(cap.length);
    final capStyle = T.display(76, height: .8, color: Palette.royal);
    return LayoutBuilder(builder: (context, c) {
      final capPainter = TextPainter(text: TextSpan(text: cap, style: capStyle), textDirection: TextDirection.ltr)..layout();
      final capW = capPainter.width + 12;
      final lineH = (style.fontSize ?? 18) * (style.height ?? 1.8);
      final lines = ((capPainter.height + 8) / lineH).ceil().clamp(2, 3);
      final tp = TextPainter(text: TextSpan(text: rest, style: style), textDirection: TextDirection.ltr)
        ..layout(maxWidth: (c.maxWidth - capW).clamp(50, double.infinity));
      final metrics = tp.computeLineMetrics();
      if (metrics.length <= lines) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 8, right: 12), child: Text(cap, style: capStyle)),
          Expanded(child: Text(rest, style: style)),
        ]);
      }
      final split = tp.getLineBoundary(tp.getPositionForOffset(Offset(1, lineH * (lines - 1) + lineH / 2))).end;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 8, right: 12), child: Text(cap, style: capStyle)),
          Expanded(child: Text(rest.substring(0, split).trimRight(), style: style)),
        ]),
        Text(rest.substring(split).trimLeft(), style: style),
      ]);
    });
  }
}
