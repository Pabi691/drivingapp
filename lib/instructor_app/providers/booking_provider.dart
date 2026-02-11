import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/event.dart';

class BookingProvider with ChangeNotifier {
  Map<DateTime, List<Event>> _bookings = {};
  bool _isLoading = false;
  String? _error;

  Map<DateTime, List<Event>> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBookings(String instructorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient.getBookingsByInstructor(instructorId);
      final data = ApiClient.decodeResponse(res);
      final List<dynamic> bookingList = data['data'] ?? [];

      _bookings = {};

      for (var b in bookingList) {
        final dateStr = b['booking_date'];
        final startTimeStr = b['start_time']; // "10:30"
        
        if (dateStr == null || startTimeStr == null) continue;

        final date = DateTime.parse(dateStr).toLocal(); // Ensure local time for calendar
        final normalizedDate = DateTime(date.year, date.month, date.day);
        
        final parts = startTimeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        final startDateTime = DateTime(date.year, date.month, date.day, hour, minute);

        final pupilName = b['pupil_id'] is Map ? (b['pupil_id']['full_name'] ?? 'Unknown') : 'Unknown';

        final event = Event(
          title: 'Lesson with $pupilName',
          startTime: startDateTime,
          duration: const Duration(minutes: 30), // Default 30 min?
          color: Colors.blue,
        );

        if (_bookings[normalizedDate] == null) {
          _bookings[normalizedDate] = [];
        }
        _bookings[normalizedDate]!.add(event);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient.createBooking(bookingData);
      ApiClient.decodeResponse(res);
      // We need instructorId to refresh. It is in bookingData['instructor_id']
      final instructorId = bookingData['instructor_id'];
      if (instructorId != null) {
         await fetchBookings(instructorId); // Refresh list
      }
    } catch (e) {
       _error = e.toString();
       rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
