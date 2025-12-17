import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class ScheduleService {
  // Ambil BASE_URL dari file .env
  // Pastikan kunci ini (BASE_URL) ada di file .env Anda.
  // Contoh: BASE_URL=http://localhost:8000/api
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api'; 
  
  // Catatan: Nilai fallback (seperti 'http://localhost:8000/api') 
  // sangat disarankan jika dotenv gagal memuat.

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Tambahkan Authorization jika perlu
      // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
    };
  }

  // 1. Get Holidays
  static Future<List<dynamic>> fetchHolidays({int? year}) async {
    try {
      final url = year != null
          ? '$baseUrl/schedules?year=$year'
          : '$baseUrl/schedules';

      final response = await http.get(Uri.parse(url), headers: _getHeaders());

      print('Fetch Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body is List ? body : [];
      } else {
        throw Exception('Failed to fetch holidays');
      }
    } catch (e) {
      print('Error fetching holidays: $e');
      return [];
    }
  }

  // 2. Add Holiday (Tidak ada perubahan di sini selain penggunaan baseUrl)
  static Future<bool> addHoliday(String date, String name) async {
    try {
      final uri = Uri.parse('$baseUrl/schedules');
      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode({'date': date, 'name': name}),
      );

      print('Add Response: ${response.statusCode}');
      print('Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding holiday: $e');
      return false;
    }
  }

  // 3. Delete Holiday (Tidak ada perubahan di sini selain penggunaan baseUrl)
  static Future<bool> deleteHoliday(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/schedules/$id');
      final response = await http.delete(uri, headers: _getHeaders());

      print('Delete Response: ${response.statusCode}');
      print('Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting holiday: $e');
      return false;
    }
  }

  // 4. Sync National Holidays (Tidak ada perubahan di sini selain penggunaan baseUrl)
  static Future<void> syncNationalHolidays(int year) async {
    try {
      final uri = Uri.parse('$baseUrl/schedules/sync?year=$year');
      final response = await http.get(uri, headers: _getHeaders());

      print('Sync Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Sync selesai');
      } else {
        print('❌ Sync gagal');
      }
    } catch (e) {
      print('Error syncing holidays: $e');
    }
  }
}