import 'dart:convert';

import '../../core/constants/constants.dart';
import '../../domain/repositories/setting_repository.dart';
import '../datasources/local/dao/setting_dao.dart';
import '../models/setting.dart';

class SettingRepositoryImpl implements SettingRepository {
  SettingRepositoryImpl({required SettingDao settingDao}) : _settingDao = settingDao;

  final SettingDao _settingDao;

  @override
  Future<Setting> exportSetting() async {
    return getAllSettings();
  }

  @override
  Future<Setting> getAllSettings() async {
    final value = await _settingDao.getValue(StorageKeys.setting);
    if (value == null) {
      return const Setting();
    }
    return Setting.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    final value = await _settingDao.getValue(key);
    if (value == null) {
      return null;
    }
    return jsonDecode(value) as T?;
  }

  @override
  Future<void> importSetting(Setting setting) async {
    await _settingDao.upsert(
      StorageKeys.setting,
      jsonEncode(setting.toJson()),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> resetSetting() async {
    await _settingDao.deleteByKey(StorageKeys.setting);
  }

  @override
  Future<void> updateSetting<T>(String key, T value) async {
    await _settingDao.upsert(
      key,
      jsonEncode(value),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
