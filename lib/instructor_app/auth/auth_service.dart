import 'dart:convert';
import '../services/api_client.dart';
import '../utils/token_storage.dart';

class AuthService {
  static Future<void> login(String email, String password) async {
    final response = await ApiClient.post(
      '/instructor-login',
      {
        'email': email,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);

    print(data);

    if (response.statusCode == 200 && data['success'] == true) {
      await TokenStorage.saveToken(data['access_token']);

      // save instructor data
      await TokenStorage.saveInstructor(jsonEncode(data['instructor_data']));

      // Optionally save user data if needed
      await TokenStorage.saveUser(jsonEncode(data['user']));
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  static Future<void> logout() async {
    await TokenStorage.clearAll();
  }
}
