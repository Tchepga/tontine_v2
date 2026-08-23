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
      'participants': ?participants,
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
      'creationDate': ?creationDate?.toIso8601String(),
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
      'username': ?username,
      'password': ?password,
      'firstname': firstname,
      'lastname': lastname,
      'email': ?email,
      'phone': phone,
      'country': country,
      'roles': ?roles,
    };
  }

  /// attach member — tontine_service.addMemberToTontine → PATCH /api/tontine/:id/member
  static Map<String, dynamic> attachMemberToTontine(int memberId) => {
        'memberId': memberId,
      };

  /// CreateMemberDto — register_view → POST /api/member/register-president
  /// (pas de username : l'API le génère à partir du prénom/nom).
  static Map<String, dynamic> registerPresident({
    required String firstname,
    required String lastname,
    required String phone,
    required String password,
    String country = 'FR',
    String? email,
  }) {
    return createMember(
      firstname: firstname,
      lastname: lastname,
      phone: phone,
      password: password,
      country: country,
      email: email,
    );
  }

  /// ForgotPasswordDto — forgot_password_view → POST /api/auth/forgot-password
  /// L'API attend `username` (email ou identifiant), pas `usernameOrEmail`.
  static Map<String, dynamic> forgotPassword({
    required String username,
  }) {
    return {'username': username};
  }

  /// ResetPasswordDto — reset_password_view → POST /api/auth/reset-password
  /// `confirmPassword` reste côté UI ; l'API le refuse (forbidNonWhitelisted).
  static Map<String, dynamic> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}

/// Routes exactes utilisées par le mobile (EventService, TontineService, MemberService).
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
  static String registerPresident() => '/member/register-president';
  static String login() => '/auth/login';
  static String forgotPassword() => '/auth/forgot-password';
  static String resetPassword() => '/auth/reset-password';
  static String listTontines(String username) => '/tontine/member/$username';
  static String deleteTontine(int tontineId) => '/tontine/$tontineId';
}
