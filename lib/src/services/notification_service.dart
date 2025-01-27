import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/models/notification_tontine.dart';
import '../screen/services/member_service.dart';
import '../screen/services/middleware/interceptor_http.dart';

class NotificationService {
  final client = ApiClient.client;
  final storage = GetStorage();
  final String urlApi = '${dotenv.env['API_URL']}/api';
  final _logger = Logger('NotificationService');

  Future<List<NotificationTontine>?> getNotification(int id) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/notification/tontine/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((json) => NotificationTontine.fromJson(json))
            .toList();
      } else {
        _logger.severe('Error getting notifications: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.severe('Error getting notifications: $e');
      return null;
    }
  }
}
