import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/deposit.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import 'package:tontine_v2/src/providers/models/enum/deposit_type.dart';
import 'package:tontine_v2/src/providers/models/enum/event_type.dart';
import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';
import 'package:tontine_v2/src/providers/models/enum/status_loan.dart';
import 'package:tontine_v2/src/providers/models/event.dart';
import 'package:tontine_v2/src/providers/models/loan.dart';
import 'package:tontine_v2/src/providers/models/member.dart';
import 'package:tontine_v2/src/providers/models/tontine.dart';
import 'package:tontine_v2/src/utils/currency_utils.dart';

import 'helpers/fixtures.dart';

void main() {
  group('Deposit', () {
    test('fromJson parse un versement API', () {
      final deposit = Deposit.fromJson(depositJson(
        amount: 250,
        reasons: 'VERSEMENT',
        author: memberJson(id: 3, firstname: 'Jean'),
      ));
      expect(deposit.id, 1);
      expect(deposit.amount, 250);
      expect(deposit.type, DepositType.COTISATION);
      expect(deposit.status, StatusDeposit.VALIDATED);
      expect(deposit.author?.firstname, 'Jean');
      expect(deposit.currency, Currency.EUR);
    });

    test('displayLabel priorise comment puis reasons puis type', () {
      expect(
        makeDeposit(comment: 'Note', reasons: 'VERSEMENT').displayLabel,
        'Note',
      );
      expect(
        makeDeposit(comment: null, reasons: 'VERSEMENT').displayLabel,
        'VERSEMENT',
      );
      expect(
        makeDeposit(comment: null, reasons: null).displayLabel,
        DepositType.COTISATION.displayName,
      );
    });
  });

  group('Loan', () {
    test('fromJson parse un emprunt', () {
      final loan = Loan.fromJson(loanJson(amount: 1200, status: 'APPROVED'));
      expect(loan.amount, 1200);
      expect(loan.status, StatusLoan.APPROVED);
      expect(loan.author.firstname, 'Alice');
      expect(loan.tontineId, 1);
      expect(StatusLoan.PENDING.displayName, 'En attente');
    });
  });

  group('Event', () {
    test('fromJson parse un événement', () {
      final event = Event.fromJson(eventJson(title: 'AG', type: 'MEETING'));
      expect(event.title, 'AG');
      expect(event.type, EventType.MEETING);
      expect(event.type.displayName, 'Réunion');
      expect(event.author.firstname, 'Alice');
    });
  });

  group('Member / Tontine', () {
    test('Member.fromJson', () {
      final member = Member.fromJson(
        memberJson(id: 8, firstname: 'Sara', roles: ['PRESIDENT']),
      );
      expect(member.id, 8);
      expect(member.user?.roles?.first.name, 'PRESIDENT');
    });

    test('Tontine.fromJson avec cashFlow et membres', () {
      final tontine = Tontine.fromJson({
        'id': 1,
        'title': 'Calebasse',
        'members': [memberJson(id: 1)],
        'config': {
          'id': 1,
          'loopPeriod': 'MONTHLY',
          'countMaxMember': 12,
        },
        'cashFlow': {
          'id': 1,
          'amount': 50000,
          'currency': 'FCFA',
          'dividendes': 0,
        },
      });
      expect(tontine.title, 'Calebasse');
      expect(tontine.members, hasLength(1));
      expect(tontine.cashFlow.amount, 50000);
      expect(tontine.cashFlow.currency, Currency.FCFA);
    });
  });

  group('CurrencyUtils', () {
    test('format FCFA et EUR', () {
      final fcfa = CurrencyUtils.formatAmountForCard(10000, Currency.FCFA);
      expect(fcfa, contains('FCFA'));
      expect(fcfa, contains('10'));

      final eur = CurrencyUtils.formatAmountForCard(100, Currency.EUR);
      expect(eur, contains('100'));
    });
  });
}
