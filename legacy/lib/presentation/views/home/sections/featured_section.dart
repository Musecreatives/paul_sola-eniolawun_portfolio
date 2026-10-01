import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../widgets/projectItem.dart';

class FeaturedSection extends StatefulWidget {
  const FeaturedSection({super.key});

  @override
  State<FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<FeaturedSection>
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _controller;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_hasAnimated || info.visibleFraction < 0.16) return;
    _controller.forward();
    _hasAnimated = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return VisibilityDetector(
      key: const Key('featured-section'),
      onVisibilityChanged: _onVisibilityChanged,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Container(
            width: double.infinity,
            color: const Color(0xFFF4F4EF),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 70 : 18,
              vertical: isWide ? 84 : 44,
            ),
            child:
                isWide
                    ? _buildWideLayout(theme, constraints.maxWidth)
                    : _buildNarrowLayout(theme),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(TextTheme theme, double maxWidth) {
    final imageWidth = math.min(640.0, maxWidth * 0.48);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: imageWidth + 70,
          child: Column(
            children: List.generate(_imagePaths.length, (index) {
              return _StaggeredReveal(
                controller: _controller,
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Transform.translate(
                    offset: Offset(index == 1 ? 70 : 0, 0),
                    child: _ProjectShot(
                      imagePath: _imagePaths[index],
                      width: imageWidth,
                      height: 260,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 34),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StaggeredReveal(
                  controller: _controller,
                  index: 1,
                  child: _SectionHeader(theme: theme, isWide: true),
                ),
                const SizedBox(height: 30),
                ...List.generate(_projects.length, (index) {
                  final project = _projects[index];
                  return _StaggeredReveal(
                    controller: _controller,
                    index: index + 2,
                    child: ProjectItem(
                      title: project['title']!,
                      description: project['desc']!,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(TextTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaggeredReveal(
          controller: _controller,
          index: 0,
          child: _SectionHeader(theme: theme, isWide: false),
        ),
        const SizedBox(height: 26),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _imagePaths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder:
                (context, index) => _StaggeredReveal(
                  controller: _controller,
                  index: index + 1,
                  child: _ProjectShot(
                    imagePath: _imagePaths[index],
                    width: 320,
                    height: 210,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 26),
        ...List.generate(_projects.length, (index) {
          final project = _projects[index];
          return _StaggeredReveal(
            controller: _controller,
            index: index + 3,
            child: ProjectItem(
              title: project['title']!,
              description: project['desc']!,
              buttonWidth: 260,
              buttonHeight: 62,
            ),
          );
        }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final TextTheme theme;
  final bool isWide;

  const _SectionHeader({required this.theme, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: const Color(0xFF3695E5), width: 1.5),
          ),
          child: const Text(
            'Selected work',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'My featured works',
          style: (isWide ? theme.headlineMedium : theme.headlineSmall)
              ?.copyWith(fontWeight: FontWeight.w800, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Text(
          'A compact look at projects where design, product thinking, and Flutter engineering meet.',
          style: theme.titleMedium?.copyWith(
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ProjectShot extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const _ProjectShot({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  State<_ProjectShot> createState() => _ProjectShotState();
}

class _ProjectShotState extends State<_ProjectShot> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.035 : 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color:
                  _hovering
                      ? const Color(0xFF3695E5)
                      : Colors.black.withValues(alpha: 0.1),
              width: _hovering ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovering ? 0.18 : 0.1),
                blurRadius: _hovering ? 30 : 18,
                offset: Offset(0, _hovering ? 18 : 10),
              ),
            ],
          ),
          child: ClipRect(
            child: Image.asset(widget.imagePath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _StaggeredReveal extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _StaggeredReveal({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 0.72);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, math.min(start + 0.42, 1), curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
