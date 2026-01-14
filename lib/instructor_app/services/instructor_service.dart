import 'dart:convert';
import '../models/instructor.dart';
import 'api_client.dart';

class InstructorService {
  static Future<List<Instructor>> getAllInstructors() async {
    final response =
        await ApiClient.get('/ds/instructor-masters');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Instructor>.from(
        data['data'].map((e) => Instructor.fromJson(e)),
      );
    } else {
      throw Exception('Failed to load instructors');
    }
  }

  static Future<void> deleteInstructor(String id) async {
    await ApiClient.delete('/ds/instructor-masters/$id');
  }
}
