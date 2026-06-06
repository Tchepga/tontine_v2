import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import 'package:tontine_v2/src/providers/models/enum/deposit_type.dart';
import 'member.dart';
import 'cashflow.dart';

class Deposit {
  final int id;
  final double amount;
  final Member? author;
  final Currency currency;
  final StatusDeposit status;
  final DateTime creationDate;
  final String? reasons;
  final String? comment;
  final DepositType type;
  final CashFlow? cashFlow;

  Deposit({
    required this.id,
    required this.amount,
    this.author,
    required this.currency,
    required this.status,
    required this.creationDate,
    this.reasons,
    this.comment,
    this.type = DepositType.COTISATION,
    this.cashFlow,
  });

  /// Retourne le libellé à afficher : comment en priorité, sinon reasons, sinon le type
  String get displayLabel {
    if (comment != null && comment!.isNotEmpty) return comment!;
    if (reasons != null && reasons!.isNotEmpty) return reasons!;
    return type.displayName;
  }

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      id: json['id'],
      amount: json['amount']?.toDouble() ?? 0.0,
      author: json['author'] != null ? Member.fromJson(json['author']) : null,
      currency: currencyFromString(json['currency']),
      status: json['status'] != null
          ? statusDepositFromString(json['status'])
          : StatusDeposit.PENDING,
      creationDate: DateTime.parse(json['creationDate']),
      reasons: json['reasons'],
      comment: json['comment'],
      type: depositTypeFromString(json['type']),
      cashFlow:
          json['cashFlow'] != null ? CashFlow.fromJson(json['cashFlow']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      if (author != null) 'author': author!.toJson(),
      'currency': currency.toString().split('.').last,
      'status': status.toString().split('.').last,
      'creationDate': creationDate.toIso8601String(),
      if (reasons != null) 'reasons': reasons,
      if (comment != null) 'comment': comment,
      'type': type.toString().split('.').last,
      if (cashFlow != null) 'cashFlow': cashFlow!.toJson(),
    };
  }
}
