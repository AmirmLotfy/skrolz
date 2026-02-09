import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/services/error_logger.dart';

/// Record user interactions (dwell, completed) for ranking. RLS: insert own user_id only.
class InteractionsRepository {
  static Future<void> recordView({
    required String contentType,
    required String contentId,
    int? dwellTimeSec,
    bool completed = false,
    bool saved = false,
  }) async {
    if (!AppSupabase.isInitialized) return;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await AppSupabase.client.from('user_interactions').insert({
        'user_id': uid,
        'content_type': contentType,
        'content_id': contentId,
        if (dwellTimeSec != null) 'dwell_time_sec': dwellTimeSec,
        'completed': completed,
        'saved': saved,
      });
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'InteractionsRepository.recordView', context: {
        'contentType': contentType,
        'contentId': contentId,
        'dwellTimeSec': dwellTimeSec,
        'completed': completed,
      });
    }
  }
}
