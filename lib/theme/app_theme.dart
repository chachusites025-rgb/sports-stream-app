import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF090E15);
  static const Color darkSurface = Color(0xFF0F1722);
  static const Color darkCard = Color(0xFF141E2B);
  static const Color darkCardBorder = Color(0x14FFFFFF);

  static const Color brandGreen = Color(0xFF00E676);
  static const Color brandGreenGlow = Color(0x5900E676);
  static const Color brandGreenSubtle = Color(0x1F00E676);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8FA3B8);
  static const Color textMuted = Color(0xFF5A6E82);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: brandGreen,
      colorScheme: const ColorScheme.dark(
        primary: brandGreen,
        secondary: brandGreen,
        surface: darkSurface,
        background: darkBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkCardBorder, width: 1),
        ),
      ),
    );
  }
}
