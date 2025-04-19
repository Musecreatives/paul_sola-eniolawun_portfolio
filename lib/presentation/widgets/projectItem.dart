// lib/widgets/project_item.dart

import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/cta_button.dart';

class ProjectItem extends StatelessWidget {
  /// Project title, e.g. “RapidRobo Website”
  final String title;

  /// Short description below the title
  final String description;

  /// Width of the View Project button
  final double buttonWidth;

  const ProjectItem({
    super.key,
    required this.title,
    required this.description,
    this.buttonWidth = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Textual info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
