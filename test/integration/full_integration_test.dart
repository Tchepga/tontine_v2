@Tags(['integration', 'integration-full'])
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'integration_config.dart';
import 'integration_http_client.dart';

/// Tests full — création + nettoyage. Local ou staging uniquement.
void main() {
  final configured = IntegrationConfig.isConfigured;
  final fullMode = IntegrationConfig.mode == IntegrationMode.full;
  final session = IntegrationSession.instance;

  setUpAll(() async {
    if (IntegrationConfig.isConfigured && IntegrationConfig.credentialsConfigured) {
      await session.ensureLoggedIn();
    }
  });

  tearDownAll(() {
    session.dispose();
  });

  bool ensureLiveSession() {
    final skip = IntegrationConfig.skipReason;
    if (skip.isNotEmpty) {
      markTestSkipped(skip);
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

  group('Full — Event CRUD', () {
    test('create event then delete', () async {
      if (!configured || !fullMode) return;
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;
      final title = 'IT-event-${DateTime.now().millisecondsSinceEpoch}';
      final start = DateTime.now().add(const Duration(days: 7));

      final create = await client.post(
        '/event',
        {
          'tontineId': tontineId,
          'title': title,
          'type': 'MEETING',
          'description': 'Integration test event',
          'startDate': start.toIso8601String(),
          'endDate': start.add(const Duration(hours: 2)).toIso8601String(),
        },
        withTontine: true,
      );
      expect(create.statusCode, 201, reason: create.body);
      final event = jsonDecode(create.body) as Map<String, dynamic>;
      final eventId = event['id'] as int;

      final list = await client.get('/event/tontine/$tontineId', withTontine: true);
      expect(list.statusCode, 200);
      final events = jsonDecode(list.body) as List<dynamic>;
      expect(events.any((e) => (e as Map)['id'] == eventId), isTrue);

      final del = await client.delete('/event/$eventId', withTontine: true);
      expect(del.statusCode, 200, reason: del.body);
    }, skip: _skipFull(configured, fullMode));
  });

  group('Full — Deposit CRUD', () {
    test('create deposit then delete', () async {
      if (!configured || !fullMode) return;
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;

      final tontine = jsonDecode(
        (await client.get('/tontine/$tontineId', withTontine: true)).body,
      ) as Map<String, dynamic>;
      final cashFlow = tontine['cashFlow'] as Map<String, dynamic>;
      final memberId = (tontine['members'] as List).first['id'] as int;

      final create = await client.post(
        '/tontine/$tontineId/deposit',
        {
          'amount': 100,
          'currency': 'EUR',
          'memberId': memberId,
          'status': 'PENDING',
          'cashFlowId': cashFlow['id'],
          'reasons': 'VERSEMENT',
        },
        withTontine: true,
      );
      expect(create.statusCode, 201, reason: create.body);
      final deposit = jsonDecode(create.body) as Map<String, dynamic>;
      final depositId = deposit['id'] as int;

      final del = await client.delete(
        '/tontine/$tontineId/deposit/$depositId',
        withTontine: true,
      );
      expect(del.statusCode, 200, reason: del.body);
    }, skip: _skipFull(configured, fullMode));
  });

  group('Full — Add member to tontine', () {
    test('add member then remove', () async {
      if (!configured || !fullMode) return;
      if (!ensureLiveSession()) return;
      final client = session.client!;
      final tontineId = client.tontineId!;
      final suffix = DateTime.now().millisecondsSinceEpoch;

      final createMember = await client.post(
        '/member',
        {
          'firstname': 'Test',
          'lastname': 'Integration$suffix',
          'phone': '+33600000099',
          'country': 'FR',
          'email': 'it$suffix@test.local',
          'password': 'TestPass123!',
        },
        withTontine: true,
      );
      expect(
        createMember.statusCode,
        anyOf(201, 403),
        reason: createMember.body,
      );
      if (createMember.statusCode != 201) return;

      final member = jsonDecode(createMember.body) as Map<String, dynamic>;
      final memberId = member['id'] as int;

      final attach = await client.patch(
        '/tontine/$tontineId/member',
        {'memberId': memberId},
        withTontine: true,
      );
      expect(attach.statusCode, 200, reason: attach.body);

      final detach = await client.delete(
        '/tontine/$tontineId/member/$memberId',
        withTontine: true,
      );
      expect(detach.statusCode, 200, reason: detach.body);
    }, skip: _skipFull(configured, fullMode));
  });
}

String? _skipFull(bool configured, bool fullMode) {
  if (!configured) return IntegrationConfig.skipReason;
  if (!fullMode) {
    return 'INTEGRATION_MODE=full requis — smoke ne crée pas de données';
  }
  return null;
}
