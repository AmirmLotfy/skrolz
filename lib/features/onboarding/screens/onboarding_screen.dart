import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Onboarding: 4 interactive preview pages (mini story cards), not static slides.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _PreviewCard(
                      headline: 'onboarding.slide1_title'.tr(),
                      subline: 'onboarding.slide1_sub'.tr(),
                      icon: Icons.swipe_vertical,
                    ),
                    _PreviewCard(
                      headline: 'onboarding.slide2_title'.tr(),
                      subline: 'onboarding.slide2_sub'.tr(),
                      icon: Icons.article_outlined,
                    ),
                    _PreviewCard(
                      headline: 'onboarding.slide3_title'.tr(),
                      subline: 'onboarding.slide3_sub'.tr(),
                      icon: Icons.bookmark_outline,
                    ),
                    _PreviewCard(
                      headline: 'onboarding.slide4_title'.tr(),
                      subline: 'onboarding.slide4_sub'.tr(),
                      icon: Icons.auto_awesome,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassSurface(
                      borderRadius: BorderRadius.circular(16),
                      padding: EdgeInsets.zero,
                      blur: 20,
                      child: TextButton(
                        onPressed: () => context.go(AppPaths.languageStyle),
                        child: Text(
                          'common.skip'.tr(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        4,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _page == i ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _page == i ? AppColors.primaryGradient : null,
                            color: _page == i ? null : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    GlassSurface(
                      borderRadius: BorderRadius.circular(16),
                      padding: EdgeInsets.zero,
                      blur: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (_page < 3) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                context.go(AppPaths.languageStyle);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Text(
                                _page < 3 ? 'common.next'.tr() : 'onboarding.get_started'.tr(),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.headline,
    required this.subline,
    required this.icon,
  });

  final String headline;
  final String subline;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(32),
        blur: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              headline,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
