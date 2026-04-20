import 'member.dart';

class LoanRepayment {
  final int id;
  final double amount;
  final double principalAmount;
  final double interestAmount;
  final String currency;
  final DateTime paidAt;
  final String? notes;
  final Member? recordedBy;

  LoanRepayment({
    required this.id,
    required this.amount,
    required this.principalAmount,
    required this.interestAmount,
    required this.currency,
    required this.paidAt,
    this.notes,
    this.recordedBy,
  });

  factory LoanRepayment.fromJson(Map<String, dynamic> json) {
    return LoanRepayment(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestAmount: (json['interestAmount'] as num).toDouble(),
      currency: json['currency'] ?? 'FCFA',
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'])
          : DateTime.now(),
      notes: json['notes'],
      recordedBy: json['recordedBy'] != null
          ? Member.fromJson(json['recordedBy'])
          : null,
    );
  }
}
