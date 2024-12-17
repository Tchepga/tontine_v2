import 'member.dart';
import 'tontine.dart';

class RapportMeeting {
  final int id;
  final String title;
  final String content;
  final Member author;
  final Tontine tontine;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RapportMeeting({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.tontine,
    required this.createdAt,
    this.updatedAt,
  });

  factory RapportMeeting.fromJson(Map<String, dynamic> json) {
    return RapportMeeting(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: Member.fromJson(json['author']),
      tontine: Tontine.fromJson(json['tontine']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
} 