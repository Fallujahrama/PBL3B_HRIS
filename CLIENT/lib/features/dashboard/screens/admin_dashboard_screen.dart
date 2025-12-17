import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hris_3B/widgets/app_drawer.dart'; // <--- Tambahkan import AppDrawer

import '../../login/services/AdminDashboardService.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String adminName = '-';
  String adminEmail = '-';
  String adminRole = 'Admin';

  int totalEmployees = 0;
  int hadir = 0;
  int izin = 0;
  int telat = 0;
  int alpha = 0;
  double tingkatKehadiran = 0;

  int selectedMonth = DateTime.now().month;
  bool loading = true;
  int touchedIndex = -1;

  final List<String> months = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    await _loadProfile();
    await _loadStats();
    if (mounted) setState(() => loading = false);
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan UserLoggedModel di masa depan untuk data yang lebih reliable
    if (mounted) {
      setState(() {
        adminName = prefs.getString('userName') ?? '-';
        adminEmail = prefs.getString('userEmail') ?? '-';
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final data = await AdminDashboardService.getStats(month: selectedMonth);
      if (!mounted) return;
      
      totalEmployees = data['total_employees'] ?? 0;
      final absensi = data['absensi_bulanan'] ?? {};

      hadir = absensi['hadir'] ?? 0;
      izin = absensi['izin'] ?? 0;
      telat = absensi['telat'] ?? 0;
      alpha = absensi['alpha'] ?? 0;

      final total = hadir + izin + telat + alpha;
      if (total > 0) {
        tingkatKehadiran = (hadir / total) * 100;
      } else {
        tingkatKehadiran = 0;
      }
      setState(() {});
    } catch (e) {
      debugPrint("ERROR DASHBOARD: $e");
    }
  }

  // Fungsi logout dihapus dari sini karena akan ditangani oleh AppDrawer
  /* Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) context.go('/login');
  } */

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff5478ad);
    const Color bgColor = Color(0xfff4f6fb);

    return Scaffold(
      backgroundColor: bgColor,
      // === Tambahkan AppDrawer ===
      drawer: const AppDrawer(),
      // ============================
      
      // === Tambahkan AppBar ===
      appBar: AppBar(
        title: Text(
          'Halo, ${adminName.split(' ')[0]}!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        // Hapus tombol logout dari header, gunakan drawer
        /* actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: logout,
            tooltip: 'Keluar',
          ),
        ], */
      ),
      // ============================

      body: loading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView( // Bungkus konten di SingleChildScrollView
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hapus _buildModernHeader
                  
                  // Bagian profil yang kini langsung berada di body
                  _buildProfileSection(primaryColor), 
                  const SizedBox(height: 24),
                  const Text(
                    "Ringkasan Bulan Ini",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCards(primaryColor),
                  const SizedBox(height: 24),
                  _buildChartSection(),
                  const SizedBox(height: 24),
                  const Text(
                    "Menu Cepat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildManagementGrid(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // Fungsi _buildModernHeader sudah tidak diperlukan dan bisa dihapus/dilewati.
  /* Widget _buildModernHeader(Color primaryColor) {
     // ...
  } */

  Widget _buildProfileSection(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Text(
              adminName.isNotEmpty ? adminName[0].toUpperCase() : '?',
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(adminName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(adminEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              adminRole,
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Color primaryColor) {
    // Gunakan warna hardcode untuk icon jika perlu, atau pakai primaryColor
    return Row(
      children: [
        _summaryCard('Total Karyawan', '$totalEmployees', Icons.people_outline,
            Colors.blue),
        const SizedBox(width: 16),
        _summaryCard(
            'Kehadiran',
            '${tingkatKehadiran.toStringAsFixed(0)}%',
            Icons.bar_chart_rounded,
            Colors.orange),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final total = hadir + izin + telat + alpha;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // Header Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Statistik Absensi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _buildMonthSelector(),
            ],
          ),
          const SizedBox(height: 24),
          
          if (total == 0)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text("Belum ada data",
                        style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ),
            )
          else
            // Pie Chart dan Legend
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _generateChartSections(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Legend di bawah chart
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _chartLegend('Hadir', hadir, const Color(0xff4CAF50)),
                    _chartLegend('Izin', izin, const Color(0xff2196F3)),
                    _chartLegend('Telat', telat, const Color(0xffFF9800)),
                    _chartLegend('Alpha', alpha, const Color(0xffF44336)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateChartSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final double radius = isTouched ? 50 : 40;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff4CAF50),
            value: hadir.toDouble(),
            title: '',
            radius: radius,
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xff2196F3),
            value: izin.toDouble(),
            title: '',
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xffFF9800),
            value: telat.toDouble(),
            title: '',
            radius: radius,
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xffF44336),
            value: alpha.toDouble(),
            title: '',
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }

  Widget _chartLegend(String title, int value, Color color) {
    // Legend sederhana tanpa Spacer agar tidak error di layout sempit
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          "$title: $value",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedMonth,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(
              color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
          items: List.generate(12, (i) {
            return DropdownMenuItem(
              value: i + 1,
              child: Text(months[i]),
            );
          }),
          onChanged: (val) async {
            if (val == null) return;
            setState(() {
              selectedMonth = val;
              loading = true;
            });
            await _loadStats();
            setState(() => loading = false);
          },
        ),
      ),
    );
  }

  Widget _buildManagementGrid() {
    return Row(
      children: [
        _menuGridItem('Karyawan', Icons.people_alt_rounded, '/employee',
            const Color(0xff6C63FF)),
        const SizedBox(width: 16),
        _menuGridItem('Persetujuan', Icons.assignment_turned_in_rounded,
            '/hrd-list', const Color(0xff00BFA5)),
        const SizedBox(width: 16),
        _menuGridItem('Departemen', Icons.business_rounded, '/departments',
            const Color(0xffFF6D00)),
      ],
    );
  }

  Widget _menuGridItem(
      String title, IconData icon, String route, Color accentColor) {
    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: accentColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}