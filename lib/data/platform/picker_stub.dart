import 'dart:typed_data';

class PickedFile {
  const PickedFile(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

/// No file picker off the web.
Future<PickedFile?> pickImage() async => null;
