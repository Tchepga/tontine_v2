import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tontine_v2/src/screen/services/dto/event_dto.dart';
import '../services/local_notification_service.dart';
import 'models/deposit.dart';
import 'models/enum/status_deposit.dart';
import 'models/event.dart';
import 'models/sanction.dart';
import 'models/tontine.dart';
import 'models/auction.dart';
import 'models/enum/loop_period.dart';
import 'models/enum/role.dart';
import '../screen/services/dto/deposit_dto.dart';
import '../screen/services/dto/member_dto.dart';
import '../screen/services/dto/rapport_dto.dart';
import '../screen/services/dto/sanction_dto.dart';
import '../screen/services/dto/tontine_dto.dart';
import '../screen/services/dto/auction_dto.dart';
import '../screen/services/tontine_service.dart';
import '../screen/services/auction_service.dart';
import 'models/rapport_meeting.dart';
import 'package:get_storage/get_storage.dart';
import 'models/part.dart';

class TontineProvider extends ChangeNotifier {
  static const KEY_SELECTED_TONTINE_ID = 'selectedTontineId';

  final _tontineService = TontineService();
  final _auctionService = AuctionService();
  final _logger = Logger('TontineProvider');
  final _storage = GetStorage();
  List<Tontine> _tontines = [];
  List<Deposit> _deposits = [];
  List<Auction> _auctions = [];
  Tontine? _currentTontine;
  bool _isLoading = false;
  final _notificationService = LocalNotificationService();
  final List<Part> _parts = [];

  List<Tontine> get tontines => _tontines;
  Tontine? get currentTontine => _currentTontine;
  List<Deposit> get deposits => _deposits;
  List<Auction> get auctions => _auctions;
  bool get isLoading => _isLoading;
  List<Part> get parts => _parts;

