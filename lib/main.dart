import 'package:flutter/material.dart';

import 'theme/tokens.dart';
import 'widgets/gallery.dart';

void main() => runApp(const CollectionApp());

class CollectionApp extends StatelessWidget {
  const CollectionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Paul Sola-Eniolawun · The Collection',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(GalleryColors.day),
        darkTheme: buildTheme(GalleryColors.night),
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Center(child: Seal())),
      );
}
