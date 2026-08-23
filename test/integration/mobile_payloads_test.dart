import 'package:flutter_test/flutter_test.dart';

import 'mobile_payloads.dart';

/// Vérifie la forme des payloads sans appeler l'API (toujours exécuté en CI).
void main() {
  group('MobilePayloads — forme JSON', () {
    test('createEvent contient les clés EventService', () {
      final json = MobilePayloads.createEvent(
        tontineId: 1,
        title: 'Réunion mensuelle',
        type: 'MEETING',
      );
      expect(json.keys, containsAll([
        'tontineId',
        'title',
        'type',
        'description',
        'startDate',
        'endDate',
      ]));
      expect(json['type'], 'MEETING');
      expect(json['tontineId'], 1);
    });

    test('createDeposit contient memberId et status PENDING comme edit_mouvement', () {
      final json = MobilePayloads.createDeposit(
        amount: 250,
        memberId: 42,
        cashFlowId: 7,
        status: 'PENDING',
        reasons: 'VERSEMENT',
      );
      expect(json['memberId'], 42);
      expect(json['status'], 'PENDING');
      expect(json['reasons'], 'VERSEMENT');
      expect(json['cashFlowId'], 7);
    });

    test('createMember contient champs obligatoires member_view', () {
      final json = MobilePayloads.createMember(
        firstname: 'Alice',
        lastname: 'Martin',
        phone: '+33600000000',
        country: 'FR',
      );
      expect(json.keys, containsAll(['firstname', 'lastname', 'phone', 'country']));
    });

    test('MobileRoutes pointe vers les endpoints EventService / TontineService', () {
      expect(MobileRoutes.createEvent(), '/event');
      expect(MobileRoutes.listEvents(5), '/event/tontine/5');
      expect(MobileRoutes.createDeposit(3), '/tontine/3/deposit');
      expect(MobileRoutes.attachMember(3), '/tontine/3/member');
    });

    test('registerPresident reflète CreateMemberDto de register_view', () {
      final json = MobilePayloads.registerPresident(
        firstname: 'Alice',
        lastname: 'Martin',
        phone: '+33600000000',
        password: 'TestPass123!',
        email: 'alice@example.test',
      );
      expect(
        json.keys,
        containsAll(['firstname', 'lastname', 'phone', 'country', 'password', 'email']),
      );
      expect(json.containsKey('username'), isFalse);
      expect(json['country'], 'FR');
      expect(json['password'], 'TestPass123!');
    });

    test('forgotPassword envoie usernameOrEmail comme ForgotPasswordDto', () {
      final json = MobilePayloads.forgotPassword(usernameOrEmail: 'alice@example.test');
      expect(json, {'usernameOrEmail': 'alice@example.test'});
    });

    test('resetPassword contient token + newPassword + confirmPassword', () {
      final json = MobilePayloads.resetPassword(
        token: 'reset-token',
        newPassword: 'NewPass123!',
        confirmPassword: 'NewPass123!',
      );
      expect(json.keys, containsAll(['token', 'newPassword', 'confirmPassword']));
      expect(json['token'], 'reset-token');
    });

    test('MobileRoutes pointe vers les endpoints auth publics', () {
      expect(MobileRoutes.registerPresident(), '/member/register-president');
      expect(MobileRoutes.login(), '/auth/login');
      expect(MobileRoutes.forgotPassword(), '/auth/forgot-password');
      expect(MobileRoutes.resetPassword(), '/auth/reset-password');
    });
  });
}
