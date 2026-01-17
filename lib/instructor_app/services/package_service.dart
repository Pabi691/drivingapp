import 'dart:convert';
import 'api_client.dart';

class PackageService {
  static Future<List> getPackages() async {
    final res = await ApiClient.get('/ds/package-masters');
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }
}
