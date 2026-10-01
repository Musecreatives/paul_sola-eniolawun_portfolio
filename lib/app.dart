import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/tokens.dart';

/// Night gallery by default; the toggle in the header switches to day.
final dayGallery = ValueNotifier<bool>(false);

class CollectionApp extends StatelessWidget {
  const CollectionApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: dayGallery,
        builder: (context, day, _) => MaterialApp.router(
          title: 'Paul Sola-Eniolawun · The Collection',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(day ? GalleryColors.day : GalleryColors.night),
          routerConfig: router,
        ),
      );
}
