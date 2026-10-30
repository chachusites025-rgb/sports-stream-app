import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF140E13);
  static const Color darkSurface = Color(0xFF1C151A);
  static const Color darkCard = Color(0xFF231B20);
  static const Color darkCardBorder = Color(0xFF32262E);

  static const Color accentRed = Color(0xFFE12B4C);
  static const Color accentPink = Color(0xFFFF3B5C);
  static const Color liveGreen = Color(0xFF22C55E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E8E97);
  static const Color textMuted = Color(0xFF6D6067);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: accentRed,
      colorScheme: const ColorScheme.dark(
        primary: accentRed,
        secondary: accentPink,
        surface: darkSurface,
        background: darkBackground,
        error: accentPink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: darkCardBorder, width: 1),
        ),
      ),
    );
  }
}
