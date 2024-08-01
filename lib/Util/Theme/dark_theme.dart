import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    background: Colors.black,
    primary: Colors.white,
    secondary: Colors.grey[400]!,
    onPrimary: const Color(0xff607d8b),
    outline: Colors.grey[800]!,
    seedColor: const Color(0xff607d8b),
  ),
  cardTheme: CardTheme(
    color: Colors.black,
    shadowColor: Colors.grey.shade400,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 3,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
    ),
    displayLarge: TextStyle(
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
    ),
    headlineLarge: TextStyle(
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
    ),
    headlineSmall: TextStyle(
      color: Colors.white,
    ),
    labelLarge: TextStyle(
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
    ),
  ),
// listTileTheme: ListTileThemeData(
//   tileColor: Colors.grey [600]!,
//   shape: RoundedRectangleBorder( //<-- SEE HERE
//     side: BorderSide(width: 2,color: Colors.grey [800]!),
//     borderRadius: BorderRadius.circular(10),
//   ),
// )
);
