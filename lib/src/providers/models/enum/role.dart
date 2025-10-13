import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

enum Role {
  PRESIDENT,
  ACCOUNT_MANAGER,
  OFFICE_MANAGER,
  TONTINARD,
  SECRETARY,
}

Role fromStringToRole(String role) {
  return Role.values.firstWhere((r) => r.toString().split('.').last == role);
}

extension RoleExtension on Role {
  String get displayName {
    switch (this) {
      case Role.PRESIDENT:
        return 'Président';
      case Role.ACCOUNT_MANAGER:
        return 'Trésorier';
      case Role.OFFICE_MANAGER:
        return 'Gestionnaire';
      case Role.SECRETARY:
        return 'Secrétaire';
      case Role.TONTINARD:
        return 'Membre';
    }
  }

  String get description {
    switch (this) {
      case Role.PRESIDENT:
        return 'Tous les droits - Gestion complète';
      case Role.ACCOUNT_MANAGER:
        return 'Gestion de la trésorerie';
      case Role.OFFICE_MANAGER:
        return 'Validation des prêts';
      case Role.SECRETARY:
        return 'Gestion des rapports';
      case Role.TONTINARD:
        return 'Consultation et demande de prêts';
    }
  }

  IconData get icon {
    switch (this) {
      case Role.PRESIDENT:
        return Icons.stars;
      case Role.ACCOUNT_MANAGER:
        return Icons.account_balance;
      case Role.OFFICE_MANAGER:
        return Icons.business_center;
      case Role.SECRETARY:
        return Icons.description;
      case Role.TONTINARD:
        return Icons.person;
    }
  }

  Color get color {
    switch (this) {
      case Role.PRESIDENT:
        return AppColors.primary;
      case Role.ACCOUNT_MANAGER:
        return AppColors.success;
      case Role.OFFICE_MANAGER:
        return AppColors.secondary;
      case Role.SECRETARY:
        return AppColors.tertiary;
      case Role.TONTINARD:
        return AppColors.textSecondary;
    }
  }
}
