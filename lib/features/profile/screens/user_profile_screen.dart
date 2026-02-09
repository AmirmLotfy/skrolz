import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skrolz_app/data/supabase/follows_repository.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// User Profile: displays any user's profile (read-only, with follow button).
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, int> _stats = {'posts': 0, 'lessons': 0, 'saved': 0};
  bool _loading = true;
  bool _isFollowing = false;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _checkIfCurrentUser();
    _loadProfile();
  }

  void _checkIfCurrentUser() {
    final currentUserId = AppSupabase.auth.currentUser?.id;
    _isCurrentUser = currentUserId == widget.userId;
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    
    final profile = await ProfileRepository.getProfileById(widget.userId);
    final stats = await ProfileRepository.getStats(widget.userId);
    
    if (!_isCurrentUser) {
      _isFollowing = await FollowsRepository.isFollowing(widget.userId);
    }
    
    if (mounted) {
      setState(() {
        _profile = profile;
        _stats = stats;
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_isCurrentUser) return;
    
    final following = _isFollowing;
    final ok = following 
        ? await FollowsRepository.unfollow(widget.userId)
        : await FollowsRepository.follow(widget.userId);
    
    if (ok && mounted) {
      setState(() {
        _isFollowing = !following;
      });
    }
  }

  String _getDisplayName() {
    if (_profile == null) return 'User';
    final name = _profile!['display_name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    return 'User';
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
                _getDisplayName(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              if (!_isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GlassSurface(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(8),
                    blur: 20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: GlassSurface(
                        borderRadius: BorderRadius.circular(20),
                        padding: EdgeInsets.symmetric(
                          horizontal: _isFollowing ? 20 : 24,
                          vertical: 10,
                        ),
                        blur: 20,
                        gradient: _isFollowing ? null : AppColors.primaryGradient,
                        child: GestureDetector(
                          onTap: _toggleFollow,
                          child: Text(
                            _isFollowing ? 'Following' : 'Follow',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _isFollowing ? null : Colors.white,
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
          // Empty state or content placeholder
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_profile == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 64,
                      color: AppColors.textDarkSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'User not found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDarkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
