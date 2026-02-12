import 'api_client.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile(String id) async {
    final res = await ApiClient.getInstructorById(id);
    return ApiClient.decodeResponse(res);
  }

  static Future<List> getWorkingDays(String id) async {
    final res = await ApiClient.getInstructorWorkingDays(id);
    final data = ApiClient.decodeResponse(res);
    return data['data'] ?? [];
  }

  // static Future<List> getWorkingHours(String id) async {
  //   final res = await ApiClient.get('/ds/instructor-working-hours/$id');
  //   final data = jsonDecode(res.body);
  //   return data['data'] ?? [];
  // }

  static Future<void> upsertWorkingDays(Map<String, dynamic> body) async {
    final res = await ApiClient.upsertInstructorWorkingDays(body);
    ApiClient.decodeResponse(res);
  }

  static Future<void> updateProfile(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await ApiClient.updateInstructor(id, body);
    ApiClient.decodeResponse(res);
  }

  // static Future<void> createWorkingHour(Map<String, dynamic> body) async {
  //   await ApiClient.post('/ds/instructor-working-hours', body);
  // }
}
