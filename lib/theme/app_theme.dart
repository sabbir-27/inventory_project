import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color secondaryColor = Color(0xFFFF8F00);
  static const Color tertiaryColor = Color(0xFF2E7D32);
  static const Color scaffoldBackgroundColor = Color(0xFFF2F6FC);

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        onSurface: Colors.black.withValues(alpha: 0.9),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // Professional Font Configuration: Montserrat for Headings, Open Sans for Body
      textTheme: GoogleFonts.openSansTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(textStyle: baseTextTheme.displayLarge),
        displayMedium: GoogleFonts.montserrat(textStyle: baseTextTheme.displayMedium),
        displaySmall: GoogleFonts.montserrat(textStyle: baseTextTheme.displaySmall),
        headlineLarge: GoogleFonts.montserrat(textStyle: baseTextTheme.headlineLarge),
        headlineMedium: GoogleFonts.montserrat(textStyle: baseTextTheme.headlineMedium),
        headlineSmall: GoogleFonts.montserrat(textStyle: baseTextTheme.headlineSmall),
        titleLarge: GoogleFonts.montserrat(textStyle: baseTextTheme.titleLarge),
        titleMedium: GoogleFonts.montserrat(textStyle: baseTextTheme.titleMedium),
        titleSmall: GoogleFonts.montserrat(textStyle: baseTextTheme.titleSmall),
      ).apply(
        bodyColor: Colors.black.withValues(alpha: 0.9),
        displayColor: Colors.black.withValues(alpha: 0.9),
      ),
    );
  }
}
