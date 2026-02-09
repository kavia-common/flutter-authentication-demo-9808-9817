import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Color(0xFF2563EB);
  static const Color _secondary = Color(0xFFF59E0B);
  static const Color _error = Color(0xFFEF4444);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _text = Color(0xFF111827);
  static const Color _bg = Color(0xFFF9FAFB);

  static ThemeData get lightTheme {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      error: _error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bg,
      textTheme: Typography.blackMountainView.apply(
        bodyColor: _text,
        displayColor: _text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withAlpha(18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withAlpha(18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 1.5,
        shadowColor: Colors.black.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
