enum SystemType {
  PART,
  AUCTION,
}

extension SystemTypeExtension on SystemType {
  String get name {
    switch (this) {
      case SystemType.PART:
        return 'Part';
      case SystemType.AUCTION:
        return 'Enchère';
    }
  }
}

SystemType fromStringToSystemType(String status) {
  return SystemType.values.firstWhere((s) => s.toString().split('.').last == status.toUpperCase());
}



