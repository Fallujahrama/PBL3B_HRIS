import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeService {
  // String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://localhost:8000/api';
  //   } else if (Platform.isAndroid) {
  //     return 'http://10.0.2.2:8000/api';
  //   } else {
  //     return 'http://localhost:8000/api';
  //   }
  // }

  String get baseUrl => 'http://127.0.0.1:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/employee/dashboard/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Dashboard Status: ${response.statusCode}');
      print('📦 Dashboard Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw Exception('Gagal mengambil data dashboard');
    } catch (e) {
      print('❌ Dashboard Error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getWeeklyAttendance() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/employee/dashboard/weekly-attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as List;
        }
      }

      throw Exception('Gagal mengambil data kehadiran');
    } catch (e) {
      print('❌ Weekly Attendance Error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getOvertimeHistory() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/employee/overtime/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as List;
        }
      }

      throw Exception('Gagal mengambil riwayat lembur');
    } catch (e) {
      print('❌ Overtime History Error: $e');
      rethrow;
    }
  }
}