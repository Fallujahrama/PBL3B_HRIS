import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/department.dart';

class DepartmentService {
  // GANTI kalau kamu pakai HP fisik / iOS
  static const String baseUrl = 'http://127.0.0.1:8000/api';

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

      // kalau response Laravel kamu seperti:
      // { "success": true, "message": "...", "data": [ ... ] }
      final List<dynamic> list = body['data'];

      return list.map((item) => Department.fromJson(item)).toList();
    } else {
      throw Exception(
          'Gagal mengambil data department. Code: ${response.statusCode}');
    }
  }
}