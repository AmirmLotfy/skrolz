import 'package:flutter/material.dart';

/// RTL and accessibility helpers.
/// Mirror layouts and tap zones for RTL; support dynamic type, reduce motion, high contrast.
class Accessibility {
  Accessibility._();

  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  static bool reduceMotion(BuildContext context) {
    return MediaQuery.accessibleNavigationOf(context) ||
        MediaQuery.disableAnimationsOf(context);
  }

  static bool highContrast(BuildContext context) {
    return MediaQuery.highContrastOf(context);
  }

  /// Scale factor for text from system (dynamic type). Use in theme or per-widget.
  static double textScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0);
  }
}

/// Wraps a widget with semantics for screen readers. Use for interactive elements.
class AccessibleTap extends StatelessWidget {
  const AccessibleTap({
    super.key,
    required this.onPressed,
    required this.label,
    required this.child,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: InkWell(
        onTap: onPressed,
        child: child,
      ),
    );
  }
}
