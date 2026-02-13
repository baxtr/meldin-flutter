import 'package:flutter/material.dart';

class MeldenTheme {
  static const Color meldenBlue = Color(0xFF3B82F6);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: meldenBlue,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: meldenBlue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: meldenBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: meldenBlue,
        scaffoldBackgroundColor: const Color(0xFF111827),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1F2937),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF374151),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4B5563)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4B5563)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: meldenBlue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: meldenBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
