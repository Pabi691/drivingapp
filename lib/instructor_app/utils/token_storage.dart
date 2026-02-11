import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'access_token';
  static const _instructorKey = 'instructor';
  static const _userKey = 'user';

  static const _secureStorage = FlutterSecureStorage();
  static Future<SharedPreferences>? _prefs;

  static Future<SharedPreferences> _getPrefs() {
    return _prefs ??= SharedPreferences.getInstance();
  }

  static Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.setString(key, value);
      return;
    }
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      return prefs.getString(key);
    }
    return _secureStorage.read(key: key);
  }

  static Future<void> saveToken(String token) async {
    await _write(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    return _read(_tokenKey);
  }

  static Future<void> saveInstructor(String instructorJson) async {
    await _write(_instructorKey, instructorJson);
  }

  static Future<String?> getInstructor() async {
    return _read(_instructorKey);
  }

  static Future<void> saveUser(String userJson) async {
    await _write(_userKey, userJson);
  }

  static Future<String?> getUser() async {
    return _read(_userKey);
  }

  static Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.clear();
      return;
    }
    await _secureStorage.deleteAll();
  }
}
