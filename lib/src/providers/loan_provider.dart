import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/loan.dart';
import '../screen/services/loan_service.dart';
import '../screen/services/dto/loan_dto.dart';

class LoanProvider extends ChangeNotifier {
  final _loanService = LoanService();
  final _logger = Logger('LoanProvider');
  List<Loan> _loans = [];
  bool _isLoading = false;

  List<Loan> get loans => _loans;
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
    } catch (e) {
      _logger.severe('Error creating loan: $e');
      rethrow;
    }
  }

  Future<void> updateLoan(int id, UpdateLoanDto loanDto) async {
    try {
      await _loanService.updateLoan(id, loanDto);
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
      // Recharger la liste après le vote
      final loan = _loans.firstWhere((l) => l.id == id);
      if (loan.tontineId != null) {
        await loadLoans(loan.tontineId!);
      }
    } catch (e) {
      _logger.severe('Error voting for loan: $e');
      rethrow;
    }
  }
} 