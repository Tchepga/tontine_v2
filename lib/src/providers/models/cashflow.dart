import 'package:tontine_v2/src/providers/models/enum/currency.dart';

class CashFlow {
  final int id;
  final double amount;
  final Currency currency;
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
      id: json['id'] ?? 0,
      amount: json['amount']?.toDouble() ?? 0,
      currency: _parseCurrency(json['currency']),
      dividendes: json['dividendes']?.toDouble() ?? 0,
      deposits: json['deposits'] != null
          ? (json['deposits'] as List)
              .map((deposit) => CashFlow.fromJson(deposit))
              .toList()
          : [],
    );
  }

  static Currency _parseCurrency(dynamic value) {
    if (value == null) return Currency.EUR;
    if (value is String) {
      try {
        return currencyFromString(value);
      } catch (_) {
        return Currency.EUR;
      }
    }
    if (value is Map) {
      final name = value['name'] ?? value['code'];
      if (name is String) {
        try {
          return currencyFromString(name);
        } catch (_) {
          return Currency.EUR;
        }
      }
    }
    return Currency.EUR;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency.name,
      'dividendes': dividendes,
      'deposits': deposits.map((deposit) => deposit.toJson()).toList(),
    };
  }
} 