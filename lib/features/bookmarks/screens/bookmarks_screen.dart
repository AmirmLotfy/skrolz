import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/local/skrolz_cache.dart';
import 'package:skrolz_app/data/supabase/reactions_repository.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';

/// Bookmarks: card-based list with modern empty state.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                'Bookmarks',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadBookmarks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final list = snapshot.data!;
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 80,
                            color: AppColors.textDarkSecondary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No saved stories yet',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save stories you love to read later',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textDarkSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final b = list[i];
                      final type = b['content_type'] as String? ?? 'post';
                      final id = b['content_id'] as String? ?? '';
                      final title = b['title'] as String? ?? (type == 'lesson' ? 'Lesson' : 'Post');
                      final snippet = b['snippet'] as String? ?? '';
                      return ContentCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        onTap: () => context.push('${AppPaths.story}/$id?type=$type'),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: type == 'lesson'
                                    ? AppColors.accentGradient
                                    : AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                type == 'lesson' ? Icons.school : Icons.article,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (snippet.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      snippet,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textDarkSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 18),
                          ],
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> _loadBookmarks() async {
    final saved = await ReactionsRepository.getSavedForUser();
    if (saved.isNotEmpty) {
      final cache = await SkrolzCache.instance;
      final list = <Map<String, dynamic>>[];
      for (final e in saved) {
        final type = e['content_type'] as String;
        final id = e['content_id'] as String;
        final b = await cache.getBookmark(type, id);
        list.add({
          'content_type': type,
          'content_id': id,
          'title': b?['title'] ?? (type == 'lesson' ? 'Lesson' : 'Post'),
          'snippet': b?['snippet'] ?? '',
        });
      }
      return list;
    }
      final cache = await SkrolzCache.instance;
    return cache.getBookmarks();
  }
}
