import 'package:skrolz_app/data/supabase/supabase_client.dart';

/// Notification row as returned from API.
class NotificationRow {
  const NotificationRow({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.read,
    required this.createdAt,
    this.contentType,
    this.contentId,
    this.actorId,
  });

  final String id;
  final String type; // 'like', 'comment', 'follow', 'mention', 'system'
  final String title;
  final String? body;
  final bool read;
  final DateTime createdAt;
  final String? contentType;
  final String? contentId;
  final String? actorId;

  static NotificationRow fromMap(Map<String, dynamic> map) {
    return NotificationRow(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      body: map['body'] as String?,
      read: map['read'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      contentType: map['content_type'] as String?,
      contentId: map['content_id'] as String?,
      actorId: map['actor_id'] as String?,
    );
  }
}

/// Notifications CRUD via Supabase. RLS applies.
class NotificationsRepository {
  /// Get all notifications for current user.
  static Future<List<NotificationRow>> getNotifications({int limit = 50}) async {
    if (!AppSupabase.isInitialized) return [];
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final res = await AppSupabase.client
          .from('notifications')
          .select('id, type, title, body, read, created_at, content_type, content_id, actor_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (res as List).map((e) => NotificationRow.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Mark notification as read.
  static Future<bool> markAsRead(String notificationId) async {
    if (!AppSupabase.isInitialized) return false;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await AppSupabase.client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mark all notifications as read.
  static Future<bool> markAllAsRead() async {
    if (!AppSupabase.isInitialized) return false;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await AppSupabase.client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get unread count.
  static Future<int> getUnreadCount() async {
    if (!AppSupabase.isInitialized) return 0;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return 0;
    try {
      final res = await AppSupabase.client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('read', false);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }
}
