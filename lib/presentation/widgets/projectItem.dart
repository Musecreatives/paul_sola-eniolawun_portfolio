// lib/widgets/project_item.dart

import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/data/models/project.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/cta_button.dart';

import '../views/project/project_page.dart';

class ProjectItem extends StatelessWidget {
  /// Project title, e.g. “RapidRobo Website”
  final String title;

  /// Short description below the title
  final String description;

  /// Width of the View Project button
  final double buttonWidth;

  /// Height of the View Project button
  final double buttonHeight;

  const ProjectItem({
    Key? key,
    required this.title,
    required this.description,
    this.buttonWidth = 320,
    this.buttonHeight = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Textual info grows to fill remaining space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                // 2) View Project button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 2a) Left border
                    Container(
                      width: 6,
                      height: buttonHeight,
                      decoration: BoxDecoration(),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ctaButton(
                        label: 'View Project',
                        onPressed: () {
                          // Handle button tap
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProjectPage(),
                            ),
                          );
                        },
                        width: buttonWidth,
                        height: buttonHeight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
