import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/constants.dart';
import '../../data/models/setting.dart';
import '../../domain/repositories/setting_repository.dart';
import 'app_providers.dart';

class AppLaunchController {
  AppLaunchController(this._settingRepository);

  final SettingRepository _settingRepository;

  Future<void> initializeAppData() async {
    final storedSetting =
        await _settingRepository.getSetting<Map<String, dynamic>>(StorageKeys.setting);
    if (storedSetting == null) {
      await _settingRepository.importSetting(const Setting());
    }
  }

  Future<bool> isDisclaimerAccepted() async {
    return await _settingRepository.getSetting<bool>(StorageKeys.disclaimerAccepted) ??
        false;
  }

  Future<String> resolveInitialRoute() async {
    await initializeAppData();
    final accepted = await isDisclaimerAccepted();
    return accepted ? RouteConstants.film : RouteConstants.disclaimer;
  }

  Future<void> acceptDisclaimer() async {
    await initializeAppData();
    await _settingRepository.updateSetting(StorageKeys.disclaimerAccepted, true);
    await _settingRepository.updateSetting(StorageKeys.appInitialized, true);
  }
}

final appLaunchControllerProvider = Provider<AppLaunchController>((ref) {
  return AppLaunchController(ref.watch(settingRepositoryProvider));
});
