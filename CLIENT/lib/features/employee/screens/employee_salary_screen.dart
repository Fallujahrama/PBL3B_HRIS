import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class EmployeeSalaryScreen extends StatefulWidget {
  const EmployeeSalaryScreen({super.key});

  @override
  State<EmployeeSalaryScreen> createState() => _EmployeeSalaryScreenState();
}

class _EmployeeSalaryScreenState extends State<EmployeeSalaryScreen> {
  Map<String, dynamic>? salaryData;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchSalaryData();
  }

  String formatRupiah(num number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );
    return formatCurrency.format(number);
  }

  Future<void> fetchSalaryData() async {
    setState(() => isLoading = true);
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      
      // GANTI DENGAN IP ANDA
      String baseUrl = "http://127.0.0.1:8000"; 

      final response = await http.get(
        Uri.parse("$baseUrl/api/employee/salary-slip?month=${selectedDate.month}&year=${selectedDate.year}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          salaryData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() { salaryData = null; isLoading = false; });
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Gagal: ${response.statusCode}"))
           );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: "Pilih Bulan Gaji",
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      fetchSalaryData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/employee-dashboard'),
        ),
        title: const Text("Slip Gaji Karyawan", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A6FA5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickMonth,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : salaryData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("Data gaji periode ini belum tersedia", style: TextStyle(color: Colors.grey[600])),
                      TextButton(onPressed: fetchSalaryData, child: const Text("Refresh"))
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchSalaryData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Card Periode
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                            ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Periode Gaji:", style: TextStyle(color: Colors.grey)),
                              Text(
                                salaryData!['period'] ?? "-",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A6FA5)),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Card Info Karyawan
                        _buildSectionCard(
                          title: "Informasi Karyawan",
                          children: [
                            _infoRow("Nama", salaryData!['employee']['name']),
                            _infoRow("Departemen", salaryData!['employee']['department']),
                            _infoRow("Jabatan", salaryData!['employee']['position']),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ==========================================
                        // CARD RINCIAN PENDAPATAN (HANYA 2 ITEM)
                        // ==========================================
                        _buildSectionCard(
                          title: "Rincian Pendapatan",
                          children: [
                            // 1. Insentif Kehadiran (Reguler)
                            _salaryRow(
                              "Insentif Kehadiran", 
                              "${salaryData!['details']['work_days']} hari x ${formatRupiah(salaryData!['details']['rate_reguler'])}",
                              salaryData!['details']['total_attendance_pay']
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(),
                            ),

                            // 2. Lembur (Overtime)
                            _salaryRow(
                              "Lembur", 
                              "${salaryData!['details']['overtime_hours']} jam x ${formatRupiah(salaryData!['details']['rate_overtime'])}",
                              salaryData!['details']['total_overtime_pay']
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Card Total
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A6FA5), Color(0xFF6B8BB9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF4A6FA5).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                            ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Penerimaan",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                formatRupiah(salaryData!['details']['grand_total']),
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // --- Widget Builders ---
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          ...children
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _salaryRow(String title, String subtitle, num amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          Text(
            formatRupiah(amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4A6FA5)),
          ),
        ],
      ),
    );
  }
}