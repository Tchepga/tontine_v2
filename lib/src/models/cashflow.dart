class CashFlow {
  final int id;
  final double amount;
  final String currency;
  final double dividendes;
  final List<CashFlow> deposits;

  CashFlow({
    required this.id,
    required this.amount,
    required this.currency,
    required this.dividendes,
    this.deposits = const [],
  });

  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      id: json['id'],
      amount: json['amount']?.toDouble() ?? 0,
      currency: json['currency'],
      dividendes: json['dividendes']?.toDouble() ?? 0,
      deposits: json['deposits'] != null
          ? (json['deposits'] as List)
              .map((deposit) => CashFlow.fromJson(deposit))
              .toList()
          : [],
    );
  }
} 