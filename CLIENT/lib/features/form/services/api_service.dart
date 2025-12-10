import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  // ============================
  // TOKEN MANAGEMENT
  // ============================
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // UNTUK DEVELOPMENT (TANPA LOGIN - PAKAI TOKEN DARI TINKER)
  static Future<Map<String, String>> _headersWithToken() async {
    const token = "1|9nTtLsxWZZw7kplxnriTdw8lesXM235GZ8Jnhabe46efaa6a";

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // UNTUK PRODUCTION (DENGAN FITUR LOGIN)
  // Uncomment ini saat sudah ada fitur login
  // static Future<Map<String, String>> _headersWithToken() async {
  //   final token = await _getToken();
  //
  //   return {
  //     'Accept': 'application/json',
  //     'Content-Type': 'application/json',
  //     if (token != null) 'Authorization': 'Bearer $token',
  //   };
  // }

  // ============================
  // LOGIN (Untuk nanti jika sudah ada fitur login)
  // ============================
  // static Future<bool> login(String email, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseURL/login'),
  //       headers: {
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'email': email,
  //         'password': password,
  //       }),
  //     );
  //
  //     print("Login Status: ${response.statusCode}");
  //     print("Login Body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final token = data['token'];
  //
  //       // Simpan token ke SharedPreferences
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', token);
  //
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print("Login Exception: $e");
  //     return false;
  //   }
  // }

  // ============================
  // LOGOUT
  // ============================
  // static Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('token');
  // }

  // ============================
  // GET PROFILE (employeeInfo) - DARI LetterSubmissionController
  // ============================
  static Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/letter/employee'),
        headers: await _headersWithToken(),
      );

      print("Profile Status: ${response.statusCode}");
      print("Profile Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('employee')) {
          return data; // Return full response
        }
        
        if (data is Map<String, dynamic>) {
          return data;
        }
        
        return null;
      }
      return null;
    } catch (e) {
      print("Profile Exception: $e");
      return null;
    }
  }

  // ============================
  // CREATE PENGAJUAN SURAT - DARI LetterSubmissionController
  // ============================
  static Future<bool> createPengajuanSurat(Map<String, dynamic> data) async {
    try {
      final payload = {
        'letter_format_id': data['letter_format_id'],
        'tanggal_mulai': data['tanggal_mulai'],
        'tanggal_selesai': data['tanggal_selesai'], 
      };

      print('📤 Submitting letter data: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl/letters/submit'),
        headers: await _headersWithToken(),
        body: jsonEncode(payload),
      );

      print("Submit Letter Status: ${response.statusCode}");
      print("Submit Letter Body: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Submit Letter Exception: $e");
      return false;
    }
  }

  // ============================
  // GET LIST SURAT - UNTUK HRD (dari LetterController)
  // ============================
  static Future<List> getSurat() async {
    try {
      print('🔍 Fetching: $baseUrl/letters');
      
      final res = await http.get(
        Uri.parse("$baseUrl/letters"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode == 200) {
        final decode = jsonDecode(res.body);
        
        // Response langsung array dari LetterController
        if (decode is List) {
          print('✅ Found ${decode.length} letters');
          return decode;
        }
        
        // Jika wrapped dalam object
        if (decode is Map) {
          if (decode.containsKey('data') && decode['data'] is List) {
            print('✅ Found ${decode['data'].length} letters (wrapped)');
            return decode['data'];
          }
          // Single item in array
          return [decode];
        }
      }
      
      print('⚠️ No data or error ${res.statusCode}');
      return [];
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }

  // ============================
  // UPDATE STATUS SURAT - UNTUK HRD (dari LetterController)
  // ============================
  static Future<bool> updateStatus(dynamic id, String status) async {
    try {
      print('Updating status for letter $id to $status');

      final res = await http.put(
        Uri.parse("$baseUrl/letters/$id/status"),
        headers: await _headersWithToken(),
        body: jsonEncode({"status": status}),
      );

      print('Update Status: ${res.statusCode}');
      print('Update Response: ${res.body}');

      return res.statusCode == 200;
    } catch (e) {
      print('Update Status Exception: $e');
      return false;
    }
  }

  // ============================
  // DOWNLOAD PDF
  // ============================
  static Future<Uint8List?> downloadPdf(dynamic id) async {
    try {
      print('🔽 Downloading PDF for letter $id');

      final url = Uri.parse("$baseUrl/letters/$id/download");
      print('📡 URL: $url');

      final res = await http.get(
        url,
        headers: {
          'Accept': 'application/pdf',
          'Content-Type': 'application/json',
        },
      );

      print('📥 PDF Download Status: ${res.statusCode}');
      print('📥 Content-Type: ${res.headers['content-type']}');
      print('📥 Content-Length: ${res.headers['content-length']}');

      if (res.statusCode == 200) {
        final contentType = res.headers['content-type'];
        
        if (contentType != null && contentType.contains('application/pdf')) {
          print('✅ PDF download successful, size: ${res.bodyBytes.length} bytes');
          return res.bodyBytes;
        } else {
          print('❌ Response is not PDF: $contentType');
          print('Response body: ${res.body}');
          return null;
        }
      } else {
        print('❌ PDF download failed with status ${res.statusCode}');
        print('Response: ${res.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Download PDF Exception: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
