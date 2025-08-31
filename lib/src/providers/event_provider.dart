import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../screen/services/dto/event_dto.dart';
import '../screen/services/event_service.dart';
import 'models/event.dart';
import '../services/local_notification_service.dart';

class EventProvider extends ChangeNotifier {
  final _eventService = EventService();
  final _logger = Logger('EventProvider');
  final _notificationService = LocalNotificationService();
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
      // Créer l'événement d'abord
      await _eventService.createEvent(eventDto);

      // Envoyer la notification avant de recharger les événements
      try {
        await _notificationService.showNotification(
          title: 'Nouvel événement',
          body: 'Un nouvel événement "${eventDto.title}" a été créé',
          payload: '/event',
        );
      } catch (notifError) {
        _logger.warning('Error showing notification: $notifError');
      }

      // Recharger les événements en dernier
      await loadEvents(eventDto.tontineId);
    } catch (e) {
      _logger.severe('Error creating event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(int eventId, CreateEventDto eventDto) async {
    try {
      await _eventService.updateEvent(eventId, eventDto);
      await _notificationService.showNotification(
        title: 'Événement mis à jour',
        body: 'L\'événement "${eventDto.title}" a été mis à jour',
        payload: '/event',
      );
      await loadEvents(eventDto.tontineId);
    } catch (e) {
      _logger.severe('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(int tontineId, int eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
      await _notificationService.showNotification(
        title: 'Événement supprimé',
        body: 'L\'événement "$eventId" a été supprimé',
        payload: '/event',
      );
      await loadEvents(tontineId);
    } catch (e) {
      _logger.severe('Error deleting event: $e');
      rethrow;
    }
  }
}
