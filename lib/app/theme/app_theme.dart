import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.surfaceDark,
        error: AppColors.expense,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.expense,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
