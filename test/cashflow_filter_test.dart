import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/enum/deposit_reason.dart';
import 'package:tontine_v2/src/providers/models/enum/deposit_type.dart';
import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import 'package:tontine_v2/src/providers/models/deposit.dart';

// Helpers
Deposit makeDeposit({
  required int id,
  required DepositType type,
  String? reasons,
  String? firstname,
  double amount = 100,
  StatusDeposit status = StatusDeposit.VALIDATED,
}) {
  return Deposit(
    id: id,
    amount: amount,
    currency: Currency.EUR,
    status: status,
    creationDate: DateTime(2026, 1, 15),
    type: type,
    reasons: reasons,
  );
}

List<Deposit> applyFilter(
  List<Deposit> deposits, {
  DepositType? selectedType,
  String searchName = '',
}) {
  return deposits.where((deposit) {
    final matchType =
        selectedType == null || deposit.type == selectedType;
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
  group('Cashflow — Filtre par type', () {
    final deposits = [
      makeDeposit(id: 1, type: DepositType.COTISATION, reasons: 'Cotisation Janvier 2026'),
      makeDeposit(id: 2, type: DepositType.COTISATION, reasons: 'Cotisation Février 2026'),
      makeDeposit(id: 3, type: DepositType.FOND,       reasons: 'Épargne collective'),
    ];

    test('Pas de filtre → tous les dépôts visibles', () {
      final result = applyFilter(deposits);
      expect(result.length, 3);
    });

    test('Filtre COTISATION → seulement les cotisations', () {
      final result = applyFilter(deposits, selectedType: DepositType.COTISATION);
      expect(result.length, 2);
      expect(result.every((d) => d.type == DepositType.COTISATION), isTrue);
    });

    test('Filtre FOND → seulement les fonds', () {
      final result = applyFilter(deposits, selectedType: DepositType.FOND);
      expect(result.length, 1);
      expect(result.first.type, DepositType.FOND);
    });
  });

  group('Cashflow — Filtre par nom', () {
    // Impossible de tester sans Member complet car author est final
    // Ces tests vérifient le comportement sans auteur
    final deposits = [
      makeDeposit(id: 1, type: DepositType.COTISATION),
    ];

    test('Recherche vide → tous les dépôts', () {
      final result = applyFilter(deposits, searchName: '');
      expect(result.length, 1);
    });

    test('Recherche sans correspondance + auteur null → aucun résultat', () {
      final result = applyFilter(deposits, searchName: 'Jean');
      expect(result.length, 0);
    });
  });

  group('DepositReason — depositReasonFromString', () {
    test('VERSEMENT reconnu', () {
      expect(depositReasonFromString('VERSEMENT'), DepositReason.VERSEMENT);
    });

    test('Insensible à la casse', () {
      expect(depositReasonFromString('versement'), DepositReason.VERSEMENT);
      expect(depositReasonFromString('Versement'), DepositReason.VERSEMENT);
    });

    test('Valeur inconnue → AUTRE', () {
      expect(depositReasonFromString('Cotisation Janvier 2026'), DepositReason.AUTRE);
    });

    test('Chaîne vide → VERSEMENT (défaut)', () {
      expect(depositReasonFromString(''), DepositReason.VERSEMENT);
    });
  });

  group('DepositType — displayName', () {
    test('COTISATION affiche Cotisation', () {
      expect(DepositType.COTISATION.displayName, 'Cotisation');
    });

    test('FOND affiche Fond', () {
      expect(DepositType.FOND.displayName, 'Fond');
    });
  });

  group('StatusDeposit — couleurs logiques', () {
    test('PENDING reconnu', () {
      expect(statusDepositFromString('PENDING'), StatusDeposit.PENDING);
    });

    test('VALIDATED reconnu', () {
      expect(statusDepositFromString('VALIDATED'), StatusDeposit.VALIDATED);
    });

    test('REJECTED reconnu', () {
      expect(statusDepositFromString('REJECTED'), StatusDeposit.REJECTED);
    });
  });
}
