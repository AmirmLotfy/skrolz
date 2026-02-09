import 'package:skrolz_app/data/supabase/supabase_client.dart';

/// Report, block, mute via Supabase. RLS applies.
class SafetyRepository {
  static Future<bool> reportContent(String contentType, String contentId, String reason) async {
    if (!AppSupabase.isInitialized) return false;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await AppSupabase.client.from('reports').insert({
        'content_type': contentType,
        'content_id': contentId,
        'reporter_id': uid,
        'reason': reason,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> blockUser(String blockedId) async {
    if (!AppSupabase.isInitialized) return false;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null || uid == blockedId) return false;
    try {
      await AppSupabase.client.from('blocks').insert({
        'blocker_id': uid,
        'blocked_id': blockedId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> muteUser(String mutedId) async {
    if (!AppSupabase.isInitialized) return false;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null || uid == mutedId) return false;
    try {
      await AppSupabase.client.from('mutes').insert({
        'user_id': uid,
        'muted_id': mutedId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<String>> getBlockedUsers() async {
    if (!AppSupabase.isInitialized) return [];
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return [];
    try {
      final res = await AppSupabase.client
          .from('blocks')
          .select('blocked_id')
          .eq('blocker_id', uid);
      return (res as List).map((e) => e['blocked_id'] as String).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> unblockUser(String blockedId) async {
    if (!AppSupabase.isInitialized) return false;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await AppSupabase.client
          .from('blocks')
          .delete()
          .eq('blocker_id', uid)
          .eq('blocked_id', blockedId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
