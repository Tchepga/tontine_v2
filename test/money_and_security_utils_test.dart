import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/utils/money_utils.dart';
import 'package:tontine_v2/src/utils/temp_password.dart';
import 'package:tontine_v2/src/utils/submit_guard.dart';

void main() {
  group('MoneyUtils', () {
    test('parse entier positif', () {
      expect(MoneyUtils.parseToApiAmount('10000'), 10000.0);
      expect(MoneyUtils.parseToApiAmount('10 000'), 10000.0);
    });

    test('rejette décimales en mode FCFA', () {
      expect(MoneyUtils.parseToApiAmount('12,5'), isNull);
      expect(MoneyUtils.parseToApiAmount('12.5'), isNull);
    });

    test('rejette zéro et négatif', () {
      expect(MoneyUtils.parseToApiAmount('0'), isNull);
      expect(MoneyUtils.parseToApiAmount('-5'), isNull);
      expect(MoneyUtils.parseToApiAmount(''), isNull);
      expect(MoneyUtils.parseToApiAmount(null), isNull);
    });

    test('validateAmountInput messages', () {
      expect(MoneyUtils.validateAmountInput(null), isNotNull);
      expect(MoneyUtils.validateAmountInput('abc'), isNotNull);
      expect(MoneyUtils.validateAmountInput('5000'), isNull);
    });
  });

  group('TempPassword', () {
    test('génère un mot de passe aléatoire de longueur donnée', () {
      final a = TempPassword.generate(length: 12);
      final b = TempPassword.generate(length: 12);
      expect(a.length, 12);
      expect(b.length, 12);
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals('changeme')));
    });
  });

  group('SubmitGuard', () {
    test('ignore les soumissions concurrentes', () async {
      final guard = SubmitGuard();
      var count = 0;

      final first = guard.run(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        count++;
        return count;
      });
      final second = guard.run(() async {
        count++;
        return count;
      });

      final results = await Future.wait([first, second]);
      expect(results[0], 1);
      expect(results[1], isNull);
      expect(count, 1);
    });
  });
}
