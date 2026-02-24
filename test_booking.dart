import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://working.kyleinfotech.co.in/api/ds/bookings';
  
  final bookingData = {
    "school_id": "69524353687858bc38b14330",
    "pupil_id": "6985ba99c2bd011deea818bd",
    "instructor_id": "69849589dc3757d1d1b05c8f",
    "title": "Lesson",
    "booking_date": "2026-02-26T00:00:00.000Z",
    "start_time": "10:00",
    "end_time": "12:00",
    "repeat": "",
    "gearbox": "manual",
    "pickup": "",
    "dropoff": "",
    "private_notes": "",
    "pupil_summary": "",
    "status": "booking_request",
    "payment_status": "pending",
    "payment_type": "cash",
    "created_by": "6984959edc3757d1d1b05cca", // Instructor user id
    "credit_use": 1.0,
  };

  print('Sending request to $url...');
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingData),
    );

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
