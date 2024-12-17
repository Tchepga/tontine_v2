import 'package:get_storage/get_storage.dart';
import 'package:tontine_v2/src/models/member.dart';
import 'dart:convert';
import 'middleware/interceptor_http.dart';

class MemberService {
  final client = ApiClient.client;
  final storage = GetStorage();
  final String urlApi =
      "https://b35d-2a01-e0a-da0-8120-51c0-b549-4700-a09a.ngrok-free.app/api";

  Future<void> init() async {
    await GetStorage.init();
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

      print('Response: ${response.body}'); 
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          storage.write('token', data['token']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<Member?> getProfile() async {
    try {
      if (!isLoggedIn()) {
        return null;
      }

      final response = await client.get(
        headers: {
          'Authorization': 'Bearer ${getToken()}',
        },
        Uri.parse('$urlApi/member'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
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
    return token != null && token.isNotEmpty;
  }
}
