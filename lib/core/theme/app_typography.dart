import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextTheme forScheme(ColorScheme scheme) => TextTheme(
    displaySmall: TextStyle(
      fontSize: 36,
      height: 1.15,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: scheme.onSurface),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: scheme.onSurface),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
  );
}
