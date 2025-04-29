import 'package:flutter/material.dart';

class _ExperienceEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final String dateRange;

  const _ExperienceEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.dateRange,
  });
}
