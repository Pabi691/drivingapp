import 'dart:convert';
import 'api_client.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile(String id) async {
    final res = await ApiClient.get('/ds/instructor-masters/$id');
    return jsonDecode(res.body);
  }

  static Future<List> getWorkingDays(String id) async {
    final res = await ApiClient.get('/ds/instructor-working-days/$id');
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  // static Future<List> getWorkingHours(String id) async {
  //   final res = await ApiClient.get('/ds/instructor-working-hours/$id');
  //   final data = jsonDecode(res.body);
  //   return data['data'] ?? [];
  // }

  static Future<void> upsertWorkingDays(Map<String, dynamic> body) async {
    await ApiClient.post(
      '/ds/instructor-working-days/upsert',
      body,
    );
  }

  // static Future<void> createWorkingHour(Map<String, dynamic> body) async {
  //   await ApiClient.post('/ds/instructor-working-hours', body);
  // }
}
