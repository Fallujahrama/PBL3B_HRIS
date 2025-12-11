import 'dart:convert';
import 'package:http/http.dart' as http;

class SalaryService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<Map<String, dynamic>> getSalary(int userId) async {
    final url = Uri.parse("$baseUrl/salary/$userId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw "Failed to load salary (code: ${response.statusCode})";
    }
  }
}
