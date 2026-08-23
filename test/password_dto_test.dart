import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/screen/services/dto/password_dto.dart';

void main() {
  group('Password DTOs — contrat API', () {
    test('ForgotPasswordDto envoie username (email ou identifiant)', () {
      final json = ForgotPasswordDto(email: 'alice.martin').toJson();
      expect(json, {'username': 'alice.martin'});
      expect(json.containsKey('usernameOrEmail'), isFalse);
    });

    test('ResetPasswordDto n\'envoie pas confirmPassword', () {
      final json = ResetPasswordDto(
        token: 'tok',
        newPassword: 'NewPass123!',
        confirmPassword: 'NewPass123!',
      ).toJson();
      expect(json, {
        'token': 'tok',
        'newPassword': 'NewPass123!',
      });
      expect(json.containsKey('confirmPassword'), isFalse);
    });
  });
}
