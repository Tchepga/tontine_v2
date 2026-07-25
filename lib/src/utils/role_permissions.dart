import '../providers/models/enum/role.dart';
import '../providers/models/member.dart';
import '../providers/models/tontine.dart';

/// Rôles d'un membre dans une tontine (scopes MemberRole), pas User.roles global.
List<Role> rolesForMemberInTontine(Tontine? tontine, int? memberId) {
  if (memberId == null || tontine == null) {
    return const [Role.TONTINARD];
  }
  for (final member in tontine.members) {
    if (member.id == memberId) {
      final roles = member.user?.roles;
      if (roles == null || roles.isEmpty) {
        return const [Role.TONTINARD];
      }
      return roles;
    }
  }
  return const [Role.TONTINARD];
}

/// Validation / édition trésorerie (dépôts).
bool canValidateDeposits(List<Role> roles) {
  return roles.any((role) =>
      role == Role.PRESIDENT ||
      role == Role.VICE_PRESIDENT ||
      role == Role.ACCOUNT_MANAGER);
}

/// Alias métier pour la gestion trésorerie (mêmes droits que validation).
bool canManageTreasury(List<Role> roles) => canValidateDeposits(roles);

/// Gestion du statut des emprunts (dont OFFICE_MANAGER).
bool canManageLoans(List<Role> roles) {
  return roles.any((role) =>
      role == Role.ACCOUNT_MANAGER ||
      role == Role.PRESIDENT ||
      role == Role.VICE_PRESIDENT ||
      role == Role.OFFICE_MANAGER);
}

/// Création / édition des rapports.
bool canManageReports(List<Role> roles) {
  return roles.any((role) =>
      role == Role.PRESIDENT ||
      role == Role.VICE_PRESIDENT ||
      role == Role.SECRETARY ||
      role == Role.ACCOUNT_MANAGER ||
      role == Role.OFFICE_MANAGER);
}

bool memberHasRole(Member? member, Role role) {
  return member?.user?.roles?.contains(role) ?? false;
}
