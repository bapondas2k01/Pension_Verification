class PaymentInfo {
  final String fiscalYear;
  final List<MonthlyPayment> months;

  PaymentInfo({required this.fiscalYear, required this.months});

  double get totalAmount =>
      months.fold(0, (sum, payment) => sum + payment.amount);

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      fiscalYear: json['fiscalYear'] ?? '',
      months:
          (json['months'] as List?)
              ?.map((m) => MonthlyPayment.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fiscalYear': fiscalYear,
      'months': months.map((m) => m.toJson()).toList(),
    };
  }
}

class MonthlyPayment {
  final String month;
  final double amount;

  MonthlyPayment({required this.month, required this.amount});

  factory MonthlyPayment.fromJson(Map<String, dynamic> json) {
    return MonthlyPayment(
      month: json['month'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'amount': amount};
  }
}
