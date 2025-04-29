class Certificate {
  final String title;
  final List<String> specialization;
  final List<String> tools;
  final String subtitle;
  final String imageAsset;
  final String date;

  Certificate({
    required this.subtitle,
    required this.title,
    required this.specialization,
    required this.tools,
    required this.imageAsset,
    required this.date,
  });
}
