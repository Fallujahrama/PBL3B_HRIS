class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String gender;
  final String? address;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.address,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      address: json['address'],
    );
  }
}
