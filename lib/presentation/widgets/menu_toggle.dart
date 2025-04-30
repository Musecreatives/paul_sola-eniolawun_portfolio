import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/routes/route_transitions.dart';
import 'package:muse_creatives_portfolio/presentation/views/menu/menu_page.dart';

class MenuToggleButton extends StatefulWidget {
  const MenuToggleButton({Key? key}) : super(key: key);

  @override
  _MenuToggleButtonState createState() => _MenuToggleButtonState();
}

class _MenuToggleButtonState extends State<MenuToggleButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // 1) detect hover
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        // 2) pulse/scale on hover
        scale: _hovering ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          // 3) subtle background change
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _hovering ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            // 4) ripple + tap handling
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              // navigate immediately (or use a fast slide)
              Navigator.of(
                context,
              ).push(createSlideDownRoute(const MenuPage()));
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // animate the bar widths on hover
                Container(
                  width: _hovering ? 60 : 55,
                  height: 4,
                  color: const Color(0xFF3695E5),
                ),
                const SizedBox(height: 8),
                Container(
                  width: _hovering ? 50 : 35,
                  height: 4,
                  color: const Color(0xFF3695E5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
