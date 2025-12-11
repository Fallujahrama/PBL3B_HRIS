import 'employee_model.dart';

class User {
  final int id;
  final String email;
  final String role;
  final Employee? employee;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.employee,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,

      email: json['email']?.toString() ?? "",

      // Ambil role langsung dari API (sudah disiapkan Laravel)
      role: json['role']?.toString() ?? "employee",

      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'])
          : null,
    );
  }
}