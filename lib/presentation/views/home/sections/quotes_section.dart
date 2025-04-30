// lib/presentation/views/sections/quote_section.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/quote.dart';

enum Breakpoint { mobile, tablet, desktop }

class QuoteSection extends StatefulWidget {
  final List<Quote> quotes;
  final Color backgroundColor;
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
    _timer = Timer.periodic(widget.switchDuration, (_) => _nextQuote());
  }

  void _nextQuote() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.quotes.length;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Breakpoint _breakpoint(double w) {
    if (w < 600) return Breakpoint.mobile;
    if (w < 1024) return Breakpoint.tablet;
    return Breakpoint.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quotes[_currentIndex];

    return LayoutBuilder(
      builder: (_, bc) {
        final w = bc.maxWidth;
        final bp = _breakpoint(w);

        // responsive sizing
        final height =
            bp == Breakpoint.mobile
                ? 250.0
                : bp == Breakpoint.tablet
                ? 300.0
                : 400.0;
        final hPad =
            bp == Breakpoint.mobile
                ? 16.0
                : bp == Breakpoint.tablet
                ? 32.0
                : 60.0;
        final vPad =
            bp == Breakpoint.mobile
                ? 24.0
                : bp == Breakpoint.tablet
                ? 40.0
                : 60.0;
        final quoteSize =
            bp == Breakpoint.mobile
                ? 20.0
                : bp == Breakpoint.tablet
                ? 28.0
                : 36.0;
        final authorSize =
            bp == Breakpoint.mobile
                ? 14.0
                : bp == Breakpoint.tablet
                ? 16.0
                : 18.0;

        return GestureDetector(
          onTap: _nextQuote,
          child: Container(
            height: height,
            width: double.infinity,
            color: widget.backgroundColor,
            padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
            child: Stack(
              children: [
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      '“${quote.name}”',
                      key: ValueKey(quote.name),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: quoteSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      '— ${quote.author}',
                      key: ValueKey(quote.author),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: authorSize,
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
