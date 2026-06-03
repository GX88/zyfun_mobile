import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/data/models/analyze.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';
import 'package:zyfun_mobile/data/models/setting.dart';
import 'package:zyfun_mobile/data/models/site.dart';
import 'package:zyfun_mobile/data/models/video.dart';
import 'package:zyfun_mobile/data/services/config_import_service.dart';
import 'package:zyfun_mobile/domain/repositories/analyze_repository.dart';
import 'package:zyfun_mobile/domain/repositories/iptv_repository.dart';
import 'package:zyfun_mobile/domain/repositories/setting_repository.dart';
import 'package:zyfun_mobile/domain/repositories/site_repository.dart';

void main() {
  test('ConfigImportService 导入桌面配置并写入默认值', () async {
    final siteRepository = FakeSiteRepository();
    final iptvRepository = FakeIptvRepository();
    final analyzeRepository = FakeAnalyzeRepository();
    final settingRepository = FakeSettingRepository();
    final service = ConfigImportService(
      siteRepository: siteRepository,
      iptvRepository: iptvRepository,
      analyzeRepository: analyzeRepository,
      settingRepository: settingRepository,
    );

    final json = jsonEncode(<String, Object?>{
      'tbl_site': <Map<String, Object?>>[
        <String, Object?>{
          'id': '1',
          'key': '量子资源',
          'name': '量子资源',
          'api': 'https://example.com/json',
          'jiexiUrl': 'https://jx.example.com/?url=',
          'group': '默认',
          'type': 1,
          'search': 1,
          'isActive': true,
        },
        <String, Object?>{
          'id': '2',
          'name': 'XML资源',
          'api': 'https://example.com/xml',
          'type': 0,
          'isActive': true,
        },
      ],
      'tbl_iptv': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'iptv-1',
          'name': '直播源',
          'url': '#EXTM3U\n#EXTINF:-1,测试频道\nhttps://example.com/live.m3u8',
          'type': 'batches',
          'isActive': true,
          'epg': 'IPTV',
        },
      ],
      'tbl_analyze': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'analyze-1',
          'name': '咸鱼',
          'url': 'https://jx.example.com/?url=',
          'isActive': true,
        },
      ],
      'tbl_setting': <Map<String, Object?>>[
        <String, Object?>{'key': 'theme', 'value': 'light'},
        <String, Object?>{'key': 'defaultSite', 'value': '1'},
        <String, Object?>{'key': 'defaultIptv', 'value': 'iptv-1'},
        <String, Object?>{'key': 'defaultAnalyze', 'value': 'analyze-1'},
        <String, Object?>{'key': 'defaultIptvEpg', 'value': 'https://epg.example.com'},
        <String, Object?>{'key': 'hardwareAcceleration', 'value': true},
        <String, Object?>{'key': 'analyzeFlag', 'value': <String>['qq', 'youku']},
      ],
    });

    final result = await service.importDesktopConfig(json);

    expect(result.sitesImported, 1);
    expect(result.skippedSites, 1);
    expect(result.iptvsImported, 1);
    expect(result.analyzesImported, 1);
    expect(siteRepository.sites.single.playUrl, 'https://jx.example.com/?url=');
    expect(iptvRepository.iptvs.single.type, 3);
    expect(analyzeRepository.analyzes.single.flag, <String>['qq', 'youku']);
    expect(settingRepository.setting.theme, 'light');
    expect(settingRepository.setting.live?.epg, 'https://epg.example.com');
    expect(settingRepository.setting.defaultSite, '1');
    expect(siteRepository.defaultSiteId, '1');
    expect(iptvRepository.defaultIptvId, 'iptv-1');
    expect(analyzeRepository.defaultAnalyzeId, 'analyze-1');
  });

  test('ConfigImportService 支持 url 字段并回退选择首个默认项', () async {
    final siteRepository = FakeSiteRepository();
    final iptvRepository = FakeIptvRepository();
    final analyzeRepository = FakeAnalyzeRepository();
    final settingRepository = FakeSettingRepository();
    final service = ConfigImportService(
      siteRepository: siteRepository,
      iptvRepository: iptvRepository,
      analyzeRepository: analyzeRepository,
      settingRepository: settingRepository,
    );

    final json = jsonEncode(<String, Object?>{
      'tbl_site': <Map<String, Object?>>[
        <String, Object?>{
          'key': 'site-a',
          'name': '站点A',
          'url': 'https://example.com/a',
          'type': 1,
        },
      ],
      'tbl_iptv': <Map<String, Object?>>[
        <String, Object?>{
          'name': '直播A',
          'content': '#EXTM3U\n#EXTINF:-1,频道A\nhttps://example.com/live.m3u8',
          'type': 'batches',
        },
      ],
      'tbl_analyze': <Map<String, Object?>>[
        <String, Object?>{
          'name': '解析A',
          'api': 'https://jx.example.com/?url=',
        },
      ],
      'tbl_setting': <Map<String, Object?>>[
        <String, Object?>{'key': 'theme', 'value': 'dark'},
      ],
    });

    final result = await service.importDesktopConfig(json);

    expect(result.sitesImported, 1);
    expect(result.iptvsImported, 1);
    expect(result.analyzesImported, 1);
    expect(siteRepository.sites.single.id, 'site-a');
    expect(siteRepository.sites.single.api, 'https://example.com/a');
    expect(siteRepository.defaultSiteId, 'site-a');
    expect(iptvRepository.iptvs.single.id, '直播A');
    expect(iptvRepository.defaultIptvId, '直播A');
    expect(analyzeRepository.analyzes.single.id, '解析A');
    expect(analyzeRepository.defaultAnalyzeId, '解析A');
  });
}

