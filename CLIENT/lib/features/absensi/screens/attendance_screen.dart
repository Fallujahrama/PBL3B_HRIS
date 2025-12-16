// lib/features/absensi/screens/attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../models/attendance_models.dart';
import '../services/api_services.dart';
import '../services/geolocator_services.dart';
import '../../../widgets/app_drawer.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // ==========================================
  // LOGIC & STATE (TIDAK DIUBAH)
  // ==========================================
  DateTime selectedTime = DateTime.now();
  DateTime? checkIn;
  DateTime? checkOut;
  DateTime? overtimeStart;
  DateTime? overtimeEnd;
  Position? currentPosition;
  DepartmentLocation? departmentLocation;
  bool isLoading = false;
  bool isWithinRadius = false;
  String statusMessage = "";
  String radiusStatus = "";
  List<CheckClockHistory> attendanceHistory = [];

  final int employeeId = 1;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _getCurrentLocation();
    await _getDepartmentLocation();
    await _fetchAttendanceHistory();
  }

  Future<void> _getCurrentLocation() async {
    final pos = await GeolocatorService.getCurrentPosition();
    if (pos != null) {
      setState(() {
        currentPosition = pos;
      });
      _checkIfWithinRadius();
    }
  }

  Future<void> _getDepartmentLocation() async {
    try {
      final dept = await ApiService.getDepartmentLocation(employeeId);
      setState(() {
        departmentLocation = dept;
      });
      _checkIfWithinRadius();
    } catch (e) {
      setState(() => statusMessage = "❌ Gagal mendapatkan lokasi departemen");
    }
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      final history = await ApiService.getAttendanceHistory(employeeId);
      setState(() {
        attendanceHistory = history;
      });
    } catch (e) {
      debugPrint("Error fetching history: $e");
    }
  }

  void _checkIfWithinRadius() {
    if (currentPosition == null || departmentLocation == null) return;

    double distance = _calculateDistance(
      currentPosition!.latitude,
      currentPosition!.longitude,
      departmentLocation!.latitude,
      departmentLocation!.longitude,
    );

    setState(() {
      isWithinRadius = distance <= departmentLocation!.radius;
      radiusStatus = isWithinRadius
          ? "Dalam jangkauan departemen (${distance.toStringAsFixed(2)} KM)"
          : "Diluar jangkauan departemen (${distance.toStringAsFixed(2)} KM)";
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;
    double dLat = _toRadian(lat2 - lat1);
    double dLon = _toRadian(lon2 - lon1);

    double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadian(lat1)) *
            math.cos(_toRadian(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadian(double degree) {
    return degree * (3.14159265359 / 180);
  }

  Future<void> _handlePunch(String type) async {
    if (currentPosition == null) {
      _showErrorMessage("Gagal mendapatkan lokasi!");
      return;
    }

    if (!isWithinRadius) {
      _showErrorMessage("Anda berada diluar jangkauan departemen!");
      return;
    }

    final request = AttendanceRequest(
      employeeId: employeeId,
      time: selectedTime,
      latitude: currentPosition!.latitude,
      longitude: currentPosition!.longitude,
      checkType: type,
    );

    setState(() {
      isLoading = true;
      statusMessage = "Mengirim data...";
    });

    try {
      final response = await ApiService.submitAttendance(request);
      if (response.success) {
        setState(() {
          if (type == 'clock_in') {
            checkIn = selectedTime;
            statusMessage = "✅ Absen Masuk Berhasil!";
          } else if (type == 'clock_out') {
            checkOut = selectedTime;
            statusMessage = "✅ Absen Keluar Berhasil!";
          } else if (type == 'overtime_start') {
            overtimeStart = selectedTime;
            statusMessage = "✅ Overtime Mulai Berhasil!";
          } else if (type == 'overtime_end') {
            overtimeEnd = selectedTime;
            statusMessage = "✅ Overtime Selesai Berhasil!";
          }
        });
        await _fetchAttendanceHistory();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage("❌ Error: $e");
    }

    setState(() => isLoading = false);
  }

  void _showErrorMessage(String message) {
    setState(() => statusMessage = message);
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "-";
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    final days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];
    final months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatDateFull(DateTime date) {
    final months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Warna Utama
    final primaryBlue = const Color(0xFF0066CC);
    final bgGrey = const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: bgGrey,
      drawer: const AppDrawer(),

      // AppBar dibuat menyatu warnanya dengan header
      appBar: AppBar(
        title: const Text(
          "Live Attendance",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryBlue,
        centerTitle: true,
        elevation: 0, // Hilangkan shadow agar menyatu dengan container bawah
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER YANG DIMODIFIKASI ---
            // Dibuat lebar (width: double.infinity) dan menonjol
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 50),
              decoration: BoxDecoration(
                color: primaryBlue,
                // Memberikan sedikit lengkungan di bawah agar terlihat modern
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "${selectedTime.hour.toString().padLeft(2, '0')}.${selectedTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 64, // Diperbesar agar menonjol
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: 2.0, // Memberi jarak antar angka
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatDate(selectedTime),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // ---------------------------------

            // Container untuk konten di bawahnya (ditarik sedikit ke atas)
            Transform.translate(
              offset: const Offset(0, -25), // Efek overlap ke atas
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // --- Status Location Box ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isWithinRadius
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isWithinRadius
                              ? Colors.green.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isWithinRadius ? Icons.check_circle : Icons.cancel,
                            color: isWithinRadius ? Colors.green : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  radiusStatus,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (currentPosition != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${currentPosition!.latitude.toStringAsFixed(4)}, ${currentPosition!.longitude.toStringAsFixed(4)}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
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
                    ),

                    const SizedBox(height: 24),

                    // --- Action Buttons ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: "Check In",
                            color: primaryBlue,
                            onPressed:
                                !isLoading && checkIn == null && isWithinRadius
                                ? () => _handlePunch('clock_in')
                                : null,
                            isActive:
                                !isLoading && checkIn == null && isWithinRadius,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            label: "Check Out",
                            color: primaryBlue,
                            onPressed:
                                !isLoading &&
                                    checkIn != null &&
                                    checkOut == null &&
                                    isWithinRadius
                                ? () => _handlePunch('clock_out')
                                : null,
                            isActive:
                                !isLoading &&
                                checkIn != null &&
                                checkOut == null &&
                                isWithinRadius,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: "Overtime Start",
                            color: Colors.grey[400]!,
                            activeColor: Colors.orange,
                            onPressed:
                                !isLoading &&
                                    checkOut != null &&
                                    overtimeStart == null &&
                                    isWithinRadius
                                ? () => _handlePunch('overtime_start')
                                : null,
                            isActive:
                                !isLoading &&
                                checkOut != null &&
                                overtimeStart == null &&
                                isWithinRadius,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            label: "Overtime End",
                            color: Colors.grey[400]!,
                            activeColor: Colors.orange,
                            onPressed:
                                !isLoading &&
                                    overtimeStart != null &&
                                    overtimeEnd == null &&
                                    isWithinRadius
                                ? () => _handlePunch('overtime_end')
                                : null,
                            isActive:
                                !isLoading &&
                                overtimeStart != null &&
                                overtimeEnd == null &&
                                isWithinRadius,
                          ),
                        ),
                      ],
                    ),

                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: primaryBlue),
                      ),

                    if (statusMessage.isNotEmpty && !isLoading)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: statusMessage.contains("✅")
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 30),

                    // --- Riwayat ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Riwayat absensi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (attendanceHistory.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Belum ada riwayat hari ini.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attendanceHistory.length,
                        itemBuilder: (context, index) {
                          final record = attendanceHistory[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateFull(record.date),
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Divider(height: 20, thickness: 0.5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildHistoryItem(
                                        "Check In",
                                        _formatTime(record.clockIn),
                                      ),
                                      _buildHistoryItem(
                                        "Check Out",
                                        _formatTime(record.clockOut),
                                      ),
                                    ],
                                  ),
                                  if (record.overtimeStart != null ||
                                      record.overtimeEnd != null) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildHistoryItem(
                                          "OT Start",
                                          _formatTime(record.overtimeStart),
                                          isOt: true,
                                        ),
                                        _buildHistoryItem(
                                          "OT End",
                                          _formatTime(record.overtimeEnd),
                                          isOt: true,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Helper ---
  Widget _buildActionButton({
    required String label,
    required Color color,
    Color? activeColor,
    required VoidCallback? onPressed,
    required bool isActive,
  }) {
    final finalColor = isActive ? (activeColor ?? color) : Colors.grey[300];
    final textColor = isActive ? Colors.white : Colors.grey[500];

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: finalColor,
          foregroundColor: textColor,
          elevation: isActive ? 3 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String label, String time, {bool isOt = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isOt ? Colors.orange[800] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}