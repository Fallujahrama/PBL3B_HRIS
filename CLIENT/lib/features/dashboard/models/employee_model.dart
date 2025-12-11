class Employee {
  final int id;
  final int? userId;
  final int? positionId;
  final int? departmentId;
  final String firstName;
  final String lastName;
  final String gender;
  final String? address;

  Employee({
    required this.id,
    this.userId,
    this.positionId,
    this.departmentId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.address,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      userId: json['user_id'],
      positionId: json['position_id'],
      departmentId: json['department_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      address: json['address'],
    );
  }
}
