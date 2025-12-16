import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = "http://localhost:8000/api";

  // =============================
  //            LOGIN
  // =============================
  Future<User> login(String email, String password) async {
    final uri = Uri.parse("$baseUrl/auth/login");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "email": email,
          "password": password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? "Login failed");
      }

      final token = data['token'] ?? "";
      final userMap = data['user'] ?? {};

      if (token.isEmpty) {
        throw Exception("Token kosong dari server");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userName', userMap['name'] ?? '');
      await prefs.setString('userEmail', userMap['email'] ?? '');

      return User.fromJson(userMap, token);
    } catch (e) {
      rethrow;
    }
  }

  // =============================
  //        RESET PASSWORD
  // =============================
  Future<void> resetPassword(String email, String newPassword) async {
    final uri = Uri.parse("$baseUrl/auth/reset-password");

    final response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "email": email,
        "password": newPassword,
        "password_confirmation": newPassword,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Reset failed');
    }
  }

  // =============================
  //            LOGOUT
  // =============================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final url = Uri.parse('$baseUrl/auth/logout');

    await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    prefs.remove('token');
    prefs.remove('userName');
    prefs.remove('userEmail');
  }
}
