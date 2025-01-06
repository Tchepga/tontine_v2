enum StatusDeposit { 
  PENDING, 
  VALIDATED, 
  REJECTED 
  }

StatusDeposit statusDepositFromString(String status) {
  return StatusDeposit.values.firstWhere((e) => e.toString().split('.').last == status);
}

String statusDepositToString(StatusDeposit status) {
  return status.toString().split('.').last;
}

extension StatusDepositExtension on StatusDeposit {
  String get displayName {
    switch (this) {
      case StatusDeposit.PENDING:
        return 'En attente';
      case StatusDeposit.VALIDATED:
        return 'Validé';
      case StatusDeposit.REJECTED:
        return 'Rejeté';
      }
  }
}
