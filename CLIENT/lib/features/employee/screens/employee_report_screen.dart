import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import '../serviceS/absensi_service.dart';

class EmployeeReportScreen extends StatefulWidget {
  const EmployeeReportScreen({super.key});

  @override
  State<EmployeeReportScreen> createState() => _EmployeeReportScreenState();
}

class _EmployeeReportScreenState extends State<EmployeeReportScreen> {
  String? selectedMonth; // null = semua bulan
  String? selectedYear;

  List<Map<String, dynamic>> absensi = [];
  bool loading = true;

  final List<String> months =
      List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> years =
      List.generate(5, (i) => (DateTime.now().year - i).toString());

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    final now = DateTime.now();
    selectedMonth = null; // default semua bulan
    selectedYear = now.year.toString();
    fetchAbsensi();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    Intl.defaultLocale = 'id_ID';
  }

  Future<void> fetchAbsensi() async {
    setState(() => loading = true);

    try {
      final data = await AbsensiService.getAbsensi(
        month: selectedMonth ?? "",
        year: selectedYear,
      );

      setState(() {
        absensi = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat absensi: $e")),
      );
    }
  }

  void onMonthChanged(String? v) {
    setState(() => selectedMonth = v);
    fetchAbsensi();
  }

  void onYearChanged(String? v) {
    setState(() => selectedYear = v);
    fetchAbsensi();
  }

  // --- UI Helpers ---

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'dinas':
        return Colors.blue;
      case 'cuti':
        return Colors.orange;
      case 'sakit':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle;
      case 'dinas':
        return Icons.business_center;
      case 'cuti':
        return Icons.beach_access;
      case 'sakit':
        return Icons.local_hospital;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String? status) {
    if (status == null || status.isEmpty) return '-';
    return status[0].toUpperCase() + status.substring(1);
  }

  // --- Detail Modal ---

  void showDetailModal(BuildContext context, Map<String, dynamic> item) {
    final tanggal = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
    final status = item['status'];
    final bool isLembur = (item['check_clock_type'] == 1 || item['check_clock_type'] == true);
    final statusColor = _getStatusColor(status);

    String totalJamKerja = '-';

    if (item['clock_in'] != null && item['clock_out'] != null) {
      try {
        final masuk = DateFormat('HH:mm:ss').parse(item['clock_in']);
        final pulang = DateFormat('HH:mm:ss').parse(item['clock_out']);
        final diff = pulang.difference(masuk);
        totalJamKerja = "${diff.inHours} jam ${diff.inMinutes.remainder(60)} menit";
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header Tanggal
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withOpacity(0.8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat.EEEE('id_ID').format(tanggal),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('d MMMM yyyy', 'id_ID').format(tanggal),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (isLembur) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Text("LEMBUR",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                )
                              ]
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(status), color: statusColor),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                    color: statusColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Details List
                        _detailRow("Jam Masuk", item['clock_in'] ?? "-"),
                        const SizedBox(height: 10),
                        _detailRow("Jam Pulang", item['clock_out'] ?? "-"),
                        const SizedBox(height: 10),
                        if (status == 'hadir')
                          _detailRow("Total Jam Kerja", totalJamKerja),

                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Tutup"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- Main Build ---

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    // Hitung total berdasarkan status
    final totalHadir = absensi.where((e) => e['status'] == 'hadir').length;
    final totalSakit = absensi.where((e) => e['status'] == 'sakit').length;
    final totalCuti  = absensi.where((e) => e['status'] == 'cuti').length;
    final totalDinas = absensi.where((e) => e['status'] == 'dinas').length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text("Rangkuman Kehadiran"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/employee-dashboard'),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- 1. Filter Dropdown ---
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: selectedMonth,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_month),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Semua Bulan", style: TextStyle(fontSize: 14)),
                            ),
                            ...months.map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  DateFormat('MMMM', 'id_ID').format(DateTime(2024, int.parse(m))),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                          ],
                          onChanged: onMonthChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<String?>(
                          value: selectedYear,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: years
                              .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                              .toList(),
                          onChanged: onYearChanged,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- 2. Summary Cards (4 Kolom Proporsional) ---
                  Row(
                    children: [
                      _totalBox("Hadir", totalHadir, Colors.green, Icons.check_circle),
                      const SizedBox(width: 8),
                      _totalBox("Sakit", totalSakit, Colors.redAccent, Icons.local_hospital),
                      const SizedBox(width: 8),
                      _totalBox("Cuti", totalCuti, Colors.orange, Icons.beach_access),
                      const SizedBox(width: 8),
                      _totalBox("Dinas", totalDinas, Colors.blue, Icons.business_center),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- 3. List Header ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(width: 52), // Space untuk Icon
                        SizedBox(
                          width: 60,
                          child: Text("Tanggal",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Expanded(
                          child: Text("Masuk",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Expanded(
                          child: Text("Pulang",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text("Status",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        SizedBox(width: 20), // Space untuk Chevron
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- 4. List View Absensi ---
                  Expanded(
                    child: absensi.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text("Belum ada data absensi",
                                    style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: absensi.length,
                            itemBuilder: (_, i) {
                              final item = absensi[i];
                              
                              // Parsing data dari API
                              final tanggal = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
                              final status = item['status'];
                              final statusColor = _getStatusColor(status);

                              // Format Jam Helper
                              String formatTime(String? timeStr) {
                                if (timeStr == null) return "-";
                                try {
                                  final dt = DateFormat("HH:mm:ss").parse(timeStr);
                                  return DateFormat("HH:mm").format(dt);
                                } catch (e) {
                                  return "-";
                                }
                              }

                              return InkWell(
                                onTap: () => showDetailModal(context, item),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      // Status Icon Box
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(status),
                                          color: statusColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Kolom Tanggal
                                      SizedBox(
                                        width: 60,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('dd MMM', 'id_ID').format(tanggal),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              DateFormat('EEE', 'id_ID').format(tanggal),
                                              style: TextStyle(
                                                  fontSize: 11, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Kolom Jam Masuk
                                      Expanded(
                                        child: Text(
                                          formatTime(item['clock_in']),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                        ),
                                      ),

                                      // Kolom Jam Pulang
                                      Expanded(
                                        child: Text(
                                          formatTime(item['clock_out']),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                        ),
                                      ),

                                      // Kolom Label Status Kecil
                                      SizedBox(
                                        width: 70,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _getStatusLabel(status),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.chevron_right,
                                          size: 18, color: Colors.grey.shade400),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
    );
  }

  // --- Widget Summary Box ---
  Widget _totalBox(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}