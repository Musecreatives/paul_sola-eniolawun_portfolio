import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const NavbarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          width: 49,
          height: 49,
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
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              // Navigate to the About page
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                Container(
                  width: 72,
                  height: 5,
                  decoration: BoxDecoration(color: const Color(0xFF3695E5)),
                ),
                Container(
                  width: 49,
                  height: 5,
                  decoration: BoxDecoration(color: const Color(0xFF3695E5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
