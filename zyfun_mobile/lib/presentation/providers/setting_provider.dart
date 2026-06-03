import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/setting.dart';
import '../../domain/repositories/setting_repository.dart';
import 'app_providers.dart';

class SettingNotifier extends StateNotifier<Setting> {
  SettingNotifier(this._repository) : super(const Setting());

  final SettingRepository _repository;

  Future<void> load() async {
    state = await _repository.getAllSettings();
  }

  Future<void> updateThemeMode(String theme) async {
    state = state.copyWith(theme: theme);
    await _repository.importSetting(state);
  }

  Future<void> updateHardwareAcceleration(bool enabled) async {
    state = state.copyWith(hardwareAcceleration: enabled);
    await _repository.importSetting(state);
  }

  ThemeMode get themeMode {
    switch (state.theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final settingNotifierProvider =
    StateNotifierProvider<SettingNotifier, Setting>((ref) {
  return SettingNotifier(ref.watch(settingRepositoryProvider));
});
