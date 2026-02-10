import 'package:flutter/material.dart';

/// Ocean Professional application theme.
///
/// Blue primary (#2563EB) with amber accent (#F59E0B), subtle shadows,
/// rounded corners, and consistent typography/spacing.
///
/// Centralizing these values ensures every screen (forms, buttons, cards,
/// app bars) stays visually consistent.
class AppTheme {
  static const Color _primary = Color(0xFF2563EB);
  static const Color _secondary = Color(0xFFF59E0B);
  static const Color _error = Color(0xFFEF4444);

  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _text = Color(0xFF111827);
  static const Color _bg = Color(0xFFF9FAFB);

  static const double _radiusSm = 12;
  static const double _radiusMd = 14;
  static const double _radiusLg = 18;

  static const EdgeInsets _fieldPadding =
      EdgeInsets.symmetric(horizontal: 14, vertical: 14);

  static Color _onColor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
          ? Colors.white
          : _text;

  static ThemeData get lightTheme {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      error: _error,
      brightness: Brightness.light,
    );

    final TextTheme baseText =
        Typography.blackMountainView.apply(bodyColor: _text, displayColor: _text);

    final TextTheme textTheme = baseText.copyWith(
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.1,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        height: 1.35,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bg,
      textTheme: textTheme,

      // App bars: clean surface, subtle divider, strong title.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        surfaceTintColor: scheme.surface,
      ),

      // Cards: rounded, subtle shadow for depth (Ocean Professional style).
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(20),
        surfaceTintColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: DividerThemeData(
        color: Colors.black.withAlpha(14),
        space: 24,
        thickness: 1,
      ),

      // Inputs: filled, rounded, consistent padding and focus state.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        labelStyle: TextStyle(color: scheme.onSurface.withAlpha(170)),
        hintStyle: TextStyle(color: scheme.onSurface.withAlpha(120)),
        helperStyle: TextStyle(color: scheme.onSurface.withAlpha(140)),
        errorStyle: const TextStyle(color: _error, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: BorderSide(color: Colors.black.withAlpha(18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: BorderSide(color: Colors.black.withAlpha(18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: _primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: _error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: _error, width: 1.6),
        ),
        contentPadding: _fieldPadding,
      ),

      // Buttons: consistent height, rounded corners, strong labels.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0.5,
          shadowColor: Colors.black.withAlpha(18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
          side: BorderSide(color: scheme.primary.withAlpha(90)),
          textStyle: textTheme.labelLarge?.copyWith(color: scheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(color: scheme.primary),
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusSm),
          ),
        ),
      ),

      // Segmented controls used for Password/OTP toggles.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusMd),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ),

      // Checkbox style consistent with accents.
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: Colors.black.withAlpha(24)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
        ),
      ),

      // Small icon theme polish.
      iconTheme: IconThemeData(color: scheme.onSurface.withAlpha(200)),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface.withAlpha(200),
        textColor: scheme.onSurface,
      ),

      // Optional: keep FABs consistent if introduced later.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: _onColor(scheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusLg),
        ),
      ),
    );
  }
}
