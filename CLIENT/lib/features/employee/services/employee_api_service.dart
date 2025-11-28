import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class EmployeeApiService {
  // Ganti dengan URL API Laravel Anda
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
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

  // Create new employee
  Future<Employee> createEmployee(Employee employee) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(employee.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Employee.fromJson(jsonData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create employee');
      }
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }

  // Update employee
  Future<Employee> updateEmployee(int id, Employee employee) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(employee.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Employee.fromJson(jsonData['data']);
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
}