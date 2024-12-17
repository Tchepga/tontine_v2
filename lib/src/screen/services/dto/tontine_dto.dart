


import '../../../models/enum/currency.dart';
import '../../../models/enum/loop_period.dart';
import '../../../models/enum/type_mouvement.dart';

class CreateConfigTontineDto {
  final double defaultLoanRate;
  final int defaultLoanDuration;
  final LoopPeriod loopPeriod;
  final double minLoanAmount;
  final int countPersonPerMovement;
  final MovementType movementType;

  CreateConfigTontineDto({
    required this.defaultLoanRate,
    required this.defaultLoanDuration,
    required this.loopPeriod,
    required this.minLoanAmount,
    required this.countPersonPerMovement,
    required this.movementType,
  });

  Map<String, dynamic> toJson() {
    return {
      'defaultLoanRate': defaultLoanRate,
      'defaultLoanDuration': defaultLoanDuration,
      'loopPeriod': loopPeriod.toString().split('.').last,
      'minLoanAmount': minLoanAmount,
      'countPersonPerMovement': countPersonPerMovement,
      'movementType': movementType.toString().split('.').last,
    };
  }
}

class CreateTontineDto {
  final String title;
  final String? legacy;
  final List<int> memberIds;  // On utilise les IDs des membres plutôt que CreateMemberDto
  final CreateConfigTontineDto config;
  final Currency currency;

  CreateTontineDto({
    required this.title,
    this.legacy,
    required this.memberIds,
    required this.config,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (legacy != null) 'legacy': legacy,
      'members': memberIds,
      'config': config.toJson(),
      'currency': currency.toString().split('.').last,
    };
  }
}
