import 'dart:convert';

import '../../../models/analyze.dart';
import '../app_database.dart';

class AnalyzeDao {
  AnalyzeDao({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<void> insert(Analyze analyze) async {
    final db = await _database.database;
    await db.insert('analyzes', _serialize(analyze));
  }

  Future<void> update(Analyze analyze) async {
    final db = await _database.database;
    await db.update(
      'analyzes',
      _serialize(analyze),
      where: 'id = ?',
      whereArgs: <Object>[analyze.id],
    );
  }

  Future<void> deleteById(String id) async {
    final db = await _database.database;
    await db.delete('analyzes', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<List<Analyze>> findAll() async {
    final db = await _database.database;
    final rows = await db.query('analyzes', orderBy: 'updatedAt DESC');
    return rows.map(_deserialize).toList();
  }

  Future<Analyze?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query('analyzes', where: 'id = ?', whereArgs: <Object>[id], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return _deserialize(rows.first);
  }

  Map<String, Object?> _serialize(Analyze analyze) {
    final json = analyze.toJson();
    return <String, Object?>{
      ...json,
      'isActive': analyze.isActive ? 1 : 0,
      'flag': analyze.flag.join(','),
      'headers': json['headers'] == null ? null : jsonEncode(json['headers']),
    };
  }

  Analyze _deserialize(Map<String, Object?> row) {
    final normalized = <String, dynamic>{...row};
    final headers = row['headers'] as String?;
    normalized['isActive'] = (row['isActive'] as int? ?? 0) == 1;
    normalized['flag'] = (row['flag'] as String? ?? '')
        .split(',')
        .where((item) => item.isNotEmpty)
        .toList();
    normalized['headers'] = headers == null || headers.isEmpty
        ? null
        : jsonDecode(headers) as Map<String, dynamic>;
    return Analyze.fromJson(normalized);
  }
}
