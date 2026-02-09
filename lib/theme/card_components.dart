import 'package:flutter/material.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Content card for feed items, stories, and posts.
/// Rounded corners, glassmorphism, subtle shadows.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation = 2,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);
    
    Widget content = GlassSurface(
      borderRadius: radius,
      padding: padding ?? const EdgeInsets.all(16),
      blur: 20,
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
        blurRadius: elevation * 8,
        offset: Offset(0, elevation * 2),
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

/// Action card for CTAs, premium features, and highlighted content.
/// Gradient backgrounds, prominent styling.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.gradient,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);
    final cardGradient = gradient ?? (isDark ? AppColors.primaryGradient : AppColors.accentGradient);

    Widget content = GlassSurface(
      borderRadius: radius,
      padding: padding ?? const EdgeInsets.all(20),
      blur: 25,
      gradient: cardGradient,
      shadow: BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

/// Profile card for user profiles and creator previews.
/// Circular avatar support, glassmorphism background.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    Widget content = GlassSurface(
      borderRadius: radius,
      padding: padding ?? const EdgeInsets.all(16),
      blur: 20,
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
