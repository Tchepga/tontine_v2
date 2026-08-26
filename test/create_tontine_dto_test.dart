import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import 'package:tontine_v2/src/providers/models/enum/loop_period.dart';
import 'package:tontine_v2/src/providers/models/enum/system_type.dart';
import 'package:tontine_v2/src/providers/models/enum/type_mouvement.dart';
import 'package:tontine_v2/src/screen/services/dto/member_dto.dart';
import 'package:tontine_v2/src/screen/services/dto/tontine_dto.dart';
import 'package:tontine_v2/src/screen/services/middleware/interceptor_http.dart';

void main() {
  group('CreateTontineDto.toJson', () {
    test('omet members, legacy vide et rateMaps vides', () {
      final dto = CreateTontineDto(
        title: '  Ma tontine  ',
        legacy: '   ',
        memberDtos: const [],
        currency: Currency.EUR,
        config: CreateConfigTontineDto(
          defaultLoanRate: 2,
          defaultLoanDuration: 30,
          loopPeriod: LoopPeriod.MONTHLY,
          minLoanAmount: 100,
          countPersonPerMovement: 1,
          movementType: MovementType.ROTATIVE,
          countMaxMember: 12,
          systemType: SystemType.PART,
        ),
      );

      final json = dto.toJson();
      expect(json['title'], 'Ma tontine');
      expect(json.containsKey('legacy'), isFalse);
      expect(json.containsKey('members'), isFalse);
      expect(json['currency'], 'EUR');
      expect(json['config']['systemType'], 'PART');
      expect(json['config']['loopPeriod'], 'MONTHLY');
      expect(json['config']['movementType'], 'ROTATIVE');
      expect(json['config'].containsKey('rateMaps'), isFalse);
    });

    test('inclut members seulement s ils sont fournis', () {
      final dto = CreateTontineDto(
        title: 'Tontine',
        memberDtos: [
          CreateMemberDto(
            username: 'alice',
            firstname: 'Alice',
            lastname: 'Martin',
            phone: '+33600000000',
            country: 'FR',
          ),
        ],
        currency: Currency.EUR,
        config: CreateConfigTontineDto(
          defaultLoanRate: 2,
          defaultLoanDuration: 30,
          loopPeriod: LoopPeriod.MONTHLY,
          minLoanAmount: 100,
          countPersonPerMovement: 1,
          movementType: MovementType.ROTATIVE,
          countMaxMember: 12,
        ),
      );

      expect(dto.toJson()['members'], isA<List>());
      expect(dto.toJson()['members'], hasLength(1));
    });
  });

  group('AuthInterceptor.isCreateTontineRequest', () {
    test('POST /api/tontine est une creation', () {
      expect(
        AuthInterceptor.isCreateTontineRequest(
          'POST',
          Uri.parse('https://api.example.com/api/tontine'),
        ),
        isTrue,
      );
    });

    test('POST sous-ressource tontine n est pas une creation', () {
      expect(
        AuthInterceptor.isCreateTontineRequest(
          'POST',
          Uri.parse('https://api.example.com/api/tontine/1/deposit'),
        ),
        isFalse,
      );
    });

    test('GET /api/tontine n est pas une creation', () {
      expect(
        AuthInterceptor.isCreateTontineRequest(
          'GET',
          Uri.parse('https://api.example.com/api/tontine'),
        ),
        isFalse,
      );
    });
  });
}
