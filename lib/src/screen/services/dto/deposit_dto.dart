import '../../../models/enum/currency.dart';
import '../../../models/enum/status_deposit.dart';



class CreateDepositDto {
  final double amount;
  final Currency currency;
  final int memberId;
  final StatusDeposit status;
  final int cashFlowId;
  final String? reasons;

  CreateDepositDto({
    required this.amount,
    this.currency = Currency.EUR,
    required this.memberId,
    required this.status,
    required this.cashFlowId,
    this.reasons,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency.toString().split('.').last,
      'memberId': memberId,
      'status': status.toString().split('.').last,
      'cashFlowId': cashFlowId,
      if (reasons != null) 'reasons': reasons,
    };
  }
}
