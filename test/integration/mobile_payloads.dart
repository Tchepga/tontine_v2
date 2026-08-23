/// Payloads JSON identiques à ceux produits par les DTO mobile (toJson).
///
/// Source de vérité : lib/src/screen/services/dto/*.dart
class MobilePayloads {
  /// CreateEventDto — event_service.dart → POST /api/event
  static Map<String, dynamic> createEvent({
    required int tontineId,
    required String title,
    String type = 'MEETING',
    String description = 'Test intégration',
    DateTime? startDate,
    DateTime? endDate,
    List<int>? participants,
  }) {
    final start = startDate ?? DateTime.now().add(const Duration(days: 7));
    final end = endDate ?? start.add(const Duration(hours: 2));
    return {
      'tontineId': tontineId,
      'title': title,
      'type': type,
      'description': description,
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      if (participants != null) 'participants': participants,
    };
  }

  /// CreateDepositDto — edit_mouvement.dart → POST /api/tontine/:id/deposit
  static Map<String, dynamic> createDeposit({
    required double amount,
    required int memberId,
    required int cashFlowId,
    String currency = 'EUR',
    String status = 'PENDING',
    String reasons = 'VERSEMENT',
    DateTime? creationDate,
  }) {
    return {
      'amount': amount,
      'currency': currency,
      'memberId': memberId,
      'status': status,
      'cashFlowId': cashFlowId,
      'reasons': reasons,
      if (creationDate != null)
        'creationDate': creationDate.toIso8601String(),
    };
  }

  /// CreateMemberDto — member_view / add_members_view → POST /api/member
  static Map<String, dynamic> createMember({
    required String firstname,
    required String lastname,
    required String phone,
    String country = 'FR',
    String? email,
    String? password,
    String? username,
    List<String>? roles,
  }) {
    return {
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      'firstname': firstname,
      'lastname': lastname,
      if (email != null) 'email': email,
      'phone': phone,
      'country': country,
      if (roles != null) 'roles': roles,
    };
  }

  /// attach member — tontine_service.addMemberToTontine → PATCH /api/tontine/:id/member
  static Map<String, dynamic> attachMemberToTontine(int memberId) => {
        'memberId': memberId,
      };
}

/// Routes exactes utilisées par le mobile (EventService, TontineService).
class MobileRoutes {
  static String createEvent() => '/event';
  static String listEvents(int tontineId) => '/event/tontine/$tontineId';
  static String deleteEvent(int eventId) => '/event/$eventId';
  static String createDeposit(int tontineId) => '/tontine/$tontineId/deposit';
  static String deleteDeposit(int tontineId, int depositId) =>
      '/tontine/$tontineId/deposit/$depositId';
  static String createMember() => '/member';
  static String attachMember(int tontineId) => '/tontine/$tontineId/member';
  static String detachMember(int tontineId, int memberId) =>
      '/tontine/$tontineId/member/$memberId';
}
