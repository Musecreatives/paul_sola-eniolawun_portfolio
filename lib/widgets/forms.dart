import 'package:flutter/material.dart';

import '../theme/tokens.dart';

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateEmail(String? v) =>
    (v == null || !_emailRe.hasMatch(v.trim())) ? 'Enter a valid email address.' : null;

String? Function(String?) needs(String what) => (v) => (v == null || v.trim().isEmpty) ? 'Please add $what.' : null;

/// Placard-style input decoration: square, cream, 2px royal focus ring.
InputDecoration galleryInput({String? hint, Color fill = Palette.input}) {
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    hintText: hint,
    hintStyle: T.body(15, height: 1.4, color: Palette.placardMuted),
    filled: true,
    fillColor: fill,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: b(const Color(0x401C1830)),
    enabledBorder: b(const Color(0x401C1830)),
    focusedBorder: b(Palette.royalAction, 2),
    errorBorder: b(const Color(0xFF8A1C2C)),
    focusedErrorBorder: b(const Color(0xFF8A1C2C), 2),
    errorStyle: T.body(13, height: 1.3, color: const Color(0xFFB3263A)),
    counterStyle: T.mono(size: 11, color: Palette.placardMuted),
  );
}

/// A labelled text field. Every control has a visible (or screen-reader) label.
class GalleryField extends StatelessWidget {
  const GalleryField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.lines = 1,
    this.maxLength,
    this.keyboard,
    this.autofill,
    this.validator,
    this.onSubmit,
    this.hideLabel = false,
    this.labelColor = Palette.tyrian,
    this.obscure = false,
    this.onChanged,
    this.textStyle,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final int lines;
  final int? maxLength;
  final TextInputType? keyboard;
  final Iterable<String>? autofill;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmit;
  final bool hideLabel;
  final Color labelColor;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      minLines: lines,
      maxLines: obscure ? 1 : (lines == 1 ? 1 : lines + 6),
      maxLength: maxLength,
      obscureText: obscure,
      keyboardType: keyboard ?? (lines > 1 ? TextInputType.multiline : null),
      autofillHints: autofill,
      validator: validator,
      onChanged: onChanged,
      textInputAction: lines > 1 ? TextInputAction.newline : TextInputAction.done,
      onFieldSubmitted: onSubmit == null || lines > 1 ? null : (_) => onSubmit!(),
      style: textStyle ?? T.body(15, height: 1.4, color: Palette.placardInk),
      cursorColor: Palette.royalAction,
      decoration: galleryInput(hint: hint),
    );
    if (hideLabel) return Semantics(label: label, textField: true, child: field);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ExcludeSemantics(child: Text(label.toUpperCase(), style: T.mono(size: 11, tracking: .14, color: labelColor))),
        Semantics(label: label, child: field),
      ],
    );
  }
}

class GallerySelect extends StatelessWidget {
  const GallerySelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.labelColor = Palette.tyrian,
    this.display,
  });
  final String label;
  final String value;
  final List<String> options;

  /// How an option reads in the menu, when it differs from the stored value.
  final String Function(String)? display;
  final ValueChanged<String> onChanged;
  final Color labelColor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          ExcludeSemantics(child: Text(label.toUpperCase(), style: T.mono(size: 11, tracking: .14, color: labelColor))),
          Semantics(
            label: label,
            child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              dropdownColor: Palette.input,
              style: T.body(15, height: 1.4, color: Palette.placardInk),
              iconEnabledColor: Palette.placardInk,
              decoration: galleryInput(),
              items: [for (final o in options) DropdownMenuItem(value: o, child: Text(display?.call(o) ?? o))],
              onChanged: (v) => v == null ? null : onChanged(v),
            ),
          ),
        ],
      );
}

class SendState {
  const SendState({this.busy = false, this.ok = false, this.message});
  final bool busy;
  final bool ok;
  final String? message;
}

/// Tracks a form submission so the UI never pretends something was sent.
class SendStatus extends ValueNotifier<SendState> {
  SendStatus() : super(const SendState());

  Future<void> run(Future<void> Function() send, {required String done, String? fallback}) async {
    value = const SendState(busy: true);
    try {
      await send();
      value = SendState(ok: true, message: done);
    } catch (e) {
      value = SendState(message: fallback ?? "That didn't go through: $e Please try again in a moment.");
    }
  }
}

/// Announces the result of a submission to screen readers.
class StatusLine extends StatelessWidget {
  const StatusLine(this.status, {super.key, this.onDark = false});
  final SendStatus status;
  final bool onDark;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: status,
        builder: (_, s, _) => s.message == null
            ? const SizedBox.shrink()
            : Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: s.ok ? Palette.nowDot : const Color(0xFFE07A8A)),
                    ),
                    Expanded(
                      child: Text(s.message!,
                          style: T.body(14, height: 1.5, color: onDark ? const Color(0xFFF3EEE3) : Palette.placardInk)),
                    ),
                  ],
                ),
              ),
      );
}

/// Off-screen honeypot. People never fill it; bots usually do.
class Honeypot extends StatelessWidget {
  const Honeypot(this.controller, {super.key});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Offstage(
          child: SizedBox(width: 1, height: 1, child: TextField(controller: controller, enableInteractiveSelection: false)),
        ),
      );
}
