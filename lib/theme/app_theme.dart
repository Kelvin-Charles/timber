import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF2E7D32); // Green
  static const Color secondaryColor = Color(0xFF1565C0); // Blue
  static const Color accentColor = Color(0xFFFFA000); // Amber
  
  // Background colors
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color cardColor = Colors.white;
  
  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  
  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF0288D1); // Light Blue
  
  // Get the theme data
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: 'Roboto',
    );
  }
} 