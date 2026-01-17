import 'dart:convert';
import 'api_client.dart';

class BranchService {
  static Future<List> getBranches() async {
    final res = await ApiClient.get('/branchs');
    final data = jsonDecode(res.body);
    return data['branches'] ?? [];
  }
}
