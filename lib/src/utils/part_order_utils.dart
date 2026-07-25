import '../providers/models/enum/loop_period.dart';
import '../providers/models/tontine.dart';

/// Résout la part courante et la suivante selon la période de boucle.
Map<String, PartOrder?> resolveCurrentAndNextPartOrders({
  required List<PartOrder> parts,
  required LoopPeriod loopPeriod,
  DateTime? now,
}) {
  if (parts.isEmpty) {
    return {'current': null, 'next': null};
  }

  final reference = now ?? DateTime.now();
  final sortedParts = List<PartOrder>.from(parts)
    ..sort((a, b) => a.order.compareTo(b.order));

  PartOrder? currentPart;
  PartOrder? nextPart;

  for (int i = 0; i < sortedParts.length; i++) {
    final part = sortedParts[i];
    if (part.period == null) continue;

    if (isPeriodMatching(reference, part.period!, loopPeriod)) {
      currentPart = part;
      nextPart = sortedParts[(i + 1) % sortedParts.length];
      break;
    }
  }

  if (currentPart == null) {
    for (final part in sortedParts) {
      if (part.period != null && part.period!.isAfter(reference)) {
        nextPart = part;
        break;
      }
    }
  }

  return {'current': currentPart, 'next': nextPart};
}

bool isPeriodMatching(
  DateTime currentDate,
  DateTime partDate,
  LoopPeriod loopPeriod,
) {
  switch (loopPeriod) {
    case LoopPeriod.DAILY:
      return currentDate.year == partDate.year &&
          currentDate.month == partDate.month &&
          currentDate.day == partDate.day;
    case LoopPeriod.WEEKLY:
      return currentDate.year == partDate.year &&
          weekOfYear(currentDate) == weekOfYear(partDate);
    case LoopPeriod.MONTHLY:
      return currentDate.year == partDate.year &&
          currentDate.month == partDate.month;
  }
}

int weekOfYear(DateTime date) {
  final firstDayOfYear = DateTime(date.year, 1, 1);
  final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
  return (daysSinceFirstDay / 7).ceil();
}
