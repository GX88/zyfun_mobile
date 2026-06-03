import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/dao/dao.dart';
import '../../data/datasources/local/key_value_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/analyze_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/iptv_repository_impl.dart';
import '../../data/repositories/setting_repository_impl.dart';
import '../../data/repositories/site_repository_impl.dart';
import '../../domain/repositories/analyze_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/iptv_repository.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../domain/repositories/site_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final keyValueStorageProvider = Provider<KeyValueStorage>((ref) {
  return KeyValueStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final siteDaoProvider = Provider<SiteDao>((ref) {
  return SiteDao(database: ref.watch(appDatabaseProvider));
});

final historyDaoProvider = Provider<HistoryDao>((ref) {
  return HistoryDao(database: ref.watch(appDatabaseProvider));
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
  );
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(historyDao: ref.watch(historyDaoProvider));
});

final iptvRepositoryProvider = Provider<IptvRepository>((ref) {
  return IptvRepositoryImpl(
    iptvDao: ref.watch(iptvDaoProvider),
    storage: ref.watch(keyValueStorageProvider),
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
