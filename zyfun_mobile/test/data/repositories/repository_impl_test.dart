import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zyfun_mobile/core/constants/constants.dart';
import 'package:zyfun_mobile/data/datasources/local/app_database.dart';
import 'package:zyfun_mobile/data/datasources/local/dao/dao.dart';
import 'package:zyfun_mobile/data/datasources/local/key_value_storage.dart';
import 'package:zyfun_mobile/data/models/analyze.dart';
import 'package:zyfun_mobile/data/models/history.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';
import 'package:zyfun_mobile/data/models/setting.dart';
import 'package:zyfun_mobile/data/models/site.dart';
import 'package:zyfun_mobile/data/repositories/analyze_repository_impl.dart';
import 'package:zyfun_mobile/data/repositories/history_repository_impl.dart';
import 'package:zyfun_mobile/data/repositories/iptv_repository_impl.dart';
import 'package:zyfun_mobile/data/repositories/setting_repository_impl.dart';
import 'package:zyfun_mobile/data/repositories/site_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDirectory;
  late AppDatabase appDatabase;
  late SharedPreferences sharedPreferences;
  late KeyValueStorage storage;

  late SiteRepositoryImpl siteRepository;
  late HistoryRepositoryImpl historyRepository;
  late IptvRepositoryImpl iptvRepository;
  late AnalyzeRepositoryImpl analyzeRepository;
  late SettingRepositoryImpl settingRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPreferences = await SharedPreferences.getInstance();
    storage = KeyValueStorage(sharedPreferences: sharedPreferences);

    tempDirectory = await Directory.systemTemp.createTemp(
      'zyfun_mobile_repository_test_',
    );
    appDatabase = AppDatabase.test(
      databaseDirectoryResolver: () async => tempDirectory.path,
      databaseFactory: databaseFactoryFfi,
    );

    siteRepository = SiteRepositoryImpl(
      siteDao: SiteDao(database: appDatabase),
      storage: storage,
    );
    historyRepository = HistoryRepositoryImpl(
      historyDao: HistoryDao(database: appDatabase),
    );
    iptvRepository = IptvRepositoryImpl(
      iptvDao: IptvDao(database: appDatabase),
      storage: storage,
    );
    analyzeRepository = AnalyzeRepositoryImpl(
      analyzeDao: AnalyzeDao(database: appDatabase),
      storage: storage,
    );
    settingRepository = SettingRepositoryImpl(
      settingDao: SettingDao(database: appDatabase),
    );
  });

  tearDown(() async {
    final db = await appDatabase.database;
    await db.close();

    final dbFile = File(p.join(tempDirectory.path, DatabaseConstants.dbName));
    if (await dbFile.exists()) {
      await databaseFactoryFfi.deleteDatabase(dbFile.path);
    }

    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  group('SiteRepositoryImpl', () {
    test('支持站点 CRUD 和默认站点存储', () async {
      const site = Site(
        id: 'site-1',
        key: 'demo',
        name: '演示站点',
        api: 'https://example.com/api',
        categories: '电影,电视剧',
        createdAt: 1,
        updatedAt: 2,
      );

      await siteRepository.addSite(site);
      expect(await siteRepository.getAllSites(), hasLength(1));
      expect((await siteRepository.getSiteById(site.id))?.name, '演示站点');

      await siteRepository.setDefaultSite(site.id);
      expect(await siteRepository.getDefaultSite(), site.id);

      await siteRepository.updateSite(site.copyWith(name: '演示站点2'));
      expect((await siteRepository.getSiteById(site.id))?.name, '演示站点2');

      await siteRepository.deleteSite(site.id);
      expect(await siteRepository.getAllSites(), isEmpty);
    });

    test('根据分类和关键字生成演示视频数据', () async {
      const site = Site(
        id: 'site-1',
        key: 'demo',
        name: '演示站点',
        api: 'https://example.com/api',
        categories: '电影,电视剧',
        createdAt: 1,
        updatedAt: 2,
      );

      await siteRepository.addSite(site);

      final categories = await siteRepository.getCategories(site.id);
      expect(categories.map((item) => item.name), <String>['电影', '电视剧']);
      expect(categories.first.isHome, isTrue);

      final videos = await siteRepository.getVideosByCategory(
        site.id,
        categories.first.id,
        1,
      );
      expect(videos, hasLength(12));
      expect(videos.first.siteId, site.id);
      expect(videos.first.type, '电影');

      final searchResults = await siteRepository.searchVideos(site.id, '三体');
      expect(searchResults, hasLength(8));
      expect(searchResults.first.title, contains('三体'));

      final detail = await siteRepository.getVideoDetail(
        site.id,
        searchResults.first.id,
      );
      expect(detail.video.id, searchResults.first.id);
      expect(detail.episodes, isNotEmpty);

      expect(
        await siteRepository.getPlayUrl(site.id, 'https://example.com/play/1'),
        'https://example.com/play/1',
      );
      expect(await siteRepository.searchVideos(site.id, '  '), isEmpty);
      expect(await siteRepository.getCategories('missing-site'), isEmpty);
    });
  });

  group('HistoryRepositoryImpl', () {
    test('支持历史记录保存、更新、查询和清空', () async {
      const history = History(
        id: 'history-1',
        siteId: 'site-1',
        videoId: 'video-1',
        title: '视频一',
        episodeUrl: 'https://example.com/play/1',
        progress: 1000,
        duration: 5000,
        createdAt: 1,
        updatedAt: 2,
      );

      await historyRepository.addHistory(history);
      await historyRepository.addHistory(
        history.copyWith(id: 'history-2', title: '视频二', updatedAt: 5),
      );

      expect(await historyRepository.getAllHistories(), hasLength(2));
      expect(
        (await historyRepository.getRecentHistories(limit: 1)).single.id,
        'history-2',
      );

      await historyRepository.updateHistory(
        history.copyWith(progress: 3000, updatedAt: 6),
      );
      expect((await historyRepository.getHistoryById(history.id))?.progress, 3000);

      await historyRepository.deleteHistory('history-2');
      expect(await historyRepository.getAllHistories(), hasLength(1));

      await historyRepository.clearAllHistories();
      expect(await historyRepository.getAllHistories(), isEmpty);
    });
  });

  group('IptvRepositoryImpl', () {
    test('支持直播源 CRUD、默认值读写和占位方法返回', () async {
      const iptv = Iptv(
        id: 'iptv-1',
        key: 'demo-live',
        name: '演示直播源',
        api: 'https://example.com/live.m3u',
        headers: <String, dynamic>{'Authorization': 'Bearer token'},
        createdAt: 1,
        updatedAt: 2,
      );

      await iptvRepository.addIptv(iptv);
      expect(await iptvRepository.getAllIptvs(), hasLength(1));
      expect(
        (await iptvRepository.getIptvById(iptv.id))?.headers?['Authorization'],
        'Bearer token',
      );

      await iptvRepository.setDefaultIptv(iptv.id);
      expect(await iptvRepository.getDefaultIptv(), iptv.id);

      await iptvRepository.updateIptv(iptv.copyWith(name: '演示直播源2'));
      expect((await iptvRepository.getIptvById(iptv.id))?.name, '演示直播源2');

      expect(await iptvRepository.getChannels(iptv.id), isEmpty);
      expect(await iptvRepository.parseM3u('#EXTM3U'), isEmpty);

      await iptvRepository.deleteIptv(iptv.id);
      expect(await iptvRepository.getAllIptvs(), isEmpty);
    });
  });

  group('AnalyzeRepositoryImpl', () {
    test('支持解析源 CRUD、默认值读写', () async {
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

      await analyzeRepository.addAnalyze(analyze);
      expect(await analyzeRepository.getAllAnalyzes(), hasLength(1));

      final found = await analyzeRepository.getAnalyzeById(analyze.id);
      expect(found?.flag, <String>['qq', 'youku']);
      expect(found?.headers?['Referer'], 'https://example.com');

      await analyzeRepository.setDefaultAnalyze(analyze.id);
      expect(await analyzeRepository.getDefaultAnalyze(), analyze.id);

      await analyzeRepository.updateAnalyze(analyze.copyWith(name: '默认解析2'));
      expect(
        (await analyzeRepository.getAnalyzeById(analyze.id))?.name,
        '默认解析2',
      );

      await analyzeRepository.deleteAnalyze(analyze.id);
      expect(await analyzeRepository.getAllAnalyzes(), isEmpty);
    });
  });

  group('SettingRepositoryImpl', () {
    test('支持默认设置、导入导出、键值更新和重置', () async {
      expect(await settingRepository.getAllSettings(), const Setting());

      const setting = Setting(
        theme: 'dark',
        defaultSite: 'site-1',
        timeout: 8000,
        hardwareAcceleration: false,
        proxy: ProxyConfig(type: 'custom', url: 'http://127.0.0.1:7890'),
      );

      await settingRepository.importSetting(setting);

      final storedSetting = await settingRepository.getAllSettings();
      expect(storedSetting.theme, 'dark');
      expect(storedSetting.proxy?.url, 'http://127.0.0.1:7890');
      expect(await settingRepository.exportSetting(), storedSetting);

      await settingRepository.updateSetting<String>(StorageKeys.theme, 'light');
      await settingRepository.updateSetting<int>(StorageKeys.language, 1);

      expect(await settingRepository.getSetting<String>(StorageKeys.theme), 'light');
      expect(await settingRepository.getSetting<int>(StorageKeys.language), 1);

      await settingRepository.resetSetting();
      expect(await settingRepository.getAllSettings(), const Setting());
    });
  });
}
