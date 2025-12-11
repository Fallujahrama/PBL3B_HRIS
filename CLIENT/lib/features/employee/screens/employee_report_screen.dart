// lib/employee/screens/employee_report_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/absensi_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';

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

  // UI helpers
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'hadir':
        return Colors.green;
      case 'lembur':
        return Colors.blue;
      case 'sakit':
        return Colors.orange;
      case 'izin':
        return Colors.amber;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'hadir':
        return Icons.check_circle;
      case 'lembur':
        return Icons.access_time_filled;
      case 'sakit':
        return Icons.local_hospital;
      case 'izin':
        return Icons.event;
      case 'alpha':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'lembur':
        return 'Lembur';
      case 'sakit':
        return 'Sakit';
      case 'izin':
        return 'Izin';
      case 'alpha':
        return 'Alpha';
      default:
        return '-';
    }
  }

  void showDetailModal(BuildContext context, Map<String, dynamic> item) {
    final tanggal = DateTime.tryParse(item['tanggal'] ?? '') ?? DateTime.now();
    final status = item['status'];
    final isHadir = status == 'hadir' || status == 'lembur';
    final statusColor = _getStatusColor(status);

    String totalJamKerja = '-';

    if (item['jam_masuk'] != null && item['jam_pulang'] != null) {
      try {
        final masuk = DateFormat('HH:mm:ss').parse(item['jam_masuk']);
        final pulang = DateFormat('HH:mm:ss').parse(item['jam_pulang']);
        final diff = pulang.difference(masuk);
        totalJamKerja =
            "${diff.inHours} jam ${diff.inMinutes.remainder(60)} menit";
      } catch (_) {}
    }

    bool isLate = false;
    if (isHadir && item['jam_masuk'] != null) {
      try {
        final masuk = DateFormat('HH:mm:ss').parse(item['jam_masuk']);
        final batas = DateFormat('HH:mm:ss').parse('08:00:00');
        isLate = masuk.isAfter(batas);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8)
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
                                AbsensiService.formatTanggal(item['tanggal']),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(status),
                                  color: statusColor),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // details
                        if (isHadir) ...[
                          _detailRow("Jam Masuk", item['jam_masuk'] ?? "-"),
                          const SizedBox(height: 8),
                          _detailRow("Jam Pulang", item['jam_pulang'] ?? "-"),
                          const SizedBox(height: 8),
                          _detailRow("Total Jam Kerja", totalJamKerja),
                          if (isLate) ...[
                            const SizedBox(height: 8),
                            _detailRow("Keterlambatan", "Terlambat"),
                          ],
                        ] else ...[
                          _detailRow("Status", _getStatusLabel(status)),
                          if (status == "izin" || status == "sakit")
                            _detailRow("Keterangan", _getStatusLabel(status)),
                        ],
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
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final totalHadir = absensi
        .where((e) => e['status'] == 'hadir' || e['status'] == 'lembur')
        .length;

    final totalTidakHadir =
        absensi.length - totalHadir;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
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
                  // filter row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: selectedMonth,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_month),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Semua Bulan"),
                            ),
                            ...months.map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(AbsensiService.monthName(m)),
                              ),
                            )
                          ],
                          onChanged: onMonthChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 130,
                        child: DropdownButtonFormField<String?>(
                          value: selectedYear,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          items: years
                              .map((y) =>
                                  DropdownMenuItem(value: y, child: Text(y)))
                              .toList(),
                          onChanged: onYearChanged,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // total boxes
                  Row(
                    children: [
                      _totalBox("Hadir", totalHadir, Colors.green),
                      const SizedBox(width: 8),
                      _totalBox("Tidak Hadir", totalTidakHadir, Colors.red),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(width: 52),
                        SizedBox(
                          width: 70,
                          child: Text("Tanggal",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text("Masuk",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text("Pulang",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text("Status",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // list
                  Expanded(
                    child: absensi.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text("Belum ada data absensi",
                                    style: TextStyle(
                                        color: Colors.grey.shade600)),
                                if (selectedMonth != null) ...[
                                  const SizedBox(height: 6),
                                  Text("untuk bulan yang dipilih",
                                      style: TextStyle(
                                          color: Colors.grey.shade500)),
                                ]
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: absensi.length,
                            itemBuilder: (_, i) {
                              final item = absensi[i];
                              final tanggal =
                                  DateTime.tryParse(item['tanggal'] ?? '') ??
                                      DateTime.now();
                              final status = item['status'];
                              final statusColor =
                                  _getStatusColor(status);

                              return InkWell(
                                onTap: () => showDetailModal(context, item),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(status),
                                          color: statusColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 70,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('dd MMM')
                                                  .format(tanggal),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor),
                                            ),
                                            Text(
                                              DateFormat('EEE', 'id_ID')
                                                  .format(tanggal),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item['jam_masuk'] != null
                                              ? DateFormat('HH:mm').format(
                                                  DateFormat('HH:mm:ss')
                                                      .parse(item[
                                                          'jam_masuk']))
                                              : "-",
                                          style: TextStyle(
                                              color: statusColor,
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item['jam_pulang'] != null
                                              ? DateFormat('HH:mm').format(
                                                  DateFormat('HH:mm:ss')
                                                      .parse(item[
                                                          'jam_pulang']))
                                              : "-",
                                          style: TextStyle(
                                              color: statusColor,
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _getStatusLabel(status),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: statusColor,
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 11),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.chevron_right,
                                          color: Colors.grey.shade400),
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

  Widget _totalBox(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              label == "Hadir"
                  ? Icons.check_circle
                  : Icons.cancel,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color)),
            const SizedBox(height: 6),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text("Hari",
                style: TextStyle(
                    color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}