import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/link.dart';

import '../theme/tokens.dart';

typedef PressableBuilder = Widget Function(BuildContext context, bool hovered, bool focused);

/// One interactive primitive for everything clickable: keyboard reachable,
/// a 2px royal-action focus ring, pointer cursor, and the right semantics.
///
/// Give it [href] for navigation (renders a real link, so middle-click and
/// "open in new tab" work on the web) or [onTap] for an action.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.builder,
    this.href,
    this.onTap,
    this.label,
    this.external = false,
    this.focusRing = true,
    this.onHover,
    this.cursor,
    this.ringOffset = 2,
  });

  final PressableBuilder builder;
  final String? href;
  final VoidCallback? onTap;
  final String? label;
  final bool external;
  final bool focusRing;
  final ValueChanged<bool>? onHover;
  final MouseCursor? cursor;
  final double ringOffset;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _focus = false;

  void _setHover(bool v) {
    if (_hover == v) return;
    setState(() => _hover = v);
    widget.onHover?.call(v);
  }

  Widget _wrap(VoidCallback? activate, {required bool isLink}) {
    final enabled = activate != null;
    Widget child = widget.builder(context, _hover, _focus);
    if (widget.focusRing) {
      child = CustomPaint(
        foregroundPainter: _focus ? _RingPainter(widget.ringOffset) : null,
        child: child,
      );
    }
    return Semantics(
      button: !isLink,
      link: isLink,
      label: widget.label,
      enabled: enabled,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? (widget.cursor ?? SystemMouseCursors.click) : MouseCursor.defer,
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        onShowHoverHighlight: _setHover,
        onFocusChange: (v) {
          // Keyboard focus also "hovers" so focus-driven effects (menu) fire.
          if (!v && _focus) setState(() => _focus = false);
          widget.onHover?.call(v || _hover);
        },
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            activate?.call();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: activate,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final href = widget.href;
    if (href == null) return _wrap(widget.onTap, isLink: false);
    return Link(
      uri: Uri.parse(href),
      target: widget.external ? LinkTarget.blank : LinkTarget.self,
      builder: (context, follow) => _wrap(() {
        widget.onTap?.call();
        follow?.call();
      }, isLink: true),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.offset);
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).inflate(offset);
    canvas.drawRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Palette.royalAction,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.offset != offset;
}
