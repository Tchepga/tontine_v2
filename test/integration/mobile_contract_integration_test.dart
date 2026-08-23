import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'integration_config.dart';
import 'integration_http_client.dart';
import 'mobile_payloads.dart';

/// Tests de contrat mobile ↔ API avec payloads et routes identiques à l'app.
@Tags(['integration', 'integration-full', 'mobile-contract'])
void main() {
  final configured = IntegrationConfig.isConfigured;
  final fullMode = IntegrationConfig.mode == IntegrationMode.full;
  final session = IntegrationSession.instance;
  late IntegrationHttpClient client;

  setUpAll(() async {
    if (IntegrationConfig.isConfigured && IntegrationConfig.credentialsConfigured) {
      await session.ensureLoggedIn();
    }
  });

  tearDownAll(() {
    session.dispose();
  });

  setUp(() {
    client = IntegrationHttpClient();
    if (session.isReady) {
      client.useAuthFrom(session.client!);
    }
  });

  tearDown(() {
    client.dispose();
  });

  Future<Map<String, dynamic>> bootstrapTontine() async {
    if (!session.isReady) {
      throw StateError(session.skipReason ?? 'Session non initialisée');
    }
    final liveClient = session.client!;
    final tontineId = liveClient.tontineId!;
    final detail = await liveClient.get('/tontine/$tontineId', withTontine: true);
    expect(detail.statusCode, 200, reason: detail.body);
    return jsonDecode(detail.body) as Map<String, dynamic>;
  }

  group('Contrat — header tontine-id (EventService)', () {
    test('POST /event SANS tontine-id → 403 (cause fréquente d\'échec mobile)', () async {
      final skipReason = IntegrationConfig.skipReason;
      if (skipReason.isNotEmpty) {
        markTestSkipped(skipReason);
        return;
      }
      if (!session.isReady) {
        markTestSkipped(
          session.skipReason ?? session.loginFailure ?? 'Login échoué',
        );
        return;
      }
      final liveClient = session.client!;
      final tontineId = liveClient.tontineId!;
      final start = DateTime.now().add(const Duration(days: 3));

      final response = await liveClient.post(
        MobileRoutes.createEvent(),
        MobilePayloads.createEvent(
          tontineId: tontineId,
          title: 'probe-no-header',
          startDate: start,
        ),
        withTontine: false,
      );

      expect(
        response.statusCode,
        403,
        reason:
            'RolesGuard exige tontine-id — AuthInterceptor doit l\'envoyer: ${response.body}',
      );
    }, skip: IntegrationConfig.skipReason.isEmpty ? false : IntegrationConfig.skipReason);

    test('POST /event AVEC tontine-id + payload mobile → 201', () async {
      if (!configured || !fullMode) return;
      if (!session.isReady) {
        markTestSkipped(session.skipReason ?? 'Login échoué');
        return;
      }
      final tontine = await bootstrapTontine();
      final tontineId = tontine['id'] as int;
      final title = 'IT-mobile-event-${DateTime.now().millisecondsSinceEpoch}';
      final start = DateTime.now().add(const Duration(days: 14));

      final create = await client.post(
        MobileRoutes.createEvent(),
        MobilePayloads.createEvent(
          tontineId: tontineId,
          title: title,
          type: 'MEETING',
          description: 'Payload identique event_view → EventService',
          startDate: start,
        ),
        withTontine: true,
      );
      expect(create.statusCode, 201, reason: create.body);

      final eventId = (jsonDecode(create.body) as Map)['id'] as int;

      final list = await client.get(
        MobileRoutes.listEvents(tontineId),
        withTontine: true,
      );
      expect(list.statusCode, 200, reason: list.body);
      final events = jsonDecode(list.body) as List;
      expect(events.any((e) => (e as Map)['title'] == title), isTrue);

      final del = await client.delete(
        MobileRoutes.deleteEvent(eventId),
        withTontine: true,
      );
      expect(del.statusCode, 200, reason: del.body);
    }, skip: _skipFull(configured, fullMode));
  });

  group('Contrat — versement (edit_mouvement → CreateDepositDto)', () {
    test('POST deposit payload mobile complet → 201 puis DELETE', () async {
      if (!configured || !fullMode) return;
      if (!session.isReady) {
        markTestSkipped(session.skipReason ?? 'Login échoué');
        return;
      }
      final tontine = await bootstrapTontine();
      final tontineId = tontine['id'] as int;
      final cashFlow = tontine['cashFlow'] as Map<String, dynamic>;
      final members = tontine['members'] as List<dynamic>;
      expect(members, isNotEmpty, reason: 'Tontine sans membres');
      final memberId = (members.first as Map)['id'] as int;

      final payload = MobilePayloads.createDeposit(
        amount: 100,
        memberId: memberId,
        cashFlowId: cashFlow['id'] as int,
        currency: (cashFlow['currency'] as String?) ?? 'EUR',
        status: 'PENDING',
        reasons: 'VERSEMENT',
        creationDate: DateTime.now(),
      );

      final create = await client.post(
        MobileRoutes.createDeposit(tontineId),
        payload,
        withTontine: true,
      );
      expect(create.statusCode, 201, reason: create.body);

      final depositId = (jsonDecode(create.body) as Map)['id'] as int;

      final del = await client.delete(
        MobileRoutes.deleteDeposit(tontineId, depositId),
        withTontine: true,
      );
      expect(del.statusCode, 200, reason: del.body);
    }, skip: _skipFull(configured, fullMode));
  });

  group('Contrat — ajout membre (member_view → addMemberToTontine)', () {
    test('POST /member + PATCH /tontine/:id/member puis detach', () async {
      if (!configured || !fullMode) return;
      if (!session.isReady) {
        markTestSkipped(session.skipReason ?? 'Login échoué');
        return;
      }
      final tontine = await bootstrapTontine();
      final tontineId = tontine['id'] as int;
      final suffix = DateTime.now().millisecondsSinceEpoch;

      final createMember = await client.post(
        MobileRoutes.createMember(),
        MobilePayloads.createMember(
          firstname: 'Integ',
          lastname: 'Mobile$suffix',
          phone: '+33601020304',
          country: 'FR',
          email: 'integ$suffix@test.local',
          password: 'TestPass123!',
        ),
        withTontine: true,
      );
      expect(
        createMember.statusCode,
        anyOf(201, 403),
        reason: createMember.body,
      );
      if (createMember.statusCode != 201) return;

      final memberId =
          (jsonDecode(createMember.body) as Map<String, dynamic>)['id'] as int;

      final attach = await client.patch(
        MobileRoutes.attachMember(tontineId),
        MobilePayloads.attachMemberToTontine(memberId),
        withTontine: true,
      );
      expect(attach.statusCode, 200, reason: attach.body);

      final detach = await client.delete(
        MobileRoutes.detachMember(tontineId, memberId),
        withTontine: true,
      );
      expect(detach.statusCode, 200, reason: detach.body);
    }, skip: _skipFull(configured, fullMode));
  });
}

String? _skipFull(bool configured, bool fullMode) {
  final base = IntegrationConfig.skipReason;
  if (base.isNotEmpty) return base;
  if (!fullMode) {
    return 'INTEGRATION_MODE=full requis';
  }
  return null;
}
