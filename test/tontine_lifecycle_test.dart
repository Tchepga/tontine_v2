import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/closure_summary.dart';
import 'package:tontine_v2/src/providers/models/enum/tontine_status.dart';
import 'package:tontine_v2/src/providers/models/tontine.dart';

import 'package:tontine_v2/src/utils/tontine_title.dart';

import 'helpers/fixtures.dart';

void main() {
  group('TontineStatus', () {
    test('fromString parse ACTIVE et CLOSED', () {
      expect(tontineStatusFromString('CLOSED'), TontineStatus.CLOSED);
      expect(tontineStatusFromString('ACTIVE'), TontineStatus.ACTIVE);
      expect(tontineStatusFromString(null), TontineStatus.ACTIVE);
    });

    test('Tontine.fromJson inclut status et parentTontineId', () {
      final tontine = Tontine.fromJson(tontineJson(
        status: 'CLOSED',
        parentTontineId: 42,
        closedAt: '2026-08-23T10:00:00.000Z',
      ));
      expect(tontine.status, TontineStatus.CLOSED);
      expect(tontine.isClosed, isTrue);
      expect(tontine.parentTontineId, 42);
      expect(tontine.closedAt, isNotNull);
    });
  });

  group('ClosureSummary', () {
    test('fromJson parse reliquat et parts membres', () {
      final summary = ClosureSummary.fromJson({
        'remainingBalance': 3000,
        'currency': 'EUR',
        'memberShares': [
          {
            'memberId': 1,
            'memberName': 'Alice Dupont',
            'shareAmount': 2000,
          },
          {
            'memberId': 2,
            'shareAmount': 1000,
            'member': memberJson(id: 2, firstname: 'Bob'),
          },
        ],
      });

      expect(summary.remainingBalance, 3000);
      expect(summary.memberShares.length, 2);
      expect(summary.memberShares.first.displayName, 'Alice Dupont');
      expect(summary.memberShares.last.displayName, contains('Bob'));
    });
  });

  group('Titre de tontine unique', () {
    test('détecte un doublon insensible à la casse et aux espaces', () {
      final tontines = [
        makeTontine(id: 1, title: 'Familiale'),
        makeTontine(id: 2, title: 'Épargne'),
      ];

      expect(hasDuplicateTontineTitle(tontines, 'familiale'), isTrue);
      expect(hasDuplicateTontineTitle(tontines, '  FAMILIALE  '), isTrue);
      expect(hasDuplicateTontineTitle(tontines, 'Nouvelle'), isFalse);
    });

    test('ignore la tontine en cours de modification', () {
      final tontines = [makeTontine(id: 1, title: 'Familiale')];

      expect(
        hasDuplicateTontineTitle(tontines, 'Familiale', excludeTontineId: 1),
        isFalse,
      );
      expect(
        hasDuplicateTontineTitle(tontines, 'Familiale', excludeTontineId: 2),
        isTrue,
      );
    });

    test('propose un nom unique si le titre existe déjà', () {
      final tontines = [
        makeTontine(id: 1, title: 'Familiale (suite)'),
        makeTontine(id: 2, title: 'Familiale (suite) 2'),
      ];

      expect(
        suggestUniqueTontineTitle(tontines, 'Familiale (suite)'),
        'Familiale (suite) 3',
      );
      expect(
        suggestUniqueTontineTitle(tontines, 'Épargne'),
        'Épargne',
      );
    });
  });
}
