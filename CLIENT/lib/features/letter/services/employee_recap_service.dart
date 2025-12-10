import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/employee_recap.dart';

class EmployeeRecapService {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000';
    return url.replaceAll('/api', '').replaceAll(RegExp(r'/$'), '');
  }

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // ============================
  // FETCH EMPLOYEE RECAP
  // ============================
  static Future<List<EmployeeRecap>> fetchEmployeeRecap() async {
    try {
      final url = '$baseUrl/api/employee-recap';
      print('🌐 GET: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      print('📡 Status: ${response.statusCode}');
      print('📄 Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle response structure: {success: true, data: [...]}
        if (data is Map && data.containsKey('data')) {
          final List list = data['data'];
          print('✅ Found ${list.length} employees');
          
          // Debug: Print first employee if exists
          if (list.isNotEmpty) {
            print('📋 Sample employee: ${list.first}');
          }
          
          return list.map((e) => EmployeeRecap.fromJson(e)).toList();
        } 
        // Handle direct array: [...]
        else if (data is List) {
          print('✅ Found ${data.length} employees (direct array)');
          return data.map((e) => EmployeeRecap.fromJson(e)).toList();
        } 
        else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in fetchEmployeeRecap: $e');
      rethrow;
    }
  }
}
