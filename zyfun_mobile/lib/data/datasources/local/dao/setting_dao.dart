import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class SettingDao {
  SettingDao({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<void> upsert(String key, String value, {required int updatedAt}) async {
    final db = await _database.database;
    await db.insert(
      'settings',
      <String, Object?>{
        'key': key,
        'value': value,
        'updatedAt': updatedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getValue(String key) async {
    final db = await _database.database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: <Object>[key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['value'] as String;
  }

  Future<void> deleteByKey(String key) async {
    final db = await _database.database;
    await db.delete('settings', where: 'key = ?', whereArgs: <Object>[key]);
  }
}
