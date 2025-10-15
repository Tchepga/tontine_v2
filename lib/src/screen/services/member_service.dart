import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../../providers/models/member.dart';
import '../../providers/models/enum/role.dart';
import 'dto/member_dto.dart';
import 'dto/password_dto.dart';
import 'middleware/interceptor_http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class MemberService {
  final client = ApiClient.client;
  final storage = GetStorage();
  static final String urlApi = '${dotenv.env['API_URL']}/api';
  final _logger = Logger('MemberService');
  static const String KEY_USER_INFO = 'userInfo';
  static const String KEY_TOKEN = 'token';

  Future<void> init() async {
    if (urlApi.isEmpty) {
      throw Exception('API_URL is not set in .env file');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$urlApi/auth/login'),
        body: {
          'username': username,
          'password': password,
        },
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          storage.write(KEY_TOKEN, data['token']);
          return true;
        }
      }
      return false;
    } catch (e) {
      _logger.severe('Error: $e');
      return false;
    }
  }

  Future<Member?> getProfile() async {
    try {
      if (!(await hasValidToken())) {
        throw Exception('Token invalide');
      }

      final response = await client.get(
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
        Uri.parse('$urlApi/member'),
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final member = Member.fromJson(jsonDecode(response.body));
        storage.write(KEY_USER_INFO, member.toJson());
        return member;
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting profile: $e');
      return null;
    }
  }

  Future<bool> hasConnectedMemberInfo() async {
    final storageUserInfo = await storage.read(KEY_USER_INFO);
    return storageUserInfo != null;
  }

  Future<void> updateMemberInfo(CreateMemberDto member) async {
    await client.patch(
      Uri.parse('$urlApi/member'),
      body: member.toJson(),
    );
  }

  Future<User?> getUserByUsername(String username) async {
    final response =
        await client.get(Uri.parse('$urlApi/auth/username/$username'));
    if (response.statusCode == 200 &&
        response.body.isNotEmpty &&
        response.body != 'null') {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Member?> getMemberByUsername(String username) async {
    final response =
        await client.get(Uri.parse('$urlApi/member/username/$username'));
    if (response.statusCode == 200 &&
        response.body.isNotEmpty &&
        response.body != 'null') {
      return Member.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Récupérer le token
  String? getToken() {
    return storage.read(KEY_TOKEN);
  }

  // Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return storage.hasData(KEY_TOKEN);
  }

  // Déconnexion
  void logout() {
    storage.remove(KEY_TOKEN);
    storage.remove(KEY_USER_INFO);
  }

  Future<bool> hasValidToken() async {
    final token = await storage.read(KEY_TOKEN);
    if (token == null) {
      return false;
    }
    final response = await client
        .post(Uri.parse('$urlApi/auth/verify'), body: {'token': token});
    final decodedResponse = jsonDecode(response.body);
    return decodedResponse['valid'] == true;
  }

  Future<bool> register(CreateMemberDto memberDto) async {
    try {
      final response = await client.post(
        Uri.parse('$urlApi/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(memberDto.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      _logger.severe('Error during registration: $e');
      return false;
    }
  }

  Future<int> registerPresident(CreateMemberDto memberDto) async {
    try {
      final response = await client.post(
        Uri.parse('$urlApi/member/register-president'),
        body: jsonEncode(memberDto.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode;
    } catch (e) {
      _logger.severe('Error during registration: $e');
      return 500;
    }
  }

  Future<void> updateMemberRoles(int memberId, List<Role> roles) async {
    try {
      if (!(await hasValidToken())) {
        throw Exception('Token invalide');
      }

      final response = await client.put(
        Uri.parse('$urlApi/member/$memberId/roles'),
        headers: {
          'Authorization': 'Bearer ${getToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'roles':
              roles.map((role) => role.toString().split('.').last).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour des rôles');
      }
    } catch (e) {
      _logger.severe('Error updating member roles: $e');
      rethrow;
    }
  }

  // Méthodes pour la gestion des mots de passe
  Future<void> changePassword(ChangePasswordDto passwordDto) async {
    try {
      if (!(await hasValidToken())) {
        throw Exception('Token invalide');
      }

      final response = await client.put(
        Uri.parse('$urlApi/auth/change-password'),
        headers: {
          'Authorization': 'Bearer ${getToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(passwordDto.toJson()),
      );

      if (response.statusCode != 200) {
        final errorBody = response.body;
        throw Exception(
            'Erreur lors du changement de mot de passe: $errorBody');
      }
    } catch (e) {
      _logger.severe('Error changing password: $e');
      rethrow;
    }
  }

  Future<void> forgotPassword(ForgotPasswordDto forgotPasswordDto) async {
    try {
      final response = await client.post(
        Uri.parse('$urlApi/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(forgotPasswordDto.toJson()),
      );

      if (response.statusCode != 200) {
        final errorBody = response.body;
        throw Exception(
            'Erreur lors de la demande de réinitialisation: $errorBody');
      }
    } catch (e) {
      _logger.severe('Error requesting password reset: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(ResetPasswordDto resetPasswordDto) async {
    try {
      final response = await client.post(
        Uri.parse('$urlApi/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(resetPasswordDto.toJson()),
      );

      if (response.statusCode != 200) {
        final errorBody = response.body;
        throw Exception('Erreur lors de la réinitialisation: $errorBody');
      }
    } catch (e) {
      _logger.severe('Error resetting password: $e');
      rethrow;
    }
  }
}
