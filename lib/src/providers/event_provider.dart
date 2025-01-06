import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../screen/services/dto/event_dto.dart';
import '../screen/services/event_service.dart';
import 'models/event.dart';

class EventProvider extends ChangeNotifier {
  final _eventService = EventService();
  final _logger = Logger('EventProvider');
  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> loadEvents(int tontineId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await _eventService.getEvents(tontineId);
    } catch (e) {
      _logger.severe('Error loading events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent(CreateEventDto eventDto) async {
    try {
      await _eventService.createEvent(eventDto);
      await loadEvents(eventDto.tontineId);
    } catch (e) {
      _logger.severe('Error creating event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(int eventId, CreateEventDto eventDto) async {
    try {
      await _eventService.updateEvent(eventId, eventDto);
      await loadEvents(eventDto.tontineId);
    } catch (e) {
      _logger.severe('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(int tontineId, int eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
      await loadEvents(tontineId);
    } catch (e) {
      _logger.severe('Error deleting event: $e');
      rethrow;
    }
  }
} 