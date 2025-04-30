import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/views/home/homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muse Creative - Paul Sola-Eniolawun',
      theme: ThemeData(
        // set Montserrat as the default text theme:
        textTheme: GoogleFonts.montserratAlternatesTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: const Color(0xFF3DA9FC),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
