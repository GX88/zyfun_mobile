import '../../data/models/setting.dart';

/// 设置数据仓库接口
abstract class SettingRepository {
  /// 获取所有设置
  Future<Setting> getAllSettings();
  
  /// 获取单个设置
  Future<T?> getSetting<T>(String key);
  
  /// 更新设置
  Future<void> updateSetting<T>(String key, T value);
  
  /// 导入设置
  Future<void> importSetting(Setting setting);
  
  /// 导出设置
  Future<Setting> exportSetting();
  
  /// 重置设置
  Future<void> resetSetting();
}
