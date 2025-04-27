import 'package:flutter/material.dart';

import '../../../data/models/quote.dart';
import '../../widgets/navbar.dart';
import 'sections/featured_section.dart';
import 'sections/footer_section.dart';
import 'sections/hero_section.dart';
import 'sections/quotes_section.dart';

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
          children: [
            HeroSection(),
            SizedBox(height: 60),
            FeaturedSection(),
            QuoteSection(
              quotes: [
                Quote(name: 'Stay hungry, stay foolish', author: 'Steve Jobs'),
                Quote(
                  name:
                      'The only limit to our realization of tomorrow is our doubts of today',
                  author: 'Franklin D. Roosevelt',
                ),
                Quote(
                  name: 'The best way to predict the future is to invent it',
                  author: 'Alan Kay',
                ),
                Quote(
                  name:
                      'Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful',
                  author: 'Albert Schweitzer',
                ),
              ],
            ),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}
