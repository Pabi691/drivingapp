import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    debugPrint('AuthService: Login response: $data');

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['token'] ?? data['access_token']; // Handle both keys
      if (token == null) throw Exception('No token in response');
      await TokenStorage.saveToken(token);

      // save instructor data
      // save instructor data
      if (data['instructor_data'] != null) {
        await TokenStorage.saveInstructor(jsonEncode(data['instructor_data']));
      } else {
        debugPrint('AuthService: instructor_data missing, fetching from API...');
        // Fetch all instructors and find the one matching the user ID
        try {
          final userId = data['user']['_id'];
          final instructorsRes = await ApiClient.getInstructors(); // Assuming this exists
          final instructorsData = ApiClient.decodeResponse(instructorsRes);
          final List instructors = instructorsData['data'] ?? [];
          
          final instructor = instructors.firstWhere(
            (i) => i['instructor_user_id'] == userId, 
            orElse: () => null,
          );

          if (instructor != null) {
             debugPrint('AuthService: Found instructor via API: $instructor');
             await TokenStorage.saveInstructor(jsonEncode(instructor));
          } else {
             debugPrint('AuthService: Error - Could not find instructor record for user $userId');
          }

        } catch (e) {
          debugPrint('AuthService: Error fetching instructor details: $e');
        }
      }

      // Optionally save user data if needed
      if (data['user'] != null) {
        await TokenStorage.saveUser(jsonEncode(data['user']));
      }
    } else {
      String errorMessage = data['message'] ?? 'Login failed';
      // Mappings based on requested validation
      if (errorMessage.toLowerCase().contains("user not found") || 
          errorMessage.toLowerCase().contains("not registered")) {
        errorMessage = "Instructor not found";
      } else if (errorMessage.toLowerCase().contains("password")) {
        errorMessage = "Wrong password";
      }
      
      throw errorMessage;
    }
  }

  static Future<void> logout() async {
    await TokenStorage.clearAll();
  }
}
