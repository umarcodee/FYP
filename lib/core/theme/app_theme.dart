import 'package:flutter/material.dart';

/// Futuristic theme with dark mode and neon accents
class AppTheme {
  // Color palette
  static const Color primaryNeon = Color(0xFF00FFFF); // Cyan neon
  static const Color secondaryNeon = Color(0xFFFF00FF); // Magenta neon
  static const Color accentNeon = Color(0xFF00FF00); // Green neon
  static const Color warningNeon = Color(0xFFFFFF00); // Yellow neon
  static const Color dangerNeon = Color(0xFFFF0040); // Red neon
  
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF2A2A2A);
  
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0F0);

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryNeon,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Orbitron',
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryNeon,
        surface: darkSurface,
        background: darkBg,
        error: dangerNeon,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        iconTheme: IconThemeData(color: primaryNeon),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 8,
        shadowColor: primaryNeon.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryNeon.withOpacity(0.3), width: 1),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: Colors.black,
          elevation: 8,
          shadowColor: primaryNeon.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryNeon,
        foregroundColor: Colors.black,
        elevation: 12,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryNeon.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryNeon.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryNeon, width: 2),
        ),
        labelStyle: TextStyle(color: primaryNeon.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: primaryNeon,
        size: 24,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        displaySmall: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'Orbitron',
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Orbitron',
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Orbitron',
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Orbitron',
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Orbitron',
        ),
        titleSmall: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Orbitron',
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryNeon,
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Orbitron',
      
      colorScheme: const ColorScheme.light(
        primary: primaryNeon,
        secondary: secondaryNeon,
        surface: lightSurface,
        background: lightBg,
        error: dangerNeon,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        iconTheme: IconThemeData(color: primaryNeon),
      ),
      
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 4,
        shadowColor: primaryNeon.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryNeon.withOpacity(0.2), width: 1),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: primaryNeon.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
      ),
    );
  }
}