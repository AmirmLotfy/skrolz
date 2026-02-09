import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skrolz_app/data/local/skrolz_cache.dart';
import 'package:skrolz_app/data/supabase/comments_repository.dart';
import 'package:skrolz_app/data/supabase/feed_repository.dart';
import 'package:skrolz_app/data/supabase/interactions_repository.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/data/supabase/reactions_repository.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';
import 'package:skrolz_app/features/feed/widgets/feed_skeleton.dart';
import 'package:skrolz_app/features/feed/widgets/story_card.dart';
import 'package:skrolz_app/providers/feed_provider.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';
import 'package:share_plus/share_plus.dart';

/// Full-screen vertical pager with glassmorphism overlay UI.
/// Engagement buttons on right, creator info bottom-left.
/// Swipe up/down: next/prev; swipe right: save; swipe left: like.
class FeedPager extends ConsumerStatefulWidget {
  const FeedPager({
    super.key,
    this.tabIndex = 0,
    this.initialIndex = 0,
    this.onOpenContext,
    this.onOpenComments,
  });

  final int tabIndex;
  final int initialIndex;
  final void Function(FeedItem item)? onOpenContext;
  final void Function(FeedItem item)? onOpenComments;

  @override
  ConsumerState<FeedPager> createState() => _FeedPagerState();
}

