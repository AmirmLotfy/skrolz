import 'package:flutter/material.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/app_typography.dart';

/// Motion: &lt;180ms taps, 220–280ms transitions, spring for sheets.
class AppMotion {
  static const Duration tapFeedback = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 250);
  static const Duration transitionSlow = Duration(milliseconds: 280);
}

/// Skrolz theme — Dark Glassmorphism + Modern Typography.
class AppTheme {
  static ThemeData light([Locale? locale]) {
    final l = locale ?? const Locale('en');
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.accentSecondary,
        surface: AppColors.lightBg,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: AppTypography.forLocale(l),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark([Locale? locale]) {
    final l = locale ?? const Locale('en');
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.accentSecondary,
        surface: AppColors.darkBg,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: AppTypography.forLocale(l),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
