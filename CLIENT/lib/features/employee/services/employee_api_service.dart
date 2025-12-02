import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class EmployeeApiService {
  // Ganti dengan URL API Laravel Anda
  static const String baseUrl = 'http://192.168.66.90:8000/api';
  
  // Get all employees
  Future<List<Employee>> getAllEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List employeesData = jsonData['data']['data'] ?? jsonData['data'];
        return employeesData.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employees: $e');
    }
  }

  // Get single employee by ID
  Future<Employee> getEmployeeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Employee.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employee: $e');
    }
  }

  // Create new employee with user account
  // UPDATED: Sekarang menerima Map<String, dynamic> untuk mengirim data user + employee
  Future<void> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        // Success
        return;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create employee');
      }
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }

// Update employee - GANTI METHOD INI di employee_api_service.dart
Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/employees/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Success
      return;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update employee');
    }
  } catch (e) {
    throw Exception('Error updating employee: $e');
  }
}

  // Delete employee
  Future<void> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete employee');
      }
    } catch (e) {
      throw Exception('Error deleting employee: $e');
    }
  }

  // Fetch departments
  Future<List<Department>> fetchDepartments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employee/department'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List data = jsonData['data'];
        return data.map((d) => Department.fromJson(d)).toList();
      } else {
        throw Exception('Gagal memuat daftar department');
      }
    } catch (e) {
      throw Exception('Error fetching departments: $e');
    }
  }

  // Fetch positions
  Future<List<Position>> fetchPositions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employee/position'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List data = jsonData['data'];
        return data.map((p) => Position.fromJson(p)).toList();
      } else {
        throw Exception('Gagal memuat daftar position');
      }
    } catch (e) {
      throw Exception('Error fetching positions: $e');
    }
  }
}