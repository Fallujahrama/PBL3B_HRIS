import 'dart:convert';
import 'package:intl/intl.dart';

// --- Data Historis Bulanan untuk Sparkline ---
class MonthlySalaryHistory {
  final int month;
  final int year;
  final String label; // Cth: Jan, Feb
  final double totalSalary;

  MonthlySalaryHistory({
    required this.month, 
    required this.year, 
    required this.label, 
    required this.totalSalary
  });

  factory MonthlySalaryHistory.fromJson(Map<String, dynamic> json) {
    return MonthlySalaryHistory(
      month: (json['month'] as int?) ?? 0,
      year: (json['year'] as int?) ?? 0,
      label: json['label'] as String? ?? DateFormat.MMM().format(DateTime(json['year'] ?? 2000, json['month'] ?? 1)),
      totalSalary: (json['total_salary'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// --- Data Departemen untuk Filter ---
class Department {
  final dynamic id; 
  final String name;

  Department({required this.id, required this.name});
  
  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
    );
  }
}

// --- Data untuk Chart Departemen ---
class DepartmentChartData {
  final String department;
  final double totalValue; 

  DepartmentChartData({required this.department, required this.totalValue});

  factory DepartmentChartData.fromSalaryJson(Map<String, dynamic> json) {
    return DepartmentChartData(
      department: json['department'] as String,
      totalValue: (json['total_salary'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  factory DepartmentChartData.fromOvertimeJson(Map<String, dynamic> json) {
    return DepartmentChartData(
      department: json['department'] as String,
      totalValue: (json['total_overtime'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// --- Data KPI Summary ---
class SummaryReport {
  final double totalSalary;
  final double totalHours;
  final double totalOvertime;
  final int employeeCount;
  final double salaryChangePercentage;

  SummaryReport({
    required this.totalSalary,
    required this.totalHours,
    required this.totalOvertime,
    required this.employeeCount,
    required this.salaryChangePercentage,
  });

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    return SummaryReport(
      totalSalary: (json['total_salary'] as num?)?.toDouble() ?? 0.0,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
      totalOvertime: (json['total_overtime'] as num?)?.toDouble() ?? 0.0,
      employeeCount: (json['employee_count'] as int?) ?? 0,
      salaryChangePercentage: (json['salary_change_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// --- Data Detail Tabel Karyawan (dihilangkan untuk fokus pada perbaikan) ---


// --- Data Report Lengkap (Dikembalikan oleh API index) ---
class SalaryReportData {
  final SummaryReport summary;
  final List<DepartmentChartData> salaryByDepartment;
  final List<DepartmentChartData> overtimeByDepartment;
  final List<dynamic> tableData; // Menggunakan dynamic karena paginasi Laravel kompleks

  SalaryReportData({
    required this.summary, 
    required this.salaryByDepartment, 
    required this.overtimeByDepartment,
    required this.tableData,
  });

  factory SalaryReportData.fromJson(Map<String, dynamic> json) {
    return SalaryReportData(
      summary: SummaryReport.fromJson(json['summary']),
      salaryByDepartment: (json['charts']['salary_by_department'] as List)
          .map((i) => DepartmentChartData.fromSalaryJson(i as Map<String, dynamic>))
          .toList(),
      overtimeByDepartment: (json['charts']['overtime_by_department'] as List)
          .map((i) => DepartmentChartData.fromOvertimeJson(i as Map<String, dynamic>))
          .toList(),
      // Ambil data dari 'data' di dalam 'table' (hanya data paginasi)
      tableData: json['table']['data'] as List? ?? [], 
    );
  }
}

// --- Data Gabungan untuk Fetch (Report + Options Filter + History) ---
class SalaryReportCombined {
  final SalaryReportData report;
  final List<Department> departments; 
  final List<MonthlySalaryHistory> history; // <-- NEW FIELD

  SalaryReportCombined({
    required this.report, 
    required this.departments, 
    required this.history
  });
}