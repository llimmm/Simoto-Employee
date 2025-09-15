import 'package:flutter/material.dart';

class AppTheme {
  // Primary purple color
  static const Color primaryPurple = Color(0xFF5753EA);

  // Light purple variations
  static const Color lightPurple = Color(0xFFE8E7FF);
  static const Color lightPurpleBackground = Color(0xFFF5F4FF);

  // Dark purple variations
  static const Color darkPurple = Color(0xFF3D3A9E);
  static const Color darkerPurple = Color(0xFF2A2770);

  // Accent colors
  static const Color accentPurple = Color(0xFF7B78F5);
  static const Color lightAccentPurple = Color(0xFFB5B2FF);

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F4FF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color darkCardBackground = Color(0xFF282828);

  // Text colors
  static const Color primaryText = Color(0xFF282828);
  static const Color secondaryText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow colors
  static const Color shadowColor = Color(0x1A000000);

  // Border colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color lightBorderColor = Color(0xFFF0F0F0);

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.purple,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: accentPurple,
        surface: cardBackground,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: primaryText,
        onBackground: primaryText,
        onError: Colors.white,
      ),
    );
  }
}
