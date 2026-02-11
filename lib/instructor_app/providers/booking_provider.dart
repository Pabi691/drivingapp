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
      // Backend returns booking list from /ds/bookings (sometimes even with 201),
      // so load all and filter by instructor on client.
      final res = await ApiClient.getBookings();
      final data = ApiClient.decodeResponse(res);
      final List<dynamic> bookingList = _extractBookingList(data)
          .where((b) => _belongsToInstructor(b, instructorId))
          .toList();

      _bookings = {};

      for (var b in bookingList) {
        if (b is! Map) continue;
        final dateStr = b['booking_date'];
        final startTimeStr = b['start_time'];

        if (dateStr == null || startTimeStr == null) continue;

        final date = _parseBookingDate(dateStr.toString());
        if (date == null) continue;
        final normalizedDate = DateTime(date.year, date.month, date.day);

        final startParts = startTimeStr.toString().split(':');
        final startHour = int.tryParse(startParts[0]) ?? 0;
        final startMinute = int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0;

        final startDateTime = DateTime(date.year, date.month, date.day, startHour, startMinute);

        final endTimeStr = b['end_time']?.toString();
        int durationMinutes = 30;
        if (endTimeStr != null && endTimeStr.contains(':')) {
          final endParts = endTimeStr.split(':');
          final endHour = int.tryParse(endParts[0]) ?? startHour;
          final endMinute = int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? startMinute;

          final endDateTime = DateTime(date.year, date.month, date.day, endHour, endMinute);
          final diff = endDateTime.difference(startDateTime).inMinutes;
          if (diff > 0) {
            durationMinutes = diff;
          }
        }

        final pupilName = b['pupil_id'] is Map
            ? (b['pupil_id']['full_name']?.toString() ?? 'Unknown')
            : (b['pupil_name']?.toString() ?? 'Unknown');
        final status = (b['status']?.toString() ?? 'pending').toLowerCase();
        final bookingId = b['_id']?.toString() ?? '';

        final event = Event(
          id: bookingId,
          title: 'Lesson with $pupilName',
          startTime: startDateTime,
          duration: Duration(minutes: durationMinutes),
          color: _colorForStatus(status),
          status: status,
        );

        if (_bookings[normalizedDate] == null) {
          _bookings[normalizedDate] = [];
        }
        _bookings[normalizedDate]!.add(event);
      }

      for (final entry in _bookings.entries) {
        entry.value.sort((a, b) => a.startTime.compareTo(b.startTime));
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

      final instructorId = bookingData['instructor_id'];
      if (instructorId != null) {
        await fetchBookings(instructorId);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    required String instructorId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient.updateBookingStatus(bookingId, status);
      ApiClient.decodeResponse(res);
      await fetchBookings(instructorId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Color _colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  List<dynamic> _extractBookingList(Map<String, dynamic> data) {
    final rawData = data['data'];

    if (rawData is List) return rawData;
    if (rawData is Map) {
      if (rawData['bookings'] is List) return rawData['bookings'] as List<dynamic>;
      if (rawData['items'] is List) return rawData['items'] as List<dynamic>;
      if (rawData['records'] is List) return rawData['records'] as List<dynamic>;
    }

    if (data['bookings'] is List) return data['bookings'] as List<dynamic>;
    if (data['items'] is List) return data['items'] as List<dynamic>;
    if (data['records'] is List) return data['records'] as List<dynamic>;

    return <dynamic>[];
  }

  bool _belongsToInstructor(dynamic booking, String instructorId) {
    if (booking is! Map) return false;
    final rawInstructor = booking['instructor_id'];
    if (rawInstructor is Map) {
      return rawInstructor['_id']?.toString() == instructorId;
    }
    return rawInstructor?.toString() == instructorId;
  }

  DateTime? _parseBookingDate(String input) {
    if (input.isEmpty) return null;

    final dateOnly = input.length >= 10 ? input.substring(0, 10) : input;
    final parsedDateOnly = DateTime.tryParse(dateOnly);
    if (parsedDateOnly != null) {
      return DateTime(parsedDateOnly.year, parsedDateOnly.month, parsedDateOnly.day);
    }

    final parsedFull = DateTime.tryParse(input);
    if (parsedFull != null) {
      return DateTime(parsedFull.year, parsedFull.month, parsedFull.day);
    }

    return null;
  }
}
