enum SystemType {
  PART,
  AUCTION,
}

extension SystemTypeExtension on SystemType {
  String get displayName {
    switch (this) {
      case SystemType.PART:
        return 'Système de part';
      case SystemType.AUCTION:
        return 'Système d\'enchère';
    }
  }

  String get description {
    switch (this) {
      case SystemType.PART:
        return 'Les membres reçoivent leur part selon un ordre prédéfini';
      case SystemType.AUCTION:
        return 'Les membres enchérissent pour obtenir les fonds disponibles';
    }
  }

  String get value {
    switch (this) {
      case SystemType.PART:
        return 'PART';
      case SystemType.AUCTION:
        return 'AUCTION';
    }
  }
}

SystemType systemTypeFromString(String value) {
  switch (value.toUpperCase()) {
    case 'PART':
      return SystemType.PART;
    case 'AUCTION':
      return SystemType.AUCTION;
    default:
      return SystemType.PART; // Valeur par défaut
  }
}
