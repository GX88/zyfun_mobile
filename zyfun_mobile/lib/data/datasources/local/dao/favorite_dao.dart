import 'package:sqflite/sqflite.dart';

import '../../../models/favorite.dart';
import '../app_database.dart';

class FavoriteDao {
  FavoriteDao({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<void> insertOrReplace(Favorite favorite) async {
    final db = await _database.database;
    await db.insert(
      'favorites',
      favorite.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById(String id) async {
    final db = await _database.database;
    await db.delete('favorites', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<List<Favorite>> findAll() async {
    final db = await _database.database;
    final rows = await db.query('favorites', orderBy: 'createdAt DESC');
    return rows.map(Favorite.fromJson).toList();
  }

  Future<Favorite?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query('favorites', where: 'id = ?', whereArgs: <Object>[id], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return Favorite.fromJson(rows.first);
  }

  Future<Favorite?> findByVideo(String siteId, String videoId) async {
    final db = await _database.database;
    final rows = await db.query(
      'favorites',
      where: 'siteId = ? AND videoId = ?',
      whereArgs: <Object>[siteId, videoId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Favorite.fromJson(rows.first);
  }
}
