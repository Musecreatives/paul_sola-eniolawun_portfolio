// lib/widgets/pop_button.dart

import 'package:flutter/material.dart';

class ctaButton extends StatefulWidget {
  /// The text to display
  final String label;

  /// Called when the button is tapped/clicked
  final VoidCallback onPressed;

  /// Total width of the button
  final double width;

  /// Total height of the button
  final double height;

  const ctaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 384,
    this.height = 83.57,
  });

  @override
  _ctaButtonState createState() => _ctaButtonState();
}

class _ctaButtonState extends State<ctaButton> {
  bool _hovering = false;

  void _onEnter(PointerEvent _) => setState(() => _hovering = true);
  void _onExit(PointerEvent _) => setState(() => _hovering = false);

  @override
  Widget build(BuildContext context) {
    // Scale factor on hover
    final scale = _hovering ? 1.05 : 1.0;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                // BACK LAYER (colored + white border)
                Positioned(
                  left: 26,
                  top: 6.82,
                  child: Container(
                    width: widget.width - 37.62,
                    height: widget.height - 6.82,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF3695E5),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // FRONT LAYER (just white border)
                Positioned(
                  left: 37.62,
                  top: 0,
                  child: Container(
                    width: widget.width - 37.62,
                    height: widget.height - 6.82,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Text + arrow
                Center(
                  child: SizedBox(
                    width:
                        widget.width - 63.62, // adjust so text+icon sit nicely
                    height: 39.23,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
