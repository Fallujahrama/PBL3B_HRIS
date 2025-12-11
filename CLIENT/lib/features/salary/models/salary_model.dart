class Salary {
  final int id;
  final double amount;
  final String month;

  Salary({
    required this.id,
    required this.amount,
    required this.month,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'],
      amount: json['amount'].toDouble(),
      month: json['month'],
    );
  }
}
