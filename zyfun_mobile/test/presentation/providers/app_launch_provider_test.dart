import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/core/constants/constants.dart';
import 'package:zyfun_mobile/data/models/setting.dart';
import 'package:zyfun_mobile/domain/repositories/setting_repository.dart';
import 'package:zyfun_mobile/presentation/providers/app_launch_provider.dart';

void main() {
  group('AppLaunchController', () {
    test('首次启动时跳转到免责声明页并初始化默认设置', () async {
      final repository = _InMemorySettingRepository();
      final controller = AppLaunchController(repository);

      final route = await controller.resolveInitialRoute();

      expect(route, RouteConstants.disclaimer);
      expect(repository.setting, isA<Setting>());
    });

    test('已接受免责声明时跳转到首页', () async {
      final repository = _InMemorySettingRepository()
        ..values[StorageKeys.disclaimerAccepted] = true;
      final controller = AppLaunchController(repository);

      final route = await controller.resolveInitialRoute();

      expect(route, RouteConstants.film);
    });

    test('接受免责声明后写入状态', () async {
      final repository = _InMemorySettingRepository();
      final controller = AppLaunchController(repository);

      await controller.acceptDisclaimer();

      expect(repository.values[StorageKeys.disclaimerAccepted], true);
      expect(repository.values[StorageKeys.appInitialized], true);
    });
  });
}

class _InMemorySettingRepository implements SettingRepository {
  final Map<String, Object?> values = <String, Object?>{};
  Setting? setting;

  @override
  Future<Setting> exportSetting() async => setting ?? const Setting();

  @override
  Future<Setting> getAllSettings() async => setting ?? const Setting();

  @override
  Future<T?> getSetting<T>(String key) async {
    final value = values[key];
    if (key == StorageKeys.setting && setting != null) {
      return setting!.toJson() as T;
    }
    return value as T?;
  }

  @override
  Future<void> importSetting(Setting setting) async {
    this.setting = setting;
    values[StorageKeys.setting] = setting.toJson();
  }

  @override
  Future<void> resetSetting() async {
    setting = null;
    values.clear();
  }

  @override
  Future<void> updateSetting<T>(String key, T value) async {
    values[key] = value;
  }
}
