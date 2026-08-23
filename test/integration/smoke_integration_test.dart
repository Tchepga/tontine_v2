@Tags(['integration'])
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'integration_config.dart';
import 'integration_http_client.dart';

/// Tests smoke — lecture seule, safe sur prod.
void main() {
  final session = IntegrationSession.instance;

  setUpAll(() async {
    if (IntegrationConfig.isConfigured && IntegrationConfig.credentialsConfigured) {
      await session.ensureLoggedIn();
    }
  });

  tearDownAll(() {
    session.dispose();
  });

  /// Skip explicite si config ou login manquant (évite un PASS silencieux).
  bool ensureLiveSession() {
    final configReason = IntegrationConfig.skipReason;
    if (configReason.isNotEmpty) {
      markTestSkipped(configReason);
      return false;
    }
    if (!session.isReady) {
      markTestSkipped(
        session.skipReason ?? session.loginFailure ?? 'Login échoué',
      );
      return false;
    }
    return true;
  }

  group('Smoke — API reachable', () {
    test('GET /health → 200', () async {
      if (!IntegrationConfig.isConfigured) {
        markTestSkipped(IntegrationConfig.skipReason);
        return;
      }
      final client = IntegrationHttpClient();
      addTearDown(client.dispose);
      final response = await client.get('/health');
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['status'], isNotNull);
    });
  });

  group('Smoke — Auth', () {
    test('login avec INTEGRATION_USERNAME/PASSWORD', () async {
      if (!IntegrationConfig.isConfigured || !IntegrationConfig.credentialsConfigured) {
        markTestSkipped(IntegrationConfig.skipReason);
        return;
      }
      expect(
        session.isReady,
        isTrue,
        reason: session.loginFailure ??
            'Vérifiez INTEGRATION_USERNAME et INTEGRATION_PASSWORD (compte app sur cette API)',
      );
    });
  });

  group('Smoke — Tontine', () {
    test('GET tontine courante', () async {
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;

      final detail = await client.get('/tontine/$tontineId', withTontine: true);
      expect(detail.statusCode, 200, reason: detail.body);
      final tontine = jsonDecode(detail.body) as Map<String, dynamic>;
      expect(tontine['id'], tontineId);
      expect(tontine['title'], isNotEmpty);
    });
  });

  group('Smoke — Deposits paginated', () {
    test('GET deposits page 1 returns paginated shape', () async {
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;

      final response = await client.get(
        '/tontine/$tontineId/deposit',
        query: {'page': '1', 'limit': '5'},
        withTontine: true,
      );
      expect(response.statusCode, 200, reason: response.body);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['items'], isA<List>());
      expect(body['hasMore'], isA<bool>());
    });
  });

  group('Smoke — Events', () {
    test('GET events for tontine', () async {
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;

      final response = await client.get(
        '/event/tontine/$tontineId',
        withTontine: true,
      );
      expect(response.statusCode, 200, reason: response.body);
      expect(jsonDecode(response.body), isA<List>());
    });
  });

  group('Smoke — Members contributions (bureau)', () {
    test('GET members/contributions', () async {
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;

      final response = await client.get(
        '/tontine/$tontineId/members/contributions',
        withTontine: true,
      );
      expect(
        response.statusCode,
        anyOf(200, 403),
        reason: '200 si président/trésorier, 403 sinon — ${response.body}',
      );
      if (response.statusCode == 200) {
        expect(jsonDecode(response.body), isA<List>());
      }
    });
  });

  group('Smoke — Loans & notifications', () {
    test('GET loans + notifications', () async {
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;

      final loans = await client.get('/loan', withTontine: true);
      expect(loans.statusCode, 200, reason: loans.body);

      final notifs = await client.get(
        '/notification/tontine/$tontineId',
        withTontine: true,
      );
      expect(notifs.statusCode, 200, reason: notifs.body);
    });
  });

  group('Smoke — Rapports', () {
    test('GET rapports list', () async {
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;

      final response = await client.get(
        '/tontine/$tontineId/rapport',
        withTontine: true,
      );
      expect(response.statusCode, 200, reason: response.body);
      expect(jsonDecode(response.body), isA<List>());
    });
  });
}
