import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _instructor;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  String? get instructorId => _instructor?['_id']?.toString();
  Map<String, dynamic>? get instructor => _instructor;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    
    try {
      await AuthService.login(email, password);

      final instructorJson = await TokenStorage.getInstructor();
      
      if (instructorJson != null) {
        _instructor = jsonDecode(instructorJson);
        _isAuthenticated = true;
        notifyListeners();
      }
      _setLoading(false);
      throw Exception('Invalid login response');

    } catch (e) {
      _setLoading(false);
      rethrow;
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners(); // ✅ UI only
  }

  Future<void> logout() async {
    await TokenStorage.clearAll();
    _instructor = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// 🔥 AUTO LOGIN ON APP START
  Future<void> checkAuth() async {
    final token = await TokenStorage.getToken();
    final instructorJson = await TokenStorage.getInstructor();

    if (token != null && instructorJson != null) {
      _instructor = jsonDecode(instructorJson);
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }

    notifyListeners();
  }
}
