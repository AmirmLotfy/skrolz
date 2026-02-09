import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/comments_repository.dart';
import 'package:skrolz_app/data/supabase/lesson_repository.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';
import 'package:skrolz_app/features/feed/widgets/story_card.dart';
import 'package:skrolz_app/features/lesson/models/lesson.dart';
import 'package:skrolz_app/features/lesson/screens/lesson_viewer_screen.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Wrapper that fetches lesson by ID and shows viewer or loading.
class _LessonStoryWrapper extends StatefulWidget {
  const _LessonStoryWrapper({required this.id});

  final String id;

  @override
  State<_LessonStoryWrapper> createState() => _LessonStoryWrapperState();
}

class _LessonStoryWrapperState extends State<_LessonStoryWrapper> {
  Lesson? _lesson;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    LessonRepository.getLessonById(widget.id).then((l) {
      if (mounted) setState(() { _lesson = l; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_lesson == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Lesson not found')));
    return LessonViewerScreen(lesson: _lesson!);
  }
}

/// Story details: post (single card) or lesson (multi-slide viewer) with context/sources and comments.
class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({
    super.key,
    required this.id,
    this.contentType = 'post',
    this.item,
    this.lesson,
  });

  final String id;
  final String contentType;
  final FeedItem? item;
  final Lesson? lesson;

  @override
  Widget build(BuildContext context) {
    if (contentType == 'lesson' && lesson != null) {
      return LessonViewerScreen(lesson: lesson!);
    }
    if (contentType == 'lesson') {
      return _LessonStoryWrapper(id: id);
    }
    final feedItem = item ?? FeedItem(id: id, contentType: contentType, body: 'Story $id');
    return Scaffold(
      body: Stack(
        children: [
          StoryCard(
            item: feedItem,
            focusMode: false,
            onTapTopRight: () => _showContext(context),
            onTapBottom: () => _showComments(context),
          ),
          // Glassmorphism header
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
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showContext(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContext(BuildContext context) {
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
              'Why you saw this',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context) {
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
          contentType: contentType,
          contentId: id,
          scrollController: scrollController,
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
    final list = await CommentsRepository.getComments(widget.contentType, widget.contentId);
    if (mounted) setState(() { _comments = list; _loading = false; });
  }

  Future<void> _post() async {
    final body = _textController.text.trim();
    if (body.isEmpty) return;
    _textController.clear();
    final added = await CommentsRepository.addComment(widget.contentType, widget.contentId, body);
    if (added != null && mounted) setState(() => _comments = [..._comments, added]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassSurface(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      blur: 30,
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_comments.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDarkSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: AppColors.textDarkSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textDarkSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _comments.length,
                        itemBuilder: (context, i) {
                          final c = _comments[i];
                          return ContentCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        (c.authorDisplayName ?? 'U')[0].toUpperCase(),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                          Text(
                                            _formatTime(c.createdAt),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: AppColors.textDarkSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  c.body,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // Comment input
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            child: GlassSurface(
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              blur: 20,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDarkSecondary,
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                      onSubmitted: (_) => _post(),
                    ),
                  ),
                  IconButton(
                    onPressed: _post,
                    icon: Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
