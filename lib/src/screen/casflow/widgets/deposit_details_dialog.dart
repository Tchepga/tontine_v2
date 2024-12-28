import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tontine_v2/src/models/enum/status_deposit.dart';
import '../../../models/deposit.dart';
import '../../../providers/tontine_provider.dart';
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
                const Text(
                  'Détails du mouvement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildDetailRow('Montant', '${deposit.amount} ${deposit.currency.name}'),
                _buildDetailRow('Date', DateFormat('dd/MM/yyyy').format(deposit.creationDate)),
                _buildDetailRow('Raison', deposit.reasons ?? 'Non spécifiée'),
                _buildDetailRow('Statut', deposit.status.displayName),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEditButton(context),
                    _buildDeleteButton(context),
                  ],
                )
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