import 'package:tontine_v2/src/screen/services/dto/member_dto.dart';

import '../../../providers/models/enum/currency.dart';
import '../../../providers/models/enum/loop_period.dart';
import '../../../providers/models/enum/type_mouvement.dart';
import '../../../providers/models/tontine.dart';

class CreateConfigTontineDto {
  final double defaultLoanRate;
  final int defaultLoanDuration;
  final LoopPeriod loopPeriod;
  final double minLoanAmount;
  final int countPersonPerMovement;
  final MovementType movementType;
  final List<RateMap> rateMaps;
  final int countMaxMember;


  CreateConfigTontineDto({
    required this.defaultLoanRate,
    required this.defaultLoanDuration,
    required this.loopPeriod,
    required this.minLoanAmount,
    required this.countPersonPerMovement,
    required this.movementType,
    this.rateMaps = const [],
    required this.countMaxMember,
  });

  Map<String, dynamic> toJson() {
    return {
      'defaultLoanRate': defaultLoanRate,
      'defaultLoanDuration': defaultLoanDuration,
      'loopPeriod': loopPeriod.toString().split('.').last,
      'minLoanAmount': minLoanAmount,
      'countPersonPerMovement': countPersonPerMovement,
      'movementType': movementType.toString().split('.').last,
      'rateMaps': rateMaps.map((rateMap) => rateMap.toJson()).toList(),
      'countMaxMember': countMaxMember,
    };
  }
}

class CreateTontineDto {
  final String title;
  final String? legacy;
  final List<CreateMemberDto> memberDtos;
  final CreateConfigTontineDto config;
  final Currency currency;

  CreateTontineDto({
    required this.title,
    this.legacy,
    required this.memberDtos,
    required this.config,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (legacy != null) 'legacy': legacy,
      'members': memberDtos.map((memberDto) => memberDto.toJson()).toList(),
      'config': config.toJson(),
      'currency': currency.toString().split('.').last,
    };
  }
}
