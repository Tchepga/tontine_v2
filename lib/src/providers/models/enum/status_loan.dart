enum StatusLoan {
  PENDING,
  PAID,
  CANCELLED,
  REJECTED,
  APPROVED,
}

StatusLoan fromStringToStatusLoan(String status) {
  return StatusLoan.values.firstWhere((s) => s.toString().split('.').last == status.toUpperCase());
}

extension StatusLoanExtension on StatusLoan {
  String get displayName {
    switch (this) {
      case StatusLoan.PENDING:
        return 'En attente';
      case StatusLoan.PAID:
        return 'Payé';
      case StatusLoan.CANCELLED:
        return 'Annulé';
      case StatusLoan.REJECTED:
        return 'Rejeté';
      case StatusLoan.APPROVED:
        return 'Approuvé';
    }
  }
}
