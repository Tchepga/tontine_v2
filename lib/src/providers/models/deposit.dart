import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import 'member.dart';
import 'cashflow.dart';

class Deposit {
  final int id;
  final double amount;
  final Member author;
  final Currency currency;
  final StatusDeposit status;
  final DateTime creationDate;
  final String? reasons;
  final CashFlow cashFlow;

  Deposit({
    required this.id,
    required this.amount,
    required this.author,
    required this.currency,
    required this.status,
    required this.creationDate,
    this.reasons,
    required this.cashFlow,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      id: json['id'],
      amount: json['amount']?.toDouble() ?? 0.0,
      author: Member.fromJson(json['author']),
      currency: currencyFromString(json['currency']),
      status: json['status'] != null ? statusDepositFromString(json['status']) : StatusDeposit.PENDING,
      creationDate: DateTime.parse(json['creationDate']),
      reasons: json['reasons'],
      cashFlow: CashFlow.fromJson(json['cashFlow']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'author': author.toJson(),
      'currency': currency.toString().split('.').last,
      'status': status.toString().split('.').last,
      'creationDate': creationDate.toIso8601String(),
      if (reasons != null) 'reasons': reasons,
      'cashFlow': cashFlow.toJson(),
    };
  }
}
