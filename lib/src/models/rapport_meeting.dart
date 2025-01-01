import 'member.dart';

class RapportMeeting {
  final int id;
  final String title;
  final String content;
  final Member author;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? attachmentFilename;

  RapportMeeting({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.updatedAt,
    this.attachmentFilename,
  });

  factory RapportMeeting.fromJson(Map<String, dynamic> json) {
    return RapportMeeting(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: Member.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      attachmentFilename: json['attachmentFilename'] != null
          ? json['attachmentFilename'] as String
          : null,
    );
  }
} 