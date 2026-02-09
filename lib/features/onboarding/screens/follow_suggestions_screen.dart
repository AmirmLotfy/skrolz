import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/follows_repository.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Follow Suggestions: modern card-based selection with glassmorphism.
class FollowSuggestionsScreen extends StatefulWidget {
  const FollowSuggestionsScreen({super.key});

  @override
  State<FollowSuggestionsScreen> createState() => _FollowSuggestionsScreenState();
}

class _FollowSuggestionsScreenState extends State<FollowSuggestionsScreen> {
  final Set<String> _followedIds = {};
  List<Map<String, dynamic>> _suggestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    FollowsRepository.getSuggestedProfiles(limit: 20).then((list) {
      if (mounted) setState(() { _suggestions = list; _loading = false; });
    });
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'onboarding.follow_suggestions'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Follow creators and collections to personalize your feed.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDarkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _suggestions.isEmpty
                        ? Center(
                            child: GlassSurface(
                              borderRadius: BorderRadius.circular(20),
                              padding: const EdgeInsets.all(32),
                              blur: 25,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: AppColors.textDarkSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No suggestions right now',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textDarkSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _suggestions.length,
                            itemBuilder: (context, i) {
                              final s = _suggestions[i];
                              final id = s['id'] as String? ?? '';
                              final name = s['display_name'] as String? ?? 'Creator';
                              final selected = _followedIds.contains(id);
                              return ProfileCard(
                                margin: const EdgeInsets.only(bottom: 12),
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      _followedIds.remove(id);
                                    } else {
                                      _followedIds.add(id);
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        name.isNotEmpty
                                            ? name.substring(0, 1).toUpperCase()
                                            : '?',
                                        style: theme.textTheme.titleMedium?.copyWith(
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
                                            name,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '@${name.toLowerCase().replaceAll(' ', '')}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: AppColors.textDarkSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      child: GlassSurface(
                                        borderRadius: BorderRadius.circular(20),
                                        padding: EdgeInsets.all(selected ? 8 : 10),
                                        blur: 20,
                                        gradient: selected ? AppColors.primaryGradient : null,
                                        child: Icon(
                                          selected ? Icons.person : Icons.person_add,
                                          color: selected ? Colors.white : AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
                      await FollowsRepository.followAll(_followedIds.toList());
                      if (mounted) context.go(AppPaths.permissions);
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
