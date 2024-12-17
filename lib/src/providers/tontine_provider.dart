import 'package:flutter/material.dart';
import '../models/tontine.dart';
import '../screen/services/tontine_service.dart';

class TontineProvider extends ChangeNotifier {
  final _tontineService = TontineService();
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
      print('Error loading tontines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentTontine(Tontine tontine) {
    _currentTontine = tontine;
    notifyListeners();
  }

  Future<void> createTontine(Tontine tontine) async {
    try {
      final newTontine = await _tontineService.createTontine(tontine);
      _tontines.add(newTontine);
      notifyListeners();
    } catch (e) {
      print('Error creating tontine: $e');
      rethrow;
    }
  }

  Future<void> updateTontine(Tontine tontine) async {
    try {
      await _tontineService.updateTontine(tontine);
      final index = _tontines.indexWhere((t) => t.id == tontine.id);
      if (index != -1) {
        _tontines[index] = tontine;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating tontine: $e');
      rethrow;
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      final newEvent = await _tontineService.createEvent(event);
      final tontineIndex = _tontines.indexWhere((t) => t.id == event.tontine.id);
      if (tontineIndex != -1) {
        // Mise à jour de la liste des événements de la tontine
        final updatedTontine = await _tontineService.getTontine(event.tontine.id);
        _tontines[tontineIndex] = updatedTontine;
        if (_currentTontine?.id == event.tontine.id) {
          _currentTontine = updatedTontine;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  Future<List<Event>> getEventsForTontine(int tontineId) async {
    try {
      return await _tontineService.getEvents(tontineId);
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  Future<void> addRapport(RapportMeeting rapport) async {
    try {
      final newRapport = await _tontineService.createRapport(rapport);
      final tontineIndex = _tontines.indexWhere((t) => t.id == rapport.tontine.id);
      if (tontineIndex != -1) {
        // Mise à jour de la liste des rapports de la tontine
        final updatedTontine = await _tontineService.getTontine(rapport.tontine.id);
        _tontines[tontineIndex] = updatedTontine;
        if (_currentTontine?.id == rapport.tontine.id) {
          _currentTontine = updatedTontine;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error creating rapport: $e');
      rethrow;
    }
  }

  Future<List<RapportMeeting>> getRapportsForTontine(int tontineId) async {
    try {
      return await _tontineService.getRapports(tontineId);
    } catch (e) {
      print('Error getting rapports: $e');
      return [];
    }
  }

  Future<void> updateRapport(RapportMeeting rapport) async {
    try {
      await _tontineService.updateRapport(rapport);
      final tontineIndex = _tontines.indexWhere((t) => t.id == rapport.tontine.id);
      if (tontineIndex != -1) {
        final updatedTontine = await _tontineService.getTontine(rapport.tontine.id);
        _tontines[tontineIndex] = updatedTontine;
        if (_currentTontine?.id == rapport.tontine.id) {
          _currentTontine = updatedTontine;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating rapport: $e');
      rethrow;
    }
  }

  Future<void> addSanction(Sanction sanction) async {
    try {
      final newSanction = await _tontineService.createSanction(sanction);
      final tontineIndex = _tontines.indexWhere((t) => t.id == sanction.tontine.id);
      if (tontineIndex != -1) {
        final updatedTontine = await _tontineService.getTontine(sanction.tontine.id);
        _tontines[tontineIndex] = updatedTontine;
        if (_currentTontine?.id == sanction.tontine.id) {
          _currentTontine = updatedTontine;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error creating sanction: $e');
      rethrow;
    }
  }

  Future<List<Sanction>> getSanctionsForTontine(int tontineId) async {
    try {
      return await _tontineService.getSanctions(tontineId);
    } catch (e) {
      print('Error getting sanctions: $e');
      return [];
    }
  }

  Future<void> updateSanction(Sanction sanction) async {
    try {
      await _tontineService.updateSanction(sanction);
      final tontineIndex = _tontines.indexWhere((t) => t.id == sanction.tontine.id);
      if (tontineIndex != -1) {
        final updatedTontine = await _tontineService.getTontine(sanction.tontine.id);
        _tontines[tontineIndex] = updatedTontine;
        if (_currentTontine?.id == sanction.tontine.id) {
          _currentTontine = updatedTontine;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating sanction: $e');
      rethrow;
    }
  }
} 