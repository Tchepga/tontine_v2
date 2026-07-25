import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';

/// Stockage sécurisé du JWT (Keychain / EncryptedSharedPreferences).
/// Migre automatiquement l'ancien token GetStorage au premier démarrage.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const String keyToken = 'token';
  static const String keyMustChangePassword = 'must_change_password';

  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _logger = Logger('TokenStorage');
  String? _cached;

  Future<void> init() async {
    try {
      _cached = await _secure.read(key: keyToken);
      if (_cached == null || _cached!.isEmpty) {
        await _migrateFromGetStorage();
      }
    } catch (e) {
      _logger.severe('TokenStorage init failed: $e');
      _cached = null;
    }
  }

  Future<void> _migrateFromGetStorage() async {
    try {
      final legacy = GetStorage().read(keyToken);
      if (legacy != null && legacy.toString().isNotEmpty) {
        await write(legacy.toString());
        await GetStorage().remove(keyToken);
        _logger.info('Migrated JWT from GetStorage to secure storage');
      }
    } catch (e) {
      _logger.warning('Legacy token migration skipped: $e');
    }
  }

  String? get token => _cached;

  bool get hasToken => _cached != null && _cached!.isNotEmpty;

  Future<void> write(String value) async {
    _cached = value;
    await _secure.write(key: keyToken, value: value);
  }

  Future<void> clear() async {
    _cached = null;
    await _secure.delete(key: keyToken);
    try {
      await GetStorage().remove(keyToken);
    } catch (_) {}
  }

  Future<void> setMustChangePassword(bool value) async {
    if (value) {
      await _secure.write(key: keyMustChangePassword, value: 'true');
    } else {
      await _secure.delete(key: keyMustChangePassword);
    }
  }

  Future<bool> mustChangePassword() async {
    final v = await _secure.read(key: keyMustChangePassword);
    return v == 'true';
  }
}
