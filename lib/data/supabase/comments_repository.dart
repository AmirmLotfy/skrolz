import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/services/error_logger.dart';

/// Comment row as returned from API.
class CommentRow {
  const CommentRow({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.authorId,
    this.parentId,
    required this.body,
    required this.createdAt,
    this.authorDisplayName,
  });

  final String id;
  final String contentType;
  final String contentId;
  final String authorId;
  final String? parentId;
  final String body;
  final DateTime createdAt;
  final String? authorDisplayName;

  static CommentRow fromMap(Map<String, dynamic> map) {
    String? name;
    if (map['authorDisplayName'] != null) {
      name = map['authorDisplayName'] as String?;
    } else if (map['profiles'] != null && map['profiles'] is Map) {
      name = (map['profiles'] as Map)['display_name'] as String?;
    }
    return CommentRow(
      id: map['id'] as String,
      contentType: map['content_type'] as String,
      contentId: map['content_id'] as String,
      authorId: map['author_id'] as String,
      parentId: map['parent_id'] as String?,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      authorDisplayName: name,
    );
  }
}

/// Comments CRUD via Supabase. RLS applies.
class CommentsRepository {
  /// Fetch comments for a content, optionally only top-level (parent_id null).
  static Future<List<CommentRow>> getComments(String contentType, String contentId, {bool topLevelOnly = true}) async {
    if (!AppSupabase.isInitialized) return [];
    try {
      final res = await AppSupabase.client
          .from('comments')
          .select('id, content_type, content_id, author_id, parent_id, body, created_at, profiles(display_name)')
          .eq('content_type', contentType)
          .eq('content_id', contentId)
          .order('created_at', ascending: true);
      final list = res as List;
      final rows = list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        final profile = map['profiles'];
        if (profile != null) map['profiles'] = profile;
        return CommentRow.fromMap(map);
      }).toList();
      if (topLevelOnly) return rows.where((r) => r.parentId == null).toList();
      return rows;
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'CommentsRepository.getComments', context: {
        'contentType': contentType,
        'contentId': contentId,
      });
      return [];
    }
  }

  /// Add a comment. author_id must be current user (RLS).
  static Future<CommentRow?> addComment(String contentType, String contentId, String body, {String? parentId}) async {
    if (!AppSupabase.isInitialized) return null;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final insert = {
        'content_type': contentType,
        'content_id': contentId,
        'author_id': userId,
        'body': body,
        if (parentId != null) 'parent_id': parentId,
      };
      final res = await AppSupabase.client.from('comments').insert(insert).select('id, content_type, content_id, author_id, parent_id, body, created_at').single();
      final map = Map<String, dynamic>.from(res as Map);
      map['authorDisplayName'] = null;
      return CommentRow.fromMap(map);
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'CommentsRepository.addComment', context: {
        'contentType': contentType,
        'contentId': contentId,
      });
      return null;
    }
  }
}
