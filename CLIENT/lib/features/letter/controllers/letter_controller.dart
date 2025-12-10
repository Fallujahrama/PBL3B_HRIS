import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/letter_format_services.dart';
import '../models/letter_format.dart';

class LetterController {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000';
    return url.replaceAll('/api', '').replaceAll(RegExp(r'/$'), '');
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // ============================
  // LETTER METHODS
  // ============================

  Future<http.Response> createLetter(Map<String, dynamic> data) async {
    try {
      print('📤 Creating letter: $data');
      final response = await http.post(
        Uri.parse('$baseUrl/api/letters'),
        headers: _headers,
        body: jsonEncode(data),
      );
      print('📡 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error creating letter: $e');
      rethrow;
    }
  }

  Future<http.Response> getLetter(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/letters/$id'),
        headers: _headers,
      );
      return response;
    } catch (e) {
      print('❌ Error getting letter: $e');
      rethrow;
    }
  }

  Future<http.Response> getLetters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/letters'),
        headers: _headers,
      );
      return response;
    } catch (e) {
      print('❌ Error getting letters: $e');
      rethrow;
    }
  }

  // ============================
  // LETTER FORMAT METHODS
  // ============================

  Future<List<LetterFormat>> fetchLetterFormats() async {
    try {
      print('📥 Fetching letter formats from: $baseUrl/api/letter-formats');
      return await LetterFormatService.fetchLetterFormats();
    } catch (e) {
      print('❌ Error fetching letter formats: $e');
      rethrow;
    }
  }

  Future<LetterFormat> createLetterFormat(Map<String, dynamic> data) async {
    try {
      print('📤 Creating letter format: $data');
      return await LetterFormatService.createLetterFormat(data);
    } catch (e) {
      print('❌ Error creating letter format: $e');
      rethrow;
    }
  }

  Future<LetterFormat> updateLetterFormat(int id, Map<String, dynamic> data) async {
    try {
      print('📤 Updating letter format $id: $data');
      return await LetterFormatService.updateLetterFormat(id, data);
    } catch (e) {
      print('❌ Error updating letter format: $e');
      rethrow;
    }
  }

  Future<void> deleteLetterFormat(int id) async {
    try {
      print('🗑️ Deleting letter format: $id');
      return await LetterFormatService.deleteLetterFormat(id);
    } catch (e) {
      print('❌ Error deleting letter format: $e');
      rethrow;
    }
  }

  // ============================
  // UTILITY METHODS
  // ============================

  String pdfUrl(int id) {
    return '$baseUrl/api/letters/$id/pdf';
  }

  String getFullUrl(String path) {
    return '$baseUrl$path';
  }
}
