import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/services/error_logger.dart';

/// Create post (body ≤280), then call moderate-content and update status.
class PostsRepository {
  static Future<Map<String, dynamic>?> createPost({
    required String body,
    String? categoryId,
    String? difficulty,
    int? timeToReadSec,
  }) async {
    if (!AppSupabase.isInitialized) return null;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final insert = {
        'author_id': uid,
        'body': body,
        if (categoryId != null) 'category_id': categoryId,
        if (difficulty != null) 'difficulty': difficulty,
        if (timeToReadSec != null) 'time_to_read_sec': timeToReadSec,
        'moderation_status': 'pending',
      };
      final res = await AppSupabase.client.from('posts').insert(insert).select('id').single();
      final id = (res as Map)['id'] as String?;
      if (id == null) return null;

      try {
        final mod = await AppSupabase.client.functions.invoke(
          'moderate-content',
          body: {'content_type': 'post', 'content_id': id, 'text': body},
        );
        final data = mod.data as Map<String, dynamic>?;
        final status = data?['status'] as String?;
        if (status != null && status != 'pending') {
          await AppSupabase.client.from('posts').update({'moderation_status': status}).eq('id', id);
        }
      } catch (e, st) {
        ErrorLogger.logError(e, st, tag: 'PostsRepository.moderateContent');
      }

      return {'id': id};
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'PostsRepository.createPost');
      return null;
    }
  }
}
