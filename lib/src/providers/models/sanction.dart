import 'package:tontine_v2/src/providers/models/enum/type_sanction.dart';

import 'member.dart';
import 'tontine.dart';

class Sanction {
  final int id;
  final TypeSanction type;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final Member gulty;
  final Tontine tontine;

  Sanction({
    required this.id,
    required this.type,
    required this.description,
    this.startDate,
    this.endDate,
    required this.gulty,
    required this.tontine,
  });

  factory Sanction.fromJson(Map<String, dynamic> json) {
    return Sanction(
      id: json['id'],
      type: TypeSanction.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      gulty: Member.fromJson(json['gulty']),
      tontine: Tontine.fromJson(json['tontine']),
    );
  }
} 