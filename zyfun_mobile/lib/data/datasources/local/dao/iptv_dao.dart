import 'dart:convert';

import '../../../models/iptv.dart';
import '../app_database.dart';

class IptvDao {
  IptvDao({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<void> insert(Iptv iptv) async {
    final db = await _database.database;
    await db.insert('iptvs', _serialize(iptv));
  }

  Future<void> update(Iptv iptv) async {
    final db = await _database.database;
    await db.update(
      'iptvs',
      _serialize(iptv),
      where: 'id = ?',
      whereArgs: <Object>[iptv.id],
    );
  }

  Future<void> deleteById(String id) async {
    final db = await _database.database;
    await db.delete('iptvs', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<List<Iptv>> findAll() async {
    final db = await _database.database;
    final rows = await db.query('iptvs', orderBy: 'updatedAt DESC');
    return rows.map(_deserialize).toList();
  }

  Future<Iptv?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query('iptvs', where: 'id = ?', whereArgs: <Object>[id], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return _deserialize(rows.first);
  }

  Map<String, Object?> _serialize(Iptv iptv) {
    final json = iptv.toJson();
    return <String, Object?>{
      ...json,
      'isActive': iptv.isActive ? 1 : 0,
      'headers': json['headers'] == null ? null : jsonEncode(json['headers']),
    };
  }

  Iptv _deserialize(Map<String, Object?> row) {
    final normalized = <String, dynamic>{...row};
    final headers = row['headers'] as String?;
    normalized['isActive'] = (row['isActive'] as int? ?? 0) == 1;
    normalized['headers'] = headers == null || headers.isEmpty
        ? null
        : jsonDecode(headers) as Map<String, dynamic>;
    return Iptv.fromJson(normalized);
  }
}
