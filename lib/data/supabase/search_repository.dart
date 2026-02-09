import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';

/// Search posts and lessons by query. Uses ilike for body/title; filter by type.
class SearchRepository {
  static Future<List<FeedItem>> search(String query, {String filter = 'all', int limit = 20}) async {
    if (!AppSupabase.isInitialized || query.trim().isEmpty) return [];
    final q = query.trim();
    final pattern = '%$q%';
    final items = <FeedItem>[];

    try {
      if (filter == 'all' || filter == 'posts') {
        final res = await AppSupabase.client
            .from('posts')
            .select('id, author_id, category_id, body, difficulty, time_to_read_sec, created_at, engagement_score')
            .eq('moderation_status', 'approved')
            .ilike('body', pattern)
            .order('created_at', ascending: false)
            .limit(limit);
        for (final row in res as List) {
          final map = Map<String, dynamic>.from(row as Map);
          items.add(FeedItem.fromJson({...map, 'content_type': 'post', 'title': null}));
        }
      }

      if (filter == 'all' || filter == 'lessons') {
        final res = await AppSupabase.client
            .from('lessons')
            .select('id, author_id, category_id, title, thumbnail_url, created_at, engagement_score')
            .eq('moderation_status', 'approved')
            .ilike('title', pattern)
            .order('created_at', ascending: false)
            .limit(limit);
        for (final row in res as List) {
          final map = Map<String, dynamic>.from(row as Map);
          items.add(FeedItem.fromJson({...map, 'content_type': 'lesson', 'body': null}));
        }
      }

      items.sort((a, b) {
        final at = a.createdAt ?? DateTime(0);
        final bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return items.take(limit).toList();
    } catch (_) {
      return [];
    }
  }
}
