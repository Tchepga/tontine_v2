import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/utils/auth_deep_link.dart';

void main() {
  group('AuthDeepLink.resetTokenFromLocation', () {
    test('extrait token depuis une route Flutter', () {
      expect(
        AuthDeepLink.resetTokenFromLocation('/reset-password?token=abc123'),
        'abc123',
      );
    });

    test('extrait token depuis le scheme thoua://', () {
      expect(
        AuthDeepLink.resetTokenFromLocation(
          'thoua://reset-password?token=from-email',
        ),
        'from-email',
      );
    });

    test('accepte resetToken en query', () {
      expect(
        AuthDeepLink.resetTokenFromLocation(
          '/reset-password?resetToken=other',
        ),
        'other',
      );
    });

    test('ignore une route sans token', () {
      expect(AuthDeepLink.resetTokenFromLocation('/reset-password'), isNull);
      expect(AuthDeepLink.resetTokenFromLocation('/login'), isNull);
      expect(AuthDeepLink.resetTokenFromLocation(null), isNull);
    });
  });

  group('AuthDeepLink.resetTokenFromRouteSettings', () {
    test('priorité aux arguments String', () {
      expect(
        AuthDeepLink.resetTokenFromRouteSettings(
          const RouteArgs(
            name: '/reset-password?token=from-url',
            arguments: 'from-args',
          ),
        ),
        'from-args',
      );
    });

    test('lit arguments Map token', () {
      expect(
        AuthDeepLink.resetTokenFromRouteSettings(
          const RouteArgs(
            name: '/reset-password',
            arguments: {'token': 'map-token'},
          ),
        ),
        'map-token',
      );
    });
  });
}