class FakeSiteRepository implements SiteRepository {
  final List<Site> sites = <Site>[];
  String? defaultSiteId;

  @override
  Future<void> addSite(Site site) async {
    sites.add(site);
  }

  @override
  Future<void> deleteSite(String id) async {
    sites.removeWhere((site) => site.id == id);
  }

  @override
  Future<List<Site>> getAllSites() async => List<Site>.from(sites);

  @override
  Future<List<Category>> getCategories(String siteId) async => const <Category>[];

  @override
  Future<String?> getDefaultSite() async => defaultSiteId;

  @override
  Future<String> getPlayUrl(String siteId, String episodeUrl) async => episodeUrl;

  @override
  Future<Site?> getSiteById(String id) async => null;

  @override
  Future<VideoDetail> getVideoDetail(String siteId, String videoId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Video>> getVideosByCategory(String siteId, String categoryId, int page) async {
    return const <Video>[];
  }

  @override
  Future<List<Video>> searchVideos(String siteId, String keyword) async {
    return const <Video>[];
  }

  @override
  Future<void> setDefaultSite(String id) async {
    defaultSiteId = id;
  }

  @override
  Future<void> updateSite(Site site) async {}
}

class FakeIptvRepository implements IptvRepository {
  final List<Iptv> iptvs = <Iptv>[];
  String? defaultIptvId;

  @override
  Future<void> addIptv(Iptv iptv) async {
    iptvs.add(iptv);
  }

  @override
  Future<void> deleteIptv(String id) async {
    iptvs.removeWhere((iptv) => iptv.id == id);
  }

  @override
  Future<List<Iptv>> getAllIptvs() async => List<Iptv>.from(iptvs);

  @override
  Future<List<Channel>> getChannels(String iptvId) async => const <Channel>[];

  @override
  Future<String?> getDefaultIptv() async => defaultIptvId;

  @override
  Future<Iptv?> getIptvById(String id) async => null;

  @override
  Future<List<Channel>> parseM3u(String content) async => const <Channel>[];

  @override
  Future<void> setDefaultIptv(String id) async {
    defaultIptvId = id;
  }

  @override
  Future<void> updateIptv(Iptv iptv) async {}
}

class FakeAnalyzeRepository implements AnalyzeRepository {
  final List<Analyze> analyzes = <Analyze>[];
  String? defaultAnalyzeId;

  @override
  Future<void> addAnalyze(Analyze analyze) async {
    analyzes.add(analyze);
  }

  @override
  Future<void> deleteAnalyze(String id) async {
    analyzes.removeWhere((analyze) => analyze.id == id);
  }

  @override
  Future<List<Analyze>> getAllAnalyzes() async => List<Analyze>.from(analyzes);

  @override
  Future<Analyze?> getAnalyzeById(String id) async => null;

  @override
  Future<String?> getDefaultAnalyze() async => defaultAnalyzeId;

  @override
  Future<void> setDefaultAnalyze(String id) async {
    defaultAnalyzeId = id;
  }

  @override
  Future<void> updateAnalyze(Analyze analyze) async {}
}

class FakeSettingRepository implements SettingRepository {
  Setting setting = const Setting();

  @override
  Future<Setting> exportSetting() async => setting;

  @override
  Future<Setting> getAllSettings() async => setting;

  @override
  Future<T?> getSetting<T>(String key) async => null;

  @override
  Future<void> importSetting(Setting setting) async {
    this.setting = setting;
  }

  @override
  Future<void> resetSetting() async {
    setting = const Setting();
  }

  @override
  Future<void> updateSetting<T>(String key, T value) async {}
}
