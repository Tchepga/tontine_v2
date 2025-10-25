import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/providers/models/enum/status_loan.dart';
import 'package:tontine_v2/src/providers/models/enum/role.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import 'package:tontine_v2/src/providers/models/member.dart';
import '../../providers/models/loan.dart';
import '../../providers/models/tontine.dart';
import '../../providers/loan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/status_badge.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

import '../services/dto/loan_dto.dart';

class LoanView extends StatefulWidget {
  static const routeName = '/loan';
  const LoanView({super.key});

  @override
  State<LoanView> createState() => _LoanViewState();
}

class _LoanViewState extends State<LoanView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      await loanProvider.loadLoans(tontineProvider.currentTontine!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TontineProvider, LoanProvider, AuthProvider>(
      builder: (context, tontineProvider, loanProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final currentUser = authProvider.currentUser;
        final loans = loanProvider.loans;

        // Séparer les prêts de l'utilisateur des autres prêts
        final myLoans =
            loans.where((loan) => loan.author.id == currentUser?.id).toList();
        final otherLoans =
            loans.where((loan) => loan.author.id != currentUser?.id).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Prêts'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildRateCard(currentTontine),
              const SizedBox(height: 16),
              _buildLoanStatistics(loans),
              const SizedBox(height: 16),
              if (myLoans.isNotEmpty) ...[
                _buildSectionTitle('Mes prêts', Icons.person),
                const SizedBox(height: 16),
                ...myLoans.map((loan) =>
                    _buildLoanCard(loan, true, currentTontine, currentUser)),
                const SizedBox(height: 24),
              ],
              if (otherLoans.isNotEmpty) ...[
                _buildSectionTitle('Autres prêts', Icons.people),
                const SizedBox(height: 16),
                ...otherLoans.map((loan) =>
                    _buildLoanCard(loan, false, currentTontine, currentUser)),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'loan_fab',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: () =>
                _showCreateLoanDialog(context, tontineProvider, loanProvider),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildLoanCard(
      Loan loan, bool isMyLoan, Tontine? currentTontine, Member? currentUser) {
    final canManageStatus = currentUser?.user?.roles?.any(
            (role) => role == Role.ACCOUNT_MANAGER || role == Role.PRESIDENT) ??
        false;

    return ModernCard(
      type: _getLoanCardType(loan.status),
      icon: _getLoanIcon(loan.status),
      title: '${loan.amount} ${loan.currency.displayName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emprunteur: ${loan.author.firstname} ${loan.author.lastname}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Échéance: ${DateFormat('dd/MM/yyyy').format(loan.redemptionDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votes: ${loan.voters?.length ?? 0}/${currentTontine?.members.length ?? 0}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _getStatusBadge(loan.status),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton de vote pour les membres
                      if (loan.status == StatusLoan.PENDING)
                        IconButton(
                          icon: Icon(
                            loan.voters?.any(
                                        (voter) => voter == currentUser?.id) ??
                                    false
                                ? Icons.how_to_vote
                                : Icons.how_to_vote_outlined,
                            color: loan.voters?.any(
                                        (voter) => voter == currentUser?.id) ??
                                    false
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          onPressed: () => _handleVote(loan, currentUser),
                          tooltip: loan.voters?.any(
                                      (voter) => voter == currentUser?.id) ??
                                  false
                              ? 'Vous avez voté'
                              : 'Voter',
                        ),
                      // Bouton de gestion de statut pour trésorier/président
                      if (canManageStatus &&
                          loan.status != StatusLoan.PAID &&
                          loan.status != StatusLoan.CANCELLED)
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _showStatusManagementDialog(loan),
                          tooltip: 'Modifier le statut',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  ModernCardType _getLoanCardType(StatusLoan status) {
    switch (status) {
      case StatusLoan.PENDING:
        return ModernCardType.warning;
      case StatusLoan.APPROVED:
        return ModernCardType.success;
      case StatusLoan.REJECTED:
        return ModernCardType.error;
      case StatusLoan.PAID:
        return ModernCardType.info;
      case StatusLoan.CANCELLED:
        return ModernCardType.secondary;
    }
  }

  IconData _getLoanIcon(StatusLoan status) {
    switch (status) {
      case StatusLoan.PENDING:
        return Icons.pending_actions;
      case StatusLoan.APPROVED:
        return Icons.check_circle;
      case StatusLoan.REJECTED:
        return Icons.cancel;
      case StatusLoan.PAID:
        return Icons.paid;
      case StatusLoan.CANCELLED:
        return Icons.block;
    }
  }

  Widget _getStatusBadge(StatusLoan status) {
    switch (status) {
      case StatusLoan.PENDING:
        return const PendingBadge(text: 'En attente');
      case StatusLoan.APPROVED:
        return const SuccessBadge(text: 'Approuvé');
      case StatusLoan.REJECTED:
        return const ErrorBadge(text: 'Rejeté');
      case StatusLoan.PAID:
        return const InfoBadge(text: 'Remboursé');
      case StatusLoan.CANCELLED:
        return const StatusBadge(
          text: 'Annulé',
          color: AppColors.textSecondary,
          icon: Icons.block,
        );
    }
  }

  Future<void> _handleVote(Loan loan, Member? currentUser) async {
    if (currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Utilisateur non connecté'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    try {
      await Provider.of<LoanProvider>(context, listen: false).voteLoan(loan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vote enregistré'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors du vote'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _showCreateLoanDialog(BuildContext context,
      TontineProvider tontineProvider, LoanProvider loanProvider) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final redemptionDateController = TextEditingController();
    final currentTontine = tontineProvider.currentTontine;
    DateTime selectedDate = DateTime.now()
        .add(const Duration(days: 30)); // Date par défaut à 30 jours

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Nouveau prêt'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    prefixIcon: const Icon(Icons.monetization_on),
                    suffixText: 'FCFA',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le montant est requis';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Montant invalide';
                    }
                    if (amount < currentTontine!.config.minLoanAmount) {
                      return 'Le montant minimum est de ${currentTontine.config.minLoanAmount} FCFA';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: redemptionDateController,
                  decoration: InputDecoration(
                    labelText: 'Date d\'échéance',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                      redemptionDateController.text =
                          DateFormat('dd/MM/yyyy').format(picked);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La date d\'échéance est requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(30)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.percent,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Taux d\'intérêt: ${currentTontine?.config.defaultLoanRate}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    currentTontine != null) {
                  try {
                    if (!mounted) return;
                    final loanDto = CreateLoanDto(
                      amount: double.parse(amountController.text),
                      currency: currentTontine.cashFlow.currency,
                      tontineId: currentTontine.id,
                      redemptionDate: selectedDate,
                    );

                    await loanProvider.createLoan(loanDto);
                    await loanProvider.loadLoans(currentTontine.id);

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Prêt créé avec succès. Il devra être validé par la suite'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  } catch (e) {
                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Erreur lors de la création du prêt'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRateCard(Tontine? currentTontine) {
    return ModernCard(
      type: ModernCardType.primary,
      icon: Icons.percent,
      title: 'Taux d\'intérêt actuel',
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentTontine?.config.defaultLoanRate ?? 0}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Taux d\'intérêt par défaut',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanStatistics(List<Loan> loans) {
    final activeLoans =
        loans.where((loan) => loan.status == StatusLoan.APPROVED).length;
    final pendingLoans =
        loans.where((loan) => loan.status == StatusLoan.PENDING).length;
    final totalAmount = loans
        .where((loan) => loan.status == StatusLoan.APPROVED)
        .fold(0.0, (sum, loan) => sum + loan.amount);

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Prêts actifs',
            value: activeLoans.toString(),
            icon: Icons.account_balance_wallet,
            type: ModernCardType.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'En attente',
            value: pendingLoans.toString(),
            icon: Icons.pending_actions,
            type: ModernCardType.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Total prêté',
            value: '${totalAmount.toStringAsFixed(0)} FCFA',
            icon: Icons.monetization_on,
            type: ModernCardType.info,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showStatusManagementDialog(Loan loan) {
    StatusLoan selectedStatus = loan.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Modifier le statut'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations du prêt
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prêt de ${loan.amount} ${loan.currency.displayName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Emprunteur: ${loan.author.firstname} ${loan.author.lastname}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Statut actuel: ${loan.status.displayName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sélection du nouveau statut
              const Text(
                'Nouveau statut:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RadioGroup<StatusLoan>(
                groupValue: selectedStatus,
                onChanged: (StatusLoan? value) {
                  if (value != null && _canChangeToStatus(loan.status, value)) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
                child: Column(
                  children: StatusLoan.values.map((status) {
                    bool canSelect = _canChangeToStatus(loan.status, status);
                    return RadioListTile<StatusLoan>(
                      value: status,
                      title: Text(
                        status.displayName,
                        style: TextStyle(
                          color: canSelect
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        _getStatusDescription(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: canSelect
                              ? AppColors.textSecondary
                              : AppColors.textLight,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: selectedStatus != loan.status
                  ? () async {
                      await _updateLoanStatus(loan, selectedStatus);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  bool _canChangeToStatus(StatusLoan currentStatus, StatusLoan newStatus) {
    // Logique de transition des statuts
    switch (currentStatus) {
      case StatusLoan.PENDING:
        return newStatus == StatusLoan.APPROVED ||
            newStatus == StatusLoan.REJECTED ||
            newStatus == StatusLoan.CANCELLED;
      case StatusLoan.APPROVED:
        return newStatus == StatusLoan.PAID ||
            newStatus == StatusLoan.CANCELLED;
      case StatusLoan.REJECTED:
        return newStatus == StatusLoan.PENDING ||
            newStatus == StatusLoan.CANCELLED;
      case StatusLoan.PAID:
        return false; // Un prêt payé ne peut plus changer de statut
      case StatusLoan.CANCELLED:
        return newStatus == StatusLoan.PENDING; // Peut être remis en attente
    }
  }

  String _getStatusDescription(StatusLoan status) {
    switch (status) {
      case StatusLoan.PENDING:
        return 'En attente de validation par les membres';
      case StatusLoan.APPROVED:
        return 'Prêt approuvé et accordé';
      case StatusLoan.REJECTED:
        return 'Prêt rejeté par les membres';
      case StatusLoan.PAID:
        return 'Prêt entièrement remboursé';
      case StatusLoan.CANCELLED:
        return 'Prêt annulé';
    }
  }

  Future<void> _updateLoanStatus(Loan loan, StatusLoan newStatus) async {
    try {
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);

      // TODO: Implémenter la méthode updateLoanStatus dans LoanProvider
      // await loanProvider.updateLoanStatus(loan.id, newStatus);

      // Pour l'instant, on simule la mise à jour
      await Future.delayed(const Duration(seconds: 1));

      // Recharger les prêts
      await loanProvider.loadLoans(tontineProvider.currentTontine!.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut modifié vers: ${newStatus.displayName}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de la modification du statut'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
