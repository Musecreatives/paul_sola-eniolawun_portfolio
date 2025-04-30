// lib/presentation/sections/featured_section.dart

import 'package:flutter/material.dart';
import '../../../widgets/projectItem.dart';

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key});

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
          'NCRS web app is a government-integrated website for remote-sensing data.',
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

    return LayoutBuilder(
      builder: (context, bc) {
        final isWide = bc.maxWidth >= 800;

        if (isWide) {
          // ─── Desktop/Tablet Wide ────────────────────────────
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← Screenshots column
                Column(
                  children: List.generate(_imagePaths.length, (i) {
                    final dx = i == 1 ? 80.0 : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Transform.translate(
                        offset: Offset(dx, 0),
                        child: SizedBox(
                          width: 640,
                          height: 250,
                          child: Image.asset(_imagePaths[i], fit: BoxFit.cover),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 20),

                // → Text + project items
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My featured works',
                          style: theme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here are a selection of my recent projects',
                          style: theme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        // project items
                        ..._projects.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ProjectItem(
                              title: p['title']!,
                              description: p['desc']!,
                              onView: () {
                                // handle “View” tap
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // ─── Mobile/Tablet Narrow ────────────────────────────
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My featured works',
                  style: theme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here are a selection of my recent projects',
                  style: theme.titleMedium,
                ),
                const SizedBox(height: 24),

                // horizontally scrollable screenshots
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagePaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder:
                        (context, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _imagePaths[i],
                            width: 300,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 24),

                // stacked project items
                ..._projects.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ProjectItem(
                      title: p['title']!,
                      description: p['desc']!,
                      onView: () {
                        // handle “View” tap
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
