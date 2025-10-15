import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../providers/models/deposit.dart';
import '../../../providers/models/enum/deposit_reason.dart';
import '../../../providers/models/enum/status_deposit.dart';
import '../../../providers/tontine_provider.dart';
import '../../../theme/app_theme.dart';
import 'deposit_details_dialog.dart';

class DepositListItem extends StatelessWidget {
  final Deposit deposit;
  final TontineProvider tontineProvider;
  final int tontineId;

  const DepositListItem({
    super.key,
    required this.deposit,
    required this.tontineProvider,
    required this.tontineId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withAlpha(30),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => _showDetails(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône selon le type de mouvement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getDepositReasonColor().withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDepositReasonIcon(),
                    color: _getDepositReasonColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              deposit.reasons ?? 'Mouvement',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Badge de statut
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              deposit.status.displayName,
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Par ${deposit.author.firstname} ${deposit.author.lastname}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy à HH:mm')
                            .format(deposit.creationDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Montant
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${deposit.amount.toStringAsFixed(0)} ${deposit.currency.name}',
                      style: TextStyle(
                        color: _getAmountColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      deposit.amount >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: _getAmountColor(),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDepositReasonIcon() {
    final reason = depositReasonFromString(deposit.reasons ?? '');
    switch (reason) {
      case DepositReason.VERSEMENT:
        return Icons.arrow_upward;
      case DepositReason.REMBOURSEMENT:
        return Icons.arrow_downward;
      case DepositReason.SANCTION:
        return Icons.warning;
      case DepositReason.AUTRE:
        return Icons.more_horiz;
    }
  }

  Color _getDepositReasonColor() {
    final reason = depositReasonFromString(deposit.reasons ?? '');
    switch (reason) {
      case DepositReason.VERSEMENT:
        return AppColors.success;
      case DepositReason.REMBOURSEMENT:
        return AppColors.primary;
      case DepositReason.SANCTION:
        return AppColors.warning;
      case DepositReason.AUTRE:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor() {
    switch (deposit.status) {
      case StatusDeposit.PENDING:
        return AppColors.warning;
      case StatusDeposit.VALIDATED:
        return AppColors.success;
      case StatusDeposit.REJECTED:
        return AppColors.error;
    }
  }

  Color _getAmountColor() {
    switch (deposit.status) {
      case StatusDeposit.PENDING:
        return AppColors.textSecondary;
      case StatusDeposit.VALIDATED:
        return deposit.amount >= 0 ? AppColors.success : AppColors.error;
      case StatusDeposit.REJECTED:
        return AppColors.textSecondary;
    }
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DepositDetailsDialog(
          deposit: deposit,
          tontineProvider: tontineProvider,
          tontineId: tontineId,
        );
      },
    );
  }
}
