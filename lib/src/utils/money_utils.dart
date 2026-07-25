/// Utilitaires montants : validation stricte et arrondi entier (FCFA / centimes).
class MoneyUtils {
  MoneyUtils._();

  /// Parse un montant saisi (accepte `,` ou `.` comme séparateur décimal).
  /// Pour les devises sans décimale (ex. FCFA), [allowDecimals] = false.
  static int? parseToMinorUnits(
    String? raw, {
    bool allowDecimals = false,
    int decimals = 0,
  }) {
    if (raw == null) return null;
    final normalized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;

    final value = double.tryParse(normalized);
    if (value == null || value.isNaN || value.isInfinite) return null;
    if (value <= 0) return null;

    if (!allowDecimals) {
      if (value != value.roundToDouble()) return null;
      return value.round();
    }

    final factor = _pow10(decimals);
    return (value * factor).round();
  }

  /// Valide un champ montant formulaire. Retourne le message d'erreur ou null.
  static String? validateAmountInput(
    String? value, {
    bool allowDecimals = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un montant';
    }
    final parsed = parseToMinorUnits(value, allowDecimals: allowDecimals);
    if (parsed == null) {
      return allowDecimals
          ? 'Montant invalide (nombre positif requis)'
          : 'Montant invalide (entier positif requis)';
    }
    return null;
  }

  /// Convertit la saisie en double API (entier si pas de décimales).
  static double? parseToApiAmount(
    String? raw, {
    bool allowDecimals = false,
  }) {
    final minor = parseToMinorUnits(raw, allowDecimals: allowDecimals);
    if (minor == null) return null;
    if (!allowDecimals) return minor.toDouble();
    return minor / 100.0;
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
