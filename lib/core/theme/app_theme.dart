import 'package:flutter/material.dart';

class AppTheme {
  static const Color cream = Color(0xFFFFF7EC);
  static const Color warmPeach = Color(0xFFF6D5AE);
  static const Color ginger = Color(0xFFE89A3D);
  static const Color softOrange = Color(0xFFF2B56B);
  static const Color brownText = Color(0xFF6B4A2E);
  static const Color cardWhite = Color(0xFFFFFDF9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ginger,
      primary: ginger,
      secondary: softOrange,
      surface: cardWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cream,
      foregroundColor: brownText,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: cardWhite,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ginger, width: 1.2),
      ),
    ),
  );
}
