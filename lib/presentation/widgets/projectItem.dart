import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/views/project/project_page.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/cta_button.dart';

class ProjectItem extends StatefulWidget {
  final String title;
  final String description;
  final double buttonWidth;
  final double buttonHeight;

  const ProjectItem({
    super.key,
    required this.title,
    required this.description,
    this.buttonWidth = 320,
    this.buttonHeight = 70,
  });

  @override
  State<ProjectItem> createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 700;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 18 : 22,
          horizontal: isCompact ? 16 : 24,
        ),
        decoration: BoxDecoration(
          color:
              _hovering ? Colors.white : Colors.white.withValues(alpha: 0.48),
          border: Border.all(
            color:
                _hovering
                    ? const Color(0xFF3695E5)
                    : Colors.black.withValues(alpha: 0.08),
            width: _hovering ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovering ? 0.12 : 0.04),
              blurRadius: _hovering ? 26 : 12,
              offset: Offset(0, _hovering ? 14 : 6),
            ),
          ],
        ),
        child: Transform.translate(
          offset: Offset(_hovering ? 6 : 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 5,
                    height: isCompact ? 54 : 68,
                    color:
                        _hovering
                            ? const Color(0xFF3695E5)
                            : Colors.black.withValues(alpha: 0.18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: isCompact ? 22 : 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: isCompact ? 15 : 18,
                            color: Colors.black54,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment:
                    isCompact ? Alignment.centerLeft : Alignment.centerRight,
                child: SizedBox(
                  width: widget.buttonWidth,
                  height: widget.buttonHeight,
                  child: ctaButton(
                    label: 'View Project',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProjectPage(),
                        ),
                      );
                    },
                    width: widget.buttonWidth,
                    height: widget.buttonHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
