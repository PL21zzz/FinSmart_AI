import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0F172A); // Deep Slate / Navy
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color accent = Color(0xFF6366F1); // Indigo Accent

  // Financial Status Colors
  static const Color income = Color(0xFF10B981); // Emerald Green
  static const Color expense = Color(0xFFF43F5E); // Vivid Rose Red
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color info = Color(0xFF3B82F6); // Electric Blue

  // Neutral Colors (Dark Mode First)
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF131C2E);
  static const Color cardDark = Color(0xFF1E293B);

  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
