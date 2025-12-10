import 'package:flutter/foundation.dart';
import '../services/employee_recap_service.dart';
import '../models/employee_recap.dart';

class EmployeeRecapController extends ChangeNotifier {
  List<EmployeeRecap> employees = [];
  bool isLoading = false;
  String? error;

  // ============================
  // FETCH EMPLOYEE RECAP
  // ============================
  Future<void> fetchEmployeeRecap() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      print('🔄 Fetching employee recap...');
      employees = await EmployeeRecapService.fetchEmployeeRecap();
      print('✅ Loaded ${employees.length} employees');
      error = null;
    } catch (e) {
      print('❌ Error: $e');
      error = e.toString();
      employees = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // FILTER EMPLOYEES
  // ============================
  List<EmployeeRecap> searchEmployees(String query) {
    if (query.isEmpty) return employees;
    
    final queryLower = query.toLowerCase();
    
    return employees.where((emp) {
      final nameLower = emp.name.toLowerCase();
      final deptLower = emp.departement?.toLowerCase() ?? '';
      final positionLower = emp.position?.toLowerCase() ?? '';
      
      return nameLower.contains(queryLower) || 
             deptLower.contains(queryLower) ||
             positionLower.contains(queryLower);
    }).toList();
  }

  // ============================
  // GET STATISTICS
  // ============================
  Map<String, int> getStatistics() {
    int totalLetters = 0;
    int pendingLetters = 0;
    int approvedLetters = 0;
    int rejectedLetters = 0;

    for (var employee in employees) {
      if (employee.letters != null) {
        totalLetters += employee.letters!.length;
        
        for (var letter in employee.letters!) {
          final status = letter['status']?.toString().toLowerCase() ?? '';
          
          switch (status) {
            case 'pending':
              pendingLetters++;
              break;
            case 'approved':
              approvedLetters++;
              break;
            case 'rejected':
              rejectedLetters++;
              break;
          }
        }
      }
    }

    return {
      'totalEmployees': employees.length,
      'totalLetters': totalLetters,
      'pending': pendingLetters,
      'approved': approvedLetters,
      'rejected': rejectedLetters,
    };
  }

  // ============================
  // GET LETTERS BY STATUS
  // ============================
  List<Map<String, dynamic>> getLettersByStatus(String status) {
    final List<Map<String, dynamic>> result = [];
    
    for (var employee in employees) {
      if (employee.letters != null) {
        for (var letter in employee.letters!) {
          if (letter['status']?.toString().toLowerCase() == status.toLowerCase()) {
            result.add({
              ...letter,
              'employee_name': employee.name,
              'employee_department': employee.departement,
            });
          }
        }
      }
    }
    
    return result;
  }

  // ============================
  // CLEAR DATA
  // ============================
  void clear() {
    employees = [];
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
