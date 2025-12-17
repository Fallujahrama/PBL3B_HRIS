import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final int role; // 1 = admin, 0 = employee
  final String token;
  final Map<String, dynamic>? employeeData; // Data employee lengkap

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    this.employeeData,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    // Controller Laravel mengirim data employee di bawah key 'employee'
    final employeeMap = json['employee'] as Map<String, dynamic>?; 
    
    // Tentukan nama: ambil dari first_name + last_name dari employee jika ada
    final firstName = employeeMap?['first_name'] ?? '';
    final lastName = employeeMap?['last_name'] ?? '';
    final fullName = "$firstName $lastName".trim();

    return User(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: fullName.isNotEmpty ? fullName : json['name']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      role: (json['role'] is int) ? json['role'] : int.tryParse('${json['role'] ?? 0}') ?? 0,
      token: token,
      employeeData: employeeMap, // Simpan map employee
    );
  }

  // Tambahkan ini agar bisa disimpan utuh sebagai JSON di SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      // Token tidak perlu disimpan di JSON ini, karena disimpan terpisah
      'employee': employeeData,
    };
  }
}