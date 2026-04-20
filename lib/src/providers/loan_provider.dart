import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/local_notification_service.dart';
import 'models/loan.dart';
import 'models/loan_repayment.dart';
import '../screen/services/loan_service.dart';
import '../screen/services/dto/loan_dto.dart';
import '../screen/services/dto/loan_repayment_dto.dart';

class LoanProvider extends ChangeNotifier {
  final _loanService = LoanService();
  final _logger = Logger('LoanProvider');
  List<Loan> _loans = [];
  List<LoanRepayment> _repayments = [];
  final _notificationService = LocalNotificationService();

  bool _isLoading = false;

  List<Loan> get loans => _loans;
  List<LoanRepayment> get repayments => _repayments;
  bool get isLoading => _isLoading;

  Future<void> loadLoans(int tontineId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _loans = await _loanService.getLoans(tontineId);
    } catch (e) {
      _logger.severe('Error loading loans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createLoan(CreateLoanDto loanDto) async {
    try {
      await _loanService.createLoan(loanDto);
      // Recharger la liste après création
      await loadLoans(loanDto.tontineId);
      await _notificationService.showNotification(
        title: 'Prêt créé',
        body: 'Un nouveau prêt a été créé',
        payload: '/loan',
      );
    } catch (e) {
      _logger.severe('Error creating loan: $e');
      rethrow;
    }
  }

  Future<void> updateLoan(int id, UpdateLoanDto loanDto) async {
    try {
      await _loanService.updateLoan(id, loanDto);
      await _notificationService.showNotification(
        title: 'Prêt mis à jour',
        body: 'Le prêt a été mis à jour',
        payload: '/loan',
      );
      // Recharger la liste après mise à jour
      final loan = _loans.firstWhere((l) => l.id == id);
      if (loan.tontineId != null) {
        await loadLoans(loan.tontineId!);
      }
    } catch (e) {
      _logger.severe('Error updating loan: $e');
      rethrow;
    }
  }

  Future<void> deleteLoan(int id) async {
    try {
      final loan = _loans.firstWhere((l) => l.id == id);
      await _loanService.deleteLoan(id);
      await _notificationService.showNotification(
        title: 'Prêt supprimé',
        body: 'Le prêt a été supprimé',
        payload: '/loan',
      );
      // Recharger la liste après suppression
      if (loan.tontineId != null) {
        await loadLoans(loan.tontineId!);
      }
    } catch (e) {
      _logger.severe('Error deleting loan: $e');
      rethrow;
    }
  }

  Future<void> voteLoan(int id) async {
    try {
      await _loanService.voteLoan(id);
      final loan = _loans.firstWhere((l) => l.id == id);
      if (loan.tontineId != null) {
        await loadLoans(loan.tontineId!);
      }
    } catch (e) {
      _logger.severe('Error voting for loan: $e');
      rethrow;
    }
  }

  /// Approbation directe par le président.
  Future<void> approveLoan(int id) async {
    try {
      await _loanService.approveLoan(id);
      await _notificationService.showNotification(
        title: 'Prêt approuvé',
        body: 'Le prêt a été approuvé',
        payload: '/loan',
      );
      final loan = _loans.firstWhere((l) => l.id == id);
      if (loan.tontineId != null) await loadLoans(loan.tontineId!);
    } catch (e) {
      _logger.severe('Error approving loan: $e');
      rethrow;
    }
  }

  /// Rejet par le président.
  Future<void> rejectLoan(int id, String reason) async {
    try {
      await _loanService.rejectLoan(id, reason);
      await _notificationService.showNotification(
        title: 'Prêt rejeté',
        body: 'Le prêt a été rejeté',
        payload: '/loan',
      );
      final loan = _loans.firstWhere((l) => l.id == id);
      if (loan.tontineId != null) await loadLoans(loan.tontineId!);
    } catch (e) {
      _logger.severe('Error rejecting loan: $e');
      rethrow;
    }
  }

  /// Charge les remboursements d'un prêt.
  Future<void> loadRepayments(int loanId) async {
    try {
      _repayments = await _loanService.getRepayments(loanId);
      notifyListeners();
    } catch (e) {
      _logger.severe('Error loading repayments: $e');
    }
  }

  /// Enregistre un remboursement.
  Future<void> recordRepayment(int loanId, CreateLoanRepaymentDto dto) async {
    try {
      await _loanService.recordRepayment(loanId, dto);
      await loadRepayments(loanId);
      // Recharger aussi la liste des prêts (statut peut changer en PAID)
      final loan = _loans.firstWhere((l) => l.id == loanId,
          orElse: () => _loans.first);
      if (loan.tontineId != null) await loadLoans(loan.tontineId!);
      await _notificationService.showNotification(
        title: 'Remboursement enregistré',
        body: 'Le remboursement a été enregistré avec succès',
        payload: '/loan',
      );
    } catch (e) {
      _logger.severe('Error recording repayment: $e');
      rethrow;
    }
  }
}
