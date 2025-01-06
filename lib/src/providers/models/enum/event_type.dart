enum EventType {
  MEETING,
  BIRTHDAY,
  WEDDING,
  PARTY,
  CONFERENCE,
  WORKSHOP,
  SEMINAR,
  FUNERAL,
  ILLNESS,
  NEWBORN,
  GRIEF,
  OTHER
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.MEETING:
        return 'Réunion';
      case EventType.BIRTHDAY:
        return 'Anniversaire';
      case EventType.WEDDING:
        return 'Mariage';
      case EventType.PARTY:
        return 'Fête';
      case EventType.CONFERENCE:
        return 'Conférence';
      case EventType.WORKSHOP:
        return 'Atelier';
      case EventType.SEMINAR:
        return 'Séminaire';
      case EventType.FUNERAL:
        return 'Funéraille';
      case EventType.ILLNESS:
        return 'Maladie';
      case EventType.NEWBORN:
        return 'Naissance';
      case EventType.GRIEF:
        return 'Funéraille';
      case EventType.OTHER:
        return 'Autre';
    }
  }
}
