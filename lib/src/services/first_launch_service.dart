import 'package:get_storage/get_storage.dart';

class FirstLaunchService {
  static const String _firstLaunchKey = 'app_first_launch';
  static const String _firstLaunchTimeKey = 'app_first_launch_time';

  final GetStorage _storage = GetStorage();

  /// Vérifie si c'est le premier lancement de l'application
  bool isFirstLaunch() {
    final hasLaunched = _storage.read(_firstLaunchKey);
    return hasLaunched == null || hasLaunched == false;
  }

  /// Marque que l'application a été lancée
  Future<void> markAppAsLaunched() async {
    await _storage.write(_firstLaunchKey, true);
    await _storage.write(_firstLaunchTimeKey, DateTime.now().toIso8601String());
  }

  /// Réinitialise le statut de premier lancement (pour test)
  Future<void> resetFirstLaunch() async {
    await _storage.remove(_firstLaunchKey);
    await _storage.remove(_firstLaunchTimeKey);
  }

  /// Obtient la date du premier lancement
  DateTime? getFirstLaunchTime() {
    final timeString = _storage.read(_firstLaunchTimeKey);
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }
}
