import 'dart:convert';

import '../../data/models/analyze.dart';
import '../../data/models/iptv.dart';
import '../../data/models/setting.dart';
import '../../data/models/site.dart';
import '../../domain/repositories/analyze_repository.dart';
import '../../domain/repositories/iptv_repository.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../domain/repositories/site_repository.dart';

class ConfigImportResult {
  const ConfigImportResult({
    required this.sitesImported,
    required this.iptvsImported,
    required this.analyzesImported,
    required this.skippedSites,
  });

  final int sitesImported;
  final int iptvsImported;
  final int analyzesImported;
  final int skippedSites;
}

class ConfigImportService {
  ConfigImportService({
    required SiteRepository siteRepository,
    required IptvRepository iptvRepository,
    required AnalyzeRepository analyzeRepository,
    required SettingRepository settingRepository,
  })  : _siteRepository = siteRepository,
        _iptvRepository = iptvRepository,
        _analyzeRepository = analyzeRepository,
        _settingRepository = settingRepository;

  final SiteRepository _siteRepository;
  final IptvRepository _iptvRepository;
  final AnalyzeRepository _analyzeRepository;
  final SettingRepository _settingRepository;

  Future<ConfigImportResult> importDesktopConfig(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('配置文件格式无效');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final siteRows = _asMapList(decoded['tbl_site']);
    final iptvRows = _asMapList(decoded['tbl_iptv']);
    final analyzeRows = _asMapList(decoded['tbl_analyze']);
    final settingRows = _asMapList(decoded['tbl_setting']);

    final existingSites = await _siteRepository.getAllSites();
    for (final site in existingSites) {
      await _siteRepository.deleteSite(site.id);
    }

    final existingIptvs = await _iptvRepository.getAllIptvs();
    for (final iptv in existingIptvs) {
      await _iptvRepository.deleteIptv(iptv.id);
    }

    final existingAnalyzes = await _analyzeRepository.getAllAnalyzes();
    for (final analyze in existingAnalyzes) {
      await _analyzeRepository.deleteAnalyze(analyze.id);
    }

    var importedSites = 0;
    var skippedSites = 0;
    for (final row in siteRows) {
      final type = _asInt(row['type'], defaultValue: 1);
      if (type != 1) {
        skippedSites += 1;
        continue;
      }

      final site = Site(
        id: _asString(row['id']),
        key: _asString(row['key']).isEmpty ? _asString(row['name']) : _asString(row['key']),
        name: _asString(row['name']).isEmpty ? _asString(row['key']) : _asString(row['name']),
        api: _asString(row['api']),
        playUrl: _asString(row['playUrl']).isEmpty
            ? _asString(row['jiexiUrl'])
            : _asString(row['playUrl']),
        search: _asInt(row['search']),
        group: _asString(row['group']).isEmpty ? '默认' : _asString(row['group']),
        type: type,
        ext: _asString(row['ext']),
        categories: _asString(row['categories']),
        isActive: _asBool(row['isActive'], fallback: _asBool(row['status'], fallback: true)),
        createdAt: now,
        updatedAt: now,
      );
      if (!site.isValid) {
        skippedSites += 1;
        continue;
      }
      await _siteRepository.addSite(site);
      importedSites += 1;
    }

    var importedIptvs = 0;
    for (final row in iptvRows) {
      final type = _mapIptvType(_asString(row['type']));
      final source = _asString(row['url']);
      final iptv = Iptv(
        id: _asString(row['id']),
        key: _asString(row['name']),
        name: _asString(row['name']),
        api: source,
        type: type,
        epg: _asString(row['epg']),
        isActive: _asBool(row['isActive'], fallback: true),
        createdAt: now,
        updatedAt: now,
      );
      if (!iptv.isValid) {
        continue;
      }
      await _iptvRepository.addIptv(iptv);
      importedIptvs += 1;
    }

    final analyzeFlag = _readListSetting(settingRows, 'analyzeFlag');
    var importedAnalyzes = 0;
    for (final row in analyzeRows) {
      final analyze = Analyze(
        id: _asString(row['id']),
        key: _asString(row['name']),
        name: _asString(row['name']),
        api: _asString(row['url']),
        type: 1,
        flag: analyzeFlag,
        isActive: _asBool(row['isActive'], fallback: true),
        createdAt: now,
        updatedAt: now,
      );
      if (!analyze.isValid) {
        continue;
      }
      await _analyzeRepository.addAnalyze(analyze);
      importedAnalyzes += 1;
    }

    final setting = await _buildSettingFromRows(settingRows);
    await _settingRepository.importSetting(setting);

    final defaultSite = _readStringSetting(settingRows, 'defaultSite');
    final defaultIptv = _readStringSetting(settingRows, 'defaultIptv');
    final defaultAnalyze = _readStringSetting(settingRows, 'defaultAnalyze');

    if (defaultSite.isNotEmpty) {
      await _siteRepository.setDefaultSite(defaultSite);
    }
    if (defaultIptv.isNotEmpty) {
      await _iptvRepository.setDefaultIptv(defaultIptv);
    }
    if (defaultAnalyze.isNotEmpty) {
      await _analyzeRepository.setDefaultAnalyze(defaultAnalyze);
    }

    return ConfigImportResult(
      sitesImported: importedSites,
      iptvsImported: importedIptvs,
      analyzesImported: importedAnalyzes,
      skippedSites: skippedSites,
    );
  }

