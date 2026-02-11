import 'api_client.dart';

class PupilService {
  // Get all pupils
  static Future<List> getAllPupils() async {
    final res = await ApiClient.get('/ds/pupils');
    final data = ApiClient.decodeResponse(res);
    return data['data'] ?? [];
  }

  // Create pupil
  static Future<void> createPupil(Map<String, dynamic> body) async {
    final res = await ApiClient.post('/ds/pupils', body);
    ApiClient.decodeResponse(res);
  }

  // Update pupil
  static Future<void> updatePupil(String id, Map<String, dynamic> body) async {
    final res = await ApiClient.post('/ds/pupils/$id', body);
    ApiClient.decodeResponse(res);
  }

  // Delete pupil
  static Future<void> deletePupil(String id) async {
    final res = await ApiClient.get('/ds/pupils/delete/$id');
    ApiClient.decodeResponse(res);
  }
}
