import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingCompletedKey = 'skrolz_onboarding_completed';

/// Splash: Skrolz branding with glassmorphism logo + dark gradient.
/// Smooth fade-in animation, then redirect to onboarding or main.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      final session = AppSupabase.isInitialized ? AppSupabase.auth.currentSession : null;
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_kOnboardingCompletedKey) ?? false;
      if (session != null && completed) {
        context.go(AppPaths.home);
      } else {
        context.go(AppPaths.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Stack(
          children: [
            // Animated gradient overlay
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3 * _fade.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fade.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassSurface(
                            borderRadius: BorderRadius.circular(32),
                            padding: const EdgeInsets.all(24),
                            blur: 30,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.3),
                                AppColors.accent.withValues(alpha: 0.2),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Skrolz',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scroll. Learn. Grow.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textDarkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
