import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import 'package:tontine_v2/src/providers/models/enum/deposit_type.dart';
import 'package:tontine_v2/src/providers/models/enum/loop_period.dart';
import 'package:tontine_v2/src/providers/models/enum/role.dart';
import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';
import 'package:tontine_v2/src/providers/models/member.dart';
import 'package:tontine_v2/src/providers/models/tontine.dart';
import 'package:tontine_v2/src/providers/models/cashflow.dart';
import 'package:tontine_v2/src/providers/models/deposit.dart';

Member makeMember({
  int id = 1,
  String email = 'user@test.com',
  String? firstname = 'Alice',
  String? lastname = 'Martin',
  List<Role> roles = const [Role.TONTINARD],
  String? username = 'alice',
}) {
  return Member(
    id: id,
    email: email,
    firstname: firstname,
    lastname: lastname,
    phone: '+33600000000',
    avatar: '',
    country: 'FR',
    user: User(
      username: username,
      roles: roles,
    ),
  );
}

PartOrder makePartOrder({
  int id = 1,
  int order = 1,
  Member? member,
  DateTime? period,
}) {
  return PartOrder(
    id: id,
    order: order,
    member: member ?? makeMember(id: id),
    period: period,
  );
}

Tontine makeTontine({
  int id = 1,
  String title = 'Tontine Test',
  List<Member>? members,
  List<PartOrder>? parts,
  LoopPeriod loopPeriod = LoopPeriod.MONTHLY,
  double cashAmount = 1000,
}) {
  return Tontine(
    id: id,
    title: title,
    members: members ?? [makeMember()],
    config: ConfigTontine(
      id: 1,
      loopPeriod: loopPeriod,
      parts: parts,
    ),
    cashFlow: CashFlow(
      id: 1,
      amount: cashAmount,
      currency: Currency.EUR,
      dividendes: 0,
    ),
  );
}

Deposit makeDeposit({
  int id = 1,
  double amount = 100,
  DepositType type = DepositType.COTISATION,
  StatusDeposit status = StatusDeposit.VALIDATED,
  Member? author,
  String? reasons,
  String? comment,
  DateTime? creationDate,
}) {
  return Deposit(
    id: id,
    amount: amount,
    currency: Currency.EUR,
    status: status,
    creationDate: creationDate ?? DateTime(2026, 7, 15),
    type: type,
    author: author,
    reasons: reasons,
    comment: comment,
  );
}

Map<String, dynamic> memberJson({
  int id = 1,
  String firstname = 'Alice',
  String lastname = 'Martin',
  List<String> roles = const ['TONTINARD'],
}) {
  return {
    'id': id,
    'email': 'alice@test.com',
    'firstname': firstname,
    'lastname': lastname,
    'phone': '+33600000000',
    'avatar': '',
    'country': 'FR',
    'user': {
      'username': 'alice',
      'roles': roles,
    },
  };
}

Map<String, dynamic> depositJson({
  int id = 1,
  double amount = 100,
  String type = 'COTISATION',
  String status = 'VALIDATED',
  String? reasons,
  Map<String, dynamic>? author,
}) {
  return {
    'id': id,
    'amount': amount,
    'currency': 'EUR',
    'status': status,
    'creationDate': '2026-07-15T10:00:00.000Z',
    'type': type,
    if (reasons != null) 'reasons': reasons,
    if (author != null) 'author': author,
  };
}

Map<String, dynamic> loanJson({
  int id = 1,
  double amount = 500,
  String status = 'PENDING',
}) {
  return {
    'id': id,
    'amount': amount,
    'currency': 'EUR',
    'interestRate': 5.0,
    'redemptionDate': '2026-12-01T00:00:00.000Z',
    'status': status,
    'author': memberJson(),
    'tontineId': 1,
    'voters': [],
  };
}

Map<String, dynamic> eventJson({
  int id = 1,
  String title = 'Assemblée',
  String type = 'MEETING',
}) {
  return {
    'id': id,
    'title': title,
    'type': type,
    'description': 'Réunion mensuelle',
    'startDate': '2026-07-20T18:00:00.000Z',
    'endDate': '2026-07-20T20:00:00.000Z',
    'participants': [],
    'author': memberJson(),
  };
}
