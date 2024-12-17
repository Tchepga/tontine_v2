import 'member.dart';
import 'tontine.dart';

enum EventType {
  MEETING,
  CONTRIBUTION,
  LOAN,
  SANCTION,
  OTHER
}

class Event {
  final int id;
  final String title;
  final EventType type;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final List<Member> participants;
  final Member author;
  final Tontine tontine;

  Event({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.participants,
    required this.author,
    required this.tontine,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      type: EventType.values.firstWhere(
        (e) => e.toString() == 'EventType.${json['type']}',
      ),
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      participants: (json['participants'] as List)
          .map((participant) => Member.fromJson(participant))
          .toList(),
      author: Member.fromJson(json['author']),
      tontine: Tontine.fromJson(json['tontine']),
    );
  }
} 