import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; 
import 'package:open_filex/open_filex.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🔹 TAMBAHKAN INI
import 'dart:html' as html; 

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
      ? (dotenv.env['BASE_URL_WEB'] ?? 'http://127.0.0.1:8000/api') 
      : (dotenv.env['BASE_URL_MOBILE'] ?? 'http://10.0.2.2:8000/api');

  @override
  void initState() {
    super.initState();
    fetchAttendanceReport();
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export berhasil (Web)')),
          );
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final filePath =
              '${dir.path}/attendance-report-${DateTime.now().millisecondsSinceEpoch}.xlsx';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Export berhasil')));
            await OpenFilex.open(filePath);
          }
        }
      } else {
        throw Exception('Gagal export');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export error: $e')));
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
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Report")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: employeeController,
              decoration: const InputDecoration(
                labelText: "Nama Karyawan",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => selectedEmployeeName = value,
            ),
            const SizedBox(height: 10),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: selectedDate == null
                    ? "Pilih Tanggal"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                    if (selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: fetchAttendanceReport,
                    child: const Text("Cari"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: exportAttendanceReport,
                    child: const Text("Export Excel"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Nama")),
                          DataColumn(label: Text("Departemen")),
                          DataColumn(label: Text("Tanggal")),
                          DataColumn(label: Text("Clock In")),
                          DataColumn(label: Text("Clock Out")),
                          DataColumn(label: Text("OT Start")),
                          DataColumn(label: Text("OT End")),
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
          ],
        ),
      ),
    );
  }
}