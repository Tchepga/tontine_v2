enum MovementType { ROTATIVE, CUMULATIVE }

extension MovementTypeExtension on MovementType {
  String get displayName {
    switch (this) {
      case MovementType.ROTATIVE:
        return 'Rotative';
      case MovementType.CUMULATIVE:
        return 'Cumulative';
    }
  }
}