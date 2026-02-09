import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local cache: feed snapshot, read progress, bookmarks. File-based DB for persistence across restarts.
class SkrolzDatabase {
  SkrolzDatabase._();

  static Future<QueryExecutor> _openExecutor() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'skrolz_cache.db');
    return LazyDatabase(() => NativeDatabase(File(path)));
  }

  static DatabaseConnection? _connection;
  static Future<DatabaseConnection> get connection async {
    _connection ??= DatabaseConnection(await _openExecutor());
    return _connection!;
  }
}
