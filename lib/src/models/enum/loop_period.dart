enum LoopPeriod { DAILY, WEEKLY, MONTHLY }

extension LoopPeriodExtension on LoopPeriod {
  String get displayName {
    switch (this) {
      case LoopPeriod.DAILY:
        return 'Journalier';
      case LoopPeriod.WEEKLY:
        return 'Hebdo';
      case LoopPeriod.MONTHLY:
        return 'Mensuel';
    }
  }
}
