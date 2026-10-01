// lib/presentation/views/project/project_page.dart

import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/project.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  // Replace these with your real project data
  List<Project> get _projects => [
    Project(
      name: 'RapidRobo Website',
      summary:
          'A responsive landing page designed and developed to represent RapidRobo Limited, a trading robot for digital asset trading like crypto, forex and prop firm trading. The project delivers a sleek, fast-loading site communicating the brand’s tech-forward identity while remaining accessible across devices.',
      tech: [
        'Flutter Web',
        'Dart',
        'Firebase Hosting',
        'Figma (UI/UX)',
        'Git & GitHub',
        'Netlify',
      ],
      platforms: ['Web'],
      goals: [
        'Build a visually engaging, responsive landing page',
        'Ensure seamless UX across mobile & desktop',
        'Deploy quickly with minimal backend dependencies',
        'Showcase company offerings, contact form & animations',
      ],
      link: 'https://rapidrobo.org',
    ),
    Project(
      name: 'NCRS GeoSmart',
      summary:
          'Led development of a GIS-driven web platform for the National Centre for Remote Sensing (NCRS). Built main corporate site and a data-intensive GeoSmart app for geospatial analysis & visualization.',
      tech: [
        'Next.js',
        'Node.js/Express',
        'PostgreSQL',
        'Mapbox/Leaflet.js',
        'Tailwind CSS',
        'JWT/OAuth2.0',
      ],
      platforms: ['Web'],
      goals: [
        'Digitize NCRS ops via a scalable web platform',
        'Build interactive geospatial dashboards',
        'Enable real‐time data visualization & remote processing',
        'Ensure high performance & secure data access',
      ],
      link: 'https://ncrs.gov.ng',
    ),
    Project(
      name: 'Moveables Logistics',
      summary:
          'An end-to-end logistics & delivery management platform for Moveables Technologies Ltd. Connected SMEs with vetted service providers, optimized flows & streamlined dispatch.',
      tech: [
        'Flutter (Mobile+Web)',
        'Firebase (Auth, Firestore, Functions)',
        'Node.js/Express (APIs)',
        'Figma',
        'Trello/Slack/Notion',
      ],
      platforms: ['iOS', 'Android', 'Web'],
      goals: [
        'Build scalable delivery tracking platform for small businesses',
        'Enable SMEs to book, track & manage deliveries',
        'Provide partner dashboard for delivery agents',
        'Launch MVP with multi-platform support',
      ],
      link: 'https://moveable.com.ng',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kblack,
      appBar: const NavbarWidget(),
      body: LayoutBuilder(
        builder: (ctx, bc) {
          final isWide = bc.maxWidth >= 800;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 16,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Heading ───────────────────────────────────────────
                Center(
                  child: Text(
                    'Browse my projects',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ─── Project Cards ──────────────────────────────────────
                for (final p in _projects) ...[
                  _ProjectCard(project: p, isWide: isWide),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final bool isWide;
  const _ProjectCard({required this.project, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.kprimary; // your blue
    final radius = BorderRadius.circular(16.0);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          children: [
            Image.asset(
              'assets/icons/flat-color-icons_folder.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Project Overview: ${project.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Summary heading
        Row(
          children: [
            Image.asset(
              'assets/icons/fluent-emoji-flat_brain.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 6),
            const Text(
              'Project Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Summary text
        Text(
          project.summary,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Details row or wrap
        isWide
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DetailColumn(
                    icon: Icons.build,
                    label: 'Technologies Used',
                    items: project.tech,
                  ),
                ),
                Expanded(
                  child: _DetailColumn(
                    icon: Icons.computer,
                    label: 'Available Platforms',
                    items: project.platforms,
                  ),
                ),
                Expanded(
                  child: _DetailColumn(
                    icon: Icons.flag,
                    label: 'Project Goals',
                    items: project.goals,
                  ),
                ),
                Expanded(
                  child: _DetailColumn(
                    icon: Icons.link,
                    label: 'Project Links',
                    items: [project.link],
                    isLink: true,
                  ),
                ),
              ],
            )
            : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _DetailColumn(
                    icon: Icons.build,
                    label: 'Technologies',
                    items: project.tech,
                  ),
                  const SizedBox(width: 16),
                  _DetailColumn(
                    icon: Icons.computer,
                    label: 'Platforms',
                    items: project.platforms,
                  ),
                  const SizedBox(width: 16),
                  _DetailColumn(
                    icon: Icons.flag,
                    label: 'Goals',
                    items: project.goals,
                  ),
                  const SizedBox(width: 16),
                  _DetailColumn(
                    icon: Icons.link,
                    label: 'Links',
                    items: [project.link],
                    isLink: true,
                  ),
                ],
              ),
            ),
      ],
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: cardColor, borderRadius: radius),
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      ],
    );
  }
}

class _DetailColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final bool isLink;
  const _DetailColumn({
    required this.icon,
    required this.label,
    required this.items,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final it in items) ...[
            isLink
                ? GestureDetector(
                  onTap: () => launchUrl(Uri.parse(it)),
                  child: Text(
                    it,
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        it,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
