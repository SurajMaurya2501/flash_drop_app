import 'package:flutter/material.dart';

ThemeData buildLuxuryTheme() {
  const baseBackground = Color(0xFF0A0D12);
  const accentGold = Color(0xFFE4C685);
  const textPrimary = Color(0xFFF7F2E8);

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: accentGold,
        brightness: Brightness.dark,
      ).copyWith(
        surface: const Color(0xFF121821),
        onSurface: textPrimary,
        primary: accentGold,
        onPrimary: const Color(0xFF1E1607),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: baseBackground,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF111721),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
}
