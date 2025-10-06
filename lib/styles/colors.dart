import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Deep Purple/Indigo
  static const Color primary = Color(0xFF6366F1);       // Vibrant Indigo
  static const Color primaryLight = Color(0xFFA5B4FC);  // Light Indigo
  static const Color primaryDark = Color(0xFF4338CA);   // Dark Indigo

  // Secondary / Accent Colors - Teal/Cyan
  static const Color secondary = Color(0xFF14B8A6);     // Teal
  static const Color secondaryLight = Color(0xFF5EEAD4);
  static const Color secondaryDark = Color(0xFF0F766E);

  // Success, Warning, Error Colors
  static const Color success = Color(0xFF10B981);        // Emerald Green
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color error = Color(0xFFEF4444);          // Red

  // Neutral / Grayscale - Modern slate tones
  static const Color black = Color(0xFF0F172A);          // Slate 900
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF64748B);           // Slate 500
  static const Color lightGray = Color(0xFFF1F5F9);     // Slate 100
  static const Color darkGray = Color(0xFF334155);       // Slate 700

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);     // Soft slate background
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);    // Slate 900
  static const Color textSecondary = Color(0xFF64748B);  // Slate 500
  static const Color textOnPrimary = white;
  static const Color textOnSecondary = Color(0xFF0F172A);
  
  // Additional Modern Colors
  static const Color accent = Color(0xFFEC4899);         // Pink accent
  static const Color info = Color(0xFF3B82F6);           // Blue
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
  ];
}