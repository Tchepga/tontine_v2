import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/models/event.dart';
import 'middleware/interceptor_http.dart';
import 'dto/event_dto.dart';
import 'member_service.dart';
import '../../services/websocket_service.dart';

class EventService {
  final client = ApiClient.client;
  final storage = GetStorage();
  final String urlApi = '${dotenv.env['API_URL']}/api';
  final _logger = Logger('EventService');

  Future<List<Event>> getEvents(int tontineId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/event/tontine/$tontineId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error getting events: $e');
      return [];
    }
  }

  Future<Event?> getEvent(int id) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/event/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return Event.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting event: $e');
      return null;
    }
  }

  Future<void> createEvent(CreateEventDto eventDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.post(
      Uri.parse('$urlApi/event'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(eventDto.toJson()),
    );
    if (response.statusCode == 201) {
      final eventData = jsonDecode(response.body);

      // Émettre un événement WebSocket pour notifier les autres utilisateurs
      try {
        final wsService = WebSocketService();
        if (wsService.isConnected) {
          wsService.emit('event.created', {
            'eventId': eventData['id'],
            'title': eventDto.title,
            'tontineId': eventDto.tontineId,
          });
        }
      } catch (e) {
        _logger.warning('Error emitting WebSocket event: $e');
      }
    } else {
      throw Exception('Failed to create event');
    }
  }

  Future<void> updateEvent(int id, CreateEventDto eventDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.patch(
      Uri.parse('$urlApi/event/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(eventDto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(int id) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.delete(
      Uri.parse('$urlApi/event/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }
}
