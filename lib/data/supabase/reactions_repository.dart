import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/services/error_logger.dart';

/// Reactions (like/save) via Supabase. RLS applies.
class ReactionsRepository {
  /// Toggle a reaction (like or save). Returns true if added, false if removed.
  static Future<bool?> toggleReaction(String contentType, String contentId, String reactionType) async {
    if (!AppSupabase.isInitialized) return null;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final existing = await AppSupabase.client
        .from('reactions')
        .select('id')
        .eq('user_id', userId)
        .eq('content_type', contentType)
        .eq('content_id', contentId)
        .eq('reaction_type', reactionType)
        .maybeSingle();
      if (existing != null) {
        await AppSupabase.client.from('reactions').delete().eq('id', (existing as Map)['id']);
        return false;
      }
      await AppSupabase.client.from('reactions').insert({
        'user_id': userId,
        'content_type': contentType,
        'content_id': contentId,
        'reaction_type': reactionType,
      });
    return true;
  } catch (e, st) {
    ErrorLogger.logError(e, st, tag: 'ReactionsRepository.toggleReaction', context: {
      'contentType': contentType,
      'contentId': contentId,
      'reactionType': reactionType,
    });
    return null;
  }
  }

  /// Get reaction counts for a content (e.g. like count, save count).
  static Future<Map<String, int>> getReactionCounts(String contentType, String contentId) async {
    if (!AppSupabase.isInitialized) return {'like': 0, 'save': 0};
    try {
      final res = await AppSupabase.client
          .from('reactions')
          .select('reaction_type')
          .eq('content_type', contentType)
          .eq('content_id', contentId);
      int like = 0, save = 0;
      for (final row in res as List) {
        final t = (row as Map)['reaction_type'] as String?;
        if (t == 'like') like++;
        if (t == 'save') save++;
      }
      return {'like': like, 'save': save};
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'ReactionsRepository.getReactionCounts', context: {
        'contentType': contentType,
        'contentId': contentId,
      });
      return {'like': 0, 'save': 0};
    }
  }

  /// Whether current user has reacted with the given type.
  static Future<bool> hasReaction(String contentType, String contentId, String reactionType) async {
    if (!AppSupabase.isInitialized) return false;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final res = await AppSupabase.client
          .from('reactions')
          .select('id')
          .eq('user_id', userId)
          .eq('content_type', contentType)
          .eq('content_id', contentId)
          .eq('reaction_type', reactionType)
          .maybeSingle();
      return res != null;
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'ReactionsRepository.hasReaction');
      return false;
    }
  }

  /// List of saved content ids for current user (content_type, content_id).
  static Future<List<Map<String, String>>> getSavedForUser() async {
    if (!AppSupabase.isInitialized) return [];
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final res = await AppSupabase.client
          .from('reactions')
          .select('content_type, content_id')
          .eq('user_id', userId)
          .eq('reaction_type', 'save');
      return (res as List).map((e) => {'content_type': (e as Map)['content_type'] as String, 'content_id': (e['content_id'] as String)}).toList();
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'ReactionsRepository.getSavedForUser');
      return [];
    }
  }
}
