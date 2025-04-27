import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../data/models/quote.dart';

/// A full-width section that cycles quotes with a fade animation
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
    this.switchDuration = const Duration(seconds: 5),
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

    return GestureDetector(
      onTap: _nextQuote,
      child: Container(
        height: 400,
        width: double.infinity,
        color: widget.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
