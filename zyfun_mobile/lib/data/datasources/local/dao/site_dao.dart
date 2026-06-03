import '../../../models/site.dart';
import '../app_database.dart';

class SiteDao {
  SiteDao({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<void> insert(Site site) async {
    final db = await _database.database;
    await db.insert('sites', _serialize(site));
  }

  Future<void> update(Site site) async {
    final db = await _database.database;
    await db.update(
      'sites',
      _serialize(site),
      where: 'id = ?',
      whereArgs: <Object>[site.id],
    );
  }

  Future<void> deleteById(String id) async {
    final db = await _database.database;
    await db.delete('sites', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<List<Site>> findAll() async {
    final db = await _database.database;
    final rows = await db.query('sites', orderBy: 'updatedAt DESC');
    return rows.map(_deserialize).toList();
  }

  Future<Site?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query('sites', where: 'id = ?', whereArgs: <Object>[id], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return _deserialize(rows.first);
  }

  Map<String, Object?> _serialize(Site site) {
    final json = site.toJson();
    return <String, Object?>{
      ...json,
      'isActive': site.isActive ? 1 : 0,
    };
  }

  Site _deserialize(Map<String, Object?> row) {
    final normalized = <String, dynamic>{...row};
    normalized['isActive'] = (row['isActive'] as int? ?? 0) == 1;
    return Site.fromJson(normalized);
  }
}
