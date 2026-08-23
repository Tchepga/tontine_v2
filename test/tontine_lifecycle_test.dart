import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/closure_summary.dart';
import 'package:tontine_v2/src/providers/models/enum/tontine_status.dart';
import 'package:tontine_v2/src/providers/models/tontine.dart';

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
}
