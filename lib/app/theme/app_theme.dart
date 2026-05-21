import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/theme/color_palette.dart';

/// Defines the global application theme configuration.
class AppTheme {
  /// Private constructor to prevent instantiation.
  const AppTheme._();

  /// Light theme configuration used across the application.
  static ThemeData get light => ThemeData(
    useMaterial3: true,

    // Application color scheme configuration.
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorPalette.primaryColor,
      primary: ColorPalette.primaryColor,
      secondary: ColorPalette.secondaryColor,
      tertiary: ColorPalette.tertiaryColor,
    ),

    // Default AppBar styling.
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPalette.primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    // Default elevated button styling.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
