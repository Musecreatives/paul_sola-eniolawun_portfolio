// lib/presentation/views/certificates/certificates_page.dart

import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/configs/constant_color.dart';
import 'package:muse_creatives_portfolio/presentation/widgets/navbar.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../data/models/certificate.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({Key? key}) : super(key: key);

  // Replace these with your real data
  List<Certificate> get _certs => [
    Certificate(
      title: 'HNG Internship X Finalist',
      specialization: ['Mobile Development'],
      tools: ['Dart', 'Flutter', 'Git', 'VSCode'],
      imageAsset: 'assets/images/hngx_finalist-cert_1.png',
      date: '16-11-2023',
      subtitle: 'Finalist in the HNG Internship X program.',
    ),
    Certificate(
      title: 'Diploma in Web Design and Development',
      specialization: ['Software Development', 'Website Development'],
      tools: ['Adobe Suite', 'Figma', 'Illustrator'],
      imageAsset: 'assets/images/diploma_edobits_cert_2.png',
      date: '03-07-2020',
      subtitle: 'Completed a 2 year diploma in web design and development.',
    ),
    Certificate(
      title: 'Digital Garage Completion',
      specialization: ['MS Office', 'Graphic Design'],
      tools: ['PowerPoint', 'Photoshop'],
      imageAsset: 'assets/images/digital_garage_edobits.png',
      date: '20-12-2019',
      subtitle:
          'Completed a course on digital skills and gained valuable experience.',
    ),

    Certificate(
      title: 'Google Digital Garage',
      specialization: ['Digital Marketing'],
      tools: ['Google Ads', 'Google Analytics'],
      imageAsset: 'assets/images/diploma_edobits_cert_2.png',
      date: '20-12-2019',
      subtitle:
          'Completed a course on digital marketing and gained valuable experience.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kwhite,
      appBar: const NavbarWidget(),
      body: LayoutBuilder(
        builder: (ctx, bc) {
          final isWide = bc.maxWidth >= 800;
          final crossCount = isWide ? 2 : 1;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Heading ────────────────────────────
                Row(
                  children: [
                    Container(width: 40, height: 4, color: AppColors.kblack),
                    const SizedBox(width: 12),
                    Text(
                      'Certificates',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kblack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Grid of thumbnails ─────────────────
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 16 / 9,
                    ),
                    itemCount: _certs.length,
                    itemBuilder: (ctx, i) {
                      final cert = _certs[i];
                      return GestureDetector(
                        onTap: () => _showPreview(context, cert),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            cert.imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPreview(BuildContext context, Certificate cert) {
    showGeneralDialog(
      barrierLabel: 'Certificate Preview',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: _PreviewDialog(cert: cert),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        );
      },
    );
  }
}

/// The white “lightbox” dialog showing full image + info
class _PreviewDialog extends StatelessWidget {
  final Certificate cert;
  const _PreviewDialog({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kwhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Header with title + close button ───
          Row(
            children: [
              Icon(Icons.school, color: AppColors.kprimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      cert.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cert.subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.kblack,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, size: 28),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Specialization & Tools info ────────
          _InfoRow(
            label: 'Specialization:',
            value: cert.specialization.join(', '),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Trained to proficiency in following tools:',
            value: cert.tools.join(', '),
          ),
          const SizedBox(height: 30),

          // ─── Big image preview ───────────────────
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(1),
            dashPattern: const [10, 10],
            color: AppColors.kprimary,
            strokeWidth: 1,
            padding: const EdgeInsets.all(15),
            // 5. Inside the dashed border we clip & show your image
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(cert.imageAsset, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              cert.date,
              style: TextStyle(
                color: AppColors.kblack,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Expanded(child: Text(value)),
      ],
    );
  }
}
