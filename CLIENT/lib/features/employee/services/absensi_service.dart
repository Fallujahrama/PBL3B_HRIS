import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiService {
  static String baseUrl = "http://localhost:8000/api";

  static String monthName(String mm) {
    const map = {
      "01": "Januari",
      "02": "Februari",
      "03": "Maret",
      "04": "April",
      "05": "Mei",
      "06": "Juni",
      "07": "Juli",
      "08": "Agustus",
      "09": "September",
      "10": "Oktober",
      "11": "November",
      "12": "Desember",
    };
    return map[mm] ?? mm;
  }

  static String formatTanggal(String? date) {
    if (date == null) return "-";
    try {
      final d = DateTime.parse(date);
      return "${d.day.toString().padLeft(2, '0')} ${monthName(d.month.toString().padLeft(2, '0'))} ${d.year}";
    } catch (_) {
      return date;
    }
  }

  static Future<List<Map<String, dynamic>>> getAbsensi({
    String? month,
    String? year,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) throw "Token tidak ditemukan";

    final url =
        "$baseUrl/employee/absensi/report?month=${month ?? ''}&year=$year";

    final res = await http.get(
  Uri.parse(url),
  headers: {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
  },
);

print("ABSENSI RAW RESPONSE: ${res.body}");  // <-- Tambahkan ini

if (res.statusCode == 200) {
  final jsonData = jsonDecode(res.body);

  if (jsonData["data"] is List) {
    return List<Map<String, dynamic>>.from(jsonData["data"]);
  }
  throw "Format JSON salah";
}

    throw "Gagal mengambil data absensi";
  }
}
