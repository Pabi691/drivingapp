import 'dart:convert';
import 'api_client.dart';

class PupilService {
  // Get all pupils
  static Future<List> getAllPupils() async {
    final res = await ApiClient.get('/ds/pupils');
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  // Create pupil
  static Future<void> createPupil(Map<String, dynamic> body) async {
    await ApiClient.post('/ds/pupils', body);
  }

  // Update pupil
  static Future<void> updatePupil(String id, Map<String, dynamic> body) async {
    await ApiClient.post('/ds/pupils/$id', body);
  }

  // Delete pupil
  static Future<void> deletePupil(String id) async {
    await ApiClient.get('/ds/pupils/delete/$id');
  }
}
