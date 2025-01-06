import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../../providers/models/member.dart';
import 'dto/member_dto.dart';
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
      if (response.statusCode == 200 && response.body.isNotEmpty ) {
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
    final response = await client.get(Uri.parse('$urlApi/auth/username/$username'));
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Member?> getMemberByUsername(String username) async {
    final response = await client.get(Uri.parse('$urlApi/member/username/$username'));
    if (response.statusCode == 200 && response.body.isNotEmpty) {
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
    if(token == null) {
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
}
