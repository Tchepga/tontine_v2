import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/enum/deposit_type.dart';
import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';

import 'helpers/fixtures.dart';

/// Filtrage trésorerie (même logique que CashflowView).
List applyCashflowFilter(
  List deposits, {
  DepositType? selectedType,
  String searchName = '',
}) {
  return deposits.where((deposit) {
    final matchType = selectedType == null || deposit.type == selectedType;
    final matchName = searchName.isEmpty ||
        (deposit.author?.firstname
                ?.toLowerCase()
                .contains(searchName.toLowerCase()) ??
            false) ||
        (deposit.author?.lastname
                ?.toLowerCase()
                .contains(searchName.toLowerCase()) ??
            false);
    return matchType && matchName;
  }).toList();
}

void main() {
  group('Cashflow — fonctionnalités principales', () {
    final deposits = [
      makeDeposit(
        id: 1,
        type: DepositType.COTISATION,
        author: makeMember(id: 1, firstname: 'Alice', lastname: 'Martin'),
        status: StatusDeposit.VALIDATED,
      ),
      makeDeposit(
        id: 2,
        type: DepositType.COTISATION,
        author: makeMember(id: 2, firstname: 'Bob', lastname: 'Durand'),
        status: StatusDeposit.PENDING,
      ),
      makeDeposit(
        id: 3,
        type: DepositType.FOND,
        author: makeMember(id: 1, firstname: 'Alice', lastname: 'Martin'),
      ),
    ];

    test('filtre type + recherche nom', () {
      final byType =
          applyCashflowFilter(deposits, selectedType: DepositType.COTISATION);
      expect(byType, hasLength(2));

      final byName = applyCashflowFilter(deposits, searchName: 'bob');
      expect(byName, hasLength(1));
      expect(byName.first.author?.firstname, 'Bob');
    });

    test('dépôts en attente identifiables pour validation', () {
      final pending =
          deposits.where((d) => d.status == StatusDeposit.PENDING).toList();
      expect(pending, hasLength(1));
      expect(pending.first.id, 2);
    });

    test('tri du plus récent au plus ancien', () {
      final sorted = [...deposits]
        ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
      // Même date → ordre stable relatif ; on vérifie juste le contrat de tri.
      for (var i = 0; i < sorted.length - 1; i++) {
        expect(
          sorted[i]
              .creationDate
              .isBefore(sorted[i + 1].creationDate),
          isFalse,
        );
      }
    });
  });
}
