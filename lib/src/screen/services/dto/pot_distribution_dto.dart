class CreatePotDistributionDto {
  final int recipientId;
  final double amount;
  final String period; // ISO date string, e.g. '2024-03-01'
  final String? currency;
  final String? notes;

  CreatePotDistributionDto({
    required this.recipientId,
    required this.amount,
    required this.period,
    this.currency,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'recipientId': recipientId,
        'amount': amount,
        'period': period,
        if (currency != null) 'currency': currency,
        if (notes != null) 'notes': notes,
      };
}
