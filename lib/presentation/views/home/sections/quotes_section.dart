// lib/presentation/sections/quote_section.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/quote.dart';

/// A full-width section that cycles quotes with a fade animation and
/// adjusts its height, padding and font sizes per screen size.
class QuoteSection extends StatefulWidget {
  /// List of quotes to display
  final List<Quote> quotes;

  /// Background color
  final Color backgroundColor;

  /// Duration between automatic transitions
  final Duration switchDuration;

  const QuoteSection({
    Key? key,
    required this.quotes,
    this.backgroundColor = const Color(0xFF3993E8),
    this.switchDuration = const Duration(seconds: 8),
  }) : super(key: key);

  @override
  _QuoteSectionState createState() => _QuoteSectionState();
}

class _QuoteSectionState extends State<QuoteSection> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // start the auto-cycle timer
    _timer = Timer.periodic(widget.switchDuration, (_) => _nextQuote());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _nextQuote() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.quotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quotes[_currentIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isDesktop = w >= 800;
        final isTablet = w >= 600 && w < 800;
        final isMobile = w < 600;

        // responsive measurements
        final height =
            isMobile
                ? constraints.maxHeight * 0.25
                : isTablet
                ? 300.0
                : 400.0;
        final horizontalPadding =
            isMobile
                ? 16.0
                : isTablet
                ? 32.0
                : 60.0;
        final verticalPadding =
            isMobile
                ? 24.0
                : isTablet
                ? 40.0
                : 60.0;
        final quoteFontSize =
            isMobile
                ? 20.0
                : isTablet
                ? 28.0
                : 36.0;
        final authorFontSize =
            isMobile
                ? 14.0
                : isTablet
                ? 16.0
                : 18.0;

        return GestureDetector(
          onTap: _nextQuote,
          child: Container(
            height: height,
            width: double.infinity,
            color: widget.backgroundColor,
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: Stack(
              children: [
                // Centered quote text with fade animation
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: Text(
                      '“${quote.name}”',
                      key: ValueKey(quote.name),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: quoteFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Author attribution in bottom-right
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: Text(
                      '— ${quote.author}',
                      key: ValueKey(quote.author),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: authorFontSize,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
