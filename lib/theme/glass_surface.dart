import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skrolz_app/theme/app_colors.dart';

/// Enhanced glassmorphism surface with blur, shadows, and optional gradients.
/// Modern 2026 design component for nav bars, cards, and overlays.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blur = 25.0,
    this.alpha,
    this.shadow,
    this.gradient,
    this.borderWidth = 1.0,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double? alpha;
  final BoxShadow? shadow;
  final Gradient? gradient;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark 
        ? AppColors.glassDark(context).withValues(alpha: alpha ?? 0.85)
        : AppColors.glassLight(context).withValues(alpha: alpha ?? 0.9);
    final borderColor = isDark 
        ? AppColors.glassBorderDark(context)
        : AppColors.glassBorderLight(context);
    final radius = borderRadius ?? BorderRadius.circular(20);
    final defaultShadow = BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [shadow ?? defaultShadow],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? surfaceColor : null,
              borderRadius: radius,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
