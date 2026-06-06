import 'enum/loop_period.dart';
import 'enum/type_mouvement.dart';
import 'enum/system_type.dart';
import 'enum/currency.dart';
import 'member.dart';
import 'cashflow.dart';
import 'event.dart';
import 'rapport_meeting.dart';
import 'sanction.dart';

class RateMap {
  final int id;
  final double minAmount;
  final double maxAmount;
  final double rate;

  RateMap({
    required this.id,
    required this.minAmount,
    required this.maxAmount,
    required this.rate,
  });

  factory RateMap.fromJson(Map<String, dynamic> json) {
    return RateMap(
      id: json['id'],
      minAmount: json['minAmount'],
      maxAmount: json['maxAmount'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'rate': rate,
    };
  }
}

class PartOrder {
  final int id;
  final int order;
  final Member member;
  final DateTime? period;

  PartOrder({
    required this.id,
    required this.order,
    required this.member,
    this.period,
  });

  factory PartOrder.fromJson(Map<String, dynamic> json) {
    return PartOrder(
      id: json['id'] ?? 0,
      order: json['order'] ?? 0,
      member: json['member'] is Map
          ? Member.fromJson(Map<String, dynamic>.from(json['member'] as Map))
          : Member(
              email: '',
              firstname: null,
              lastname: null,
              phone: null,
              avatar: null,
              country: null,
              user: null,
            ),
      period: json['period'] is String
          ? DateTime.tryParse(json['period'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'member': member.toJson(),
      'period': period?.toIso8601String(),
    };
  }
}

class ConfigTontine {
  final int id;
  final double defaultLoanRate;
  final int? defaultLoanDuration;
  final LoopPeriod loopPeriod;
  final List<RateMap> rateMaps;
  final double minLoanAmount;
  final int countPersonPerMovement;
  final MovementType movementType;
  final int countMaxMember;
  final SystemType systemType;
  final List<PartOrder>? parts;
  /// Active le rappel fin de mois pour les versements manquants
  /// (notification aux membres n'ayant pas versé).
  final bool reminderMissingDepositsEnabled;

  ConfigTontine({
    required this.id,
    this.defaultLoanRate = 0,
    this.defaultLoanDuration,
    this.loopPeriod = LoopPeriod.MONTHLY,
    this.minLoanAmount = 0,
    this.countPersonPerMovement = 1,
    this.movementType = MovementType.ROTATIVE,
    this.countMaxMember = 12,
    this.systemType = SystemType.PART,
    this.rateMaps = const [],
    this.parts,
    this.reminderMissingDepositsEnabled = false,
  });

  factory ConfigTontine.fromJson(Map<String, dynamic> json) {
    return ConfigTontine(
      id: json['id'] ?? 0,
      defaultLoanRate: json['defaultLoanRate']?.toDouble() ?? 0,
      defaultLoanDuration: json['defaultLoanDuration'],
      loopPeriod: _parseLoopPeriod(json['loopPeriod']),
      minLoanAmount: json['minLoanAmount']?.toDouble() ?? 0,
      countPersonPerMovement: json['countPersonPerMovement'] ?? 1,
      movementType: _parseMovementType(json['movementType']),
      countMaxMember: json['countMaxMember'] ?? 12,
      systemType: json['systemType'] != null
          ? systemTypeFromString(json['systemType'])
          : SystemType.PART,
      rateMaps: json['rateMaps'] is List
          ? (json['rateMaps'] as List)
              .map((rateMap) => RateMap.fromJson(
                  Map<String, dynamic>.from(rateMap as Map)))
              .toList()
          : [],
      parts: json['partOrders'] is List
          ? (json['partOrders'] as List)
              .map((part) => PartOrder.fromJson(
                  Map<String, dynamic>.from(part as Map)))
              .toList()
          : null,
      reminderMissingDepositsEnabled: (json['reminderMissingDepositsEnabled'] ??
              json['reminder_missing_deposits_enabled'] ??
              false) ==
          true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'defaultLoanRate': defaultLoanRate,
      'defaultLoanDuration': defaultLoanDuration,
      'loopPeriod': loopPeriod.toString(),
      'rateMaps': rateMaps.map((rateMap) => rateMap.toJson()).toList(),
      'minLoanAmount': minLoanAmount,
      'countPersonPerMovement': countPersonPerMovement,
      'movementType': movementType.toString(),
      'countMaxMember': countMaxMember,
      'systemType': systemType.value,
      'reminderMissingDepositsEnabled': reminderMissingDepositsEnabled,
    };
  }
}

class Tontine {
  final int id;
  final String title;
  final String? legacy;
  final List<Member> members;
  final ConfigTontine config;
  final CashFlow cashFlow;
  final List<Event> events;
  List<RapportMeeting> rapports;
  final List<Sanction> sanctions;
  final bool isSelected;

  Tontine({
    required this.id,
    required this.title,
    this.legacy,
    required this.members,
    required this.config,
    required this.cashFlow,
    this.events = const [],
    this.rapports = const [],
    this.sanctions = const [],
    this.isSelected = false,
  });

  factory Tontine.fromJson(Map<String, dynamic> json) {
    final cashFlowJson = json['cashFlow'] ?? json['cash_flow'];
    return Tontine(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      legacy: json['legacy']?.toString(),
      members: json['members'] is List
          ? (json['members'] as List)
              .map((member) =>
                  Member.fromJson(Map<String, dynamic>.from(member as Map)))
              .toList()
          : [],
      config: json['config'] is Map
          ? ConfigTontine.fromJson(
              Map<String, dynamic>.from(json['config'] as Map))
          : ConfigTontine(id: 0),
      cashFlow: cashFlowJson is Map
          ? CashFlow.fromJson(Map<String, dynamic>.from(cashFlowJson))
          : CashFlow(
              id: 0,
              amount: 0,
              currency: Currency.EUR,
              dividendes: 0,
            ),
      events: json['events'] is List
          ? (json['events'] as List)
              .map((event) => Event.fromJson(
                  Map<String, dynamic>.from(event as Map)))
              .toList()
          : [],
      rapports: json['rapports'] is List
          ? (json['rapports'] as List)
              .map((rapport) => RapportMeeting.fromJson(
                  Map<String, dynamic>.from(rapport as Map)))
              .toList()
          : [],
      sanctions: json['sanctions'] is List
          ? (json['sanctions'] as List)
              .map((sanction) => Sanction.fromJson(
                  Map<String, dynamic>.from(sanction as Map)))
              .toList()
          : [],
    );
  }
}

LoopPeriod _parseLoopPeriod(dynamic value) {
  if (value == null) return LoopPeriod.MONTHLY;
  final name = value.toString().split('.').last.toUpperCase();
  return LoopPeriod.values.firstWhere(
    (e) => e.name == name,
    orElse: () => LoopPeriod.MONTHLY,
  );
}

MovementType _parseMovementType(dynamic value) {
  if (value == null) return MovementType.ROTATIVE;
  final name = value.toString().split('.').last.toUpperCase();
  return MovementType.values.firstWhere(
    (e) => e.name == name,
    orElse: () => MovementType.ROTATIVE,
  );
}
