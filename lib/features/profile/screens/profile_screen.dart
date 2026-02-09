import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Profile: hero section with gradient, glassmorphism stats cards, and modern menu.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, int> _stats = {'posts': 0, 'lessons': 0, 'saved': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    
    final profile = await ProfileRepository.getProfile(userId);
    final stats = await ProfileRepository.getStats(userId);
    
    if (mounted) {
      setState(() {
        _profile = profile;
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload profile when returning from edit screen
    _loadProfile();
  }

  String _getDisplayName() {
    if (_profile == null) return 'Your Profile';
    final name = _profile!['display_name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    return 'Your Profile';
  }

  String _getUsername() {
    if (_profile == null) return '@username';
    final name = _profile!['display_name'] as String?;
    if (name != null && name.isNotEmpty) {
      return '@${name.toLowerCase().replaceAll(' ', '')}';
    }
    return '@user';
  }

  String _getAvatarInitial() {
    final name = _getDisplayName();
    if (name == 'Your Profile') return 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero section
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          backgroundImage: _profile?['avatar_url'] != null && (_profile!['avatar_url'] as String).isNotEmpty
                              ? CachedNetworkImageProvider(_profile!['avatar_url'] as String)
                              : null,
                          child: _profile?['avatar_url'] == null || (_profile!['avatar_url'] as String).isEmpty
                              ? Text(
                                  _getAvatarInitial(),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getDisplayName(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUsername(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                'nav.profile'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GlassSurface(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(8),
                  blur: 20,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => context.push(AppPaths.editProfile),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GlassSurface(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(8),
                  blur: 20,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => context.push(AppPaths.settings),
                  ),
                ),
              ),
            ],
          ),
          // Stats cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(16),
                      blur: 25,
                      child: Column(
                        children: [
                          Text(
                            _loading ? '...' : _stats['posts'].toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'profile.posts'.tr(),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(16),
                      blur: 25,
                      child: Column(
                        children: [
                          Text(
                            _loading ? '...' : _stats['lessons'].toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'profile.lessons'.tr(),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(16),
                      blur: 25,
                      child: Column(
                        children: [
                          Text(
                            _loading ? '...' : _stats['saved'].toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'profile.saved'.tr(),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu items
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                ContentCard(
                  onTap: () => context.push(AppPaths.bookmarks),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bookmark, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'profile.bookmarks'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ContentCard(
                  onTap: () => context.push(AppPaths.drafts),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_note, color: AppColors.accent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'profile.drafts'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Premium hub removed - all features are now free
                ContentCard(
                  onTap: () => context.push(AppPaths.settings),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.textDarkSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'common.settings'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