class _FeedPagerState extends ConsumerState<FeedPager> {
  late PageController _pageController;
  List<FeedItem> _items = [];
  int _currentIndex = 0;
  DateTime? _viewStartedAt;
  // Cache for engagement data and creator profiles
  final Map<String, Map<String, dynamic>> _engagementCache = {};
  final Map<String, Map<String, dynamic>> _profileCache = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _viewStartedAt = DateTime.now();
  }

  void _recordDwell(int fromIndex) {
    if (fromIndex < 0 || fromIndex >= _items.length) return;
    final item = _items[fromIndex];
    final sec = _viewStartedAt != null ? DateTime.now().difference(_viewStartedAt!).inSeconds : 0;
    InteractionsRepository.recordView(
      contentType: item.contentType,
      contentId: item.id,
      dwellTimeSec: sec,
      completed: sec >= 5,
    );
  }

  @override
  void dispose() {
    _recordDwell(_currentIndex);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEngagementData(FeedItem item) async {
    final key = '${item.contentType}_${item.id}';
    if (_engagementCache.containsKey(key)) return;
    
    final counts = await ReactionsRepository.getReactionCounts(item.contentType, item.id);
    final hasLike = await ReactionsRepository.hasReaction(item.contentType, item.id, 'like');
    final hasSave = await ReactionsRepository.hasReaction(item.contentType, item.id, 'save');
    final comments = await CommentsRepository.getComments(item.contentType, item.id, topLevelOnly: true);
    
    setState(() {
      _engagementCache[key] = {
        'likeCount': counts['like'] ?? 0,
        'saveCount': counts['save'] ?? 0,
        'commentCount': comments.length,
        'hasLike': hasLike,
        'hasSave': hasSave,
      };
    });
  }

  Future<void> _loadCreatorProfile(FeedItem item) async {
    if (item.authorId == null) return;
    final key = item.authorId!;
    if (_profileCache.containsKey(key)) return;
    
    final profile = await ProfileRepository.getProfileById(key);
    if (profile != null && mounted) {
      setState(() {
        _profileCache[key] = profile;
      });
    }
  }

  void _onSave(FeedItem item) async {
    HapticFeedback.mediumImpact();
    final key = '${item.contentType}_${item.id}';
    final current = _engagementCache[key];
    final wasSaved = current?['hasSave'] ?? false;
    
    // Optimistic update
    setState(() {
      _engagementCache[key] = {
        ...?current,
        'hasSave': !wasSaved,
        'saveCount': ((current?['saveCount'] ?? 0) as int) + (wasSaved ? -1 : 1),
      };
    });
    
    final added = await ReactionsRepository.toggleReaction(item.contentType, item.id, 'save');
    if (added == true) {
      try {
        final cache = await SkrolzCache.instance;
        await cache.upsertBookmark(
          item.contentType,
          item.id,
          item.title ?? (item.contentType == 'lesson' ? 'Lesson' : 'Post'),
          item.body ?? '',
        );
      } catch (_) {}
    } else if (added == false && mounted) {
      // Rollback on error
      setState(() {
        _engagementCache[key] = {
          ...?current,
          'hasSave': wasSaved,
          'saveCount': ((current?['saveCount'] ?? 0) as int) + (wasSaved ? 1 : -1),
        };
      });
    }
    // Reload to sync
    _loadEngagementData(item);
  }

  void _onLike(FeedItem item) async {
    HapticFeedback.lightImpact();
    final key = '${item.contentType}_${item.id}';
    final current = _engagementCache[key];
    final wasLiked = current?['hasLike'] ?? false;
    
    // Optimistic update
    setState(() {
      _engagementCache[key] = {
        ...?current,
        'hasLike': !wasLiked,
        'likeCount': ((current?['likeCount'] ?? 0) as int) + (wasLiked ? -1 : 1),
      };
    });
    
    final added = await ReactionsRepository.toggleReaction(item.contentType, item.id, 'like');
    if (added == false && mounted) {
      // Rollback on error
      setState(() {
        _engagementCache[key] = {
          ...?current,
          'hasLike': wasLiked,
          'likeCount': ((current?['likeCount'] ?? 0) as int) + (wasLiked ? 1 : -1),
        };
      });
    }
    // Reload to sync
    _loadEngagementData(item);
  }

  void _onShare(FeedItem item) async {
    HapticFeedback.mediumImpact();
    final title = item.title ?? (item.contentType == 'lesson' ? 'Lesson' : 'Post');
    final body = item.body ?? '';
    final preview = body.length > 100 ? '${body.substring(0, 100)}...' : body;
    await Share.share('$title\n\n$preview\n\nShared from Skrolz');
  }

  Future<void> _loadMoreItems() async {
    if (_items.isEmpty) return;
    
    final cache = await SkrolzCache.instance;
    final tab = widget.tabIndex < 4 ? FeedTab.values[widget.tabIndex] : FeedTab.forYou;
    
    final remote = await FeedRepository.getFeed(
      limit: 20,
      offset: _items.length,
      tab: tab,
      useCurated: tab == FeedTab.curated,
    );
    
    if (remote.isNotEmpty && mounted) {
      await cache.mergeFeedItems(remote.map((e) => e.toJson()).toList());
      setState(() {
        _items = [..._items, ...remote];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);
    final asyncItems = ref.watch(feedItemsProvider(widget.tabIndex));

    return asyncItems.when(
      data: (items) {
        if (_items.isEmpty) {
          _items = items;
        }

        if (_items.isEmpty) {
      return Center(
        child: GlassSurface(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(32),
          blur: 30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                'No stories right now',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

        // Load engagement data and creator profile for initial item
        if (_items.isNotEmpty && _currentIndex < _items.length) {
          _loadEngagementData(_items[_currentIndex]);
          _loadCreatorProfile(_items[_currentIndex]);
        }
        
        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _items.length,
              onPageChanged: (i) {
                _recordDwell(_currentIndex);
                setState(() {
                  _currentIndex = i;
                  _viewStartedAt = DateTime.now();
                });
                // Load engagement data and creator profile for new item
                if (i < _items.length) {
                  _loadEngagementData(_items[i]);
                  _loadCreatorProfile(_items[i]);
                }
                // Load more if near end
                if (i >= _items.length - 3) {
                  _loadMoreItems();
                }
              },
          allowImplicitScrolling: true,
          padEnds: false,
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final item = _items[index];
            return _StoryPage(
              item: item,
              focusMode: focusMode,
              onTapTopRight: () => widget.onOpenContext?.call(item),
              onTapBottom: () => widget.onOpenComments?.call(item),
              onSwipeRight: () => _onSave(item),
              onSwipeLeft: () => _onLike(item),
            );
          },
        ),
            // Engagement buttons overlay (right side)
            if (!focusMode && _items.isNotEmpty)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _EngagementButtons(
                    item: _items[_currentIndex],
                    engagementData: _engagementCache['${_items[_currentIndex].contentType}_${_items[_currentIndex].id}'],
                    onLike: () => _onLike(_items[_currentIndex]),
                    onComment: () => widget.onOpenComments?.call(_items[_currentIndex]),
                    onSave: () => _onSave(_items[_currentIndex]),
                    onShare: () => _onShare(_items[_currentIndex]),
                  ),
                ),
              ),
            // Creator info overlay (bottom-left)
            if (!focusMode && _items.isNotEmpty)
              Positioned(
                left: 16,
                bottom: 100,
                child: _CreatorInfo(
                  item: _items[_currentIndex],
                  profile: _items[_currentIndex].authorId != null
                      ? _profileCache[_items[_currentIndex].authorId!]
                      : null,
                ),
              ),
          ],
        );
      },
      loading: () => const FeedSkeleton(),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _StoryPage extends StatelessWidget {
  const _StoryPage({
    required this.item,
    required this.focusMode,
    required this.onTapTopRight,
    required this.onTapBottom,
    required this.onSwipeRight,
    required this.onSwipeLeft,
  });

  final FeedItem item;
  final bool focusMode;
  final VoidCallback onTapTopRight;
  final VoidCallback onTapBottom;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if (d.velocity.pixelsPerSecond.dx > 200) onSwipeRight();
        if (d.velocity.pixelsPerSecond.dx < -200) onSwipeLeft();
      },
      child: StoryCard(
        item: item,
        focusMode: focusMode,
        onTapTopRight: onTapTopRight,
        onTapBottom: onTapBottom,
      ),
    );
  }
}

