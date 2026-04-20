import 'member.dart';

class PotDistribution {
  final int id;
  final double amount;
  final String currency;
  final DateTime period;
  final DateTime distributedAt;
  final String? notes;
  final Member recipient;
  final Member? distributedBy;

  PotDistribution({
    required this.id,
    required this.amount,
    required this.currency,
    required this.period,
    required this.distributedAt,
    this.notes,
    required this.recipient,
    this.distributedBy,
  });

  factory PotDistribution.fromJson(Map<String, dynamic> json) {
    return PotDistribution(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'FCFA',
      period: DateTime.parse(json['period']),
      distributedAt: json['distributedAt'] != null
          ? DateTime.parse(json['distributedAt'])
          : DateTime.now(),
      notes: json['notes'],
      recipient: Member.fromJson(json['recipient']),
      distributedBy: json['distributedBy'] != null
          ? Member.fromJson(json['distributedBy'])
          : null,
    );
  }
}
