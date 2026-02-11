import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

class MoneyProvider with ChangeNotifier {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMoneyRecords(String instructorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient.getMoneyByInstructor(instructorId);
      final data = ApiClient.decodeResponse(res);
      final list = (data['data'] as List?) ?? <dynamic>[];
      _records = list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMoneyRecord({
    required String pupilId,
    required String instructorId,
    required String paymentMethod,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient.createMoneyRecord({
        'pupil_id': pupilId,
        'instructor_id': instructorId,
        'payment_method': paymentMethod,
        'amount': amount,
      });
      ApiClient.decodeResponse(res);
      await fetchMoneyRecords(instructorId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editMoneyRecord({
    required String moneyId,
    required String instructorId,
    required String paymentMethod,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient.updateMoneyRecord(moneyId, {
        'instructor_id': instructorId,
        'payment_method': paymentMethod,
        'amount': amount,
      });
      ApiClient.decodeResponse(res);
      await fetchMoneyRecords(instructorId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
