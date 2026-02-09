import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:skrolz_app/data/supabase/supabase_client.dart';

/// Real-time subscription service for live updates.
class RealtimeService {
  static final Map<String, supabase.RealtimeChannel> _channels = {};

  /// Subscribe to reactions changes for a content item.
  static supabase.RealtimeChannel subscribeToReactions(
    String contentType,
    String contentId,
    void Function(Map<String, dynamic> payload) onInsert,
    void Function(Map<String, dynamic> payload) onDelete,
  ) {
    final key = 'reactions_${contentType}_$contentId';
    _channels[key]?.unsubscribe();
    
    final channel = AppSupabase.client
        .channel(key)
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'reactions',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'content_type',
            value: contentType,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            if (data != null && data['content_id'] == contentId) {
              onInsert(data);
            }
          },
        )
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.delete,
          schema: 'public',
          table: 'reactions',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'content_type',
            value: contentType,
          ),
          callback: (payload) {
            final data = payload.oldRecord;
            if (data != null && data['content_id'] == contentId) {
              onDelete(data);
            }
          },
        )
        .subscribe();
    
    _channels[key] = channel;
    return channel;
  }

  /// Subscribe to comments changes for a content item.
  static supabase.RealtimeChannel subscribeToComments(
    String contentType,
    String contentId,
    void Function(Map<String, dynamic> payload) onInsert,
    void Function(Map<String, dynamic> payload) onDelete,
  ) {
    final key = 'comments_${contentType}_$contentId';
    _channels[key]?.unsubscribe();
    
    final channel = AppSupabase.client
        .channel(key)
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'content_type',
            value: contentType,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            if (data != null && data['content_id'] == contentId) {
              onInsert(data);
            }
          },
        )
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.delete,
          schema: 'public',
          table: 'comments',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'content_type',
            value: contentType,
          ),
          callback: (payload) {
            final data = payload.oldRecord;
            if (data != null && data['content_id'] == contentId) {
              onDelete(data);
            }
          },
        )
        .subscribe();
    
    _channels[key] = channel;
    return channel;
  }

  /// Unsubscribe from a channel.
  static void unsubscribe(String key) {
    _channels[key]?.unsubscribe();
    _channels.remove(key);
  }

  /// Unsubscribe from all channels.
  static void unsubscribeAll() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
  }
}
