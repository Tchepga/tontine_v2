import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../../models/member.dart';
import 'middleware/interceptor_http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class MemberService {
  final client = ApiClient.client;
  final storage = GetStorage();
  final String urlApi = '${dotenv.env['API_URL']}/api';
  final _logger = Logger('MemberService');

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
          storage.write('token', data['token']);
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
        return Member.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting profile: $e');
      return null;
    }
  }

  // Récupérer le token
  String? getToken() {
    return storage.read('token');
  }

  // Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return storage.hasData('token');
  }

  // Déconnexion
  void logout() {
    storage.remove('token');
  }

  Future<bool> hasValidToken() async {
    final token = await storage.read('token');
    final response = await client
        .post(Uri.parse('$urlApi/auth/verify'), body: {'token': token});
    final decodedResponse = jsonDecode(response.body);
    return decodedResponse['valid'] == true;
  }
}
