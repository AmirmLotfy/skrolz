import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/follows_repository.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Discovery: modern creator cards with glassmorphism and smooth follow animations.
class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  List<Map<String, dynamic>> _suggestions = [];
  final Set<String> _followingIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await FollowsRepository.getSuggestedProfiles(limit: 30);
    final following = <String>{};
    for (final p in list) {
      final id = p['id'] as String?;
      if (id != null && await FollowsRepository.isFollowing(id)) following.add(id);
    }
    if (mounted) setState(() { _suggestions = list; _followingIds.addAll(following); _loading = false; });
  }

  Future<void> _toggleFollow(String id) async {
    final following = _followingIds.contains(id);
    final ok = following ? await FollowsRepository.unfollow(id) : await FollowsRepository.follow(id);
    if (ok && mounted) setState(() {
      if (following) _followingIds.remove(id);
      else _followingIds.add(id);
    });
  }

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
                'Discovery',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _loading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _suggestions.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final s = _suggestions[i];
                            final id = s['id'] as String? ?? '';
                            final name = s['display_name'] as String? ?? 'Creator';
                            final following = _followingIds.contains(id);
                            return ProfileCard(
                              margin: const EdgeInsets.only(bottom: 16),
                              onTap: () => context.push('${AppPaths.userProfile.replaceAll(':userId', id)}'),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: following ? 20 : 24,
                                        vertical: 10,
                                      ),
                                      blur: 20,
                                      gradient: following ? null : AppColors.primaryGradient,
                                      child: GestureDetector(
                                        onTap: () => _toggleFollow(id),
                                        child: Text(
                                          following ? 'Following' : 'Follow',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: following ? null : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: _suggestions.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
