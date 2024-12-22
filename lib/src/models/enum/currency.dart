enum Currency { FCFA, USD, EUR }

Currency currencyFromString(String currency) {
  return Currency.values.firstWhere((e) => e.toString().split('.').last == currency);
}

String currencyToString(Currency currency) {
  return currency.toString().split('.').last;
}

extension CurrencyExtension on Currency {
  String get displayName {
    return toString().split('.').last;
  }
}

