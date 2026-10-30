import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF0B0C0E);
  static const Color darkSurface = Color(0xFF141518);
  static const Color darkCard = Color(0xFF1A1B1F);
  static const Color darkCardBorder = Color(0x14FFFFFF);

  static const Color brandGreen = Color(0xFF00E676);
  static const Color brandGreenGlow = Color(0x5900E676);
  static const Color brandGreenSubtle = Color(0x1F00E676);

  // Aliases for compatibility
  static const Color primaryGreen = brandGreen;
  static const Color primaryCyan = brandGreen;
  static const Color accentLiveRed = Color(0xFFFF3366);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EA7);
  static const Color textMuted = Color(0xFF63636E);

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
          side: BorderSide.none,
        ),
      ),
    );
  }
}
