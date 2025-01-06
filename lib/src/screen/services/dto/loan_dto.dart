import '../../../providers/models/enum/currency.dart';

class CreateLoanDto {
  final double amount;
  final Currency currency;
  final int tontineId;
  final DateTime redemptionDate;

  CreateLoanDto({
    required this.amount,
    this.currency = Currency.EUR,
    required this.tontineId,
    required this.redemptionDate,
  }) : assert(amount > 0, 'Le montant doit être supérieur à 0');

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency.toString().split('.').last,
      'tontineId': tontineId,
      'redemptionDate': redemptionDate.toIso8601String(),
    };
  }
}

class UpdateLoanDto extends CreateLoanDto {
  UpdateLoanDto({
    required super.amount,
    required super.currency,
    required super.tontineId,
    required super.redemptionDate,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
    };
  }
} 