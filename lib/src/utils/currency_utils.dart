import 'package:intl/intl.dart';
import '../providers/models/enum/currency.dart';

/// Utilitaires pour l'affichage cohérent des montants avec devise
class CurrencyUtils {
  /// Formate un montant avec sa devise de manière cohérente
  static String formatAmount(double amount, Currency currency,
      {int? decimalPlaces}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: currency.displayName,
      decimalDigits: decimalPlaces ?? (amount % 1 == 0 ? 0 : 2),
    );

    // Pour les devises qui ne sont pas des symboles standards, on utilise un format personnalisé
    if (currency == Currency.FCFA) {
      final formattedAmount = NumberFormat('#,##0.##', 'fr_FR').format(amount);
      return '$formattedAmount ${currency.displayName}';
    }

    return formatter.format(amount);
  }

  /// Formate un montant avec devise pour l'affichage dans les cartes
  static String formatAmountForCard(double amount, Currency currency) {
    return formatAmount(amount, currency, decimalPlaces: 0);
  }

  /// Formate un montant avec devise pour l'affichage détaillé
  static String formatAmountDetailed(double amount, Currency currency) {
    return formatAmount(amount, currency, decimalPlaces: 2);
  }

  /// Formate un montant avec devise pour les graphiques
  static String formatAmountForChart(double amount, Currency currency) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ${currency.displayName}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ${currency.displayName}';
    } else {
      return formatAmount(amount, currency, decimalPlaces: 0);
    }
  }
}
