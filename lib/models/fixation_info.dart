class FixationInfo {
  final DateTime date;
  final double amount;
  final String remarks;

  FixationInfo({
    required this.date,
    required this.amount,
    required this.remarks,
  });

  factory FixationInfo.fromJson(Map<String, dynamic> json) {
    return FixationInfo(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0).toDouble(),
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'remarks': remarks,
    };
  }
}
