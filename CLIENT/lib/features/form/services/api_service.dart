import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// 1. Tambahkan import untuk UserLoggedModel
import '../../login/models/user_logged_model.dart'; 

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
    // NOTE: HATI-HATI menggunakan token hardcode di production
    const token = "1|9nTtLsxWZZw7kplxnriTdw8lesXM235GZ8Jnhabe46efaa6a";

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // UNTUK PRODUCTION (DENGAN FITUR LOGIN)
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
  // LOGIN (Gunakan AuthService yang sudah di-fix)
  // ============================
  // (Fungsi login/logout dipindahkan ke AuthService, dikomentari di sini)

  // ============================
  // GET PROFILE (fetchProfile) TELAH DIHAPUS!
  // Data employee kini diambil dari UserLoggedModel.
  // ============================


  // ============================
  // CREATE PENGAJUAN SURAT - DARI LetterSubmissionController
  // ============================
  static Future<bool> createPengajuanSurat(Map<String, dynamic> data) async {
    try {
      // 2. Ambil user ID dari UserLoggedModel
      final userId = UserLoggedModel().currentUser?.id;

      if (userId == null) {
          throw Exception("User ID tidak ditemukan. Harap login kembali.");
      }
      
      final payload = {
        'letter_format_id': data['letter_format_id'],
        'tanggal_mulai': data['tanggal_mulai'],
        'tanggal_selesai': data['tanggal_selesai'], 
        'user_id': userId, // 3. Masukkan User ID ke payload
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
        
        if (decode is List) {
          print('✅ Found ${decode.length} letters');
          return decode;
        }
        
        if (decode is Map) {
          if (decode.containsKey('data') && decode['data'] is List) {
            print('✅ Found ${decode['data'].length} letters (wrapped)');
            return decode['data'];
          }
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
      print('📡 baseUrl: $baseUrl');

      final url = Uri.parse('$baseUrl/letters/$id/download');
      print('📡 Full URL: $url');

      final Map<String, String> headers = await _headersWithToken();

      headers['Accept'] = 'application/pdf';
      headers['ngrok-skip-browser-warning'] = 'true'; 

      final res = await http.get(
        url,
        headers: headers,
      );

      print('📥 PDF Download Status: ${res.statusCode}');
      print('📄 Content-Type: ${res.headers['content-type']}');
      print('📦 Response body length: ${res.bodyBytes.length}');

      if (res.statusCode == 200) {
        final contentType = res.headers['content-type'];
        
        if (contentType != null && contentType.contains('application/pdf')) {
          print('✅ PDF download successful, size: ${res.bodyBytes.length} bytes');
          return res.bodyBytes;
        } else {
          print('❌ Response is not PDF: $contentType');
          print('📄 Response body preview: ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}');
          return null;
        }
      } else {
        print('❌ PDF download failed with status ${res.statusCode}');
        print('📄 Error body: ${res.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Download PDF Exception: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }
}