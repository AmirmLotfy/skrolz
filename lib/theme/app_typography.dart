import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens — Plus Jakarta Sans (EN), Cairo (AR).
/// Per-locale sizes/line-height/letter-spacing; use with [AppTypography.of].
class AppTypography {
  AppTypography._();

  static TextTheme _baseEn() {
    return GoogleFonts.plusJakartaSansTextTheme();
  }

  static TextTheme _baseAr() {
    return GoogleFonts.cairoTextTheme();
  }

  /// Build text theme for the given [locale]. Prefer [BuildContext] via [of].
  static TextTheme forLocale(Locale locale) {
    final isAr = locale.languageCode == 'ar';
    final base = isAr ? _baseAr() : _baseEn();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.3,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Text theme for current locale; use in [ThemeData.textTheme].
  static TextTheme of(BuildContext context) {
    return forLocale(Localizations.localeOf(context));
  }
}
