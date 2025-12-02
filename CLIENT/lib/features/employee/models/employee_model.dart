class Employee {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String gender;
  final int? positionId;
  final int? departmentId;
  final String? address;
  final User? user;
  final Position? position;
  final Department? department;
  final String? createdAt;
  final String? updatedAt;

  Employee({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.positionId,
    this.departmentId,
    this.address,
    this.user,
    this.position,
    this.department,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      positionId: json['position_id'],
      departmentId: json['department_id'],
      address: json['address'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      position: json['position'] != null ? Position.fromJson(json['position']) : null,
      department: json['department'] != null ? Department.fromJson(json['department']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'position_id': positionId,
      'department_id': departmentId,
      'address': address,
    };
  }
}

// GANTI class User di employee_model.dart dengan yang ini:

class User {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;  // ← TAMBAH PROPERTI INI

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,  // ← TAMBAH DI CONSTRUCTOR
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['is_admin'] == 1 || json['is_admin'] == true,  // ← PARSE is_admin
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_admin': isAdmin,  // ← TAMBAH DI toJson
    };
  }
}

class Position {
  final int id;
  final String name;

  Position({
    required this.id,
    required this.name,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Department {
  final int id;
  final String name;

  Department({
    required this.id,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}