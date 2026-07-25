import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/enum/loop_period.dart';
import 'package:tontine_v2/src/providers/models/tontine.dart';
import 'package:tontine_v2/src/utils/part_order_utils.dart';
import 'package:tontine_v2/src/widgets/circular_order_card.dart';

import 'helpers/fixtures.dart';

void main() {
  group('PartOrder.fromJson', () {
    test('parse avec membre nested', () {
      final partOrder = PartOrder.fromJson({
        'id': 10,
        'order': 2,
        'period': '2026-07-01T00:00:00.000Z',
        'member': memberJson(id: 42, firstname: 'Bob', lastname: 'Durand'),
      });
      expect(partOrder.id, 10);
      expect(partOrder.order, 2);
      expect(partOrder.member.id, 42);
      expect(partOrder.member.firstname, 'Bob');
      expect(partOrder.period?.month, 7);
    });

    test('parse avec memberId seul (sans nested member)', () {
      final partOrder = PartOrder.fromJson({
        'id': 3,
        'order': 1,
        'memberId': 99,
        'period': '2026-08-01T00:00:00.000Z',
      });
      expect(partOrder.memberId, 99);
      expect(partOrder.member.firstname, isNull);
    });
  });

  group('enrichPartOrders', () {
    test('enrichit le nom depuis la liste des membres', () {
      final stub = PartOrder.fromJson({
        'id': 1,
        'order': 1,
        'memberId': 7,
      });
      final members = [
        makeMember(id: 7, firstname: 'Claire', lastname: 'Ngono'),
      ];
      final enriched = enrichPartOrders([stub], members);
      expect(enriched.single.member.firstname, 'Claire');
      expect(memberDisplayName(enriched.single.member), 'Claire Ngono');
    });

    test('trie par order croissant', () {
      final parts = [
        PartOrder.fromJson({'id': 2, 'order': 3, 'memberId': 1}),
        PartOrder.fromJson({'id': 1, 'order': 1, 'memberId': 2}),
      ];
      final enriched =
          enrichPartOrders(parts, [makeMember(id: 1), makeMember(id: 2)]);
      expect(enriched.map((p) => p.order).toList(), [1, 3]);
    });
  });

  group('resolveCurrentAndNextPartOrders', () {
    final now = DateTime(2026, 7, 15);

    test('liste vide → null/null', () {
      final result = resolveCurrentAndNextPartOrders(
        parts: const [],
        loopPeriod: LoopPeriod.MONTHLY,
        now: now,
      );
      expect(result['current'], isNull);
      expect(result['next'], isNull);
    });

    test('période mensuelle courante + suivante', () {
      final parts = [
        makePartOrder(
          id: 1,
          order: 1,
          member: makeMember(id: 1, firstname: 'Alice'),
          period: DateTime(2026, 7, 1),
        ),
        makePartOrder(
          id: 2,
          order: 2,
          member: makeMember(id: 2, firstname: 'Bob'),
          period: DateTime(2026, 8, 1),
        ),
      ];

      final result = resolveCurrentAndNextPartOrders(
        parts: parts,
        loopPeriod: LoopPeriod.MONTHLY,
        now: now,
      );

      expect(result['current']?.member.firstname, 'Alice');
      expect(result['next']?.member.firstname, 'Bob');
    });

    test('boucle : dernière part → suivante = première', () {
      final parts = [
        makePartOrder(
          id: 1,
          order: 1,
          member: makeMember(id: 1, firstname: 'A'),
          period: DateTime(2026, 6, 1),
        ),
        makePartOrder(
          id: 2,
          order: 2,
          member: makeMember(id: 2, firstname: 'B'),
          period: DateTime(2026, 7, 1),
        ),
      ];

      final result = resolveCurrentAndNextPartOrders(
        parts: parts,
        loopPeriod: LoopPeriod.MONTHLY,
        now: now,
      );

      expect(result['current']?.member.firstname, 'B');
      expect(result['next']?.member.firstname, 'A');
    });

    test('aucune part courante → prochain à venir', () {
      final parts = [
        makePartOrder(
          id: 1,
          order: 1,
          member: makeMember(id: 1, firstname: 'Futur'),
          period: DateTime(2026, 9, 1),
        ),
      ];

      final result = resolveCurrentAndNextPartOrders(
        parts: parts,
        loopPeriod: LoopPeriod.MONTHLY,
        now: now,
      );

      expect(result['current'], isNull);
      expect(result['next']?.member.firstname, 'Futur');
    });

    test('isPeriodMatching DAILY', () {
      expect(
        isPeriodMatching(
          DateTime(2026, 7, 15),
          DateTime(2026, 7, 15, 23),
          LoopPeriod.DAILY,
        ),
        isTrue,
      );
      expect(
        isPeriodMatching(
          DateTime(2026, 7, 15),
          DateTime(2026, 7, 16),
          LoopPeriod.DAILY,
        ),
        isFalse,
      );
    });
  });

  group('memberDisplayName', () {
    test('prénom + nom', () {
      expect(
        memberDisplayName(makeMember(firstname: 'Ada', lastname: 'Lovelace')),
        'Ada Lovelace',
      );
    });

    test('fallback username puis id', () {
      expect(
        memberDisplayName(
          makeMember(firstname: null, lastname: null, username: 'ada'),
        ),
        'ada',
      );
      expect(
        memberDisplayName(
          makeMember(
            id: 12,
            firstname: null,
            lastname: null,
            username: null,
          ),
        ),
        'Membre #12',
      );
    });
  });
}
