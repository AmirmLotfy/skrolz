import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/services/error_logger.dart';

/// Follows: insert (follow), delete (unfollow), list following.
class FollowsRepository {
  /// Follow a creator. follower_id = current user, following_id = profile to follow.
  static Future<bool> follow(String followingId) async {
    if (!AppSupabase.isInitialized) return false;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null || uid == followingId) return false;
    try {
      await AppSupabase.client.from('follows').insert({
        'follower_id': uid,
        'following_id': followingId,
      });
      return true;
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'FollowsRepository.follow', context: {'followingId': followingId});
      return false;
    }
  }

  /// Unfollow.
  static Future<bool> unfollow(String followingId) async {
    if (!AppSupabase.isInitialized) return false;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await AppSupabase.client.from('follows').delete().eq('follower_id', uid).eq('following_id', followingId);
      return true;
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'FollowsRepository.unfollow', context: {'followingId': followingId});
      return false;
    }
  }

  /// Batch follow (e.g. onboarding). Ignores duplicates.
  static Future<void> followAll(List<String> followingIds) async {
    if (!AppSupabase.isInitialized) return;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return;
    for (final id in followingIds) {
      if (id != uid) {
        try {
          await AppSupabase.client.from('follows').insert({
            'follower_id': uid,
            'following_id': id,
          });
        } catch (_) {}
      }
    }
  }

  /// Whether current user follows the given profile.
  static Future<bool> isFollowing(String followingId) async {
    if (!AppSupabase.isInitialized) return false;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      final res = await AppSupabase.client
          .from('follows')
          .select('id')
          .eq('follower_id', uid)
          .eq('following_id', followingId)
          .maybeSingle();
      return res != null;
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'FollowsRepository.isFollowing', context: {'followingId': followingId});
      return false;
    }
  }

  /// Suggested profiles to follow (e.g. for onboarding). Excludes current user.
  static Future<List<Map<String, dynamic>>> getSuggestedProfiles({int limit = 10}) async {
    if (!AppSupabase.isInitialized) return [];
    final uid = AppSupabase.auth.currentUser?.id;
    try {
      final res = await AppSupabase.client.from('profiles').select('id, display_name').limit(limit + (uid != null ? 1 : 0));
      final list = (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (uid != null) list.removeWhere((m) => m['id'] == uid);
      return list.take(limit).toList();
    } catch (_) {
      return [];
    }
  }
}
