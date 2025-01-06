enum Currency {
  EUR,
  FCFA,
  USD
}

Currency currencyFromString(String currency) {
  return Currency.values.firstWhere((e) => e.toString().split('.').last == currency.toUpperCase());
}

String currencyToString(Currency currency) {
  return currency.toString().split('.').last.toUpperCase();
}

extension CurrencyExtension on Currency {
  String get displayName {
    switch (this) {
      case Currency.EUR:
        return '€';
      case Currency.FCFA:
        return 'FCFA';
      case Currency.USD:
        return '\$';
    }
  }
}

