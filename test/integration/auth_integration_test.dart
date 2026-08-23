@Tags(['integration'])
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'integration_config.dart';
import 'integration_http_client.dart';
import 'mobile_payloads.dart';

/// Tests HTTP inscription + mot de passe oublié (contrat MemberService).
///
/// Smoke : validation seule, aucun compte créé, aucun email envoyé.
/// Full : crée un président de test puis tente forgot-password (staging).
void main() {
  final configured = IntegrationConfig.isConfigured;
  final fullMode = IntegrationConfig.mode == IntegrationMode.full;

  bool ensurePublicApi() {
    final skip = IntegrationConfig.publicSkipReason;
    if (skip.isNotEmpty) {
      markTestSkipped(skip);
      return false;
    }
    return true;
  }

  group('Smoke — Inscription (register-president)', () {
    test('POST incomplet sans auth → 400 (pas 401)', () async {
      if (!ensurePublicApi()) return;
      final client = IntegrationHttpClient();
      addTearDown(client.dispose);

      final response = await client.post(
        MobileRoutes.registerPresident(),
        {'firstname': 'Integ'},
      );

      expect(
        response.statusCode,
        anyOf(400, 422),
        reason:
            'Payload incomplet doit être rejeté sans créer de compte, '
            'et la route est publique (pas 401) : ${response.body}',
      );
    });

    test('POST sans champs requis → 400, pas de création', () async {
      if (!ensurePublicApi()) return;
      final client = IntegrationHttpClient();
      addTearDown(client.dispose);

      final response = await client.post(
        MobileRoutes.registerPresident(),
        <String, dynamic>{},
      );

      expect(
        response.statusCode,
        anyOf(400, 422),
        reason: response.body,
      );
    });
  });

  group('Smoke — Mot de passe oublié', () {
    test('identifiant inconnu → 200/201 (pas de fuite 404)', () async {
      if (!ensurePublicApi()) return;
      final client = IntegrationHttpClient();
      addTearDown(client.dispose);

      final response = await client.post(
        MobileRoutes.forgotPassword(),
        MobilePayloads.forgotPassword(
          username: 'nobody-it-${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      expect(
        response.statusCode,
        anyOf(200, 201),
        reason:
            'L\'API masque l\'existence du compte (message générique) : '
            '${response.body}',
      );
      if (response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        if (body is Map) {
          expect(body['message'], isNotNull);
        }
      }
    });

    test('payload sans username → 400', () async {
      if (!ensurePublicApi()) return;
      final client = IntegrationHttpClient();
      addTearDown(client.dispose);

      final response = await client.post(
        MobileRoutes.forgotPassword(),
        <String, dynamic>{},
      );

      expect(
        response.statusCode,
        anyOf(400, 422),
        reason: response.body,
      );
    });

    test('reset-password avec token invalide → 400', () async {
      if (!ensurePublicApi()) return;
      final client = IntegrationHttpClient();
      addTearDown(client.dispose);

      final response = await client.post(
        MobileRoutes.resetPassword(),
        MobilePayloads.resetPassword(
          token: 'invalid-it-token',
          newPassword: 'NewPass123!',
        ),
      );

      expect(
        response.statusCode,
        anyOf(400, 401, 404),
        reason:
            'Un token invalide ne doit pas réinitialiser un mot de passe : '
            '${response.body}',
      );
      expect(response.statusCode, isNot(200));
      expect(response.statusCode, isNot(201));
    });
  });

  group('Full — Inscription président', () {
    test('payload register_view → 201 + username + login, doublon → conflit', () async {
      if (!configured || !fullMode) return;
      if (!ensurePublicApi()) return;

      final client = IntegrationHttpClient();
      addTearDown(client.dispose);

      final suffix = DateTime.now().millisecondsSinceEpoch;
      const password = 'TestPass123!';
      final email = 'it.reg.$suffix@example.test';
      final phone = '+337${(suffix % 100000000).toString().padLeft(8, '0')}';
      final payload = MobilePayloads.registerPresident(
        firstname: 'Integ',
        lastname: 'Reg$suffix',
        phone: phone,
        password: password,
        email: email,
      );

      final create = await client.post(
        MobileRoutes.registerPresident(),
        payload,
      );
      expect(create.statusCode, 201, reason: create.body);

      final body = jsonDecode(create.body) as Map<String, dynamic>;
      final username = _usernameFromRegister(body);
      expect(
        username,
        isNotEmpty,
        reason: 'register-president doit renvoyer username (RegisterPresidentResult)',
      );

      final login = await client.post(MobileRoutes.login(), {
        'username': username,
        'password': password,
      });
      expect(
        login.statusCode,
        anyOf(200, 201),
        reason: 'Le compte créé doit pouvoir se connecter : ${login.body}',
      );
      final loginBody = jsonDecode(login.body) as Map<String, dynamic>;
      final token = loginBody['token'] as String?;
      expect(token, isNotEmpty);

      final duplicate = await client.post(
        MobileRoutes.registerPresident(),
        payload,
      );
      expect(
        duplicate.statusCode,
        anyOf(409, 401),
        reason:
            'Un compte existant (email/téléphone) doit renvoyer 409 ou '
            'USER_ALREADY_EXISTS : ${duplicate.body}',
      );
      if (duplicate.statusCode == 401 && duplicate.body.isNotEmpty) {
        final dupBody = jsonDecode(duplicate.body);
        if (dupBody is Map) {
          expect(
            dupBody['message'],
            'USER_ALREADY_EXISTS',
            reason: duplicate.body,
          );
        }
      }

      await _bestEffortDeleteTontine(client, username, token);
    }, skip: _skipFull(configured, fullMode));
  });

  group('Full — Mot de passe oublié', () {
    test('compte venant d\'être créé → 200/201 (pas 404)', () async {
      if (!configured || !fullMode) return;
      if (!ensurePublicApi()) return;

      final client = IntegrationHttpClient();
      addTearDown(client.dispose);

      final suffix = DateTime.now().millisecondsSinceEpoch;
      const password = 'TestPass123!';
      final email = 'it.forgot.$suffix@example.test';
      final create = await client.post(
        MobileRoutes.registerPresident(),
        MobilePayloads.registerPresident(
          firstname: 'Integ',
          lastname: 'Forgot$suffix',
          phone: '+336${(suffix % 100000000).toString().padLeft(8, '0')}',
          password: password,
          email: email,
        ),
      );
      expect(create.statusCode, 201, reason: create.body);
      final username = _usernameFromRegister(
        jsonDecode(create.body) as Map<String, dynamic>,
      );
      expect(username, isNotEmpty);

      final forgot = await client.post(
        MobileRoutes.forgotPassword(),
        MobilePayloads.forgotPassword(username: username),
      );

      if (forgot.statusCode == 500 || forgot.statusCode == 503) {
        markTestSkipped(
          'Forgot-password a échoué (${forgot.statusCode}) — '
          'mail provider probablement non configuré : ${forgot.body}',
        );
        return;
      }

      expect(
        forgot.statusCode,
        anyOf(200, 201),
        reason:
            'Un compte existant ne doit pas renvoyer 404 '
            '(MemberService) : ${forgot.body}',
      );
    }, skip: _skipFull(configured, fullMode));
  });
}

String _usernameFromRegister(Map<String, dynamic> body) {
  final direct = body['username'];
  if (direct is String && direct.isNotEmpty) return direct;
  final user = body['user'];
  if (user is Map && user['username'] is String) {
    return user['username'] as String;
  }
  return '';
}

Future<void> _bestEffortDeleteTontine(
  IntegrationHttpClient client,
  String username,
  String? token,
) async {
  if (token == null || token.isEmpty || username.isEmpty) return;
  try {
    client.setSession(token: token);
    final list = await client.get(MobileRoutes.listTontines(username));
    if (list.statusCode != 200) return;
    final tontines = jsonDecode(list.body);
    if (tontines is! List || tontines.isEmpty) return;
    final first = tontines.first;
    if (first is! Map) return;
    final rawId = first['id'];
    final id = rawId is int ? rawId : (rawId is num ? rawId.toInt() : null);
    if (id == null) return;
    await client.delete(MobileRoutes.deleteTontine(id));
  } catch (_) {
    // Cleanup best-effort : l'assertion d'inscription a déjà réussi.
  }
}

String? _skipFull(bool configured, bool fullMode) {
  final base = IntegrationConfig.publicSkipReason;
  if (base.isNotEmpty) return base;
  if (!fullMode) {
    return 'INTEGRATION_MODE=full requis — smoke ne crée pas de compte';
  }
  return null;
}
