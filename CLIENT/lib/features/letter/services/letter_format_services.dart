import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/letter_format.dart';

class LetterFormatService {
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
  // FETCH LETTER FORMATS
  // ============================
  static Future<List<LetterFormat>> fetchLetterFormats() async {
    try {
      final url = '$baseUrl/api/letter-formats';
      print('🌐 GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('📡 Status: ${response.statusCode}');
      print('📄 Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle paginated response: {data: [...], links: {...}, meta: {...}}
        if (data is Map && data.containsKey('data')) {
          final List items = data['data'] as List;
          return items.map((json) => LetterFormat.fromJson(json)).toList();
        }
        // Handle direct array response: [...]
        else if (data is List) {
          return data.map((json) => LetterFormat.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetchLetterFormats: $e');
      rethrow;
    }
  }

  // ============================
  // CREATE LETTER FORMAT
  // ============================
  static Future<LetterFormat> createLetterFormat(Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl/api/letter-formats';
      print('🌐 POST: $url');
      print('📤 Data: $data');

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(data),
      );

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle: {data: {...}}
        if (responseData is Map && responseData.containsKey('data')) {
          return LetterFormat.fromJson(responseData['data']);
        }
        // Handle direct object: {...}
        else {
          return LetterFormat.fromJson(responseData);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error createLetterFormat: $e');
      rethrow;
    }
  }

  // ============================
  // UPDATE LETTER FORMAT
  // ============================
  static Future<LetterFormat> updateLetterFormat(int id, Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl/api/letter-formats/$id';
      print('🌐 PUT: $url');
      print('📤 Data: $data');

      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(data),
      );

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map && responseData.containsKey('data')) {
          return LetterFormat.fromJson(responseData['data']);
        } else {
          return LetterFormat.fromJson(responseData);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updateLetterFormat: $e');
      rethrow;
    }
  }

  // ============================
  // DELETE LETTER FORMAT
  // ============================
  static Future<void> deleteLetterFormat(int id) async {
    try {
      final url = '$baseUrl/api/letter-formats/$id';
      print('🌐 DELETE: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      );

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error deleteLetterFormat: $e');
      rethrow;
    }
  }

  // ============================
  // GET SINGLE LETTER FORMAT
  // ============================
  static Future<LetterFormat> getLetterFormat(int id) async {
    try {
      final url = '$baseUrl/api/letter-formats/$id';
      print('🌐 GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map && responseData.containsKey('data')) {
          return LetterFormat.fromJson(responseData['data']);
        } else {
          return LetterFormat.fromJson(responseData);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getLetterFormat: $e');
      rethrow;
    }
  }
}
