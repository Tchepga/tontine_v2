import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/providers/models/enum/status_deposit.dart';
import 'package:tontine_v2/src/providers/models/enum/deposit_type.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
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
            (deposit.author != null &&
                currentUser?.user?.username ==
                    deposit.author!.user?.username &&
                deposit.status == StatusDeposit.PENDING);

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          backgroundColor: Colors.transparent,
          child: _buildContent(context, canValidate, canEdit),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, bool canValidate, bool canEdit) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoSection(context),
                if (canValidate && deposit.status == StatusDeposit.PENDING)
                  _buildValidateButton(context),
                if (canEdit) _buildEditDeleteRow(context),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final statusColor = _getStatusColor();
    final typeColor =
        deposit.type == DepositType.FOND ? AppColors.info : AppColors.success;
    final typeIcon =
        deposit.type == DepositType.FOND ? Icons.savings : Icons.arrow_upward;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor,
            typeColor.withAlpha(200),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne type + bouton fermer
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      deposit.type.displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Badge statut
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(100)),
                ),
                child: Text(
                  deposit.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Montant principal
          Text(
            '${deposit.amount.toStringAsFixed(2)} ${deposit.currency.displayName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deposit.displayLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION INFOS ────────────────────────────────────────────────────────────

  Widget _buildInfoSection(BuildContext context) {
    final authorName = deposit.author != null
        ? '${deposit.author!.firstname ?? ''} ${deposit.author!.lastname ?? ''}'
            .trim()
        : 'Inconnu';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Membre',
            value: authorName.isEmpty ? 'Inconnu' : authorName,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: DateFormat('dd/MM/yyyy à HH:mm')
                .format(deposit.creationDate),
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Devise',
            value: deposit.currency.displayName,
          ),
          if (deposit.comment != null && deposit.comment!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow(
              icon: Icons.notes_outlined,
              label: 'Commentaire',
              value: deposit.comment!,
              valueMaxLines: 3,
            ),
          ],
          if (deposit.reasons != null && deposit.reasons!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow(
              icon: Icons.label_outline,
              label: 'Catégorie',
              value: deposit.reasons!,
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int valueMaxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: valueMaxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: AppColors.border);
  }

  // ── BOUTON VALIDER ────────────────────────────────────────────────────────────

  Widget _buildValidateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _validateDeposit(context),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: const Text(
            'Valider le versement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ── BOUTONS EDIT / DELETE ─────────────────────────────────────────────────────

  Widget _buildEditDeleteRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(child: _buildEditButton(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildDeleteButton(context)),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return OutlinedButton.icon(
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
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: const Text('Modifier'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _showDeleteConfirmation(context),
      icon: const Icon(Icons.delete_outline, size: 16),
      label: const Text('Supprimer'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.error,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ── ACTIONS ───────────────────────────────────────────────────────────────────

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

  Future<void> _validateDeposit(BuildContext context) async {
    try {
      await tontineProvider.validateDeposit(
          tontineId, deposit.id, StatusDeposit.VALIDATED);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Versement validé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
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

  void _showDeleteConfirmation(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce mouvement ?'),
        content: const Text(
            'Cette action est irréversible. Le mouvement sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => _handleDelete(context),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
