import 'package:flutter/material.dart';

import '../widgets/navbar.dart';
import '../sections/featured_section.dart';
import '../sections/hero_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4EF),
      extendBodyBehindAppBar: true,
      appBar: NavbarWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: [HeroSection(), SizedBox(height: 60), FeaturedSection()],
        ),
      ),
    );
  }
}
