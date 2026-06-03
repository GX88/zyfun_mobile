import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/constants.dart';

class AppDatabase {
  AppDatabase._({
    Future<String> Function()? databaseDirectoryResolver,
    DatabaseFactory? databaseFactory,
  })  : _databaseDirectoryResolver = databaseDirectoryResolver,
        _databaseFactory = databaseFactory;

  static final AppDatabase instance = AppDatabase._();

  factory AppDatabase.test({
    required Future<String> Function() databaseDirectoryResolver,
    required DatabaseFactory databaseFactory,
  }) {
    return AppDatabase._(
      databaseDirectoryResolver: databaseDirectoryResolver,
      databaseFactory: databaseFactory,
    );
  }

  Database? _database;
  final Future<String> Function()? _databaseDirectoryResolver;
  final DatabaseFactory? _databaseFactory;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final basePath = await _resolveDatabaseDirectory();
    final path = p.join(basePath, DatabaseConstants.dbName);
    final factory = _databaseFactory ?? databaseFactory;

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: DatabaseConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<String> _resolveDatabaseDirectory() async {
    if (_databaseDirectoryResolver != null) {
      return _databaseDirectoryResolver!();
    }

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sites (
        id TEXT PRIMARY KEY,
        key TEXT NOT NULL,
        name TEXT NOT NULL,
        api TEXT NOT NULL,
        playUrl TEXT,
        search INTEGER NOT NULL DEFAULT 0,
        "group" TEXT NOT NULL DEFAULT '',
        type INTEGER NOT NULL DEFAULT 1,
        ext TEXT NOT NULL DEFAULT '',
        categories TEXT NOT NULL DEFAULT '',
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE iptvs (
        id TEXT PRIMARY KEY,
        key TEXT NOT NULL,
        name TEXT NOT NULL,
        api TEXT NOT NULL,
        type INTEGER NOT NULL DEFAULT 1,
        epg TEXT,
        logo TEXT,
        headers TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE analyzes (
        id TEXT PRIMARY KEY,
        key TEXT NOT NULL,
        name TEXT NOT NULL,
        api TEXT NOT NULL,
        type INTEGER NOT NULL DEFAULT 1,
        flag TEXT,
        headers TEXT,
        script TEXT NOT NULL DEFAULT '',
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE histories (
        id TEXT PRIMARY KEY,
        siteId TEXT NOT NULL,
        videoId TEXT NOT NULL,
        title TEXT NOT NULL,
        cover TEXT,
        description TEXT,
        episodeUrl TEXT NOT NULL,
        episodeName TEXT,
        progress INTEGER NOT NULL DEFAULT 0,
        duration INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        siteId TEXT NOT NULL,
        videoId TEXT NOT NULL,
        title TEXT NOT NULL,
        cover TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_histories_updated_at ON histories(updatedAt DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_favorites_created_at ON favorites(createdAt DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
