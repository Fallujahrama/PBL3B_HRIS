import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Ubah sesuai URL backend Anda
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';
  // Untuk testing lokal: http://localhost:8000/api
  // Untuk device: http://{IP_KOMPUTER}:8000/api

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
          'Bearer YOUR_TOKEN_HERE', // Ganti dengan token dari login
    };
  }

  // 1. Submit Attendance
  static Future<AttendanceResponse> submitAttendance(
    AttendanceRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/submit'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AttendanceResponse.fromJson(jsonDecode(response.body));
      } else {
        return AttendanceResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error submitting attendance: $e');
      return AttendanceResponse(success: false, message: 'Exception: $e');
    }
  }

  // 2. Get Department Location
  static Future<DepartmentLocation> getDepartmentLocation(
    int employeeId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/department/location/$employeeId'),
        headers: _getHeaders(),
      );

      print('Department Response: ${response.statusCode}');
      print('Department Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DepartmentLocation.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch department location');
      }
    } catch (e) {
      print('Error fetching department: $e');
      throw Exception('Error: $e');
    }
  }

  // 3. Get Attendance History
  static Future<List<CheckClockHistory>> getAttendanceHistory(
    int employeeId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/history/$employeeId'),
        headers: _getHeaders(),
      );

      print('History Response: ${response.statusCode}');
      print('History Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List jsonList = data['data'] ?? [];
        return jsonList
            .map((item) => CheckClockHistory.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch attendance history');
      }
    } catch (e) {
      print('Error fetching history: $e');
      throw Exception('Error: $e');
    }
  }
}
