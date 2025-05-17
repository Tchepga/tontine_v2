import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/models/tontine.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/action_menu.dart';
import '../../widgets/menu_widget.dart';
import 'edit_mouvement.dart';
import 'widgets/deposit_list_item.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';
import '../../providers/models/enum/deposit_reason.dart';

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
      final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        tontineProvider.loadDeposits(tontineProvider.currentTontine!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TontineProvider>(
      builder: (context, tontineProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final deposits = tontineProvider.deposits;

        // Filtrage
        final filteredDeposits = deposits.where((deposit) {
          final matchType = _selectedReason == null ||
              (deposit.reasons != null && deposit.reasons!.toLowerCase() == _selectedReason!.displayName.toLowerCase());
          final matchName = _searchName.isEmpty ||
              (deposit.author.firstname?.toLowerCase().contains(_searchName.toLowerCase()) ?? false) ||
              (deposit.author.lastname?.toLowerCase().contains(_searchName.toLowerCase()) ?? false);
          return matchType && matchName;
        }).toList();

        return Scaffold(
          appBar: ActionMenu(title: 'Trésorerie', showBackButton: true),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBalanceCard(currentTontine),
              const SizedBox(height: 16),
              // Filtres
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DepositReason>(
                      value: _selectedReason,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text(
                    'Mouvements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...filteredDeposits.map((deposit) => DepositListItem(
                    deposit: deposit,
                    tontineProvider: tontineProvider,
                    tontineId: currentTontine!.id,
                  )),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDeposit(context, tontineProvider, currentTontine!.id),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildBalanceCard(Tontine? currentTontine) {
    return Card(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
              '${currentTontine?.cashFlow.amount ?? 0} ${currentTontine?.cashFlow.currency.displayName ?? ''}',
              style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
                  ),
            const Text(
                        'Solde actuel',
              style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showDateFilter(BuildContext context) async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
                            end: DateTime.now(),
                          ),
                        );
                        if (pickedDateRange != null) {
      // Implémenter le filtrage par date
    }
  }

  void _showAddDeposit(BuildContext context, TontineProvider tontineProvider, int tontineId) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
        return const EditMouvement();
      },
    ).then((_) {
      tontineProvider.loadTontines();
      tontineProvider.loadDeposits(tontineId);
    });
  }
}
