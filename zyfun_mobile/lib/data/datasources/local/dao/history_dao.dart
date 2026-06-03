import 'package:sqflite/sqflite.dart';

import '../../../models/history.dart';
import '../app_database.dart';

class HistoryDao {
  HistoryDao({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<void> insertOrReplace(History history) async {
    final db = await _database.database;
    await db.insert(
      'histories',
      history.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(History history) async {
    final db = await _database.database;
    await db.update(
      'histories',
      history.toJson(),
      where: 'id = ?',
      whereArgs: <Object>[history.id],
    );
  }

  Future<void> deleteById(String id) async {
    final db = await _database.database;
    await db.delete('histories', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<void> clear() async {
    final db = await _database.database;
    await db.delete('histories');
  }

  Future<List<History>> findAll() async {
    final db = await _database.database;
    final rows = await db.query('histories', orderBy: 'updatedAt DESC');
    return rows.map(History.fromJson).toList();
  }

  Future<List<History>> findRecent({int limit = 50}) async {
    final db = await _database.database;
    final rows = await db.query('histories', orderBy: 'updatedAt DESC', limit: limit);
    return rows.map(History.fromJson).toList();
  }

  Future<History?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query('histories', where: 'id = ?', whereArgs: <Object>[id], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return History.fromJson(rows.first);
  }
}
