// lib/widgets/pop_button.dart

import 'package:flutter/material.dart';

enum _Breakpoint { mobile, tablet, desktop }

class PopButton extends StatefulWidget {
  /// The text to display
  final String label;

  /// Called when the button is tapped/clicked
  final VoidCallback onPressed;

  /// Base width for desktop
  final double baseWidth;

  /// Base height for desktop
  final double baseHeight;

  const PopButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.baseWidth = 384,
    this.baseHeight = 83.57,
    required int width,
    required int height,
  });

  @override
  _PopButtonState createState() => _PopButtonState();
}

class _PopButtonState extends State<PopButton> {
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
    final w = MediaQuery.of(context).size.width;
    final bp = _bpForWidth(w);

    // scale factors per breakpoint
    final width =
        bp == _Breakpoint.desktop
            ? widget.baseWidth
            : bp == _Breakpoint.tablet
            ? widget.baseWidth * 0.75
            : widget.baseWidth * 0.6;

    final height =
        bp == _Breakpoint.desktop
            ? widget.baseHeight
            : bp == _Breakpoint.tablet
            ? widget.baseHeight * 0.75
            : widget.baseHeight * 0.6;

    // text + icon sizing
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

    // layered‐back offsets & sizes (ratios from original)
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

    // hover scale
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
            width: width,
            height: height,
            child: Stack(
              children: [
                // BACK LAYER (colored + white border)
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

                // FRONT LAYER (just white border)
                Positioned(
                  left: frontLeft,
                  top: 0,
                  child: Container(
                    width: layerW,
                    height: layerH,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Text + arrow, centered
                Center(
                  child: SizedBox(
                    // center region shrinks by same ratio as original
                    width: width * (384 - 63.62) / 384,
                    height: height * 39.23 / 83.57,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
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
