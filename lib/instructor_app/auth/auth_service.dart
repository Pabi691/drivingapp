
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userPin;

  static const String correctPin = '1097';

  bool get isAuthenticated => _isAuthenticated;
  String? get userPin => _userPin;

  Future<bool> login(String username, String password) async {
    // Dummy authentication
    if (username == 'driving123' && password == '1234') {
      _isAuthenticated = true;
      _userPin = correctPin;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _userPin = null;
    notifyListeners();
  }
}
