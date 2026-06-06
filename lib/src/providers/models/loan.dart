import 'member.dart';
import 'enum/currency.dart';
import 'enum/status_loan.dart';

class Loan {
  final int id;
  final double amount;
  final Currency currency;
  final double? interestRate;
  final DateTime redemptionDate;
  final StatusLoan status;
  final Member author;
  final int? tontineId;
  final List<int>? voters;
  final String? rejectionReason;

  Loan({
    required this.id,
    required this.amount,
    required this.currency,
    required this.interestRate,
    required this.redemptionDate,
    required this.status,
    required this.author,
    this.tontineId,
    this.voters,
    this.rejectionReason,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    final List<int> voters = json['voters'] != null
        ? List<int>.from(json['voters'].map((e) => int.parse(e.toString())))
        : [];
    return Loan(
      id: json['id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] != null
          ? Currency.values.firstWhere((e) => e.name == json['currency'],
              orElse: () => Currency.EUR)
          : Currency.EUR,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      redemptionDate: DateTime.parse(json['redemptionDate']),
      status: fromStringToStatusLoan(json['status']),
      author: Member.fromJson(json['author']),
      tontineId: json['tontineId'],
      voters: voters,
      rejectionReason: json['rejectionReason'],
    );
  }
}
