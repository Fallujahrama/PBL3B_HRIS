class Position {
  final int id;
  final String? name;
  final double? rateReguler;
  final double? rateOvertime;
  final String? createdAt;
  final String? updatedAt;

  Position({
    required this.id,
    this.name,
    this.rateReguler,
    this.rateOvertime,
    this.createdAt,
    this.updatedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      name: json['name'],
      rateReguler: json['rate_reguler'] != null
          ? (json['rate_reguler'] as num).toDouble()
          : null,
      rateOvertime: json['rate_overtime'] != null
          ? (json['rate_overtime'] as num).toDouble()
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "rate_reguler": rateReguler,
      "rate_overtime": rateOvertime,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
