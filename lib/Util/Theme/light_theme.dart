import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    background: Colors.white,
    primary: Colors.white,
    secondary: Colors.grey[400]!,
    onPrimary: const Color(0xff607d8b),
    outline: Colors.blue,
    seedColor: const Color(0xff607d8b),
  ),
    cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
    ),// ColorScheme.dark
);
