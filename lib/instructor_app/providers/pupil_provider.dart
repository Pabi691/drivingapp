import 'package:flutter/foundation.dart';
import '../services/pupil_service.dart';

class PupilProvider with ChangeNotifier {
  List<dynamic> _pupils = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get pupils => _pupils;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered Getters
  List<dynamic> get activePupils => _pupils.where((p) {
        final status = p['status'];
        final active = p['active'];
        return status == 'active' || status == 1 || active == 1 || active == true;
      }).toList();

  List<dynamic> get waitingPupils =>
      _pupils.where((p) => p['status'] == 'waiting').toList();
  List<dynamic> get inactivePupils =>
      _pupils.where((p) => p['status'] == 'inactive').toList();
  List<dynamic> get enquiryPupils =>
      _pupils.where((p) => p['status'] == 'enquiry').toList();
  List<dynamic> get passedPupils =>
      _pupils.where((p) => p['status'] == 'passed').toList();

  Future<void> fetchPupils() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pupils = await PupilService.getAllPupils();
      debugPrint('Fetched ${_pupils.length} pupils from API');
      if (_pupils.isNotEmpty) {
        debugPrint('First pupil data: ${_pupils.first}');
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching pupils: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addPupilLocally(Map<String, dynamic> pupil) {
    _pupils.insert(0, pupil);
    notifyListeners();
  }

  Future<void> deletePupil(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await PupilService.deletePupil(id);
      _pupils.removeWhere((p) => p['_id'] == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting pupil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePupil(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await PupilService.updatePupil(id, data);
      await fetchPupils();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating pupil: $e');
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to let the UI catch and show the error Snackbar
    }
  }
}
