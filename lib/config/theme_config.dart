import 'package:flutter/material.dart';

class AppTheme {
  // ڕەنگە سەرەکییەکان بۆ ڕووکاری ئارام و پیشەیی.
  static const Color ink = Color(0xFF173A40);
  static const Color primaryColor = Color(0xFF176B67);
  static const Color accentColor = Color(0xFFE98954);
  static const Color successColor = Color(0xFF218B6E);
  static const Color errorColor = Color(0xFFC94B4B);
  static const Color warningColor = Color(0xFFD99A37);
  static const Color backgroundColor = Color(0xFFF5F7F6);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE2E9E7);
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF607275);
  static const Color textHint = Color(0xFFA8B6B6);

  static ThemeData lightTheme = ThemeData(
    // theme ـی ڕوون بۆ هەموو پەڕەکانی ئەپەکە.
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      surface: surfaceColor,
      onSurface: ink,
      error: errorColor,
    ),
    fontFamily: 'Rudaw',
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Rudaw',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textHint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Rudaw',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: 'Rudaw',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Rudaw',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Rudaw',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Rudaw',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: TextStyle(fontFamily: 'Rudaw', fontSize: 15, color: ink),
      bodyMedium: TextStyle(fontFamily: 'Rudaw', fontSize: 13, color: ink),
      bodySmall: TextStyle(
        fontFamily: 'Rudaw',
        fontSize: 11,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Rudaw',
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
