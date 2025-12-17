import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; 
import 'package:open_filex/open_filex.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart' as html;
import '../../widgets/app_drawer.dart'; // ✅ Tambahkan import AppDrawer

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  List<dynamic> attendanceData = [];
  String? selectedEmployeeName;
  DateTime? selectedDate;
  bool isLoading = false;

  final TextEditingController employeeController = TextEditingController();

  // 🔹 MODIFIKASI: Mengambil nilai dari dotenv
  final String baseUrl = kIsWeb 
      ? (dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api') 
      : (dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api');

  @override
  void initState() {
    super.initState();
    fetchAttendanceReport();
  }

  @override
  void dispose() {
    employeeController.dispose();
    super.dispose();
  }

  // ================= FETCH REPORT =================
  Future<void> fetchAttendanceReport() async {
    setState(() => isLoading = true);

    Map<String, String> queryParams = {};

    if (selectedEmployeeName != null && selectedEmployeeName!.isNotEmpty) {
      queryParams['employee_name'] = selectedEmployeeName!;
    }

    if (selectedDate != null) {
      String date =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      queryParams['start_date'] = date;
      queryParams['end_date'] = date;
    }

    final uri = Uri.parse('$baseUrl/attendance/report')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          attendanceData = json['data'] ?? [];
        });
      } else {
        throw Exception('Gagal ambil data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= EXPORT EXCEL =================
  Future<void> exportAttendanceReport() async {
    setState(() => isLoading = true);

    Map<String, String> queryParams = {};

    if (selectedEmployeeName != null && selectedEmployeeName!.isNotEmpty) {
      queryParams['employee_name'] = selectedEmployeeName!;
    }

    if (selectedDate != null) {
      String date =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      queryParams['start_date'] = date;
      queryParams['end_date'] = date;
    }

    try {
      final uri = Uri.parse('$baseUrl/attendance/report/export')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        if (kIsWeb) {
          final bytes = response.bodyBytes;
          final blob = html.Blob([bytes],
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..download =
                'attendance-report-${DateTime.now().millisecondsSinceEpoch}.xlsx';
          html.document.body!.append(anchor);
          anchor.click();
          anchor.remove();
          html.Url.revokeObjectUrl(url);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Export berhasil'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // ✅ MOBILE PLATFORM
          Directory dir;
          if (Platform.isAndroid) {
            dir = Directory('/storage/emulated/0/Download');
            if (!await dir.exists()) {
              dir = Directory('/storage/emulated/0/Downloads');
            }
          } else {
            dir = await getApplicationDocumentsDirectory();
          }

          final filePath =
              '${dir.path}/attendance-report-${DateTime.now().millisecondsSinceEpoch}.xlsx';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Export berhasil: $filePath'),
                backgroundColor: Colors.green,
              ),
            );
            await OpenFilex.open(filePath);
          }
        }
      } else {
        throw Exception('Gagal export');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              content: Text('❌ Export error: $e'),
              backgroundColor: Colors.red,
            ));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= PICK DATE =================
  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Tambahkan drawer untuk admin
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Laporan Absensi"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // ✅ Card untuk filter
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Laporan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: employeeController,
                      decoration: const InputDecoration(
                        labelText: "Nama Karyawan",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_search),
                        hintText: 'Cari berdasarkan nama...',
                      ),
                      onChanged: (value) => selectedEmployeeName = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: selectedDate == null
                            ? "Pilih Tanggal"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: _pickDate,
                              tooltip: 'Pilih Tanggal',
                            ),
                            if (selectedDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = null;
                                  });
                                },
                                tooltip: 'Hapus Filter Tanggal',
                              ),
                          ],
                        ),
                      ),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : fetchAttendanceReport,
                            icon: const Icon(Icons.search),
                            label: const Text("Cari"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading || attendanceData.isEmpty
                                ? null
                                : exportAttendanceReport,
                            icon: const Icon(Icons.download),
                            label: const Text("Export Excel"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ✅ Result section
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (attendanceData.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data laporan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gunakan filter di atas untuk mencari data',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hasil: ${attendanceData.length} data',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedEmployeeName != null ||
                              selectedDate != null)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  selectedEmployeeName = null;
                                  selectedDate = null;
                                  employeeController.clear();
                                });
                                fetchAttendanceReport();
                              },
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text('Reset Filter'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.blue.shade50,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Nama",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Departemen",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Tanggal",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Clock In",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Clock Out",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "OT Start",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "OT End",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: attendanceData.map((e) {
                              return DataRow(cells: [
                                DataCell(Text(e['employee_name'] ?? '-')),
                                DataCell(Text(e['department'] ?? '-')),
                                DataCell(Text(e['date'] ?? '-')),
                                DataCell(Text(e['clock_in'] ?? '-')),
                                DataCell(Text(e['clock_out'] ?? '-')),
                                DataCell(Text(e['overtime_start'] ?? '-')),
                                DataCell(Text(e['overtime_end'] ?? '-')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}