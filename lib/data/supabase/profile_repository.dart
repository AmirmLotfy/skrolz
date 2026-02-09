import 'package:skrolz_app/data/supabase/supabase_client.dart';

/// Fetches and updates public.profiles (subscription_status, preferences, etc.).
class ProfileRepository {
  /// Get profile by user id. Returns null if not found or not initialized.
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    if (!AppSupabase.isInitialized) return null;
    try {
      final res = await AppSupabase.client
          .from('profiles')
          .select('id, display_name, avatar_url, subscription_status, preferences, created_at, updated_at')
          .eq('id', userId)
          .maybeSingle();
      return res != null ? Map<String, dynamic>.from(res as Map) : null;
    } catch (_) {
      return null;
    }
  }

  /// Update preferences (e.g. interests). Merges with existing preferences if only some keys passed.
  static Future<void> updatePreferences(String userId, Map<String, dynamic> preferences) async {
    if (!AppSupabase.isInitialized) return;
    final current = await getProfile(userId);
    final existing = current != null && current['preferences'] is Map
        ? Map<String, dynamic>.from(current['preferences'] as Map)
        : <String, dynamic>{};
    existing.addAll(preferences);
    await updateProfile(userId, preferences: existing);
  }

  /// Get profile by any user id (for displaying creator info). Returns null if not found.
  static Future<Map<String, dynamic>?> getProfileById(String userId) async {
    if (!AppSupabase.isInitialized) return null;
    try {
      final res = await AppSupabase.client
          .from('profiles')
          .select('id, display_name, avatar_url, created_at')
          .eq('id', userId)
          .maybeSingle();
      return res != null ? Map<String, dynamic>.from(res as Map) : null;
    } catch (_) {
      return null;
    }
  }

  /// Ensure profile exists for current user. Creates if missing.
  static Future<void> ensureProfileExists(String userId) async {
    if (!AppSupabase.isInitialized) return;
    try {
      final existing = await getProfile(userId);
      if (existing == null) {
        // Profile doesn't exist, create it
        await AppSupabase.client.from('profiles').insert({
          'id': userId,
          'display_name': null,
          'subscription_status': 'free',
          'preferences': <String, dynamic>{},
        });
      }
    } catch (_) {
      // Profile may already exist or RLS issue - ignore
    }
  }

  /// Get stats counts for a user (posts, lessons, saved).
  static Future<Map<String, int>> getStats(String userId) async {
    if (!AppSupabase.isInitialized) return {'posts': 0, 'lessons': 0, 'saved': 0};
    try {
      // Posts count
      final postsRes = await AppSupabase.client
          .from('posts')
          .select('id')
          .eq('author_id', userId);
      final postsCount = (postsRes as List).length;
      
      // Lessons count
      final lessonsRes = await AppSupabase.client
          .from('lessons')
          .select('id')
          .eq('author_id', userId);
      final lessonsCount = (lessonsRes as List).length;
      
      // Saved count (reactions with type 'save')
      final savedRes = await AppSupabase.client
          .from('reactions')
          .select('id')
          .eq('user_id', userId)
          .eq('reaction_type', 'save');
      final savedCount = (savedRes as List).length;
      
      return {
        'posts': postsCount,
        'lessons': lessonsCount,
        'saved': savedCount,
      };
    } catch (_) {
      return {'posts': 0, 'lessons': 0, 'saved': 0};
    }
  }

  /// Update profile (display_name, avatar_url, preferences). Only allowed for own id via RLS.
  static Future<void> updateProfile(String userId, {String? displayName, String? avatarUrl, Map<String, dynamic>? preferences}) async {
    if (!AppSupabase.isInitialized) return;
    final updates = <String, dynamic>{'updated_at': DateTime.now().toUtc().toIso8601String()};
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (preferences != null) updates['preferences'] = preferences;
    await AppSupabase.client.from('profiles').update(updates).eq('id', userId);
  }
}
