import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/services/api_error_message.dart';

void main() {
  group('parseApiErrorMessage', () {
    test('extrait message string Nest', () {
      expect(
        parseApiErrorMessage('{"statusCode":400,"message":"User already exists"}'),
        'User already exists',
      );
    });

    test('extrait message liste de validation', () {
      expect(
        parseApiErrorMessage(
          '{"message":["title should not be empty","config is required"]}',
        ),
        'title should not be empty config is required',
      );
    });

    test('fallback HTTP si body vide', () {
      expect(parseApiErrorMessage('', statusCode: 500), 'Erreur HTTP 500');
    });
  });
}
