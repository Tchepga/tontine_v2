import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tontine_v2/src/screen/services/dto/event_dto.dart';
import '../models/deposit.dart';
import '../models/event.dart';
import '../models/sanction.dart';
import '../models/tontine.dart';
import '../screen/services/dto/deposit_dto.dart';
import '../screen/services/dto/member_dto.dart';
import '../screen/services/dto/rapport_dto.dart';
import '../screen/services/dto/sanction_dto.dart';
import '../screen/services/dto/tontine_dto.dart';
import '../screen/services/tontine_service.dart';
import '../models/rapport_meeting.dart';
import 'package:get_storage/get_storage.dart';

class TontineProvider extends ChangeNotifier {
  static const KEY_SELECTED_TONTINE_ID = 'selectedTontineId';
  
  final _tontineService = TontineService();
  final _logger = Logger('TontineProvider');
  final _storage = GetStorage();
  List<Tontine> _tontines = [];
  List<Deposit> _deposits = [];
  Tontine? _currentTontine;
  bool _isLoading = false;

  List<Tontine> get tontines => _tontines;
  Tontine? get currentTontine => _currentTontine;
  List<Deposit> get deposits => _deposits;
  bool get isLoading => _isLoading;

  Future<void> loadTontines() async {
    _isLoading = true;
    notifyListeners();

    try {
      final tontines = await _tontineService.getTontines();
      _tontines = tontines;
      final index = _tontines.indexWhere((t) => t.id == _storage.read(KEY_SELECTED_TONTINE_ID));
      if(index != -1) {
        _currentTontine = _tontines[index];
      } else {
        throw Exception('La tontine sélectionnée n\'existe pas');
      }
    } catch (e) {
      _logger.severe('Error loading tontines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDeposits(int tontineId) async {
    _deposits = await _tontineService.getDeposits(tontineId);
    notifyListeners();
  }

  Future<void> getCurrentTontine() async {
    _currentTontine = await _tontineService.getTontine(_currentTontine!.id);
    notifyListeners();
  }

  Future<void> setCurrentTontine(Tontine tontine) async {
    try {
      // Mettre à jour la tonetine sélectionnée dans la liste
      final index = _tontines.indexWhere((t) => t.id == tontine.id);
      if (index != -1) {
        _currentTontine = _tontines[index];
        notifyListeners();

        // Sauvegarder l'ID de la tontine sélectionnée
        await _storage.write(KEY_SELECTED_TONTINE_ID, tontine.id);
      }
    } catch (e) {
      _logger.severe('Error setting current tontine: $e');
      rethrow;
    }
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

  Future<void> addMemberToTontine(int tontineId, CreateMemberDto memberDto) async {
    try {
      await _tontineService.addMemberToTontine(tontineId, memberDto);
      notifyListeners();
    } catch (e) {
      _logger.severe('Error adding member to tontine: $e');
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

  Future<void> updateTontineConfig(int tontineId, CreateConfigTontineDto configDto) async {
    try {
      await _tontineService.updateTontineConfig(tontineId, configDto);
    } catch (e) {
      _logger.severe('Error updating tontine config: $e');
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
      await _tontineService.createRapport(tontineId, rapportDto);
          notifyListeners();
    } catch (e) {
      _logger.severe('Error creating rapport: $e');
      rethrow;
    }
  }

  Future<List<RapportMeeting>> getRapportsForTontine(int tontineId) async {
    try {
      final rapports = await _tontineService.getRapports(tontineId);
      _logger.info('Rapports: ${rapports.first.attachmentFilename}');
      if(_currentTontine != null ){
        _currentTontine!.rapports = rapports;
        notifyListeners();
      }
      return rapports;
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

  Future<void> createDeposit(int tontineId, CreateDepositDto depositDto) async {
    await _tontineService.createDeposit(tontineId, depositDto);
  }

  Future<void> deleteDeposit(int tontineId, int depositId) async {
    await _tontineService.deleteDeposit(tontineId, depositId);
    await loadDeposits(tontineId);
  }

  Future<void> updateDeposit(int tontineId, int depositId, CreateDepositDto depositDto) async {
    await _tontineService.updateDeposit(tontineId, depositId, depositDto);
    await loadDeposits(tontineId);
  }

  Future<void> deleteRapport(int tontineId, int rapportId) async {
    try {
      await _tontineService.deleteRapport(tontineId, rapportId);
      await getRapportsForTontine(tontineId);
    } catch (e) {
      _logger.severe('Error deleting rapport: $e');
      rethrow;
    }
  }

  Future<File?> downloadRapportAttachment(int tontineId, int rapportId) async {
    try {
      return await _tontineService.downloadRapportAttachment(tontineId, rapportId);
    } catch (e) {
      _logger.severe('Error downloading attachment: $e');
      return null;
    }
  }

}
