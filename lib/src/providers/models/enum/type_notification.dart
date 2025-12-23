import 'package:flutter/material.dart';

enum TypeNotification {
  DEPOSIT,
  MEMBER,
  SANCTION,
  RAPPORT,
  LOAN,
  EVENT,
  REMINDER,
  OTHER;

  String get displayName {
    switch (this) {
      case TypeNotification.DEPOSIT:
        return 'Dépôt';
      case TypeNotification.MEMBER:
        return 'Membre';
      case TypeNotification.SANCTION:
        return 'Sanction';
      case TypeNotification.RAPPORT:
        return 'Rapport';
      case TypeNotification.LOAN:
        return 'Prêt';
      case TypeNotification.EVENT:
        return 'Événement';
      case TypeNotification.REMINDER:
        return 'Rappel';
      case TypeNotification.OTHER:
        return 'Autre';
    }
  }

  Color get color {
    switch (this) {
      case TypeNotification.DEPOSIT:
        return Colors.green;
      case TypeNotification.MEMBER:
        return Colors.blue;
      case TypeNotification.SANCTION:
        return Colors.red;
      case TypeNotification.RAPPORT:
        return Colors.purple;
      case TypeNotification.LOAN:
        return Colors.orange;
      case TypeNotification.EVENT:
        return Colors.teal;
      case TypeNotification.REMINDER:
        return Colors.amber;
      case TypeNotification.OTHER:
        return Colors.grey;
    }
  }
} 