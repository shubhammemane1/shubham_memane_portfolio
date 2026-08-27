import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum FontVariant { michroma, bricolage }

class AppTheme {
  static const FontVariant fontVariant = FontVariant.bricolage;

  static TextStyle get tagFont => fontVariant == FontVariant.michroma
      ? GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)
      : GoogleFonts.spaceMono(fontSize: 12, fontWeight: FontWeight.w500);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightText,
      ),
      textTheme: _textTheme(AppColors.lightText),
      scaffoldBackgroundColor: AppColors.lightBackground,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        background: AppColors.darkBackground,
      ),
      textTheme: _textTheme(AppColors.darkText),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
    );
  }

  static TextTheme _textTheme(Color color) {
    final display = fontVariant == FontVariant.michroma
        ? GoogleFonts.michroma
        : GoogleFonts.bricolageGrotesque;
    final body = fontVariant == FontVariant.michroma
        ? GoogleFonts.inter
        : GoogleFonts.spaceMono;

    return TextTheme(
      displayLarge: display(fontSize: 72, fontWeight: FontWeight.bold, color: color),
      displayMedium: display(fontSize: 56, fontWeight: FontWeight.bold, color: color),
      displaySmall: display(fontSize: 48, fontWeight: FontWeight.bold, color: color),
      headlineLarge: display(fontSize: 40, fontWeight: FontWeight.w600, color: color),
      headlineMedium: display(fontSize: 32, fontWeight: FontWeight.w600, color: color),
      headlineSmall: display(fontSize: 24, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: color),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      bodyLarge: body(fontSize: 16, fontWeight: FontWeight.normal, color: color),
      bodyMedium: body(fontSize: 14, fontWeight: FontWeight.normal, color: color),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF10B981);
  static const secondary = Color(0xFF14B8A6);
  static const accent = Color(0xFF06B6D4);
  
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF1F2937);
  static const lightTextSecondary = Color(0xFF6B7280);
  
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF0F0F0F);
  static const darkText = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFB0B0B0);
  
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}
