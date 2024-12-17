import '../../../models/enum/event_type.dart';

class CreateEventDto {
  final int tontineId;
  final String title;
  final EventType type;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int>? participants;

  CreateEventDto({
    required this.tontineId,
    required this.title,
    required this.type,
    required this.description,
    this.startDate,
    this.endDate,
    this.participants,
  });

  Map<String, dynamic> toJson() {
    return {
      'tontineId': tontineId,
      'title': title,
      'type': type.toString().split('.').last,
      'description': description,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (participants != null) 'participants': participants,
    };
  }
} 