// lib/features/absensi/models/attendance_models.dart
import 'dart:convert';

class AttendanceRequest {
  final int employeeId;
  final DateTime time;
  final double latitude;
  final double longitude;
  final String checkType;

  AttendanceRequest({
    required this.employeeId,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.checkType,
  });

  Map<String, dynamic> toJson() {
    print('⏰ DEBUG: Input DateTime = $time');
    print('⏰ DEBUG: time.toString() = ${time.toString()}');
    
    // Format: 2025-12-05 07:30:00 (dengan SPACE, bukan T)
    final formattedTime = time.toString().substring(0, 19);
    print('🕐 Formatted time: $formattedTime');
    print('📦 Final payload akan dikirim:');
    
    final payload = {
      'employee_id': employeeId,
      'time': formattedTime,
      'latitude': latitude,
      'longitude': longitude,
      'check_type': checkType,
    };
    
    print(jsonEncode(payload));
    return payload;
  }
}

class AttendanceResponse {
  final bool success;
  final String message;
  final dynamic data;

  AttendanceResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: json['data'],
    );
  }
}

class CheckClockHistory {
  final int id;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final DateTime? overtimeStart;
  final DateTime? overtimeEnd;

  CheckClockHistory({
    required this.id,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.overtimeStart,
    this.overtimeEnd,
  });

  factory CheckClockHistory.fromJson(Map<String, dynamic> json) {
    return CheckClockHistory(
      id: json['id'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString().split(' ')[0])
          : DateTime.now(),
      clockIn: json['clock_in'] != null ? _parseTime(json['clock_in']) : null,
      clockOut: json['clock_out'] != null ? _parseTime(json['clock_out']) : null,
      overtimeStart: json['overtime_start'] != null ? _parseTime(json['overtime_start']) : null,
      overtimeEnd: json['overtime_end'] != null ? _parseTime(json['overtime_end']) : null,
    );
  }

  static DateTime? _parseTime(dynamic timeValue) {
    if (timeValue == null) return null;
    
    try {
      String timeStr = timeValue.toString();
      
      // Format: HH:MM:SS
      if (timeStr.length == 8 && timeStr.contains(':')) {
        final now = DateTime.now();
        return DateTime.parse(
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} $timeStr',
        );
      }
      
      return DateTime.parse(timeStr);
    } catch (e) {
      print('❌ Error parsing time: $timeValue - $e');
      return null;
    }
  }
}

class DepartmentLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;

  DepartmentLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory DepartmentLocation.fromJson(Map<String, dynamic> json) {
    return DepartmentLocation(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),
      radius: _parseCoordinate(json['radius'], defaultValue: 0.5),
    );
  }

  /// Helper function untuk parse koordinat dari VARCHAR ke double
  /// Menangani berbagai format: "123.456", "123,456", 123.456, 123
  static double _parseCoordinate(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    
    try {
      // Jika sudah double, return langsung
      if (value is double) return value;
      
      // Jika int, convert ke double
      if (value is int) return value.toDouble();
      
      // Jika string, parse dengan handle koma sebagai decimal separator
      if (value is String) {
        // Hapus whitespace
        String cleaned = value.trim();
        
        // Replace koma dengan titik (untuk format Eropa: 123,456)
        cleaned = cleaned.replaceAll(',', '.');
        
        // Parse ke double
        double? result = double.tryParse(cleaned);
        
        if (result != null) {
          print('✅ Parsed coordinate: "$value" -> $result');
          return result;
        }
      }
      
      print('⚠️ Failed to parse coordinate: $value, using default: $defaultValue');
      return defaultValue;
      
    } catch (e) {
      print('❌ Error parsing coordinate: $value - $e');
      return defaultValue;
    }
  }
}