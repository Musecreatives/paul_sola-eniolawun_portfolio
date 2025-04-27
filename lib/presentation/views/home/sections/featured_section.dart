// lib/presentation/sections/featured_section.dart

import 'package:flutter/material.dart';
import '../../../widgets/projectItem.dart';

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key});

  // your static data
  static const _imagePaths = [
    'assets/images/work-1.png',
    'assets/images/work-2.png',
    'assets/images/work-3.png',
  ];
  static const _projects = [
    {
      'title': 'RapidRobo Website',
      'desc': 'Rapidrobo is a trading bot product that helps newbies.',
    },
    {
      'title': 'National Centre for Remote Sensing Website',
      'desc':
          'NCRS web app is a government‑integrated website for remote‑sensing data.',
    },
    {
      'title': 'Moveables Apps',
      'desc':
          'Moveables is a logistics platform for servicing movement of goods in Nigeria.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    // layout constants
    const horizontalPadding = 60.0;
    const columnGap = 20.0;
    const imageWidth = 640.0;
    const imageHeight = 250.0;
    const imageSpacing = 30.0;
    const projectSpacing = 16.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ← LEFT: the three screenshots
          Column(
            children: List.generate(_imagePaths.length, (i) {
              // shift the 2nd image (index==1) left by 40px
              final dx = i == 1 ? 80.0 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: imageSpacing),
                child: Transform.translate(
                  offset: Offset(dx, 0),
                  child: SizedBox(
                    width: imageWidth,
                    height: imageHeight,
                    child: Image.asset(_imagePaths[i], fit: BoxFit.contain),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(width: columnGap),

          // → RIGHT: heading + project items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My featured works',
                    style: theme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Here are a selection of my recent projects',
                    style: theme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // each ProjectItem with vertical spacing
                  for (var p in _projects) ...[
                    ProjectItem(
                      title: p['title']!,
                      description: p['desc']!,
                      onView: () {},
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
