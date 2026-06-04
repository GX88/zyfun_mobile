import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/dao/dao.dart';
import '../../data/datasources/local/key_value_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/iptv_api.dart';
import '../../data/datasources/remote/parse_api.dart';
import '../../data/datasources/remote/site_api.dart';
import '../../data/repositories/analyze_repository_impl.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/iptv_repository_impl.dart';
import '../../data/repositories/setting_repository_impl.dart';
import '../../data/repositories/site_repository_impl.dart';
import '../../data/services/config_import_service.dart';
import '../../domain/repositories/analyze_repository.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/iptv_repository.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../domain/repositories/site_repository.dart';
import '../../services/background_playback_service.dart';
import '../../services/player_platform_bridge.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final keyValueStorageProvider = Provider<KeyValueStorage>((ref) {
  return KeyValueStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final siteApiProvider = Provider<SiteApi>((ref) {
  return SiteApi(apiClient: ref.watch(apiClientProvider));
});

final iptvApiProvider = Provider<IptvApi>((ref) {
  return IptvApi(apiClient: ref.watch(apiClientProvider));
});

final parseApiProvider = Provider<ParseApi>((ref) {
  return ParseApi(apiClient: ref.watch(apiClientProvider));
});

final siteDaoProvider = Provider<SiteDao>((ref) {
  return SiteDao(database: ref.watch(appDatabaseProvider));
});

final historyDaoProvider = Provider<HistoryDao>((ref) {
  return HistoryDao(database: ref.watch(appDatabaseProvider));
});

final favoriteDaoProvider = Provider<FavoriteDao>((ref) {
  return FavoriteDao(database: ref.watch(appDatabaseProvider));
});

final iptvDaoProvider = Provider<IptvDao>((ref) {
  return IptvDao(database: ref.watch(appDatabaseProvider));
});

final analyzeDaoProvider = Provider<AnalyzeDao>((ref) {
  return AnalyzeDao(database: ref.watch(appDatabaseProvider));
});

final settingDaoProvider = Provider<SettingDao>((ref) {
  return SettingDao(database: ref.watch(appDatabaseProvider));
});

final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  return SiteRepositoryImpl(
    siteDao: ref.watch(siteDaoProvider),
    storage: ref.watch(keyValueStorageProvider),
    siteApi: ref.watch(siteApiProvider),
    analyzeRepository: ref.watch(analyzeRepositoryProvider),
    parseApi: ref.watch(parseApiProvider),
  );
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(historyDao: ref.watch(historyDaoProvider));
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(favoriteDao: ref.watch(favoriteDaoProvider));
});

final iptvRepositoryProvider = Provider<IptvRepository>((ref) {
  return IptvRepositoryImpl(
    iptvDao: ref.watch(iptvDaoProvider),
    storage: ref.watch(keyValueStorageProvider),
    iptvApi: ref.watch(iptvApiProvider),
  );
});

final analyzeRepositoryProvider = Provider<AnalyzeRepository>((ref) {
  return AnalyzeRepositoryImpl(
    analyzeDao: ref.watch(analyzeDaoProvider),
    storage: ref.watch(keyValueStorageProvider),
  );
});

final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  return SettingRepositoryImpl(settingDao: ref.watch(settingDaoProvider));
});

final configImportServiceProvider = Provider<ConfigImportService>((ref) {
  return ConfigImportService(
    siteRepository: ref.watch(siteRepositoryProvider),
    iptvRepository: ref.watch(iptvRepositoryProvider),
    analyzeRepository: ref.watch(analyzeRepositoryProvider),
    settingRepository: ref.watch(settingRepositoryProvider),
  );
});

final backgroundPlaybackHandlerProvider = Provider<AppAudioHandler>((ref) {
  return BackgroundPlaybackService.instance.handler;
});

final playerPlatformBridgeProvider = Provider<PlayerPlatformBridge>((ref) {
  return const PlayerPlatformBridge();
});
