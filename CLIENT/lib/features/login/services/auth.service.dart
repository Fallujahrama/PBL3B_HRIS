import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/user_logged_model.dart'; // <--- Importasi Model Singleton

class AuthService {
  final String baseUrl = "https://nontransferential-zola-remonstratingly.ngrok-free.dev/api";

  // =============================
  //            LOGIN
  // =============================
  Future<User> login(String email, String password) async {
    final uri = Uri.parse("$baseUrl/auth/login"); // Tambahkan kembali URI

    try {
      // Tambahkan kembali Panggilan HTTP
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
      final userMap = data['user'] ?? {}; // userMap sekarang berisi 'employee'

      if (token.isEmpty) {
        throw Exception("Token kosong dari server");
      }

      // Pembuatan objek User akan otomatis menyimpan data employee di dalamnya
      final loggedInUser = User.fromJson(userMap, token);

      // --- INTEGRASI USERLOGGEDMODEL ---
      
      // Simpan objek User yang sudah lengkap (termasuk employeeData) ke Singleton
      UserLoggedModel().setLoggedInUser(loggedInUser);

      // --- END INTEGRASI ---

      return loggedInUser;
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
    // Ambil token dari Singleton
    final token = UserLoggedModel().currentUser?.token;

    if (token == null) {
        await UserLoggedModel().clearUser(); 
        return;
    }

    final url = Uri.parse('$baseUrl/auth/logout');

    await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // Hapus data dari Singleton (Ini akan menghapus data di SharedPreferences)
    await UserLoggedModel().clearUser(); 
  }
}