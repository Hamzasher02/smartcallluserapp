import 'package:flutter/material.dart';
ThemeData darkTheme = ThemeData(
brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.dark(
  background: Colors.black,
  primary: Colors.white,
  secondary: Colors.grey [400]!,
    onPrimary: Color(0xff607d8b),
    outline: Colors.grey [800]!
),
  cardTheme: CardTheme(
    color: Colors.grey [600]!,
      shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(5),
),

    elevation: 3,
  ),
  // listTileTheme: ListTileThemeData(
  //   tileColor: Colors.grey [600]!,
  //   shape: RoundedRectangleBorder( //<-- SEE HERE
  //     side: BorderSide(width: 2,color: Colors.grey [800]!),
  //     borderRadius: BorderRadius.circular(10),
  //   ),
  // )
);