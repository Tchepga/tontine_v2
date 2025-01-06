enum TypeSanction {
  FINANCIAL,
  SUSPENSION,
  WARNING,
  EXCLUSION
}

extension TypeSanctionExtension on TypeSanction {
  String get displayName {
    switch (this) {
      case TypeSanction.FINANCIAL:
        return 'Sanction financière';
      case TypeSanction.SUSPENSION:
        return 'Suspension';
      case TypeSanction.WARNING:
        return 'Avertissement';
      case TypeSanction.EXCLUSION:
        return 'Exclusion';
    }
  }
}
