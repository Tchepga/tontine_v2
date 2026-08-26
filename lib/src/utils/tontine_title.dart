import '../providers/models/tontine.dart';

String normalizeTontineTitle(String title) => title.trim().toLowerCase();

bool hasDuplicateTontineTitle(
  Iterable<Tontine> tontines,
  String title, {
  int? excludeTontineId,
}) {
  final normalized = normalizeTontineTitle(title);
  if (normalized.isEmpty) return false;

  return tontines.any(
    (tontine) =>
        tontine.id != excludeTontineId &&
        normalizeTontineTitle(tontine.title) == normalized,
  );
}

String suggestUniqueTontineTitle(
  Iterable<Tontine> tontines,
  String desiredTitle,
) {
  final base = desiredTitle.trim();
  if (base.isEmpty || !hasDuplicateTontineTitle(tontines, base)) {
    return base;
  }

  var n = 2;
  var candidate = '$base $n';
  while (hasDuplicateTontineTitle(tontines, candidate)) {
    n++;
    candidate = '$base $n';
  }
  return candidate;
}
