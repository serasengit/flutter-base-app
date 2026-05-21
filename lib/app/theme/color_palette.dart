// coverage:ignore-file
import 'package:flutter/material.dart';

/// Centralized application color definitions.
///
/// This class contains all colors used across the application
/// to ensure visual consistency and simplify theme management.
class ColorPalette {
  /// Private constructor to prevent instantiation.
  const ColorPalette._();

  /// Primary brand color used throughout the application.
  static const Color primaryColor = Colors.deepPurple;

  /// Secondary accent color used for highlights and UI elements.
  static const Color secondaryColor = Colors.deepPurpleAccent;

  /// Tertiary color used for complementary visual elements.
  static const Color tertiaryColor = Colors.purple;

  /// Color used to represent error states and messages.
  static const Color errorColor = Colors.red;

  /// Color used to represent success states and confirmations.
  static const Color successColor = Colors.green;

  /// Color used to represent warnings and alerts.
  static const Color warningColor = Colors.orange;
}