class _EngagementButtons extends StatelessWidget {
  const _EngagementButtons({
    required this.item,
    this.engagementData,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
  });

  final FeedItem item;
  final Map<String, dynamic>? engagementData;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final likeCount = engagementData?['likeCount'] ?? 0;
    final commentCount = engagementData?['commentCount'] ?? 0;
    final hasLike = engagementData?['hasLike'] ?? false;
    final hasSave = engagementData?['hasSave'] ?? false;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _EngagementButton(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          count: likeCount > 0 ? _formatCount(likeCount) : '',
          isActive: hasLike,
          onTap: onLike,
        ),
        const SizedBox(height: 24),
        _EngagementButton(
          icon: Icons.comment_outlined,
          activeIcon: Icons.comment,
          count: commentCount > 0 ? _formatCount(commentCount) : '',
          isActive: false,
          onTap: onComment,
        ),
        const SizedBox(height: 24),
        _EngagementButton(
          icon: Icons.bookmark_outline,
          activeIcon: Icons.bookmark,
          count: '',
          isActive: hasSave,
          onTap: onSave,
        ),
        const SizedBox(height: 24),
        _EngagementButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: '',
          isActive: false,
          onTap: onShare,
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _EngagementButton extends StatelessWidget {
  const _EngagementButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassSurface(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(10),
          blur: 20,
          child: IconButton(
            icon: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.accent : Colors.white,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              onTap();
            },
          ),
        ),
        if (count.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            count,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

class _CreatorInfo extends StatelessWidget {
  const _CreatorInfo({
    required this.item,
    this.profile,
  });

  final FeedItem item;
  final Map<String, dynamic>? profile;

  String _getDisplayName() {
    if (profile == null) return 'feed.creator'.tr();
    final name = profile!['display_name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    return 'feed.creator'.tr();
  }

  String _getUsername() {
    if (profile == null) return '@username';
    final name = profile!['display_name'] as String?;
    if (name != null && name.isNotEmpty) {
      return '@${name.toLowerCase().replaceAll(' ', '')}';
    }
    return '@user';
  }

  String _getAvatarInitial() {
    final name = _getDisplayName();
    final creatorLabel = 'feed.creator'.tr();
    if (name == creatorLabel) return 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?['avatar_url'] as String?;
    
    return GlassSurface(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      blur: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(
                    _getAvatarInitial(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDisplayName(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _getUsername(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
