import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';

class KeyValueStorage {
  KeyValueStorage({
    SharedPreferences? sharedPreferences,
    FlutterSecureStorage? secureStorage,
  })  : _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  SharedPreferences? _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  Future<SharedPreferences> get _prefs async {
    if (_sharedPreferences != null) {
      return _sharedPreferences!;
    }
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = await getString(key);
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      throw AppException(
        type: AppErrorType.storage,
        message: '无法解析存储的 JSON 数据',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> setSecureString(String key, String value) {
    return _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureString(String key) {
    return _secureStorage.read(key: key);
  }

  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }
}
