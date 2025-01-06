enum DepositReason {
  VERSEMENT,
  REMBOURSEMENT,
  SANCTION,
  AUTRE
}

DepositReason depositReasonFromString(String reason) {
  return DepositReason.values.firstWhere((e) => e.toString().split('.').last == reason.toUpperCase());
}

String depositReasonToString(DepositReason reason) {
  return reason.toString().split('.').last;
}

extension DepositReasonExtension on DepositReason {
  String get displayName {
    switch (this) {
      case DepositReason.VERSEMENT:
        return 'Versement';
      case DepositReason.REMBOURSEMENT:
        return 'Remboursement';
      case DepositReason.SANCTION:
        return 'Sanction';
      case DepositReason.AUTRE:
        return 'Autre';
    }
  }
} 