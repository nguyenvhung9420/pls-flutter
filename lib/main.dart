import 'package:flutter/material.dart';
import 'package:pls_flutter/home/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData lightTheme(BuildContext context) => ThemeData(
        // useMaterial3: false,
        fontFamily: GoogleFonts.robotoMono().fontFamily,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        scaffoldBackgroundColor: const Color(0xFFF7F2EF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF50057),
          // primary: Colors.red,
        ),
      );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PLS Demo',
      theme: lightTheme(context),
      home: const MyHomePage(title: 'Home'),
    );
  }
}
