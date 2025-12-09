import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/summary_salary.dart';

class SummarySalaryApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/api'; 
  // static const String _baseUrl = 'http://192.168.66.114:8000/api'; 

  static Future<List<Department>> getDepartments() async {
    final uri = Uri.parse('$_baseUrl/summary-salary/departments');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> departmentsJson = jsonResponse['data'];
        final departments = departmentsJson
            .map((json) => Department.fromJson(json as Map<String, dynamic>))
            .toList();
        return departments;
      } else {
        throw Exception('Failed to load departments: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error while fetching departments: $e');
    }
  }
  
  static Future<List<MonthlySalaryHistory>> getMonthlyHistory() async {
    final uri = Uri.parse('$_baseUrl/summary-salary/monthly-history');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> historyJson = jsonResponse['data'];
        final history = historyJson
            .map((json) => MonthlySalaryHistory.fromJson(json as Map<String, dynamic>))
            .toList();
        return history;
      } else {
        throw Exception('Failed to load monthly history: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error while fetching monthly history: $e');
    }
  }


  static Future<SalaryReportData> getFullReport({
    int? month, 
    int? year, 
    dynamic department, 
    int page = 1,
  }) async {
    final Map<String, dynamic> queryParams = {
      'month': (month ?? DateTime.now().month).toString(),
      'year': (year ?? DateTime.now().year).toString(),
      'department': department?.toString() ?? 'all',
      'page': page.toString(),
    };

    final uri = Uri.parse('$_baseUrl/summary-salary')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SalaryReportData.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      } else {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Unknown API Error';
        throw Exception('Failed to load salary report (Status ${response.statusCode}): $message');
      }
    } catch (e) {
      throw Exception('Connection error while fetching report: $e');
    }
  }

  static Future<SalaryReportCombined> fetchCombinedData({
    int? month, 
    int? year, 
    dynamic department,
  }) async {
    final reportFuture = getFullReport(month: month, year: year, department: department);
    final departmentFuture = getDepartments();
    final historyFuture = getMonthlyHistory();

    final results = await Future.wait([reportFuture, departmentFuture, historyFuture]);
    
    return SalaryReportCombined(
      report: results[0] as SalaryReportData,
      departments: results[1] as List<Department>,
      history: results[2] as List<MonthlySalaryHistory>, 
    );
  }
}