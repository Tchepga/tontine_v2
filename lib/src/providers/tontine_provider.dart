import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tontine_v2/src/screen/services/dto/event_dto.dart';
import '../models/event.dart';
import '../models/sanction.dart';
import '../models/tontine.dart';
import '../screen/services/dto/rapport_dto.dart';
import '../screen/services/dto/sanction_dto.dart';
import '../screen/services/dto/tontine_dto.dart';
import '../screen/services/tontine_service.dart';
import '../models/rapport_meeting.dart';

class TontineProvider extends ChangeNotifier {
  final _tontineService = TontineService();
  final _logger = Logger('TontineProvider');
  List<Tontine> _tontines = [];
  Tontine? _currentTontine;
  bool _isLoading = false;

  List<Tontine> get tontines => _tontines;
  Tontine? get currentTontine => _currentTontine;
  bool get isLoading => _isLoading;

  Future<void> loadTontines() async {
    _isLoading = true;
    notifyListeners();

    try {
      final tontines = await _tontineService.getTontines();
      _tontines = tontines;
      if (tontines.isNotEmpty) {
        _currentTontine = tontines.first;
      }
    } catch (e) {
      _logger.severe('Error loading tontines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentTontine(Tontine tontine) {
    _currentTontine = tontine;
    notifyListeners();
  }

  Future<void> createTontine(CreateTontineDto tontine) async {
    try {
      final newTontine = await _tontineService.createTontine(tontine);
      _tontines.add(newTontine);
      notifyListeners();
    } catch (e) {
      _logger.severe('Error creating tontine: $e');
      rethrow;
    }
  }

  Future<void> updateTontine(int tontineId, CreateTontineDto tontineDto) async {
    try {
      final tontine =
          await _tontineService.updateTontine(tontineId, tontineDto);
      final index = _tontines.indexWhere((t) => t.id == tontineId);
      if (index != -1) {
        _tontines[index] = tontine;
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error updating tontine: $e');
      rethrow;
    }
  }

  Future<void> addEvent(int tontineId, CreateEventDto eventDto) async {
    try {
      await _tontineService.createEvent(tontineId, eventDto);
      final tontineIndex = _tontines.indexWhere((t) => t.id == tontineId);
      if (tontineIndex != -1) {
        // Mise à jour de la liste des événements de la tontine
        final updatedTontine = await _tontineService.getTontine(tontineId);
        if (updatedTontine != null) {
          _tontines[tontineIndex] = updatedTontine;
          if (_currentTontine?.id == tontineId) {
            _currentTontine = updatedTontine;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      _logger.severe('Error creating event: $e');
      rethrow;
    }
  }

  Future<List<Event>> getEventsForTontine(int tontineId) async {
    try {
      return await _tontineService.getEvents(tontineId);
    } catch (e) {
      _logger.severe('Error getting events: $e');
      return [];
    }
  }

  Future<void> addRapport(
      int tontineId, CreateMeetingRapportDto rapportDto) async {
    try {
      _tontineService.createRapport(tontineId, rapportDto);
      final tontineIndex = _tontines.indexWhere((t) => t.id == tontineId);
      if (tontineIndex != -1) {
        // Mise à jour de la liste des rapports de la tontine
        final updatedTontine = await _tontineService.getTontine(tontineId);
        if (updatedTontine != null) {
          _tontines[tontineIndex] = updatedTontine;
          if (_currentTontine?.id == tontineId) {
            _currentTontine = updatedTontine;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      _logger.severe('Error creating rapport: $e');
      rethrow;
    }
  }

  Future<List<RapportMeeting>> getRapportsForTontine(int tontineId) async {
    try {
      return await _tontineService.getRapports(tontineId);
    } catch (e) {
      _logger.severe('Error getting rapports: $e');
      return [];
    }
  }

  Future<void> updateRapport(
      int tontineId, CreateMeetingRapportDto rapportDto) async {
    try {
      await _tontineService.updateRapport(tontineId, rapportDto);
      final tontineIndex = _tontines.indexWhere((t) => t.id == tontineId);
      if (tontineIndex != -1) {
        final updatedTontine = await _tontineService.getTontine(tontineId);
        if (updatedTontine != null) {
          _tontines[tontineIndex] = updatedTontine;
          if (_currentTontine?.id == tontineId) {
            _currentTontine = updatedTontine;
          }
          notifyListeners();
        }
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error updating rapport: $e');
      rethrow;
    }
  }

  Future<void> addSanction(int tontineId, CreateSanctionDto sanctionDto) async {
    try {
      await _tontineService.createSanction(tontineId, sanctionDto);
      final tontineIndex = _tontines.indexWhere((t) => t.id == tontineId);
      if (tontineIndex != -1) {
        final updatedTontine = await _tontineService.getTontine(tontineId);
        if (updatedTontine != null) {
          _tontines[tontineIndex] = updatedTontine;
          if (_currentTontine?.id == tontineId) {
            _currentTontine = updatedTontine;
          }
          notifyListeners();
        }
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error creating sanction: $e');
      rethrow;
    }
  }

  Future<List<Sanction>> getSanctionsForTontine(int tontineId) async {
    try {
      return await _tontineService.getSanctions(tontineId);
    } catch (e) {
      _logger.severe('Error getting sanctions: $e');
      return [];
    }
  }

  Future<void> updateSanction(
      int tontineId, int sanctionId, CreateSanctionDto sanctionDto) async {
    try {
      await _tontineService.updateSanction(tontineId, sanctionId, sanctionDto);
      final tontineIndex = _tontines.indexWhere((t) => t.id == tontineId);
      if (tontineIndex != -1) {
        final updatedTontine = await _tontineService.getTontine(tontineId);
        if (updatedTontine != null) {
          _tontines[tontineIndex] = updatedTontine;
          if (_currentTontine?.id == tontineId) {
            _currentTontine = updatedTontine;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      _logger.severe('Error updating sanction: $e');
      rethrow;
    }
  }
}
