import 'package:flutter/material.dart';

class ThemeModes {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    iconTheme: const IconThemeData(color: Colors.white),  // Set icon color to white
    colorScheme: ThemeData.light().colorScheme.copyWith(
        surface: const Color(0xfff1f2f6),
        secondaryContainer: Colors.white,
        primary: Colors.black,
        outline: Colors.white,
        onPrimary: const Color(0xff8097a2),
        onSecondary: Colors.grey.shade300,
        secondary: Colors.black87),
        

  );
  
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    iconTheme: const IconThemeData(color: Colors.white),  // Set icon color to white
    colorScheme: ThemeData.dark().colorScheme.copyWith(
        surface: Colors.black,
        secondaryContainer: Colors.black,
        primary: Colors.white,
        outline: const Color(0xff3b3b3b),
        secondary: Colors.white,
        onSecondary: Colors.black,
        onPrimary: const Color(0xff8097a2)),
  );
}
