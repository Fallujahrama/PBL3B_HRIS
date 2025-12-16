import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sidebar_employee.dart';
import '../../login/services/dashboard.service.dart';
import '../../../widgets/app_drawer.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  final EmployeeService _dashboardService = EmployeeService();
  
  String employeeName = '-';
  String employeeEmail = '-';
  String employeePosition = '-';
  String employeeDepartment = '-';
  bool loading = true;

  // Data dari API (Updated sesuai response JSON)
  int monthlyAttendance = 0;
  int monthlyDinas = 0;
  int monthlyCuti = 0;
  int monthlySakit = 0;
  int monthlyOvertime = 0;

  // Placeholder untuk data harian (tidak ada di snippet JSON, tetap dibiarkan default)
  String todayStatus = "Belum Absen"; 
  String checkInTime = "-";
  String checkOutTime = "-";
  
  // Data absensi mingguan/bulanan untuk UI
  List<Map<String, dynamic>> attendanceData = [
    {'label': 'Hadir', 'value': 0, 'color': Colors.green},
    {'label': 'Dinas', 'value': 0, 'color': Colors.blue},
    {'label': 'Cuti', 'value': 0, 'color': Colors.orange},
    {'label': 'Sakit', 'value': 0, 'color': Colors.red},
    {'label': 'Lembur', 'value': 0, 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Fetch data dari API
      final data = await _dashboardService.getDashboardSummary();
      
      // Ambil object 'employee' dari response
      final employee = data['employee'];

      setState(() {
        // 1. Mapping Data Employee
        employeeName = employee['name'] ?? '-';
        employeeEmail = employee['email'] ?? '-';
        employeePosition = employee['position'] ?? '-';
        employeeDepartment = employee['department'] ?? '-';

        // 2. Mapping Data Statistik Bulanan (Convert aman ke int)
        monthlyAttendance = (data['monthly_attendance'] as num?)?.toInt() ?? 0;
        monthlyDinas = (data['monthly_dinas'] as num?)?.toInt() ?? 0;
        monthlyCuti = (data['monthly_cuti'] as num?)?.toInt() ?? 0;
        monthlySakit = (data['monthly_sakit'] as num?)?.toInt() ?? 0;
        monthlyOvertime = (data['monthly_overtime'] as num?)?.toInt() ?? 0;

        // 3. Update List UI sesuai key baru (Dinas, Cuti, Sakit)
        attendanceData = [
          {
            'label': 'Hadir',
            'value': monthlyAttendance,
            'color': Colors.green
          },
          {
            'label': 'Dinas',
            'value': monthlyDinas,
            'color': Colors.blue
          },
          {
            'label': 'Cuti',
            'value': monthlyCuti,
            'color': Colors.orange
          },
          {
            'label': 'Sakit',
            'value': monthlySakit,
            'color': Colors.redAccent
          },
          {
            'label': 'Lembur',
            'value': monthlyOvertime,
            'color': Colors.purple
          },
        ];

        loading = false;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', employeeName);
      await prefs.setString('userEmail', employeeEmail);

    } catch (e) {
      print("❌ Error loading dashboard: $e");
      setState(() => loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6FA5),
        foregroundColor: Colors.white,
        title: const Text('Dashboard Perusahaan', 
          style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerSection(),
                    const SizedBox(height: 16),
                    _profileCard(),
                    const SizedBox(height: 16),
                    _attendanceCards(),
                    const SizedBox(height: 16),
                    _monthlyAttendanceSummary(),
                  ],
                ),
              ),
            ),
    );
  }

  // Header dengan greeting
  Widget _headerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF4A6FA5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang, ${employeeName.split(' ').first}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ringkasan hari ini: $todayStatus',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Profile Card
  Widget _profileCard() {
    final initials = employeeName.isNotEmpty && employeeName != '-'
        ? employeeName.split(" ").map((e) => e[0]).take(2).join().toUpperCase()
        : "?";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFF4A6FA5),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employeeEmail,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (employeePosition != '-') ...[
                  const SizedBox(height: 4),
                  Text(
                    '$employeePosition${employeeDepartment != '-' ? ' • $employeeDepartment' : ''}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, 
                        size: 8, 
                        color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Status: $todayStatus',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Attendance Cards (Absensi Hari Ini & Gaji)
  Widget _attendanceCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _todayAttendanceCard(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _salaryCard(),
          ),
        ],
      ),
    );
  }

  Widget _todayAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A6FA5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A6FA5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Absen'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Absensi Hari Ini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Masuk:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    checkInTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Pulang:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    checkOutTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _salaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6FA5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF4A6FA5),
                  size: 24,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Slip'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Gaji Bulan Ini',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Status:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Belum Dibayar',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Monthly Attendance Summary
  Widget _monthlyAttendanceSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, 
                color: Color(0xFF4A6FA5)),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Absensi Bulan Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...attendanceData.map((item) => _attendanceSummaryItem(
            label: item['label'] as String,
            value: item['value'] as int,
            color: item['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _attendanceSummaryItem({
    required String label,
    required int value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}