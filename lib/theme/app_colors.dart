import 'package:flutter/material.dart';

/// Skrolz color palette — dark glassmorphism with purple accents.
/// Modern 2026 design system with translucent surfaces and vibrant highlights.
abstract class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF8B5CF6); // Deep purple/violet
  static const Color primaryDark = Color(0xFF6B4FFC); // Vibrant purple
  static const Color accent = Color(0xFFEC4899); // Bright pink/purple for highlights
  static const Color accentSecondary = Color(0xFFA855F7); // Purple accent

  // Backgrounds
  static const Color darkBg = Color(0xFF0A0A0F); // Very dark background
  static const Color darkBgSecondary = Color(0xFF0F0F14); // Slightly lighter dark
  static const Color lightBg = Color(0xFFFAFAFA); // Off-white
  static const Color lightBgSecondary = Color(0xFFF5F5F7); // Slightly darker light

  // Surface colors (for glassmorphism)
  static const Color surfaceDark = Color(0xCC14141E); // Translucent dark (rgba(20, 20, 30, 0.8))
  static const Color surfaceLight = Color(0xD9FFFFFF); // Translucent white (rgba(255, 255, 255, 0.85))
  
  // Text colors
  static const Color textDark = Color(0xFFE5E5E5); // Light text on dark
  static const Color textDarkSecondary = Color(0xFFB0B0B0); // Secondary text on dark
  static const Color textLight = Color(0xFF1A1A1A); // Dark text on light
  static const Color textLightSecondary = Color(0xFF666666); // Secondary text on light

  // Semantic colors
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Glass surface helpers
  static Color glassLight(BuildContext context) =>
      surfaceLight.withValues(alpha: 0.9);
  static Color glassBorderLight(BuildContext context) =>
      Colors.white.withValues(alpha: 0.1);
  static Color glassDark(BuildContext context) =>
      surfaceDark.withValues(alpha: 0.85);
  static Color glassBorderDark(BuildContext context) =>
      Colors.white.withValues(alpha: 0.15);

  // Gradient accents
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, accent],
  );
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentSecondary],
  );
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBg, darkBgSecondary],
  );
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightBg, lightBgSecondary],
  );
}
