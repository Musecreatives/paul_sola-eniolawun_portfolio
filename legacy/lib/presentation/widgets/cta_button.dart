// lib/widgets/cta_button.dart

import 'package:flutter/material.dart';

enum _Breakpoint { mobile, tablet, desktop }

class ctaButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
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

  _Breakpoint _bpForWidth(double w) {
    if (w < 600) return _Breakpoint.mobile;
    if (w < 1024) return _Breakpoint.tablet;
    return _Breakpoint.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final bp = _bpForWidth(screenW);

    final scaleFactor =
        bp == _Breakpoint.desktop
            ? 1.0
            : bp == _Breakpoint.tablet
            ? 0.75
            : 0.6;
    final width = widget.width * scaleFactor;
    final height = widget.height * scaleFactor;

    final fontSize =
        bp == _Breakpoint.desktop
            ? 20.0
            : bp == _Breakpoint.tablet
            ? 16.0
            : 14.0;
    final iconSize =
        bp == _Breakpoint.desktop
            ? 30.0
            : bp == _Breakpoint.tablet
            ? 24.0
            : 20.0;

    // ratios from your original design
    const backLeftRatio = 26 / 384;
    const backTopRatio = 6.82 / 83.57;
    const layerWidthRatio = (384 - 37.62) / 384;
    const layerHeightRatio = (83.57 - 6.82) / 83.57;
    const frontLeftRatio = 37.62 / 384;

    final backLeft = width * backLeftRatio;
    final backTop = height * backTopRatio;
    final layerW = width * layerWidthRatio;
    final layerH = height * layerHeightRatio;
    final frontLeft = width * frontLeftRatio;

    final hoverScale = _hovering ? 1.05 : 1.0;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: hoverScale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                // BACK LAYER
                Positioned(
                  left: backLeft,
                  top: backTop,
                  child: Container(
                    width: layerW,
                    height: layerH,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF3695E5),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // FRONT LAYER
                Positioned(
                  left: frontLeft,
                  top: 0,
                  child: Container(
                    width: layerW,
                    height: layerH,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // **NEW: always center label+icon**
                Positioned.fill(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                          size: iconSize,
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
