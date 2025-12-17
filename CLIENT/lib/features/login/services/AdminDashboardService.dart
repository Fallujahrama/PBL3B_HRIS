import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardService {

  static Future<Map<String, dynamic>> getStats({required int month}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse('https://nontransferential-zola-remonstratingly.ngrok-free.dev/api/admin/dashboard/stats?month=$month');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception('Gagal load admin dashboard stats');
  }
}