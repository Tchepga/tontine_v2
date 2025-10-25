import '../../../providers/models/enum/currency.dart';
import '../../../providers/models/enum/status_deposit.dart';

class CreateDepositDto {
  final double amount;
  final Currency currency;
  final int memberId;
  final StatusDeposit status;
  final int cashFlowId;
  final String? reasons;
  final String? comment;

  CreateDepositDto({
    required this.amount,
    this.currency = Currency.EUR,
    required this.memberId,
    required this.status,
    required this.cashFlowId,
    this.reasons,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency.toString().split('.').last,
      'memberId': memberId,
      'status': status.toString().split('.').last,
      'cashFlowId': cashFlowId,
      if (reasons != null) 'reasons': reasons,
      if (comment != null) 'comment': comment,
    };
  }
}
