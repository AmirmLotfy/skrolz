import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Draft model for posts and lessons.
class Draft {
  const Draft({
    required this.id,
    required this.type, // 'post' or 'lesson'
    required this.data,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      id: json['id'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}

/// Local drafts repository using SharedPreferences.
class DraftsRepository {
  static const String _keyPrefix = 'draft_';
  static const String _listKey = 'drafts_list';

  /// Save or update a draft.
  static Future<void> saveDraft(Draft draft) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(draft.toJson());
    await prefs.setString('$_keyPrefix${draft.id}', json);
    
    // Update drafts list
    final list = await getDraftIds();
    if (!list.contains(draft.id)) {
      list.add(draft.id);
      await prefs.setStringList(_listKey, list);
    }
  }

  /// Get a draft by ID.
  static Future<Draft?> getDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_keyPrefix$id');
    if (json == null) return null;
    try {
      return Draft.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Get all drafts.
  static Future<List<Draft>> getAllDrafts() async {
    final ids = await getDraftIds();
    final drafts = <Draft>[];
    for (final id in ids) {
      final draft = await getDraft(id);
      if (draft != null) drafts.add(draft);
    }
    // Sort by updated_at or created_at descending
    drafts.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt;
      final bTime = b.updatedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return drafts;
  }

  /// Get draft IDs list.
  static Future<List<String>> getDraftIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_listKey) ?? [];
  }

  /// Delete a draft.
  static Future<void> deleteDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$id');
    
    final list = await getDraftIds();
    list.remove(id);
    await prefs.setStringList(_listKey, list);
  }

  /// Delete all drafts.
  static Future<void> deleteAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getDraftIds();
    for (final id in ids) {
      await prefs.remove('$_keyPrefix$id');
    }
    await prefs.remove(_listKey);
  }
}
