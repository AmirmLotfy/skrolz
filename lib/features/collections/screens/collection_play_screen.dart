import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/comments_repository.dart';
import 'package:skrolz_app/features/collections/models/collection.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';
import 'package:skrolz_app/features/feed/widgets/story_card.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Play a collection as vertical story sequence (reuse story card / pager).
class CollectionPlayScreen extends StatefulWidget {
  const CollectionPlayScreen({super.key, required this.collection});

  final Collection collection;

  @override
  State<CollectionPlayScreen> createState() => _CollectionPlayScreenState();
}

class _CollectionPlayScreenState extends State<CollectionPlayScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showContext(BuildContext context, FeedItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassSurface(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.all(24),
        blur: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Context & Sources',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.whyShown ?? 'Content from collection "${widget.collection.title}"',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('${AppPaths.story}/${item.id}?type=${item.contentType}');
              },
              child: const Text('View Full Story'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('${AppPaths.reportBlockMute}?contentId=${item.id}&contentType=${item.contentType}&creatorId=${item.authorId ?? ''}');
              },
              child: Text(
                'Report or Block',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context, FeedItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _CommentsSheet(
          contentType: item.contentType,
          contentId: item.id,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.collection.itemIds.asMap().entries.map((e) {
      final type = widget.collection.itemTypes.length > e.key ? widget.collection.itemTypes[e.key] : 'post';
      return FeedItem(
        id: e.value,
        contentType: type,
        title: 'Item ${e.key + 1}',
        body: 'Content from collection "${widget.collection.title}".',
      );
    }).toList();
    
    if (items.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.darkGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GlassSurface(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(8),
                        blur: 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.collection.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GlassSurface(
                      borderRadius: BorderRadius.circular(24),
                      padding: const EdgeInsets.all(32),
                      blur: 30,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.collections_outlined, size: 64, color: Colors.white70),
                          const SizedBox(height: 16),
                          Text(
                            'No items in this collection yet.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, i) => StoryCard(
                item: items[i],
                focusMode: false,
                onTapTopRight: () => _showContext(context, items[i]),
                onTapBottom: () => _showComments(context, items[i]),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GlassSurface(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  blur: 25,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          widget.collection.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (items.isNotEmpty)
                        Text(
                          '${_currentIndex + 1}/${items.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Comments list + post field for a story.
class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.contentType,
    required this.contentId,
    required this.scrollController,
  });

  final String contentType;
  final String contentId;
  final ScrollController scrollController;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  List<CommentRow> _comments = [];
  bool _loading = true;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await CommentsRepository.getComments(
      widget.contentType,
      widget.contentId,
      topLevelOnly: false,
    );
    if (mounted) {
      setState(() {
        _comments = list;
        _loading = false;
      });
    }
  }

  Future<void> _postComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    final comment = await CommentsRepository.addComment(
      widget.contentType,
      widget.contentId,
      text,
    );
    
    if (comment != null && mounted) {
      _textController.clear();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassSurface(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      padding: EdgeInsets.zero,
      blur: 30,
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Comments list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.all(24),
                        itemCount: _comments.length,
                        itemBuilder: (context, i) {
                          final c = _comments[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.3),
                                  child: Text(
                                    (c.authorDisplayName ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.authorDisplayName ?? 'User',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.body,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // Input field
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GlassSurface(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    blur: 20,
                    child: TextField(
                      controller: _textController,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GlassSurface(
                  borderRadius: BorderRadius.circular(20),
                  padding: EdgeInsets.zero,
                  blur: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _postComment,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
