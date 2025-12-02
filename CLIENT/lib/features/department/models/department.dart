class Department {
  final int id;
  final String name;
  final String radius;
  final String? latitude;
  final String? longitude;

  Department({
    required this.id,
    required this.name,
    required this.radius,
    this.latitude,
    this.longitude,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      name: json['name'] ?? '',
      radius: json['radius'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}