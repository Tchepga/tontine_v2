import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/services/auth_email_telemetry.dart';

void main() {
  group('AuthEmailTelemetry', () {
    test('distingue email et identifiant', () {
      expect(AuthEmailTelemetry.identifierKind('alice.martin'), 'username');
      expect(AuthEmailTelemetry.identifierKind('alice@example.com'), 'email');
    });

    test('extrait le domaine sans exposer la boîte', () {
      expect(AuthEmailTelemetry.emailDomain('Alice.Martin@Gmail.com'), 'gmail.com');
      expect(AuthEmailTelemetry.emailDomain('prenom.nom'), isNull);
    });

    test('fingerprint stable et indépendant de la casse', () {
      expect(
        AuthEmailTelemetry.fingerprint('Alice@Example.com'),
        AuthEmailTelemetry.fingerprint('alice@example.com'),
      );
      expect(
        AuthEmailTelemetry.fingerprint('alice@example.com'),
        isNot(AuthEmailTelemetry.fingerprint('bob@example.com')),
      );
    });

    test('parseBody et emailSentOf distinguent absent / true / false', () {
      expect(AuthEmailTelemetry.emailSentOf(null), isNull);
      expect(
        AuthEmailTelemetry.emailSentOf({'message': 'ok'}),
        isNull,
      );
      expect(
        AuthEmailTelemetry.emailSentOf({'emailSent': true}),
        isTrue,
      );
      expect(
        AuthEmailTelemetry.emailSentOf({'emailSent': false}),
        isFalse,
      );
    });

    test('apiMessageOf accepte string ou liste', () {
      expect(
        AuthEmailTelemetry.apiMessageOf({'message': 'hello'}),
        'hello',
      );
      expect(
        AuthEmailTelemetry.apiMessageOf({
          'message': ['a', 'b'],
        }),
        'a b',
      );
    });
  });
}
