import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';
import 'package:skrolz_app/services/error_logger.dart';

/// Tab identifiers for home feed.
enum FeedTab { forYou, following, trending, curated }

/// Fetches feed from Supabase. For You/Curated: rank-feed when signed in; Following: from follows; Trending: from mv or engagement.
class FeedRepository {
  static Future<List<FeedItem>> getFeed({
    int limit = 20,
    int offset = 0,
    FeedTab tab = FeedTab.forYou,
    bool useCurated = false,
  }) async {
    if (!AppSupabase.isInitialized) return [];
    final uid = AppSupabase.auth.currentUser?.id;

    if ((tab == FeedTab.forYou || tab == FeedTab.curated) && uid != null) {
      try {
        final res = await AppSupabase.client.functions.invoke(
          'rank-feed',
          body: {'user_id': uid, 'limit': limit, 'use_curated': tab == FeedTab.curated || useCurated},
        );
        final data = res.data as Map<String, dynamic>?;
        final list = data?['items'] as List?;
        if (list != null && list.isNotEmpty) {
          return _itemsFromRankFeed(list);
        }
      } catch (e, st) {
        ErrorLogger.logError(e, st, tag: 'FeedRepository.rankFeed');
      }
      if (tab == FeedTab.curated) return [];
    }

    if (tab == FeedTab.following && uid != null) return _getFollowingFeed(uid, limit, offset);
    if (tab == FeedTab.trending) return _getTrendingFeed(limit, offset);
    return _getDefaultFeed(limit, offset);
  }

  static Future<List<FeedItem>> _getDefaultFeed(int limit, int offset) async {
    try {
      final client = AppSupabase.client;
      final postsRes = await client
          .from('posts')
          .select('id, author_id, category_id, body, difficulty, time_to_read_sec, created_at, engagement_score')
          .eq('moderation_status', 'approved')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final items = <FeedItem>[];
      for (final row in postsRes as List) {
        final map = Map<String, dynamic>.from(row as Map);
        items.add(FeedItem.fromJson({...map, 'content_type': 'post', 'title': null, 'body': map['body']}));
      }

      final lessonsRes = await client
          .from('lessons')
          .select('id, author_id, category_id, title, thumbnail_url, created_at, engagement_score')
          .eq('moderation_status', 'approved')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      for (final row in lessonsRes as List) {
        final map = Map<String, dynamic>.from(row as Map);
        items.add(FeedItem.fromJson({...map, 'content_type': 'lesson', 'body': null}));
      }

      items.sort((a, b) {
        final at = a.createdAt ?? DateTime(0);
        final bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return items.take(limit).toList();
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'FeedRepository._getDefaultFeed');
      return [];
    }
  }

  static Future<List<FeedItem>> _getFollowingFeed(String uid, int limit, int offset) async {
    try {
      final followingRes = await AppSupabase.client.from('follows').select('following_id').eq('follower_id', uid);
      final ids = (followingRes as List).map((e) => (e as Map)['following_id'] as String).toList();
      if (ids.isEmpty) return [];

      final postsRes = await AppSupabase.client
          .from('posts')
          .select('id, author_id, category_id, body, difficulty, time_to_read_sec, created_at, engagement_score')
          .eq('moderation_status', 'approved')
          .inFilter('author_id', ids)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final lessonsRes = await AppSupabase.client
          .from('lessons')
          .select('id, author_id, category_id, title, thumbnail_url, created_at, engagement_score')
          .eq('moderation_status', 'approved')
          .inFilter('author_id', ids)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final items = <FeedItem>[];
      for (final row in postsRes as List) {
        final map = Map<String, dynamic>.from(row as Map);
        items.add(FeedItem.fromJson({...map, 'content_type': 'post', 'title': null, 'body': map['body']}));
      }
      for (final row in lessonsRes as List) {
        final map = Map<String, dynamic>.from(row as Map);
        items.add(FeedItem.fromJson({...map, 'content_type': 'lesson', 'body': null}));
      }
      items.sort((a, b) {
        final at = a.createdAt ?? DateTime(0);
        final bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return items.take(limit).toList();
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'FeedRepository._getFollowingFeed');
      return [];
    }
  }

  static Future<List<FeedItem>> _getTrendingFeed(int limit, int offset) async {
    try {
      final postsRes = await AppSupabase.client
          .from('mv_trending_posts')
          .select('id, author_id, category_id, body, difficulty, time_to_read_sec, created_at, engagement_score')
          .range(offset, offset + limit - 1);
      final lessonsRes = await AppSupabase.client
          .from('mv_trending_lessons')
          .select('id, author_id, category_id, title, thumbnail_url, created_at, engagement_score')
          .range(offset, offset + limit - 1);

      final items = <FeedItem>[];
      for (final row in postsRes as List) {
        final map = Map<String, dynamic>.from(row as Map);
        items.add(FeedItem.fromJson({...map, 'content_type': 'post', 'title': null, 'body': map['body']}));
      }
      for (final row in lessonsRes as List) {
        final map = Map<String, dynamic>.from(row as Map);
        items.add(FeedItem.fromJson({...map, 'content_type': 'lesson', 'body': null}));
      }
      items.sort((a, b) {
        final at = a.createdAt ?? DateTime(0);
        final bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });
      return items.take(limit).toList();
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'FeedRepository._getTrendingFeed');
      return _getDefaultFeed(limit, offset);
    }
  }

  static List<FeedItem> _itemsFromRankFeed(List list) {
    final items = <FeedItem>[];
    for (final e in list) {
      final map = Map<String, dynamic>.from(e as Map);
      final id = map['id'] as String?;
      final type = map['type'] as String? ?? 'post';
      if (id == null) continue;
      items.add(FeedItem(
        id: id,
        contentType: type,
        title: map['title'] as String?,
        body: map['body'] as String?,
        authorId: map['author_id'] as String?,
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
        whyShown: map['why_shown'] as String?,
      ));
    }
    return items;
  }
}
