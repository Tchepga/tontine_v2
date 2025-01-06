import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/models/tontine.dart';
import '../../providers/tontine_provider.dart';
import 'edit_mouvement.dart';
import 'widgets/deposit_list_item.dart';
import 'package:tontine_v2/src/providers/models/enum/currency.dart';

class CashflowView extends StatefulWidget {
  const CashflowView({super.key});
  static const routeName = '/cashflow';

  @override
  State<CashflowView> createState() => _CashflowViewState();
}

class _CashflowViewState extends State<CashflowView> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trésorerie'),
        actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showDateFilter(context),
                        ),
                      ],
                      ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBalanceCard(currentTontine),
              const SizedBox(height: 16),
              const Text(
                'Historique des mouvements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...deposits.map((deposit) => DepositListItem(
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
        );
      },
    );
  }

  Widget _buildBalanceCard(Tontine? currentTontine) {
    return Card(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
              '${currentTontine?.cashFlow.amount ?? 0} ${currentTontine?.cashFlow.currency.displayName ?? ''}',
              style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
