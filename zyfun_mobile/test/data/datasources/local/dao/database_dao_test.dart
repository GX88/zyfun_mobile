import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zyfun_mobile/data/datasources/local/app_database.dart';
import 'package:zyfun_mobile/data/datasources/local/dao/dao.dart';
import 'package:zyfun_mobile/data/models/analyze.dart';
import 'package:zyfun_mobile/data/models/history.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';
import 'package:zyfun_mobile/data/models/site.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDirectory;
  late AppDatabase appDatabase;
  late SiteDao siteDao;
  late HistoryDao historyDao;
  late IptvDao iptvDao;
  late AnalyzeDao analyzeDao;
  late SettingDao settingDao;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('zyfun_mobile_db_test_');
    appDatabase = AppDatabase.test(
      databaseDirectoryResolver: () async => tempDirectory.path,
      databaseFactory: databaseFactoryFfi,
    );
    siteDao = SiteDao(database: appDatabase);
    historyDao = HistoryDao(database: appDatabase);
    iptvDao = IptvDao(database: appDatabase);
    analyzeDao = AnalyzeDao(database: appDatabase);
    settingDao = SettingDao(database: appDatabase);
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();

    final dbFile = File(p.join(tempDirectory.path, 'zyfun.db'));
    if (await dbFile.exists()) {
      await deleteDatabase(dbFile.path);
    }

    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  group('数据库初始化', () {
    test('创建所有核心数据表', () async {
      final db = await appDatabase.database;
      final rows = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
      );
      final tableNames = rows
          .map((row) => row['name'] as String)
          .where((name) => !name.startsWith('sqlite_'))
          .toList();

      expect(tableNames, containsAll(<String>[
        'analyzes',
        'favorites',
        'histories',
        'iptvs',
        'settings',
        'sites',
      ]));
    });
  });

  group('SiteDao', () {
    test('支持新增、查询、更新和删除', () async {
      const site = Site(
        id: 'site-1',
        key: 'demo',
        name: '演示站点',
        api: 'https://example.com/api',
        categories: '电影,电视剧',
        createdAt: 1,
        updatedAt: 2,
      );

      await siteDao.insert(site);

      final found = await siteDao.findById(site.id);
      expect(found, isNotNull);
      expect(found?.name, '演示站点');

      await siteDao.update(site.copyWith(name: '演示站点2', updatedAt: 3));

      final updated = await siteDao.findAll();
      expect(updated, hasLength(1));
      expect(updated.first.name, '演示站点2');

      await siteDao.deleteById(site.id);

      expect(await siteDao.findAll(), isEmpty);
    });
  });

  group('HistoryDao', () {
    test('支持覆盖写入、最近记录查询和清空', () async {
      const history = History(
        id: 'history-1',
        siteId: 'site-1',
        videoId: 'video-1',
        title: '测试视频',
        episodeUrl: 'https://example.com/play/1',
        progress: 1000,
        duration: 5000,
        createdAt: 1,
        updatedAt: 2,
      );

      await historyDao.insertOrReplace(history);
      await historyDao.insertOrReplace(history.copyWith(progress: 3000, updatedAt: 5));

      final found = await historyDao.findById(history.id);
      expect(found?.progress, 3000);

      final recent = await historyDao.findRecent(limit: 10);
      expect(recent, hasLength(1));
      expect(recent.first.updatedAt, 5);

      await historyDao.clear();

      expect(await historyDao.findAll(), isEmpty);
    });
  });

  group('IptvDao', () {
    test('支持 headers 序列化与 CRUD', () async {
      const iptv = Iptv(
        id: 'iptv-1',
        key: 'iptv-demo',
        name: '直播源',
        api: 'https://example.com/live.m3u',
        headers: <String, dynamic>{'Authorization': 'Bearer token'},
        createdAt: 1,
        updatedAt: 2,
      );

      await iptvDao.insert(iptv);

      final found = await iptvDao.findById(iptv.id);
      expect(found, isNotNull);
      expect(found?.headers?['Authorization'], 'Bearer token');

      await iptvDao.update(iptv.copyWith(name: '直播源2', updatedAt: 3));
      final updated = await iptvDao.findAll();
      expect(updated.single.name, '直播源2');

      await iptvDao.deleteById(iptv.id);
      expect(await iptvDao.findAll(), isEmpty);
    });
  });

  group('AnalyzeDao', () {
    test('支持 flag 和 headers 的序列化与 CRUD', () async {
      const analyze = Analyze(
        id: 'analyze-1',
        key: 'jx',
        name: '默认解析',
        api: 'https://example.com/parse',
        flag: <String>['qq', 'youku'],
        headers: <String, dynamic>{'Referer': 'https://example.com'},
        createdAt: 1,
        updatedAt: 2,
      );

      await analyzeDao.insert(analyze);

      final found = await analyzeDao.findById(analyze.id);
      expect(found, isNotNull);
      expect(found?.flag, <String>['qq', 'youku']);
      expect(found?.headers?['Referer'], 'https://example.com');

      await analyzeDao.update(analyze.copyWith(name: '默认解析2', updatedAt: 3));
      final updated = await analyzeDao.findAll();
      expect(updated.single.name, '默认解析2');

      await analyzeDao.deleteById(analyze.id);
      expect(await analyzeDao.findAll(), isEmpty);
    });
  });

  group('SettingDao', () {
    test('支持写入、覆盖更新和删除', () async {
      await settingDao.upsert('theme', '"dark"', updatedAt: 1);
      expect(await settingDao.getValue('theme'), '"dark"');

      await settingDao.upsert('theme', '"light"', updatedAt: 2);
      expect(await settingDao.getValue('theme'), '"light"');

      await settingDao.deleteByKey('theme');
      expect(await settingDao.getValue('theme'), isNull);
    });
  });
}
