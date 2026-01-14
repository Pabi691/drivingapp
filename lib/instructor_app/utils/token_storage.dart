import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _instructorKey = 'instructor';
  static const _userKey = 'user';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveInstructor(String instructorJson) async {
    await _storage.write(key: _instructorKey, value: instructorJson);
  }

  static Future<String?> getInstructor() async {
    return await _storage.read(key: _instructorKey);
  }

  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
