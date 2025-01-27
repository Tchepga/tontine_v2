import 'package:intl/intl.dart';
import 'enum/type_notification.dart';
import 'member.dart';

class NotificationTontine {
  final int id;
  final String message;
  final TypeNotification type;
  final DateTime createdAt;
  final bool isRead;
  final Member? target;
  final int tontineId;

  NotificationTontine({
    required this.id,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    required this.target,
    required this.tontineId,
  });

  factory NotificationTontine.fromJson(Map<String, dynamic> json) {
    return NotificationTontine(
      id: json['id'] as int,
      message: json['message'] as String,
      type: TypeNotification.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['type'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      target: json['target'] != null ? Member.fromJson(json['target'] as Map<String, dynamic>) : null,
      tontineId: json['tontineId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'target': target?.toJson(),
      'tontineId': tontineId,
    };
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  @override
  String toString() {
    return 'NotificationTontine{id: $id, message: $message, type: $type, createdAt: $createdAt, isRead: $isRead}';
  }
}
