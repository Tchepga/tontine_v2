enum TontineStatus {
  ACTIVE,
  CLOSED,
}

extension TontineStatusExtension on TontineStatus {
  String get displayName {
    switch (this) {
      case TontineStatus.ACTIVE:
        return 'Active';
      case TontineStatus.CLOSED:
        return 'Clôturée';
    }
  }

  String get value {
    switch (this) {
      case TontineStatus.ACTIVE:
        return 'ACTIVE';
      case TontineStatus.CLOSED:
        return 'CLOSED';
    }
  }
}

TontineStatus tontineStatusFromString(dynamic value) {
  if (value == null) return TontineStatus.ACTIVE;
  final name = value.toString().split('.').last.toUpperCase();
  switch (name) {
    case 'CLOSED':
      return TontineStatus.CLOSED;
    case 'ACTIVE':
    default:
      return TontineStatus.ACTIVE;
  }
}
