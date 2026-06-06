enum DepositType {
  COTISATION,
  FOND,
}

DepositType depositTypeFromString(String? type) {
  if (type == null || type.isEmpty) return DepositType.COTISATION;
  return DepositType.values.firstWhere(
    (e) => e.toString().split('.').last == type.trim().toUpperCase(),
    orElse: () => DepositType.COTISATION,
  );
}

extension DepositTypeExtension on DepositType {
  String get displayName {
    switch (this) {
      case DepositType.COTISATION:
        return 'Cotisation';
      case DepositType.FOND:
        return 'Fond';
    }
  }
}
