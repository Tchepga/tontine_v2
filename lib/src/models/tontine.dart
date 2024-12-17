import 'member.dart';
import 'cashflow.dart';
import 'event.dart';
import 'rapport_meeting.dart';
import 'sanction.dart';

enum MovementType { ROTATIVE, CUMULATIVE }
enum LoopPeriod { DAILY, WEEKLY, MONTHLY }

class ConfigTontine {
  final int id;
  final double defaultLoanRate;
  final int? defaultLoanDuration;
  final LoopPeriod loopPeriod;
  final double minLoanAmount;
  final int countPersonPerMovement;
  final MovementType movementType;
  final int countMaxMember;

  ConfigTontine({
    required this.id,
    this.defaultLoanRate = 0,
    this.defaultLoanDuration,
    this.loopPeriod = LoopPeriod.MONTHLY,
    this.minLoanAmount = 0,
    this.countPersonPerMovement = 1,
    this.movementType = MovementType.ROTATIVE,
    this.countMaxMember = 12,
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
    );
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
  final List<RapportMeeting> rapports;
  final List<Sanction> sanctions;

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