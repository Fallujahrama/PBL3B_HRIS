import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/position.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/foundation.dart'; // Import ini untuk kishweb check

class PositionApi {

  static final String baseUrl_ = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  static String get baseUrl => '$baseUrl_/positions';

  // --- READ (GET) ---
  static Future<List<Position>> getPositions() async {
    final response = await http.get(Uri.parse(baseUrl));
    
    // Debugging: Print error di console Flutter jika bukan 200
    if (response.statusCode != 200) {
      print("Server Error: ${response.body}"); // Ini akan kasih tau detail error Laravel
      throw Exception("Failed to load positions: ${response.statusCode}");
    }

    final dynamic jsonData = jsonDecode(response.body);

    if (jsonData is List) {
      return jsonData.map((e) => Position.fromJson(e)).toList();
    }
    
    // Handle format Laravel standard resource
    if (jsonData is Map && jsonData.containsKey('data')) {
       // Cek apakah 'data' adalah List atau Map (pagination)
       if (jsonData['data'] is List) {
         return (jsonData['data'] as List).map((e) => Position.fromJson(e)).toList();
       } 
       // Handle Pagination Laravel
       if (jsonData['data'] is Map && jsonData['data']['data'] is List) {
          return (jsonData['data']['data'] as List).map((e) => Position.fromJson(e)).toList();
       }
    }

    return [];
  }

  // --- CREATE (POST) ---
  static Future<bool> createPosition(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json", // Penting agar Laravel membalas JSON jika error
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      print("Gagal Create: ${response.body}"); // Cek console untuk error validasi
      return false;
    }
    return true;
  }

  // --- UPDATE (PUT) ---
  static Future<bool> updatePosition(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      print("Gagal Update: ${response.body}");
      return false;
    }
    return true;
  }

  // --- DELETE (DELETE) ---
  static Future<bool> deletePosition(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
       headers: {
        "Accept": "application/json",
      },
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }
}