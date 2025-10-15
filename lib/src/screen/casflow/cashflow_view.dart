import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/models/tontine.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/action_menu.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/modern_card.dart';
import '../../theme/app_theme.dart';
import 'edit_mouvement.dart';
import 'widgets/deposit_list_item.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import '../../providers/models/enum/deposit_reason.dart';
import '../../providers/models/enum/status_deposit.dart';
import '../../providers/auth_provider.dart';

class CashflowView extends StatefulWidget {
  const CashflowView({super.key});
  static const routeName = '/cashflow';

  @override
  State<CashflowView> createState() => _CashflowViewState();
}

class _CashflowViewState extends State<CashflowView> {
  DepositReason? _selectedReason;
  String _searchName = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        tontineProvider.loadDeposits(tontineProvider.currentTontine!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TontineProvider, AuthProvider>(
      builder: (context, tontineProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final deposits = tontineProvider.deposits;
        final canValidate = authProvider.canValidateDeposits();

        // Filtrage
        final filteredDeposits = deposits.where((deposit) {
          final matchType = _selectedReason == null ||
              (deposit.reasons != null &&
                  deposit.reasons!.toLowerCase() ==
                      _selectedReason!.displayName.toLowerCase());
          final matchName = _searchName.isEmpty ||
              (deposit.author.firstname
                      ?.toLowerCase()
                      .contains(_searchName.toLowerCase()) ??
                  false) ||
              (deposit.author.lastname
                      ?.toLowerCase()
                      .contains(_searchName.toLowerCase()) ??
                  false);
          return matchType && matchName;
        }).toList();

        return Scaffold(
          appBar: ActionMenu(title: 'Trésorerie', showBackButton: true),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBalanceCard(currentTontine),
              const SizedBox(height: 16),
              // Filtres modernisés
              _buildFiltersSection(),
              const SizedBox(height: 16),
              // Section versements en attente (si président/trésorier)
              if (canValidate) ...[
                _buildPendingDepositsSection(
                    deposits, tontineProvider, currentTontine!.id),
                const SizedBox(height: 16),
              ],
              // Titre de section modernisé
              _buildSectionTitle('Mouvements', Icons.list_alt),
              const SizedBox(height: 16),
              if (filteredDeposits.isEmpty)
                _buildEmptyState()
              else
                ...filteredDeposits.map((deposit) => DepositListItem(
                      deposit: deposit,
                      tontineProvider: tontineProvider,
                      tontineId: currentTontine!.id,
                    )),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'cashflow_fab',
            onPressed: () =>
                _showAddDeposit(context, tontineProvider, currentTontine!.id),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildBalanceCard(Tontine? currentTontine) {
    return ModernCard(
      type: ModernCardType.primary,
      icon: Icons.account_balance_wallet,
      title: 'Solde actuel',
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
                  Icons.monetization_on,
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
                      '${currentTontine?.cashFlow.amount ?? 0} ${currentTontine?.cashFlow.currency.displayName ?? ''}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trésorerie disponible',
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

  Widget _buildFiltersSection() {
    return ModernCard(
      type: ModernCardType.info,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<DepositReason>(
              initialValue: _selectedReason,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Type',
                prefixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<DepositReason>(
                  value: null,
                  child: Text('Tous'),
                ),
                ...DepositReason.values.map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason.displayName),
                    ))
              ],
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Nom',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchName = value;
                });
              },
            ),
          ),
        ],
      ),
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

  Widget _buildPendingDepositsSection(
      List deposits, TontineProvider tontineProvider, int tontineId) {
    final pendingDeposits = deposits
        .where((deposit) => deposit.status == StatusDeposit.PENDING)
        .toList();

    if (pendingDeposits.isEmpty) return const SizedBox.shrink();

    return ModernCard(
      type: ModernCardType.warning,
      icon: Icons.pending_actions,
      title: 'Versements en attente (${pendingDeposits.length})',
      child: Column(
        children: [
          ...pendingDeposits.take(3).map((deposit) =>
              _buildPendingDepositItem(deposit, tontineProvider, tontineId)),
          if (pendingDeposits.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${pendingDeposits.length - 3} autres en attente',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingDepositItem(
      deposit, TontineProvider tontineProvider, int tontineId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withAlpha(50)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${deposit.author.firstname} ${deposit.author.lastname}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${deposit.amount} ${deposit.currency.displayName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    _validateDeposit(deposit.id, tontineProvider, tontineId),
                icon: const Icon(Icons.check_circle, color: AppColors.success),
                tooltip: 'Valider',
              ),
              IconButton(
                onPressed: () =>
                    _rejectDeposit(deposit.id, tontineProvider, tontineId),
                icon: const Icon(Icons.cancel, color: AppColors.error),
                tooltip: 'Rejeter',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ModernCard(
      type: ModernCardType.info,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun mouvement trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajustez vos filtres ou ajoutez un nouveau mouvement',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _validateDeposit(
      int depositId, TontineProvider tontineProvider, int tontineId) {
    // TODO: Implémenter la validation du dépôt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Validation du versement...'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectDeposit(
      int depositId, TontineProvider tontineProvider, int tontineId) {
    // TODO: Implémenter le rejet du dépôt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rejet du versement...'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showAddDeposit(
      BuildContext context, TontineProvider tontineProvider, int tontineId) {
    if (tontineProvider.canAddDeposit()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const EditMouvement();
        },
      ).then((_) {
        tontineProvider.loadTontines();
        tontineProvider.loadDeposits(tontineId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter des membres à la tontine."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
