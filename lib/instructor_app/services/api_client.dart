import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://working.kyleinfotech.co.in/api';

  static Map<String, dynamic> decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? message;

      // Try to parse server-provided error details first.
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map) {
          message =
              errorData['message']?.toString() ?? errorData['error']?.toString();
        }
      } catch (_) {
        // Ignore JSON parse failures and fall back to status-based message.
      }

      throw Exception(
        (message != null && message.trim().isNotEmpty)
            ? message
            : 'Request failed with status ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is List) {
      // If API returns a raw list, wrap it in a map
      return {'data': decoded};
    } else if (decoded is Map<String, dynamic>) {
      final isSuccess = decoded['success'];
      final isStatus = decoded['status'];

      if (isSuccess == false || isStatus == false) {
        String errorMessage = decoded['message']?.toString() ?? 'API Request Failed';
        
        if (decoded['errors'] is List) {
          final errorList = decoded['errors'] as List;
          if (errorList.isNotEmpty) {
            errorMessage += '\n' + errorList.join('\n');
          }
        }
        
        throw Exception(errorMessage);
      }

      return decoded;
    } else {
      throw Exception('Unexpected response format: ${decoded.runtimeType}');
    }
  }

  // Core HTTP helpers
  static Future<http.Response> get(String endpoint) async {
    final token = await TokenStorage.getToken();
    // debugPrint('GET $endpoint with token: $token');
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await TokenStorage.getToken();
    final url = '$baseUrl$endpoint';
    
    debugPrint('--- API POST REQUEST ---');
    debugPrint('URL: $url');
    debugPrint('Token: ${token != null ? 'Present' : 'Missing'}');
    debugPrint('Body: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    
    debugPrint('--- API POST RESPONSE ---');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');
    
    return response;
  }

  static Future<http.Response> patch(
      String endpoint, Map<String, dynamic> body) async {
    final token = await TokenStorage.getToken();

    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await TokenStorage.getToken();

    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // Booking
  static Future<http.Response> createBooking(
      Map<String, dynamic> body) async {
    return post('/ds/bookings', body);
  }

  static Future<http.Response> getBookings() async {
    return get('/ds/bookings');
  }

  static Future<http.Response> getBookingsByInstructor(String id) async {
    return get('/ds/bookings/$id');
  }

  static Future<http.Response> getBookingsByPupil(String pupilId) async {
    return get('/ds/bookings/pupil/$pupilId');
  }

  static Future<http.Response> updateBookingStatus(
    String id,
    String status,
  ) async {
    return post('/ds/bookings/update-status/$id', {'status': status});
  }

  // Money
  static Future<http.Response> createMoneyRecord(
      Map<String, dynamic> body) async {
    return post('/ds/money', body);
  }

  static Future<http.Response> updateMoneyRecord(
      String id, Map<String, dynamic> body) async {
    return post('/ds/money/$id', body);
  }

  static Future<http.Response> getMoneyByInstructor(String instructorId) async {
    return get('/ds/money/instructor/$instructorId');
  }

  // Sale
  static Future<http.Response> createSale(
      Map<String, dynamic> body) async {
    return post('/ds/sales', body);
  }

  static Future<http.Response> getSales() async {
    return get('/ds/sales');
  }

  static Future<http.Response> getSaleById(String id) async {
    return get('/ds/sales/$id');
  }

  static Future<http.Response> updateSale(
      String id, Map<String, dynamic> body) async {
    return post('/ds/sales/$id', body);
  }

  static Future<http.Response> deleteSale(String id) async {
    return get('/ds/sales/delete/$id');
  }

  // Pupil
  static Future<http.Response> createPupil(
      Map<String, dynamic> body) async {
    return post('/ds/pupils', body);
  }

  static Future<http.Response> getPupils() async {
    return get('/ds/pupils');
  }

  static Future<http.Response> getPupilById(String id) async {
    return get('/ds/pupils/$id');
  }

  static Future<http.Response> updatePupil(
      String id, Map<String, dynamic> body) async {
    return post('/ds/pupils/$id', body);
  }

  static Future<http.Response> deletePupil(String id) async {
    return get('/ds/pupils/delete/$id');
  }

  // PriceMaster
  static Future<http.Response> createPriceMaster(
      Map<String, dynamic> body) async {
    return post('/ds/price-masters', body);
  }

  static Future<http.Response> getPriceMasters() async {
    return get('/ds/price-masters');
  }

  static Future<http.Response> getPriceMasterById(String id) async {
    return get('/ds/price-masters/$id');
  }

  static Future<http.Response> updatePriceMaster(
      String id, Map<String, dynamic> body) async {
    return post('/ds/price-masters/$id', body);
  }

  static Future<http.Response> deletePriceMaster(String id) async {
    return get('/ds/price-masters/delete/$id');
  }

  // PackageMaster
  static Future<http.Response> createPackageMaster(
      Map<String, dynamic> body) async {
    return post('/ds/package-masters', body);
  }

  static Future<http.Response> getPackageMasters() async {
    return get('/ds/package-masters');
  }

  static Future<http.Response> getPackageMasterById(String id) async {
    return get('/ds/package-masters/$id');
  }

  static Future<http.Response> updatePackageMaster(
      String id, Map<String, dynamic> body) async {
    return post('/ds/package-masters/$id', body);
  }

  // InstructorWorkingDay
  static Future<http.Response> upsertInstructorWorkingDays(
      Map<String, dynamic> body) async {
    return post('/ds/instructor-working-days/upsert', body);
  }

  static Future<http.Response> getInstructorWorkingDays(
      String instructorId) async {
    return get('/ds/instructor-working-days/$instructorId');
  }

  // Instructor
  static Future<http.Response> createInstructor(
      Map<String, dynamic> body) async {
    return post('/ds/instructor-masters', body);
  }

  static Future<http.Response> getInstructors() async {
    return get('/ds/instructor-masters');
  }

  static Future<http.Response> getInstructorById(String id) async {
    return get('/ds/instructor-masters/$id');
  }

  static Future<http.Response> updateInstructor(
      String id, Map<String, dynamic> body) async {
    return post('/ds/instructor-masters/$id', body);
  }

  static Future<http.Response> updateInstructorMultipart(
      String id, Map<String, String> fields, {
        List<int>? profileBytes, String? profileFilename,
        List<int>? licenceBytes, String? licenceFilename,
      }) async {
    final token = await TokenStorage.getToken();
    final url = '$baseUrl/ds/instructor-masters/$id';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll(fields);

    if (profileBytes != null && profileBytes.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'profile',
        profileBytes,
        filename: profileFilename ?? 'profile.jpg',
      ));
    }

    if (licenceBytes != null && licenceBytes.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'upload_licence_copy',
        licenceBytes,
        filename: licenceFilename ?? 'licence.jpg',
      ));
    }

    final streamResponse = await request.send();
    return http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> deleteInstructor(String id) async {
    return get('/ds/instructor-masters/delete/$id');
  }

  static Future<http.Response> confirmInstructor(String id) async {
    return get('/ds/instructor-masters/status/$id');
  }

  // FeeInstallment
  static Future<http.Response> createFeeInstallment(
      Map<String, dynamic> body) async {
    return post('/fee-installment', body);
  }

  static Future<http.Response> getFeeInstallments() async {
    return get('/fee-installment');
  }

  static Future<http.Response> getFeeInstallmentsByAdmission(
      String admissionId) async {
    return get('/fee-installment/admission/$admissionId');
  }

  static Future<http.Response> createFeeInstallmentsBulk(
      Map<String, dynamic> body) async {
    return post('/fee-installments-bulk', body);
  }

  static Future<http.Response> getFeeInstallmentById(String id) async {
    return get('/fee-installment/$id');
  }

  static Future<http.Response> updateFeeInstallment(
      String id, Map<String, dynamic> body) async {
    return post('/fee-installment/$id', body);
  }

  static Future<http.Response> deleteFeeInstallment(String id) async {
    return get('/fee-installment/delete/$id');
  }

  // FeeInstallmentMaster
  static Future<http.Response> createFeeInstallmentMaster(
      Map<String, dynamic> body) async {
    return post('/fee-installment-master', body);
  }

  static Future<http.Response> getFeeInstallmentMasters() async {
    return get('/fee-installment-master');
  }

  static Future<http.Response> getFeeInstallmentMasterById(
      String id) async {
    return get('/fee-installment-master/$id');
  }

  static Future<http.Response> updateFeeInstallmentMaster(
      String id, Map<String, dynamic> body) async {
    return post('/fee-installment-master/$id', body);
  }

  static Future<http.Response> deleteFeeInstallmentMaster(String id) async {
    return get('/fee-installment-master/delete/$id');
  }

  // FeeType
  static Future<http.Response> createFeeType(
      Map<String, dynamic> body) async {
    return post('/fee-type', body);
  }

  static Future<http.Response> getFeeTypes() async {
    return get('/fee-type');
  }

  static Future<http.Response> updateFeeType(
      String id, Map<String, dynamic> body) async {
    return post('/fee-type/$id', body);
  }

  static Future<http.Response> deleteFeeType(String id) async {
    return get('/fee-type/delete/$id');
  }

  // PaymentMode
  static Future<http.Response> createPaymentMode(
      Map<String, dynamic> body) async {
    return post('/payment-mode', body);
  }

  static Future<http.Response> getPaymentModes() async {
    return get('/payment-mode');
  }

  static Future<http.Response> updatePaymentMode(
      String id, Map<String, dynamic> body) async {
    return post('/payment-mode/$id', body);
  }

  static Future<http.Response> deletePaymentMode(String id) async {
    return get('/payment-mode/delete/$id');
  }

  // Admission
  static Future<http.Response> searchAdmissionsByDate(
      Map<String, dynamic> body) async {
    return get('/admissions/search/by-date');
  }

  static Future<http.Response> createAdmission(
      Map<String, dynamic> body) async {
    return post('/admissions', body);
  }

  static Future<http.Response> getAdmissions() async {
    return get('/admissions');
  }

  static Future<http.Response> getAdmissionById(String id) async {
    return get('/admissions/$id');
  }

  static Future<http.Response> updateAdmission(
      String id, Map<String, dynamic> body) async {
    return post('/admissions/$id', body);
  }

  static Future<http.Response> deleteAdmission(String id) async {
    return get('/admissions/delete/$id');
  }

  static Future<http.Response> getDeletedAdmissions() async {
    return get('/deleted/list');
  }

  static Future<http.Response> restoreAdmission(String id) async {
    return get('/restore/$id');
  }

  static Future<http.Response> permanentDeleteAdmission(String id) async {
    return get('/permanent-delete/$id');
  }

  // Student
  static Future<http.Response> createStudent(
      Map<String, dynamic> body) async {
    return post('/students', body);
  }

  static Future<http.Response> getStudents() async {
    return get('/students');
  }

  static Future<http.Response> getStudentById(String id) async {
    return get('/students/$id');
  }

  static Future<http.Response> upsertStudentProfile(
      String id, Map<String, dynamic> body) async {
    return post('/students/$id/profile', body);
  }

  static Future<http.Response> enableStudentLogin(
      String studentId, Map<String, dynamic> body) async {
    return post('/students/enable-login/$studentId', body);
  }

  static Future<http.Response> disableStudentLogin(
      String studentId, Map<String, dynamic> body) async {
    return post('/students/disable-login/$studentId', body);
  }

  static Future<http.Response> getStudentProfile(
      String studentId) async {
    return get('/students/my-profile/$studentId');
  }

  // Section
  static Future<http.Response> createSection(
      Map<String, dynamic> body) async {
    return post('/sections', body);
  }

  static Future<http.Response> getSections() async {
    return get('/sections');
  }

  static Future<http.Response> updateSection(
      String id, Map<String, dynamic> body) async {
    return post('/sections/$id', body);
  }

  static Future<http.Response> deleteSection(String id) async {
    return get('/sections/delete/$id');
  }

  // Session
  static Future<http.Response> createSession(
      Map<String, dynamic> body) async {
    return post('/sessions', body);
  }

  static Future<http.Response> getSessions() async {
    return get('/sessions');
  }

  static Future<http.Response> getSessionById(String id) async {
    return get('/sessions/$id');
  }

  static Future<http.Response> updateSession(
      String id, Map<String, dynamic> body) async {
    return post('/sessions/$id', body);
  }

  static Future<http.Response> deleteSession(String id) async {
    return get('/sessions/delete/$id');
  }

  // Specialization
  static Future<http.Response> createSpecialization(
      Map<String, dynamic> body) async {
    return post('/specializations', body);
  }

  static Future<http.Response> getSpecializations() async {
    return get('/specializations');
  }

  static Future<http.Response> updateSpecialization(
      String id, Map<String, dynamic> body) async {
    return post('/specializations/$id', body);
  }

  static Future<http.Response> deleteSpecialization(String id) async {
    return get('/specializations/delete/$id');
  }

  // Course
  static Future<http.Response> createCourse(
      Map<String, dynamic> body) async {
    return post('/courses', body);
  }

  static Future<http.Response> getCourses() async {
    return get('/courses');
  }

  static Future<http.Response> getCourseById(String id) async {
    return get('/courses/$id');
  }

  static Future<http.Response> updateCourse(
      String id, Map<String, dynamic> body) async {
    return post('/courses/$id', body);
  }

  static Future<http.Response> deleteCourse(String id) async {
    return get('/courses/delete/$id');
  }

  // User
  static Future<http.Response> createUser(
      Map<String, dynamic> body) async {
    return post('/users', body);
  }

  static Future<http.Response> getUsers() async {
    return get('/users');
  }

  static Future<http.Response> updateUser(
      String id, Map<String, dynamic> body) async {
    return post('/users/$id', body);
  }

  static Future<http.Response> deleteUser(String id) async {
    return get('/users/delete/$id');
  }

  // Branch
  static Future<http.Response> createBranch(
      Map<String, dynamic> body) async {
    return post('/branchs', body);
  }

  static Future<http.Response> getBranches() async {
    return get('/branchs');
  }

  static Future<http.Response> getBranchById(String id) async {
    return get('/branchs/$id');
  }

  static Future<http.Response> updateBranch(
      String id, Map<String, dynamic> body) async {
    return post('/branchs/$id', body);
  }

  static Future<http.Response> deleteBranch(String id) async {
    return get('/branchs/delete/$id');
  }

  // Auth
  static Future<http.Response> login(
      Map<String, dynamic> body) async {
    return post('/login', body);
  }

  static Future<http.Response> studentSignup(
      Map<String, dynamic> body) async {
    return post('/student-signup', body);
  }

  static Future<http.Response> studentLogin(
      Map<String, dynamic> body) async {
    return post('/student-login', body);
  }

  static Future<http.Response> instructorSignup(
      Map<String, dynamic> body) async {
    return post('/instructor-signup', body);
  }

  static Future<http.Response> instructorLogin(
      Map<String, dynamic> body) async {
    return post('/instructor-login', body);
  }

  static Future<http.Response> validateToken() async {
    return get('/validateToken');
  }

  static Future<http.Response> changePassword(
      Map<String, dynamic> body) async {
    return post('/change-password', body);
  }
}
