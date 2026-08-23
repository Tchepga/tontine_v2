import 'dart:io';

/// Configuration des tests d'intégration (API live).
///
/// Variables (shell, CI ou fichier `.integration.env` à la racine du projet) :
/// - [INTEGRATION_API_URL] — ex. https://api.tontine.devcoorp.net
/// - [INTEGRATION_USERNAME] — compte test sur cette API
/// - [INTEGRATION_PASSWORD] — **obligatoire** (pas de défaut — évite 401 silencieux)
/// - [INTEGRATION_TONTINE_ID] — id tontine de test (optionnel, auto-détecté)
/// - [INTEGRATION_MODE] — smoke | full (défaut smoke)
///
/// Les variables d'environnement du shell priment sur `.integration.env`.
class IntegrationConfig {
  static Map<String, String>? _fileEnv;
  static bool _loaded = false;

  static void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    final file = _findIntegrationEnvFile();
    _fileEnv = file != null ? _parseEnvFile(file) : const {};
  }

  static String? _env(String key) {
    _ensureLoaded();
    final fromPlatform = Platform.environment[key];
    if (fromPlatform != null && fromPlatform.isNotEmpty) {
      return fromPlatform;
    }
    return _fileEnv![key];
  }

  static File? _findIntegrationEnvFile() {
    var dir = Directory.current;
    for (var i = 0; i < 8; i++) {
      final candidate = File('${dir.path}/.integration.env');
      if (candidate.existsSync()) return candidate;
      if (File('${dir.path}/pubspec.yaml').existsSync()) return null;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
  }

  static Map<String, String> _parseEnvFile(File file) {
    final map = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      final key = trimmed.substring(0, eq).trim();
      var value = trimmed.substring(eq + 1).trim();
      if (value.length >= 2) {
        final quote = value[0];
        if ((quote == '"' || quote == "'") && value.endsWith(quote)) {
          value = value.substring(1, value.length - 1);
        }
      }
      map[key] = value;
    }
    return map;
  }

  static String get apiBaseUrl {
    final raw = _env('INTEGRATION_API_URL') ?? _env('API_URL') ?? '';
    return raw.replaceAll(RegExp(r'/+$'), '');
  }

  static String get username => _env('INTEGRATION_USERNAME') ?? 'ronaldo';

  static String get password => _env('INTEGRATION_PASSWORD') ?? '';

  static int? get tontineId {
    final raw = _env('INTEGRATION_TONTINE_ID');
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  static IntegrationMode get mode {
    final raw = (_env('INTEGRATION_MODE') ?? 'smoke').toLowerCase();
    return raw == 'full' ? IntegrationMode.full : IntegrationMode.smoke;
  }

  static bool get isConfigured => apiBaseUrl.isNotEmpty;

  static bool get credentialsConfigured => password.isNotEmpty;

  static String get skipReason {
    if (!isConfigured) {
      return 'INTEGRATION_API_URL non défini — voir docs/INTEGRATION_TESTS.md';
    }
    if (!credentialsConfigured) {
      return 'INTEGRATION_PASSWORD non défini — utilisez un compte réel de l\'API cible';
    }
    return '';
  }

  static String get credentialsHint =>
      'export INTEGRATION_API_URL=https://api.tontine.devcoorp.net\n'
      'export INTEGRATION_USERNAME=votre_user\n'
      'export INTEGRATION_PASSWORD=\'votre_mot_de_passe\'\n'
      '# ou copier .integration.env.example → .integration.env';
}

enum IntegrationMode { smoke, full }

/// Erreur login avec message actionnable.
class IntegrationLoginException implements Exception {
  IntegrationLoginException(this.message);
  final String message;

  @override
  String toString() => message;
}
