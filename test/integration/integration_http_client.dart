import 'dart:convert';

import 'package:http/http.dart' as http;

import 'integration_config.dart';

/// Client HTTP minimal pour tests d'intégration (sans Flutter / Provider).
class IntegrationHttpClient {
  IntegrationHttpClient({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;
  int? _tontineId;

  String get baseUrl => '${IntegrationConfig.apiBaseUrl}/api';

  String? get token => _token;
  int? get tontineId => _tontineId;

  Map<String, String> _headers({bool withTontine = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
      if (withTontine && _tontineId != null) 'tontine-id': '$_tontineId',
    };
    return headers;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? query,
    bool withTontine = false,
  }) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    return _client.get(uri, headers: _headers(withTontine: withTontine));
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool withTontine = false,
  }) {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(withTontine: withTontine),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(
    String path,
    Map<String, dynamic> body, {
    bool withTontine = false,
  }) {
    return _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers(withTontine: withTontine),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(
    String path, {
    bool withTontine = false,
  }) {
    return _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers(withTontine: withTontine),
    );
  }

  Future<void> login() async {
    if (!IntegrationConfig.credentialsConfigured) {
      throw IntegrationLoginException(
        'INTEGRATION_PASSWORD manquant.\n${IntegrationConfig.credentialsHint}',
      );
    }

    final response = await post('/auth/login', {
      'username': IntegrationConfig.username,
      'password': IntegrationConfig.password,
    });

    if (response.statusCode == 401) {
      throw IntegrationLoginException(
        'Identifiants invalides pour "${IntegrationConfig.username}" sur '
        '${IntegrationConfig.apiBaseUrl} (401 INVALID_CREDENTIAL).\n'
        '→ Utilisez un compte qui existe sur cette API (pas le seed local par défaut).\n'
        '${IntegrationConfig.credentialsHint}',
      );
    }

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw IntegrationLoginException(
        'Login échoué (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _token = data['token'] as String?;
    if (_token == null || _token!.isEmpty) {
      throw IntegrationLoginException('Login OK mais token absent dans la réponse');
    }
  }

  Future<int> resolveTontineId() async {
    if (IntegrationConfig.tontineId != null) {
      _tontineId = IntegrationConfig.tontineId;
      return _tontineId!;
    }
    final response = await get(
      '/tontine/member/${IntegrationConfig.username}',
      withTontine: false,
    );
    if (response.statusCode != 200) {
      throw StateError(
        'List tontines failed (${response.statusCode}): ${response.body}',
      );
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) {
      throw StateError(
        'Aucune tontine pour "${IntegrationConfig.username}". '
        'Créez-en une ou définissez INTEGRATION_TONTINE_ID.',
      );
    }
    final first = list.first as Map<String, dynamic>;
    _tontineId = first['id'] as int;
    return _tontineId!;
  }

  void useAuthFrom(IntegrationHttpClient other) {
    _token = other._token;
    _tontineId = other._tontineId;
  }

  void dispose() => _client.close();
}

/// Session partagée : login une fois pour toute la suite smoke.
class IntegrationSession {
  IntegrationSession._();
  static IntegrationSession? _instance;

  static IntegrationSession get instance {
    _instance ??= IntegrationSession._();
    return _instance!;
  }

  IntegrationHttpClient? client;
  String? loginFailure;

  bool get isReady => client != null && loginFailure == null;

  String? get skipReason {
    final base = IntegrationConfig.skipReason;
    if (base.isNotEmpty) return base;
    if (loginFailure != null) return loginFailure;
    return null;
  }

  Future<void> ensureLoggedIn() async {
    if (client != null && isReady) return;
    if (loginFailure != null) return;

    client ??= IntegrationHttpClient();
    try {
      await client!.login();
      await client!.resolveTontineId();
    } on IntegrationLoginException catch (e) {
      loginFailure = e.message;
    } catch (e) {
      loginFailure = e.toString();
    }
  }

  void dispose() {
    client?.dispose();
    client = null;
    _instance = null;
  }
}
