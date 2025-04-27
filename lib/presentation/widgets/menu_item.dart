// lib/widgets/menu_item.dart

import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  /// The labels to show (e.g. ['Home', 'Projects', ...])
  final List<String> labels;

  /// Which index is currently hovered (-1 for none)
  final int hoveredIndex;

  /// Called when a row is hovered; passes its index (or -1 on exit)
  final ValueChanged<int> onHover;

  /// Called when a row is tapped; passes its index
  final ValueChanged<int> onTap;

  const MenuItem({
    Key? key,
    required this.labels,
    required this.hoveredIndex,
    required this.onHover,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontFamily: 'Montserrat',
    );

    return Container(
      width: 400, // you had width=400
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(labels.length, (i) {
          final isHovered = i == hoveredIndex;
          final label = labels[i];
          final idx = (i + 1).toString().padLeft(2, '0');

          return MouseRegion(
            onEnter: (_) => onHover(i),
            onExit: (_) => onHover(-1),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedScale(
                scale: isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: isHovered ? Colors.white12 : Colors.transparent,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: label,
                          style: baseStyle.copyWith(
                            fontWeight:
                                isHovered ? FontWeight.bold : FontWeight.normal,
                            color: Colors.white.withOpacity(
                              isHovered ? 1 : 0.7,
                            ),
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Transform.translate(
                            offset: const Offset(2, -8),
                            child: Text(
                              idx,
                              style: baseStyle.copyWith(
                                fontSize: 30 * 0.3,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(
                                  isHovered ? 1 : 0.7,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