  Future<void> loadTontines() async {
    _isLoading = true;
    notifyListeners();

    try {
      final tontines = await _tontineService.getTontines();
      _tontines = tontines;
      final index = _tontines
          .indexWhere((t) => t.id == _storage.read(KEY_SELECTED_TONTINE_ID));
      if (index != -1) {
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

        _logger.info('Saving selected tontine : $tontine');
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

  Future<void> addMemberToTontine(
      int tontineId, CreateMemberDto memberDto) async {
    try {
      await _tontineService.addMemberToTontine(tontineId, memberDto);
      await loadTontines(); // Recharger les données depuis l'API
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

  Future<void> updateTontineConfig(
      int tontineId, CreateConfigTontineDto configDto) async {
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

      await _notificationService.showNotification(
        title: 'Rapport créé',
        body: 'Un nouveau rapport a été créé',
        payload: '/rapport',
      );
    } catch (e) {
      _logger.severe('Error creating rapport: $e');
      rethrow;
    }
  }

  Future<List<RapportMeeting>> getRapportsForTontine(int tontineId) async {
    try {
      final rapports = await _tontineService.getRapports(tontineId);
      _logger.info('Rapports: ${rapports.first.attachmentFilename}');
      if (_currentTontine != null) {
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
      await _notificationService.showNotification(
        title: 'Sanction créée',
        body: 'Une nouvelle sanction a été créée',
        payload: '/sanction',
      );
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

  Future<void> updateDeposit(
      int tontineId, int depositId, CreateDepositDto depositDto) async {
    await _tontineService.updateDeposit(tontineId, depositId, depositDto);
    await loadDeposits(tontineId);
  }

  Future<void> validateDeposit(
      int tontineId, int depositId, StatusDeposit status) async {
    try {
      await _tontineService.validateDeposit(tontineId, depositId, status);
      await loadDeposits(tontineId);
      await getCurrentTontine(); // Recharger les données de la tontine
    } catch (e) {
      _logger.severe('Error validating deposit: $e');
      rethrow;
    }
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
      return await _tontineService.downloadRapportAttachment(
          tontineId, rapportId);
    } catch (e) {
      _logger.severe('Error downloading attachment: $e');
      return null;
    }
  }

  Future<void> removeMemberFromTontine(int tontineId, int memberId) async {
    try {
      await _tontineService.removeMemberFromTontine(tontineId, memberId);
      await loadTontines();
    } catch (e) {
      _logger.severe('Error removing member from tontine: $e');
      rethrow;
    }
  }

  Future<void> addPart(PartOrderDto partDto) async {
    try {
      final tontineId = _currentTontine!.id;
      await _tontineService.addPart(tontineId, partDto);
      await loadTontines();
    } catch (e) {
      _logger.severe('Error adding part: $e');
      rethrow;
    }
  }

  bool canAddDeposit() {
    final config = _currentTontine?.config;
    return _currentTontine?.members.length == config?.countMaxMember &&
        config?.parts?.isNotEmpty == true;
  }

  /// Retourne l'ordre actuel et le suivant basé sur la période de boucle
  Map<String, PartOrder?> getCurrentAndNextPartOrders() {
    if (_currentTontine?.config.parts == null ||
        _currentTontine!.config.parts!.isEmpty) {
      return {'current': null, 'next': null};
    }

    final now = DateTime.now();
    final parts = _currentTontine!.config.parts!;
    final loopPeriod = _currentTontine!.config.loopPeriod;

    // Trier les parts par ordre
    final sortedParts = List<PartOrder>.from(parts)
      ..sort((a, b) => a.order.compareTo(b.order));

    PartOrder? currentPart;
    PartOrder? nextPart;

    for (int i = 0; i < sortedParts.length; i++) {
      final part = sortedParts[i];
      if (part.period == null) continue;

      if (_isPeriodMatching(now, part.period!, loopPeriod)) {
        currentPart = part;
        // Le suivant est le prochain dans la liste, ou le premier si on est à la fin
        nextPart = sortedParts[(i + 1) % sortedParts.length];
        break;
      }
    }

    // Si aucun ordre actuel trouvé, chercher le prochain ordre à venir
    if (currentPart == null) {
      for (final part in sortedParts) {
        if (part.period != null && part.period!.isAfter(now)) {
          nextPart = part;
          break;
        }
      }
    }

    return {'current': currentPart, 'next': nextPart};
  }

  /// Vérifie si la date actuelle correspond à la période de la part selon le loopPeriod
  bool _isPeriodMatching(
      DateTime currentDate, DateTime partDate, LoopPeriod loopPeriod) {
    switch (loopPeriod) {
      case LoopPeriod.DAILY:
        return currentDate.year == partDate.year &&
            currentDate.month == partDate.month &&
            currentDate.day == partDate.day;

      case LoopPeriod.WEEKLY:
        // Comparer les semaines de l'année
        final currentWeek = _getWeekOfYear(currentDate);
        final partWeek = _getWeekOfYear(partDate);
        return currentDate.year == partDate.year && currentWeek == partWeek;

      case LoopPeriod.MONTHLY:
        return currentDate.year == partDate.year &&
            currentDate.month == partDate.month;
    }
  }

  /// Calcule le numéro de semaine dans l'année
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  /// Met à jour les rôles d'un membre
  Future<void> updateMemberRoles(
      int tontineId, int memberId, List<Role> roles) async {
    try {
      await _tontineService.updateMemberRoles(memberId, roles);
      await loadTontines();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ========== MÉTHODES POUR LES ENCHÈRES ==========

  Future<void> loadAuctions(int tontineId) async {
    try {
      final auctions = await _auctionService.getAuctions(tontineId);
      _auctions = auctions;
      notifyListeners();
    } catch (e) {
      _logger.severe('Error loading auctions: $e');
      rethrow;
    }
  }

  Future<void> loadActiveAuctions(int tontineId) async {
    try {
      final auctions = await _auctionService.getActiveAuctions(tontineId);
      _auctions = auctions;
      notifyListeners();
    } catch (e) {
      _logger.severe('Error loading active auctions: $e');
      rethrow;
    }
  }

  Future<Auction?> createAuction(CreateAuctionDto auctionDto) async {
    try {
      final auction = await _auctionService.createAuction(auctionDto);
      if (auction != null) {
        await loadAuctions(auctionDto.tontineId);
      }
      return auction;
    } catch (e) {
      _logger.severe('Error creating auction: $e');
      rethrow;
    }
  }

  Future<Auction?> updateAuction(
      int auctionId, UpdateAuctionDto auctionDto) async {
    try {
      final auction =
          await _auctionService.updateAuction(auctionId, auctionDto);
      if (auction != null && _currentTontine != null) {
        await loadAuctions(_currentTontine!.id);
      }
      return auction;
    } catch (e) {
      _logger.severe('Error updating auction: $e');
      rethrow;
    }
  }

  Future<bool> deleteAuction(int auctionId) async {
    try {
      final success = await _auctionService.deleteAuction(auctionId);
      if (success && _currentTontine != null) {
        await loadAuctions(_currentTontine!.id);
      }
      return success;
    } catch (e) {
      _logger.severe('Error deleting auction: $e');
      rethrow;
    }
  }

  Future<bool> placeBid(CreateAuctionBidDto bidDto) async {
    try {
      final success = await _auctionService.placeBid(bidDto);
      if (success && _currentTontine != null) {
        await loadAuctions(_currentTontine!.id);
      }
      return success;
    } catch (e) {
      _logger.severe('Error placing bid: $e');
      rethrow;
    }
  }

  Future<Auction?> completeAuction(int auctionId) async {
    try {
      final auction = await _auctionService.completeAuction(auctionId);
      if (auction != null && _currentTontine != null) {
        await loadAuctions(_currentTontine!.id);
      }
      return auction;
    } catch (e) {
      _logger.severe('Error completing auction: $e');
      rethrow;
    }
  }

  Future<Auction?> cancelAuction(int auctionId) async {
    try {
      final auction = await _auctionService.cancelAuction(auctionId);
      if (auction != null && _currentTontine != null) {
        await loadAuctions(_currentTontine!.id);
      }
      return auction;
    } catch (e) {
      _logger.severe('Error cancelling auction: $e');
      rethrow;
    }
  }

  // Méthodes utilitaires pour les enchères
  List<Auction> get activeAuctions =>
      _auctions.where((a) => a.isActive).toList();
  List<Auction> get completedAuctions =>
      _auctions.where((a) => a.isCompleted).toList();
  List<Auction> get cancelledAuctions =>
      _auctions.where((a) => a.isCancelled).toList();
}
