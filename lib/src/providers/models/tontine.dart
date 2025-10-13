import 'enum/loop_period.dart';
import 'enum/type_mouvement.dart';
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
      id: json['id'],
      order: json['order'],
      member: Member.fromJson(json['member']),
      period: json['period'] != null ? DateTime.parse(json['period']) : null,
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
  final List<PartOrder>? parts;

  ConfigTontine({
    required this.id,
    this.defaultLoanRate = 0,
    this.defaultLoanDuration,
    this.loopPeriod = LoopPeriod.MONTHLY,
    this.minLoanAmount = 0,
    this.countPersonPerMovement = 1,
    this.movementType = MovementType.ROTATIVE,
    this.countMaxMember = 12,
    this.rateMaps = const [],
    this.parts,
  });

  factory ConfigTontine.fromJson(Map<String, dynamic> json) {
    return ConfigTontine(
      id: json['id'],
      defaultLoanRate: json['defaultLoanRate']?.toDouble() ?? 0,
      defaultLoanDuration: json['defaultLoanDuration'],
      loopPeriod: LoopPeriod.values.firstWhere(
          (e) => e.toString() == 'LoopPeriod.${json['loopPeriod']}'),
      minLoanAmount: json['minLoanAmount']?.toDouble() ?? 0,
      countPersonPerMovement: json['countPersonPerMovement'] ?? 1,
      movementType: MovementType.values.firstWhere(
          (e) => e.toString() == 'MovementType.${json['movementType']}'),
      countMaxMember: json['countMaxMember'] ?? 12,
      rateMaps: json['rateMaps'] != null
          ? (json['rateMaps'] as List)
              .map((rateMap) => RateMap.fromJson(rateMap))
              .toList()
          : [],
      parts: json['partOrders'] != null
          ? (json['partOrders'] as List)
              .map((part) => PartOrder.fromJson(part))
              .toList()
          : null,
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
    return Tontine(
      id: json['id'],
      title: json['title'],
      legacy: json['legacy'],
      members: (json['members'] as List)
          .map((member) => Member.fromJson(member))
          .toList(),
      config: ConfigTontine.fromJson(json['config']),
      cashFlow: CashFlow.fromJson(json['cashFlow']),
      events: json['events'] != null
          ? (json['events'] as List)
              .map((event) => Event.fromJson(event))
              .toList()
          : [],
      rapports: json['rapports'] != null
          ? (json['rapports'] as List)
              .map((rapport) => RapportMeeting.fromJson(rapport))
              .toList()
          : [],
      sanctions: json['sanctions'] != null
          ? (json['sanctions'] as List)
              .map((sanction) => Sanction.fromJson(sanction))
              .toList()
          : [],
    );
  }
}
