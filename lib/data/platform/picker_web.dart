import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'picker_stub.dart';
export 'picker_stub.dart' show PickedFile;

/// Opens the browser's file dialog for one image.
Future<PickedFile?> pickImage() {
  final done = Completer<PickedFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*';
  input.onchange = ((web.Event _) {
    final f = input.files?.item(0);
    if (f == null) return done.complete(null);
    f.arrayBuffer().toDart.then(
          (buf) => done.complete(PickedFile(f.name, buf.toDart.asUint8List())),
          onError: (_) => done.complete(null),
        );
  }).toJS;
  input.oncancel = ((web.Event _) {
    if (!done.isCompleted) done.complete(null);
  }).toJS;
  input.click();
  return done.future;
}
