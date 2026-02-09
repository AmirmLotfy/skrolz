import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';

/// Settings: grouped sections with rounded cards and glassmorphism.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'common.settings'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account section
                Text(
                  'Account',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textDarkSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ContentCard(
                  margin: const EdgeInsets.only(bottom: 20),
                  onTap: () => context.push(AppPaths.account),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Account',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                ContentCard(
                  margin: const EdgeInsets.only(bottom: 32),
                  onTap: () => context.push(AppPaths.privacy),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock, color: AppColors.accent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Privacy',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                // Preferences section
                Text(
                  'Preferences',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textDarkSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () => context.push(AppPaths.contentPrefs),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune, color: AppColors.accentSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Content preferences',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                ContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () => context.push(AppPaths.aiPrefs),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.psychology, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'AI preferences',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                ContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () => context.push(AppPaths.languageStyle),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.language, color: AppColors.info),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Language',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                ContentCard(
                  margin: const EdgeInsets.only(bottom: 32),
                  onTap: () => context.push(AppPaths.accessibility),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.accessibility_new, color: AppColors.success),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'profile.accessibility'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                // Premium hub removed - all features are now free
                const SizedBox(height: 12),
                Text(
                  'About',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textDarkSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // About card - display only, no action needed
                ContentCard(
                  margin: const EdgeInsets.only(bottom: 32),
                  onTap: () {}, // Intentional: display-only card showing app info
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Skrolz',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Version 1.0.0',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textDarkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
