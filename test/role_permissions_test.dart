import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/enum/role.dart';
import 'package:tontine_v2/src/utils/role_permissions.dart';

import 'helpers/fixtures.dart';

void main() {
  group('rolesForMemberInTontine', () {
    test('membre inconnu / null → TONTINARD', () {
      final tontine = makeTontine(members: [makeMember(id: 1)]);
      expect(rolesForMemberInTontine(null, 1), [Role.TONTINARD]);
      expect(rolesForMemberInTontine(tontine, null), [Role.TONTINARD]);
      expect(rolesForMemberInTontine(tontine, 999), [Role.TONTINARD]);
    });

    test('retourne les rôles du membre dans la tontine', () {
      final president = makeMember(
        id: 5,
        roles: [Role.PRESIDENT, Role.ACCOUNT_MANAGER],
      );
      final tontine = makeTontine(members: [president]);
      expect(
        rolesForMemberInTontine(tontine, 5),
        [Role.PRESIDENT, Role.ACCOUNT_MANAGER],
      );
    });

    test('rôles vides → TONTINARD', () {
      final member = makeMember(id: 2, roles: const []);
      final tontine = makeTontine(members: [member]);
      expect(rolesForMemberInTontine(tontine, 2), [Role.TONTINARD]);
    });
  });

  group('canValidateDeposits / canManageTreasury', () {
    test('président, VP, trésorier autorisés', () {
      expect(canValidateDeposits([Role.PRESIDENT]), isTrue);
      expect(canValidateDeposits([Role.VICE_PRESIDENT]), isTrue);
      expect(canValidateDeposits([Role.ACCOUNT_MANAGER]), isTrue);
      expect(canManageTreasury([Role.ACCOUNT_MANAGER]), isTrue);
    });

    test('simple membre et secrétaire refusés', () {
      expect(canValidateDeposits([Role.TONTINARD]), isFalse);
      expect(canValidateDeposits([Role.SECRETARY]), isFalse);
      expect(canValidateDeposits([Role.OFFICE_MANAGER]), isFalse);
    });
  });

  group('canManageLoans', () {
    test('bureau + trésorerie + OFFICE_MANAGER', () {
      expect(canManageLoans([Role.PRESIDENT]), isTrue);
      expect(canManageLoans([Role.VICE_PRESIDENT]), isTrue);
      expect(canManageLoans([Role.ACCOUNT_MANAGER]), isTrue);
      expect(canManageLoans([Role.OFFICE_MANAGER]), isTrue);
    });

    test('tontinard et secrétaire refusés', () {
      expect(canManageLoans([Role.TONTINARD]), isFalse);
      expect(canManageLoans([Role.SECRETARY]), isFalse);
    });
  });

  group('canManageReports', () {
    test('président, VP, secrétaire, trésorier, gestionnaire', () {
      expect(canManageReports([Role.PRESIDENT]), isTrue);
      expect(canManageReports([Role.SECRETARY]), isTrue);
      expect(canManageReports([Role.OFFICE_MANAGER]), isTrue);
    });

    test('simple membre refusé', () {
      expect(canManageReports([Role.TONTINARD]), isFalse);
    });
  });

  group('Role parsing', () {
    test('parseRole et displayName', () {
      expect(parseRole('PRESIDENT'), Role.PRESIDENT);
      expect(parseRole('office_manager'), Role.OFFICE_MANAGER);
      expect(parseRole('inconnu'), Role.TONTINARD);
      expect(Role.ACCOUNT_MANAGER.displayName, 'Trésorier');
      expect(Role.OFFICE_MANAGER.displayName, 'Gestionnaire');
    });
  });
}
