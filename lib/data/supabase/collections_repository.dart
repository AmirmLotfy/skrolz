import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/features/collections/models/collection.dart';

/// Collections CRUD via Supabase. RLS applies.
class CollectionsRepository {
  /// Get all collections for current user.
  static Future<List<Collection>> getCollections() async {
    if (!AppSupabase.isInitialized) return [];
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final res = await AppSupabase.client
          .from('collections')
          .select('id, owner_id, title, description, cover_url, is_public')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      
      final collections = <Collection>[];
      for (final row in res as List) {
        final map = Map<String, dynamic>.from(row as Map);
        final id = map['id'] as String;
        
        // Fetch items from collection_items table
        final itemsRes = await AppSupabase.client
            .from('collection_items')
            .select('content_type, content_id')
            .eq('collection_id', id)
            .order('sort_order');
        
        final itemIds = <String>[];
        final itemTypes = <String>[];
        for (final item in itemsRes as List) {
          final itemMap = item as Map;
          itemIds.add(itemMap['content_id'] as String);
          itemTypes.add(itemMap['content_type'] as String);
        }
        
        collections.add(Collection(
          id: id,
          ownerId: map['owner_id'] as String,
          title: map['title'] as String,
          description: map['description'] as String?,
          coverUrl: map['cover_url'] as String?,
          isPublic: map['is_public'] as bool? ?? true,
          itemIds: itemIds,
          itemTypes: itemTypes,
        ));
      }
      
      return collections;
    } catch (_) {
      return [];
    }
  }

  /// Get a single collection by ID.
  static Future<Collection?> getCollectionById(String id) async {
    if (!AppSupabase.isInitialized) return null;
    try {
      final res = await AppSupabase.client
          .from('collections')
          .select('id, owner_id, title, description, cover_url, is_public')
          .eq('id', id)
          .maybeSingle();
      
      if (res == null) return null;
      final map = Map<String, dynamic>.from(res as Map);
      
      // Fetch items from collection_items table
      final itemsRes = await AppSupabase.client
          .from('collection_items')
          .select('content_type, content_id')
          .eq('collection_id', id)
          .order('sort_order');
      
      final itemIds = <String>[];
      final itemTypes = <String>[];
      for (final item in itemsRes as List) {
        final itemMap = item as Map;
        itemIds.add(itemMap['content_id'] as String);
        itemTypes.add(itemMap['content_type'] as String);
      }
      
      return Collection(
        id: map['id'] as String,
        ownerId: map['owner_id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        coverUrl: map['cover_url'] as String?,
        isPublic: map['is_public'] as bool? ?? true,
        itemIds: itemIds,
        itemTypes: itemTypes,
      );
    } catch (_) {
      return null;
    }
  }

  /// Create a new collection.
  static Future<String?> createCollection({
    required String title,
    String? description,
    String? coverUrl,
    bool isPublic = true,
  }) async {
    if (!AppSupabase.isInitialized) return null;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final res = await AppSupabase.client.from('collections').insert({
        'owner_id': userId,
        'title': title,
        'description': description,
        'cover_url': coverUrl,
        'is_public': isPublic,
      }).select('id').single();
      
      return (res as Map)['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Update collection metadata.
  static Future<bool> updateCollection(
    String id, {
    String? title,
    String? description,
    String? coverUrl,
    bool? isPublic,
  }) async {
    if (!AppSupabase.isInitialized) return false;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (coverUrl != null) updates['cover_url'] = coverUrl;
      if (isPublic != null) updates['is_public'] = isPublic;
      
      await AppSupabase.client
          .from('collections')
          .update(updates)
          .eq('id', id)
          .eq('owner_id', userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Add an item to a collection.
  static Future<bool> addItemToCollection(
    String collectionId,
    String contentType,
    String contentId,
  ) async {
    if (!AppSupabase.isInitialized) return false;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final collection = await getCollectionById(collectionId);
      if (collection == null || collection.ownerId != userId) return false;
      
      // Get current max sort_order
      final itemsRes = await AppSupabase.client
          .from('collection_items')
          .select('sort_order')
          .eq('collection_id', collectionId)
          .order('sort_order', ascending: false)
          .limit(1);
      
      int nextSortOrder = 0;
      if (itemsRes.isNotEmpty) {
        nextSortOrder = ((itemsRes[0] as Map)['sort_order'] as int? ?? -1) + 1;
      }
      
      await AppSupabase.client.from('collection_items').insert({
        'collection_id': collectionId,
        'content_type': contentType,
        'content_id': contentId,
        'sort_order': nextSortOrder,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Remove an item from a collection.
  static Future<bool> removeItemFromCollection(
    String collectionId,
    String contentId,
  ) async {
    if (!AppSupabase.isInitialized) return false;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final collection = await getCollectionById(collectionId);
      if (collection == null || collection.ownerId != userId) return false;
      
      await AppSupabase.client
          .from('collection_items')
          .delete()
          .eq('collection_id', collectionId)
          .eq('content_id', contentId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete a collection.
  static Future<bool> deleteCollection(String id) async {
    if (!AppSupabase.isInitialized) return false;
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await AppSupabase.client
          .from('collections')
          .delete()
          .eq('id', id)
          .eq('owner_id', userId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
