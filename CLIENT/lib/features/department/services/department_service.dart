import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/department.dart';

class DepartmentService {
  // GANTI kalau kamu pakai emulator Android / device lain:
  // - Web / Windows:  http://127.0.0.1:8000/api
  // - Android emulator: http://10.0.2.2:8000/api
  //static const String baseUrl = 'http://127.0.0.1:8000/api'; KALAU PAKE CHROME
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // KALAU PAKE EMULATOR ANDROID

  /// GET /api/departments
  static Future<List<Department>> fetchDepartments() async {
    final url = Uri.parse('$baseUrl/departments');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Response Laravel: { "success": true, "data": [ ... ] }
      final List<dynamic> list = body['data'];

      return list.map((item) => Department.fromJson(item)).toList();
    } else {
      throw Exception(
        'Gagal mengambil data department. Code: ${response.statusCode}',
      );
    }
  }

  /// GET /api/departments/{id}
  static Future<Department> fetchDepartment(int id) async {
    final url = Uri.parse('$baseUrl/departments/$id');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Department.fromJson(body['data']);
    } else {
      throw Exception(
        'Gagal mengambil detail department. Code: ${response.statusCode}',
      );
    }
  }

  /// POST /api/departments
  static Future<Department> createDepartment({
    required String name,
    required String radius,
    String? latitude,
    String? longitude,
  }) async {
    final url = Uri.parse('$baseUrl/departments');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'radius': radius,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return Department.fromJson(body['data']);
    } else {
      throw Exception(
        'Gagal membuat department. Code: ${response.statusCode} | Body: ${response.body}',
      );
    }
  }

  /// PUT /api/departments/{id}
  static Future<Department> updateDepartment({
    required int id,
    required String name,
    required String radius,
    String? latitude,
    String? longitude,
  }) async {
    final url = Uri.parse('$baseUrl/departments/$id');

    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'radius': radius,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Department.fromJson(body['data']);
    } else {
      throw Exception(
        'Gagal mengupdate department. Code: ${response.statusCode} | Body: ${response.body}',
      );
    }
  }

  /// DELETE /api/departments/{id}
  static Future<void> deleteDepartment(int id) async {
    final url = Uri.parse('$baseUrl/departments/$id');

    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal menghapus department. Code: ${response.statusCode} | Body: ${response.body}',
      );
    }
  }
}