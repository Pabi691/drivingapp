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

  String? get instructorId {
    final data = _instructor;
    if (data == null) return null;

    // Instructor master record commonly includes this field.
    if (data['instructor_user_id'] != null) {
      return data['_id']?.toString();
    }

    // Some auth responses embed instructor details.
    final embeddedInstructor = data['instructor_data'];
    if (embeddedInstructor is Map) {
      final id = embeddedInstructor['_id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }

    // Some responses include an instructor_id pointer.
    final rawInstructorId = data['instructor_id'];
    if (rawInstructorId is Map) {
      final id = rawInstructorId['_id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    } else if (rawInstructorId != null) {
      final id = rawInstructorId.toString();
      if (id.isNotEmpty) return id;
    }

    // Fallback only when no explicit instructor reference exists.
    return data['_id']?.toString();
  }
  Map<String, dynamic>? get instructor => _instructor;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    
    try {
      await AuthService.login(email, password);

      final instructorJson = await TokenStorage.getInstructor();
      // print(instructorJson);
      if (instructorJson == null) {
        throw Exception('Invalid login response');
        // notifyListeners();
      }
      _instructor = jsonDecode(instructorJson);
      debugPrint('AuthProvider: Login successful, instructor: $_instructor');
      _isAuthenticated = true;
      _setLoading(false);
      
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
      debugPrint('AuthProvider: Restored instructor: $_instructor');
      _isAuthenticated = true;
    } else {
      debugPrint('AuthProvider: No token or instructor found');
      _isAuthenticated = false;
    }

    notifyListeners();
  }
}