  Future<Setting> _buildSettingFromRows(List<Map<String, dynamic>> rows) async {
    final current = await _settingRepository.getAllSettings();
    return current.copyWith(
      theme: _readStringSetting(rows, 'theme', fallback: current.theme),
      hot: _readStringSetting(rows, 'defaultHot', fallback: current.hot),
      association: _readStringSetting(
        rows,
        'defaultSearchRecommend',
        fallback: current.association,
      ),
      defaultSite: _readStringSetting(rows, 'defaultSite', fallback: current.defaultSite),
      defaultIptv: _readStringSetting(rows, 'defaultIptv', fallback: current.defaultIptv),
      defaultAnalyze: _readStringSetting(
        rows,
        'defaultAnalyze',
        fallback: current.defaultAnalyze,
      ),
      live: (current.live ?? const LiveConfig()).copyWith(
        epg: _readStringSetting(rows, 'defaultIptvEpg', fallback: current.live?.epg ?? ''),
        thumbnail: _readBoolSetting(
          rows,
          'iptvThumbnail',
          fallback: current.live?.thumbnail ?? false,
        ),
      ),
      autoStart: _readBoolSetting(rows, 'selfBoot', fallback: current.autoStart),
      hardwareAcceleration: _readBoolSetting(
        rows,
        'hardwareAcceleration',
        fallback: current.hardwareAcceleration,
      ),
      ua: _readStringSetting(rows, 'ua', fallback: current.ua),
      dns: _readStringSetting(rows, 'doh', fallback: current.dns),
    );
  }

  List<Map<String, dynamic>> _asMapList(Object? value) {
    if (value is! List<Object?>) {
      return const <Map<String, dynamic>>[];
    }
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  String _readStringSetting(
    List<Map<String, dynamic>> rows,
    String key, {
    String fallback = '',
  }) {
    for (final row in rows) {
      if (_asString(row['key']) == key) {
        return _asString(row['value']);
      }
    }
    return fallback;
  }

  bool _readBoolSetting(
    List<Map<String, dynamic>> rows,
    String key, {
    bool fallback = false,
  }) {
    for (final row in rows) {
      if (_asString(row['key']) == key) {
        return _asBool(row['value'], fallback: fallback);
      }
    }
    return fallback;
  }

  List<String> _readListSetting(List<Map<String, dynamic>> rows, String key) {
    for (final row in rows) {
      if (_asString(row['key']) == key) {
        final value = row['value'];
        if (value is List<Object?>) {
          return value.map(_asString).where((item) => item.isNotEmpty).toList();
        }
      }
    }
    return const <String>[];
  }

  int _mapIptvType(String type) {
    switch (type) {
      case 'remote':
        return 1;
      case 'local':
        return 2;
      default:
        return 3;
    }
  }

  String _asString(Object? value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  int _asInt(Object? value, {int defaultValue = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_asString(value)) ?? defaultValue;
  }

  bool _asBool(Object? value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    final normalized = _asString(value).toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
    return fallback;
  }
}
