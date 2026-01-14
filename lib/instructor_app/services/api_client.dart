import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://drivingserver.kyleinfotech.co.in/api';

  static Future<http.Response> get(String endpoint) async {
    final token = await TokenStorage.getToken();

    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await TokenStorage.getToken();

    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> patch(
      String endpoint, Map<String, dynamic> body) async {
    final token = await TokenStorage.getToken();

    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await TokenStorage.getToken();

    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
