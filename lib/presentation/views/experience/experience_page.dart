// lib/presentation/views/experience/experience_page.dart

import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ExperiencePage extends StatelessWidget {
  const ExperiencePage({Key? key}) : super(key: key);

  // ─── Skills data ───────────────────────────────────────────────
  static const _coreSkills = [
    _SkillItem(
      icon: AssetImage('assets/icons/logos_flutter.png'),
      title: 'Flutter',
      description:
          "Building software solutions using Google's cross-platform framework",
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/material-icon-theme_dart.png'),
      title: 'Dart',
      description:
          'Programming language for creating interactive, backend apps & software.',
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/devicon_javascript.png'),
      title: 'JavaScript',
      description: "Proficient in ES6, TypeScript, and its frameworks.",
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/devicon_figma.png'),
      title: 'Figma – UI/UX',
      description:
          'Designing and prototyping human-centered digital experiences.',
    ),
  ];

  static const _toolSkills = [
    _SkillItem(
      icon: AssetImage('assets/icons/Vector-1.png'),
      title: 'Git',
      description:
          'Version control for team collaboration & open-source contributions.',
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/Vector.png'),
      title: 'Visual Studio Code',
      description: 'Preferred IDE for building apps & web services.',
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/devicon_androidstudio.png'),
      title: 'Android Studio',
      description: 'Dev environment for Android & mobile emulation.',
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/devicon_firebase.png'),
      title: 'Firebase',
      description: 'GCP hosting, analytics, storage & real-time database.',
    ),
  ];

  static const _profSkills = [
    _SkillItem(
      icon: AssetImage('assets/icons/devicon_trello.png'),
      title: 'Trello',
      description: 'Visual task management & team collaboration.',
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/devicon_slack.png'),
      title: 'Slack',
      description: 'Real-time communication between teammates & clients.',
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/logos-google-analytics.png'),
      title: 'Google Analytics',
      description: 'Track visits, pageviews & site performance.',
    ),
    _SkillItem(
      icon: AssetImage('assets/icons/logos_google-meet.png'),
      title: 'Google Meet',
      description: 'Embed invites or schedule calls; simple remote meetings.',
    ),
  ];

  // ─── Experience data ───────────────────────────────────────────
  List<_ExperienceEntry> get _entries => const [
    _ExperienceEntry(
      image: AssetImage(
        'assets/icons/material-symbols_school-outline-rounded.png',
      ),
      title: 'BSc in Computer Science',
      subtitle: 'University of Benin | Edo, NG',
      bullets: [
        'Specialization: Software Engineering, C/C++ Programming',
        'CGPA: --',
      ],
      dateRange: 'October 2020 – December 2024',
    ),
    _ExperienceEntry(
      image: AssetImage('assets/icons/Work Experience.png'),
      title: 'Frontend Developer (Flutter)',
      subtitle: 'RapidRobo | Remote',
      bullets: [
        'Developed a modern landing page using Flutter Web',
        'Focused on UX animations, responsiveness, and smooth navigation',
        'Deployed the project on Netlify for fast, scalable access',
      ],
      dateRange: 'Feb 2025 – Mar 2025',
    ),
    _ExperienceEntry(
      image: AssetImage('assets/icons/Work Experience.png'),
      title: 'Co-Founder | Chief Operations Officer',
      subtitle: 'Innovated Digital | Benin, NG',
      bullets: [
        'Oversaw product strategy across web and mobile development, ensuring timely delivery and quality control',
        'Collaborated closely with design and engineering leads to scale service offerings',
        'Managed client relationships and led high-level strategy meetings with startup and enterprise partners',
      ],
      dateRange: 'April 2025 – Present',
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

          // ─── Skills Section ────────────────────────────────────────
          Widget skillsSection = Padding(
            padding: EdgeInsets.symmetric(
              vertical: 32,
              horizontal: isWide ? 160 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header underline + title
                Row(
                  children: [
                    Container(width: 40, height: 4, color: AppColors.kprimary),
                    const SizedBox(width: 12),
                    Text(
                      'Skills',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // three columns on wide, stacked on narrow
                if (isWide)
                  Column(
                    children: [
                      const _DashedHorizontalLine(),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SkillColumn('Core Skills', _coreSkills),
                          ),
                          const _DashedVerticalLine(),
                          Expanded(child: _SkillColumn('Tools', _toolSkills)),
                          const _DashedVerticalLine(),
                          Expanded(
                            child: _SkillColumn('Professional', _profSkills),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // the bottom border under the first row of items
                      const _DashedHorizontalLine(),
                    ],
                  )
                else
                  Column(
                    children: [
                      _SkillColumn('Core Skills', _coreSkills),
                      const SizedBox(height: 24),
                      _SkillColumn('Tools', _toolSkills),
                      const SizedBox(height: 24),
                      _SkillColumn('Professional', _profSkills),
                    ],
                  ),
              ],
            ),
          );

          // ─── Experience Header + CV ───────────────────────────────
          Widget headerSection = Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 160 : 16),
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Experience',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse('https://example.com/your_cv.pdf'));
                  },
                  icon: const Icon(
                    Atlas.download_arrow_down,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Download CV',
                    style: TextStyle(color: AppColors.kwhite),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kprimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );

          // ─── Timeline ───────────────────────────────────────────────
          Widget timeline = Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 160 : 16),
            child: Column(
              children: [
                for (int i = 0; i < _entries.length; i++) ...[
                  _TimelineRow(
                    entry: _entries[i],
                    showTop: i > 0,
                    showBottom: i < _entries.length - 1,
                  ),
                  if (i != _entries.length - 1) const SizedBox(height: 24),
                ],
              ],
            ),
          );

          // ─── Assemble ───────────────────────────────────────────────
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                skillsSection,
                headerSection,
                timeline,
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Skill column widget

class _SkillColumn extends StatelessWidget {
  final String title;
  final List<_SkillItem> skills;
  const _SkillColumn(this.title, this.skills);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          for (final s in skills) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kwhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Image(image: s.icon, width: 32, height: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kblack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: AppColors.kblack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillItem {
  final AssetImage icon;
  final String title, description;
  const _SkillItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ───────────────────────────────────────────────────────────────
// Dashed vertical line

class _DashedVerticalLine extends StatelessWidget {
  const _DashedVerticalLine({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 500, // adjust or make dynamic if needed
      child: LayoutBuilder(
        builder: (_, bc) {
          final dashHeight = 6.0;
          final gap = 4.0;
          final count = (bc.maxHeight / (dashHeight + gap)).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: 1,
                height: dashHeight,
                color: Colors.white24,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Dashed horizontal line
class _DashedHorizontalLine extends StatelessWidget {
  const _DashedHorizontalLine({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1500,
      height: 1,
      child: LayoutBuilder(
        builder: (_, bc) {
          final dashWidth = 6.0;
          final gap = 4.0;
          final count = (bc.maxWidth / (dashWidth + gap)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) =>
                  Container(width: dashWidth, height: 1, color: Colors.white24),
            ),
          );
        },
      ),
    );
  }
}
// ───────────────────────────────────────────────────────────────
// Timeline widgets (unchanged)

class _TimelineRow extends StatelessWidget {
  final _ExperienceEntry entry;
  final bool showTop, showBottom;
  const _TimelineRow({
    required this.entry,
    required this.showTop,
    required this.showBottom,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (showTop)
                  Expanded(
                    child: Container(width: 2, color: AppColors.kprimary),
                  ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.kwhite,
                    shape: BoxShape.circle,
                  ),
                  child: Image(image: entry.image, width: 16, height: 16),
                ),
                if (showBottom)
                  Expanded(
                    child: Container(width: 2, color: AppColors.kprimary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _ExperienceCard(entry: entry)),
        ],
      ),
    );
  }
}

class _ExperienceEntry {
  final AssetImage image;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final String dateRange;
  const _ExperienceEntry({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.dateRange,
  });
}

class _ExperienceCard extends StatelessWidget {
  final _ExperienceEntry entry;
  const _ExperienceCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kwhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            entry.subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.kprimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final b in entry.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('• '), Expanded(child: Text(b))],
              ),
            ),
          const SizedBox(height: 12),
          Text(
            entry.dateRange,
            style: TextStyle(color: AppColors.kblack, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
