import 'package:drift/drift.dart';
import 'package:skrolz_app/data/local/skrolz_database.dart';

/// Sync strategy: on app foreground/refresh, fetch from Supabase and merge into Drift;
/// feed UI reads from cache first for instant cold start, then invalidate/refresh in background.
class SkrolzCache {
  SkrolzCache._(this._conn);

  final DatabaseConnection _conn;

  static SkrolzCache? _instance;
  static Future<SkrolzCache> get instance async {
    if (_instance == null) {
      final c = await SkrolzDatabase.connection;
      _instance = SkrolzCache._(c);
      await _instance!._ensureSchema();
    }
    return _instance!;
  }

  Future<void> _ensureSchema() async {
    await _conn.runCustom(
      'CREATE TABLE IF NOT EXISTS feed_items (id TEXT PRIMARY KEY, content_type TEXT, title TEXT, body TEXT, author_id TEXT, category_id TEXT, created_at TEXT, updated_at TEXT)',
    );
    await _conn.runCustom(
      'CREATE TABLE IF NOT EXISTS read_progress (user_id TEXT, content_type TEXT, content_id TEXT, progress_sec INTEGER, completed INTEGER, updated_at TEXT, PRIMARY KEY (user_id, content_type, content_id))',
    );
    await _conn.runCustom(
      'CREATE TABLE IF NOT EXISTS bookmarks (content_type TEXT, content_id TEXT, title TEXT, snippet TEXT, saved_at TEXT, PRIMARY KEY (content_type, content_id))',
    );
  }

  Future<void> mergeFeedItems(List<Map<String, dynamic>> items) async {
    for (final row in items) {
      await _conn.runInsert(
        'INSERT OR REPLACE INTO feed_items (id, content_type, title, body, author_id, category_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          row['id'],
          row['content_type'] ?? 'post',
          row['title'] ?? '',
          row['body'] ?? '',
          row['author_id'] ?? '',
          row['category_id'] ?? '',
          row['created_at'] ?? '',
          row['updated_at'] ?? '',
        ],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCachedFeed({int limit = 20}) async {
    final rows = await _conn.runSelect(
      'SELECT id, content_type, title, body, author_id, category_id, created_at FROM feed_items ORDER BY created_at DESC LIMIT ?',
      [limit],
    );
    return List<Map<String, dynamic>>.from(rows.map((r) => Map<String, dynamic>.from(r)));
  }

  Future<void> saveProgress(String contentType, String contentId, int progressSec, bool completed) async {
    await _conn.runInsert(
      'INSERT OR REPLACE INTO read_progress (user_id, content_type, content_id, progress_sec, completed, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
      ['local', contentType, contentId, progressSec, completed ? 1 : 0, DateTime.now().toIso8601String()],
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final rows = await _conn.runSelect(
      'SELECT content_type, content_id, title, snippet, saved_at FROM bookmarks ORDER BY saved_at DESC',
      [],
    );
    return List<Map<String, dynamic>>.from(rows.map((r) => Map<String, dynamic>.from(r)));
  }

  /// Upsert a bookmark (e.g. when user saves from feed). Keeps Drift in sync with Supabase saves.
  Future<void> upsertBookmark(String contentType, String contentId, String title, String snippet) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _conn.runInsert(
      'INSERT OR REPLACE INTO bookmarks (content_type, content_id, title, snippet, saved_at) VALUES (?, ?, ?, ?, ?)',
      [contentType, contentId, title, snippet, now],
    );
  }

  /// Get one bookmark by content for title/snippet (e.g. when showing Supabase saves in bookmarks screen).
  Future<Map<String, dynamic>?> getBookmark(String contentType, String contentId) async {
    final rows = await _conn.runSelect(
      'SELECT content_type, content_id, title, snippet, saved_at FROM bookmarks WHERE content_type = ? AND content_id = ?',
      [contentType, contentId],
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }
}
