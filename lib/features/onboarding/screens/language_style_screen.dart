import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/providers/auth_provider.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';

/// Language & Reading Style: modern card-based selection with preview.
class LanguageStyleScreen extends ConsumerWidget {
  const LanguageStyleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = context.locale;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'onboarding.language_style'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'onboarding.language_subtitle'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDarkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    ContentCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () {
                        context.setLocale(const Locale('en'));
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'EN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'English',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Preview text at different sizes',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textDarkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (currentLocale.languageCode == 'en')
                            const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                    ContentCard(
                      margin: const EdgeInsets.only(bottom: 32),
                      onTap: () {
                        context.setLocale(const Locale('ar'));
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.textDarkSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'AR',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'العربية',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'معاينة النص بأحجام مختلفة',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textDarkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (currentLocale.languageCode == 'ar')
                            const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FilledButton(
                    onPressed: () async {
                      final user = ref.read(authUserProvider).value;
                      final locale = context.locale;
                      if (user != null) {
                        await ProfileRepository.updatePreferences(user.id, {
                          'language': locale.languageCode,
                          'country': locale.countryCode ?? '',
                        });
                        // If coming from onboarding, go to auth
                        if (context.canPop() == false) {
                           context.go(AppPaths.auth);
                        } else {
                           // If from settings, just pop
                           context.pop();
                        }
                      } else {
                        context.go(AppPaths.auth);
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'common.next'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
