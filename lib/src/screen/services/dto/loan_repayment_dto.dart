class CreateLoanRepaymentDto {
  final double amount;
  final double principalAmount;
  final double interestAmount;
  final String? currency;
  final String? notes;

  CreateLoanRepaymentDto({
    required this.amount,
    required this.principalAmount,
    required this.interestAmount,
    this.currency,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'principalAmount': principalAmount,
        'interestAmount': interestAmount,
        if (currency != null) 'currency': currency,
        if (notes != null) 'notes': notes,
      };
}
