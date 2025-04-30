import 'package:flutter/material.dart';
import 'package:muse_creatives_portfolio/presentation/views/menu/menu_page.dart';
import '../routes/route_transitions.dart';
import '../views/home/homepage.dart';
import 'menu_toggle.dart';

class NavbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const NavbarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(createSlideUpRoute(const HomePage()));
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/paul-icon-1.png"),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(460),
              ),
            ),
          ),
        ),
        centerTitle: false,
        actions: [MenuToggleButton(), const SizedBox(width: 8)],
      ),
    );
  }
}
