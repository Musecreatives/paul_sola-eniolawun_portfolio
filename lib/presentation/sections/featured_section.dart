import 'package:flutter/material.dart';
import '../widgets/projectItem.dart';

class FeaturedSection extends StatefulWidget {
  const FeaturedSection({super.key});

  @override
  State<FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<FeaturedSection> {
  // Accent & background colors
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 640,
                    height: 250,
                    child: Image.asset(
                      'assets/images/work-1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 30),
                  Positioned(
                    top: 0,
                    left: 400,
                    child: SizedBox(
                      width: 640,
                      height: 250,
                      child: Image.asset(
                        'assets/images/work-2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: 640,
                    height: 250,
                    child: Image.asset(
                      'assets/images/work-3.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My featured works',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Here are a selection of my recent projects',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      ProjectItem(
                        title: 'RapidRobo Website',
                        description:
                            'Rapidrobo is a trading bot product that helps newbies.',
                      ),
                      ProjectItem(
                        title: 'National Centre for Remote Sensing Website',
                        description:
                            'NCRS app is a government‑integrated website for remote‑sensing data.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
