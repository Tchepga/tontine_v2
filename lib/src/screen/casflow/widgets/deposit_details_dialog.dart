import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';
import '../../../providers/models/deposit.dart';
import '../../../providers/tontine_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../edit_mouvement.dart';

class DepositDetailsDialog extends StatelessWidget {
  final Deposit deposit;
  final TontineProvider tontineProvider;
  final int tontineId;

  const DepositDetailsDialog({
    super.key,
    required this.deposit,
    required this.tontineProvider,
    required this.tontineId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final canValidate = authProvider.canValidateDeposits();
        final isPresident = authProvider.isPresident();
        final isAccountManager = authProvider.isAccountManager();
        final currentUser = authProvider.currentUser;
        final canEdit = (isPresident || isAccountManager) ||
            (currentUser?.user?.username == deposit.author.user?.username &&
                deposit.status == StatusDeposit.PENDING);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.only(
                  top: 50,
                  bottom: 16,
                  left: 24,
                  right: 24,
                ),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Détails du mouvement',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        // Badge de statut
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: _getStatusColor(), width: 1),
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
                    const SizedBox(height: 16),
                    _buildDetailRow('Montant',
                        '${deposit.amount} ${deposit.currency.name}'),
                    _buildDetailRow(
                        'Date',
                        DateFormat('dd/MM/yyyy à HH:mm')
                            .format(deposit.creationDate)),
                    _buildDetailRow('Auteur',
                        '${deposit.author.firstname} ${deposit.author.lastname}'),
                    _buildDetailRow(
                        'Raison', deposit.reasons ?? 'Non spécifiée'),
                    const SizedBox(height: 16),

                    // Boutons de validation (visible uniquement président/trésorier pour les versements en attente)
                    if (canValidate &&
                        deposit.status == StatusDeposit.PENDING) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _validateDeposit(context),
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white),
                              label: const Text('Valider',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Boutons d'édition et suppression
                    if (canEdit) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEditButton(context),
                          _buildDeleteButton(context),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 26,
                child: _buildCloseButton(context),
              ),
            ],
          ),
        );
      },
    );
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

  void _validateDeposit(BuildContext context) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Versement validé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: '),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return EditMouvement(deposit: deposit);
          },
        ).then((_) {
          tontineProvider.loadTontines();
          tontineProvider.loadDeposits(tontineId);
        });
      },
      child: const Text('modifier'),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return FilledButton(
      onPressed: () => _showDeleteConfirmation(context),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
      child: const Text('supprimer'),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.orange,
      radius: 20,
      child: IconButton(
        icon: const Icon(Icons.close),
        color: Colors.white,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer ce mouvement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => _handleDelete(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    try {
      await tontineProvider.deleteDeposit(tontineId, deposit.id);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mouvement supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
