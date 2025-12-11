import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import '../../../utils/token_storage.dart';
import '../../dashboard/screens/sidebar_employee.dart';


class EmployeeSalaryScreen extends StatefulWidget {
  final String employeeId; // Parameter employeeId
  
  const EmployeeSalaryScreen({
    super.key,
    this.employeeId = 'employee1', // Default value, jadi optional
  });

  @override
  State<EmployeeSalaryScreen> createState() => _EmployeeSalaryScreenState();
}

class _EmployeeSalaryScreenState extends State<EmployeeSalaryScreen> {
  DateTime selectedDate = DateTime(2022, 12); // Default: December 2022

  // Simulasi data gaji berdasarkan employee yang login dan periode
  Map<String, dynamic> _getEmployeeSalaryData(String employeeId, DateTime period) {
    // Format periode
    final periodText = _getMonthName(period.month) + ' ${period.year}';
    
    // Data dummy untuk employee
    final Map<String, Map<String, dynamic>> baseData = {
      'employee1': {
        'name': 'Rahma Mutia',
        'position': 'Software Engineer',
        'employeeId': 'EMP001',
        'period': periodText,
        'bankName': 'Mandiri',
        'accountNumber': '123654789',
        'accountHolder': 'Rahma Mutia',
        'baseSalary': 8000000,
        'allowances': 1500000,
        'bonus': 500000,
        'deductions': 235000,
        'takeHomePay': 9765000,
      },
    };

    // Ambil data berdasarkan employeeId, jika tidak ada gunakan employee1 sebagai default
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      baseData[employeeId] ?? baseData['employee1']!
    );
    
    // Tambahkan variasi berdasarkan bulan (contoh: bonus di bulan tertentu)
    if (period.month == 12) { // Bonus akhir tahun di Desember
      data['bonus'] = (data['bonus'] as int) + 500000;
    }
    if (period.month == 6) { // Bonus pertengahan tahun di Juni
      data['bonus'] = (data['bonus'] as int) + 300000;
    }
    
    // Hitung ulang take home pay
    data['takeHomePay'] = (data['baseSalary'] as int) + 
                          (data['allowances'] as int) + 
                          (data['bonus'] as int) - 
                          (data['deductions'] as int);

    return data;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<void> _showMonthYearPicker() async {
    DateTime tempDate = selectedDate;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Period',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            height: 250,
            width: 300,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  children: [
                    // Year Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setDialogState(() {
                              tempDate = DateTime(tempDate.year - 1, tempDate.month);
                            });
                          },
                        ),
                        Text(
                          '${tempDate.year}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setDialogState(() {
                              tempDate = DateTime(tempDate.year + 1, tempDate.month);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Month Grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = tempDate.month == month;
                          
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                tempDate = DateTime(tempDate.year, month);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF446A8C) 
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _getMonthName(month).substring(0, 3),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600 
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDate = tempDate;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF446A8C),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}.000';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(String label, int amount, bool isDeduction, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            '${isDeduction ? '-' : ''}${_formatCurrency(amount)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: isDeduction 
                  ? const Color(0xFFEF4444) 
                  : isTotal 
                      ? const Color(0xFF10B981) 
                      : const Color(0xFF1F2937),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil employeeId dari widget parameter
    final String currentEmployeeId = widget.employeeId;
    
    // Debug print untuk cek employeeId
    print('🔍 DEBUG: Employee ID yang masuk = $currentEmployeeId');
    
    final salaryData = _getEmployeeSalaryData(currentEmployeeId, selectedDate);
    
    // Debug print untuk cek data yang diambil
    print('🔍 DEBUG: Nama Employee = ${salaryData['name']}');
    print('🔍 DEBUG: Gaji = ${salaryData['takeHomePay']}');

    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF446A8C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/employee-dashboard'),
        ),
        title: const Text(
          'Slip Gaji',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section dengan Gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF446A8C), Color(0xFF5A7FA3)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector - CLICKABLE
                    InkWell(
                      onTap: _showMonthYearPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              salaryData['period'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 24),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Take Home Pay
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Total Gaji Bersih',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatCurrency(salaryData['takeHomePay']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Download Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.download_rounded, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Mengunduh slip gaji...'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF446A8C),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text(
                          'Unduh Slip Gaji',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF446A8C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Employee Information Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF446A8C), Color(0xFF5A7FA3)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.badge_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Informasi Karyawan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow('Nama Lengkap', salaryData['name']),
                      _buildInfoRow('Posisi', salaryData['position']),
                      _buildInfoRow('ID Karyawan', salaryData['employeeId']),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Salary Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF34D399)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Rincian Gaji',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSalaryRow('Gaji Pokok', salaryData['baseSalary'], false),
                      _buildSalaryRow('Tunjangan', salaryData['allowances'], false),
                      _buildSalaryRow('Bonus', salaryData['bonus'], false),
                      const Divider(height: 32, thickness: 1.5, color: Color(0xFFE5E7EB)),
                      _buildSalaryRow('Potongan', salaryData['deductions'], true),
                      const Divider(height: 32, thickness: 1.5, color: Color(0xFFE5E7EB)),
                      _buildSalaryRow('Total Gaji Bersih', salaryData['takeHomePay'], false, isTotal: true),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Receiver Information Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Informasi Rekening',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow('Nama Bank', salaryData['bankName']),
                      _buildInfoRow('Nomor Rekening', salaryData['accountNumber']),
                      _buildInfoRow('Atas Nama', salaryData['accountHolder']),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}