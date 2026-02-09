import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/providers/auth_provider.dart';
import 'package:skrolz_app/providers/feed_provider.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Interests: modern card-based selection with glassmorphism.
class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final Set<String> _selected = {'Tech', 'Science', 'Productivity', 'Learning'};
  static const _topics = [
    'Tech',
    'Science',
    'Productivity',
    'Learning',
    'Design',
    'Business',
    'Health',
    'Culture',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedAsync = ref.watch(feedItemsProvider(0));
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
                      'onboarding.interests_title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick topics you care about',
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _topics.map((t) {
                        final selected = _selected.contains(t);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selected.remove(t);
                              } else {
                                _selected.add(t);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: GlassSurface(
                              borderRadius: BorderRadius.circular(20),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              blur: 20,
                              gradient: selected ? AppColors.primaryGradient : null,
                              child: Text(
                                t,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '3 stories preview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    feedAsync.when(
                      data: (items) {
                        final preview = items.take(3).toList();
                        if (preview.isEmpty) {
                          return GlassSurface(
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.all(24),
                            blur: 20,
                            child: Text(
                              'No stories yet. Complete signup to see your feed.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textDarkSecondary,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: preview.map((item) {
                            return ContentCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                item.body != null && item.body!.isNotEmpty
                                    ? (item.body!.length > 60
                                        ? '${item.body!.substring(0, 60)}...'
                                        : item.body!)
                                    : (item.title ?? 'Lesson'),
                                style: theme.textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => GlassSurface(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(24),
                        blur: 20,
                        child: Text(
                          'Could not load preview',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      if (user != null) {
                        await ProfileRepository.updatePreferences(
                          user.id,
                          {'interests': _selected.toList()},
                        );
                      }
                      if (context.mounted) context.go(AppPaths.followSuggestions);
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
