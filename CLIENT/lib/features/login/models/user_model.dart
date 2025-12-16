// models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  final int role; // 1 = admin, 0 = employee
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  // NOTE: token diberikan terpisah karena backend biasanya mengirim token di root response
  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      role: (json['role'] is int) ? json['role'] : int.tryParse('${json['role'] ?? 0}') ?? 0,
      token: token,
    );
  }
}
