import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/setting.dart';
import '../../data/services/config_import_service.dart';
import '../../domain/repositories/setting_repository.dart';
import 'app_providers.dart';

class SettingNotifier extends StateNotifier<Setting> {
  SettingNotifier(
    this._repository,
    this._configImportService,
  ) : super(const Setting());

  final SettingRepository _repository;
  final ConfigImportService _configImportService;

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

  Future<ConfigImportResult> importDesktopConfigFile(String path) async {
    final content = await File(path).readAsString();
    final result = await _configImportService.importDesktopConfig(content);
    await load();
    return result;
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
  return SettingNotifier(
    ref.watch(settingRepositoryProvider),
    ref.watch(configImportServiceProvider),
  );
});
