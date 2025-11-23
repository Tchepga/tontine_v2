import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/models/tontine.dart';
import '../../providers/models/deposit.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/action_menu.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/responsive_padding.dart';
import '../../utils/responsive_helper.dart';
import '../../theme/app_theme.dart';
import 'edit_mouvement.dart';
import 'widgets/deposit_list_item.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import '../../utils/currency_utils.dart';
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
            padding: ResponsiveHelper.getAdaptivePadding(context, all: 16.0),
            children: [
              _buildBalanceCard(context, currentTontine),
              ResponsiveSpacing(height: 16),
              // Filtres modernisés
              _buildFiltersSection(context),
              ResponsiveSpacing(height: 16),
              // Section versements en attente (si président/trésorier)
              if (canValidate) ...[
                _buildPendingDepositsSection(
                    context, deposits, tontineProvider, currentTontine!.id),
                ResponsiveSpacing(height: 16),
              ],
              // Titre de section modernisé
              _buildSectionTitle(context, 'Mouvements', Icons.list_alt),
              ResponsiveSpacing(height: 16),
              if (filteredDeposits.isEmpty)
                _buildEmptyState(context)
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

  Widget _buildBalanceCard(BuildContext context, Tontine? currentTontine) {
    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 20.0);
    final iconPadding = ResponsiveHelper.getAdaptivePadding(context, all: 12.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 32.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 16.0);
    final fontSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 24.0,
      medium: 26.0,
      large: 28.0,
    );

    return ModernCard(
      type: ModernCardType.primary,
      icon: Icons.account_balance_wallet,
      title: 'Solde actuel',
      padding: cardPadding,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: iconPadding,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyUtils.formatAmountForCard(
                          currentTontine?.cashFlow.amount ?? 0,
                          currentTontine?.cashFlow.currency ?? Currency.EUR),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: spacing * 0.25),
                    Text(
                      'Trésorerie disponible',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveValue(
                          context,
                          small: 12.0,
                          medium: 13.0,
                          large: 14.0,
                        ),
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

  Widget _buildFiltersSection(BuildContext context) {
    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 16.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 12.0);
    final contentPadding = ResponsiveHelper.getAdaptivePadding(
      context,
      horizontal: 12.0,
      vertical: 8.0,
    );

    return ModernCard(
      type: ModernCardType.info,
      padding: cardPadding,
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
                contentPadding: contentPadding,
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
          SizedBox(width: spacing),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Nom',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: contentPadding,
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final iconPadding = ResponsiveHelper.getAdaptivePadding(context, all: 8.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 20.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 12.0);
    final fontSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 16.0,
      medium: 17.0,
      large: 18.0,
    );

    return Row(
      children: [
        Container(
          padding: iconPadding,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: iconSize,
          ),
        ),
        SizedBox(width: spacing),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingDepositsSection(BuildContext context,
      List<Deposit> deposits, TontineProvider tontineProvider, int tontineId) {
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
          ...pendingDeposits.take(3).map((deposit) => _buildPendingDepositItem(
              context, deposit, tontineProvider, tontineId)),
          if (pendingDeposits.length > 3)
            Padding(
              padding: EdgeInsets.only(
                top: ResponsiveHelper.getAdaptiveSpacing(context, base: 8.0),
              ),
              child: Text(
                '+ ${pendingDeposits.length - 3} autres en attente',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 11.0,
                    medium: 11.5,
                    large: 12.0,
                  ),
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingDepositItem(BuildContext context, Deposit deposit,
      TontineProvider tontineProvider, int tontineId) {
    final itemPadding = ResponsiveHelper.getAdaptivePadding(context, all: 12.0);
    final itemMargin = ResponsiveHelper.getAdaptiveSpacing(context, base: 8.0);

    return Container(
      margin: EdgeInsets.only(bottom: itemMargin),
      padding: itemPadding,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveHelper.getAdaptiveValue(
                      context,
                      small: 13.0,
                      medium: 14.0,
                      large: 14.0,
                    ),
                  ),
                ),
                Text(
                  CurrencyUtils.formatAmountForCard(
                      deposit.amount, deposit.currency),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveValue(
                      context,
                      small: 12.0,
                      medium: 13.0,
                      large: 14.0,
                    ),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _validateDeposit(
                  deposit.id,
                  tontineProvider,
                  tontineId,
                ),
                icon: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size:
                      ResponsiveHelper.getAdaptiveIconSize(context, base: 24.0),
                ),
                tooltip: 'Valider',
              ),
              IconButton(
                onPressed: () =>
                    _rejectDeposit(deposit.id, tontineProvider, tontineId),
                icon: Icon(
                  Icons.cancel,
                  color: AppColors.error,
                  size:
                      ResponsiveHelper.getAdaptiveIconSize(context, base: 24.0),
                ),
                tooltip: 'Rejeter',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 32.0);
    final iconPadding = ResponsiveHelper.getAdaptivePadding(context, all: 16.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 48.0);

    return ModernCard(
      type: ModernCardType.info,
      padding: cardPadding,
      child: Column(
        children: [
          Container(
            padding: iconPadding,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox,
              size: iconSize,
              color: AppColors.textSecondary,
            ),
          ),
          ResponsiveSpacing(height: 16),
          Text(
            'Aucun mouvement trouvé',
            style: TextStyle(
              fontSize: ResponsiveHelper.getAdaptiveValue(
                context,
                small: 16.0,
                medium: 17.0,
                large: 18.0,
              ),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          ResponsiveSpacing(height: 8),
          Text(
            'Ajustez vos filtres ou ajoutez un nouveau mouvement',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: ResponsiveHelper.getAdaptiveValue(
                context,
                small: 12.0,
                medium: 13.0,
                large: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateDeposit(
      int depositId, TontineProvider tontineProvider, int tontineId) async {
    try {
      await tontineProvider.validateDeposit(
          tontineId, depositId, StatusDeposit.VALIDATED);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Versement validé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la validation: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectDeposit(
      int depositId, TontineProvider tontineProvider, int tontineId) async {
    try {
      await tontineProvider.validateDeposit(
          tontineId, depositId, StatusDeposit.REJECTED);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Versement rejeté avec succès'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du rejet: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
