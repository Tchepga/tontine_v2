import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tontine_v2/src/models/enum/status_deposit.dart';
import '../../providers/tontine_provider.dart';
import 'edit_mouvement.dart';

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
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
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
        if (deposits.isEmpty) {
          tontineProvider.loadDeposits(currentTontine!.id);
        }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trésorerie'),
        actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () async {
                  final DateTimeRange? pickedDateRange =
                      await showDateRangePicker(
                    context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                    initialDateRange: DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 7)),
                      end: DateTime.now(),
                    ),
                  );
                  if (pickedDateRange != null) {
                    // Filtrer les dépôts par date
                  }
                },
          ),
        ],
      ),
      body: ListView(
            padding: const EdgeInsets.all(16),
        children: [
              Card(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                        '${currentTontine?.cashFlow.amount ?? 0} ${currentTontine?.cashFlow.currency.name ?? ''}',
                        style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                      const Text(
                        'Solde actuel',
                        style: TextStyle(
                          color: Colors.white,
                      ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Historique des mouvements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...deposits.map((deposit) => Card(
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
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
                                      spacing: 16,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Détails du mouvement',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Montant: '),
                                            Text(
                                                '${deposit.amount} ${deposit.currency.name}'),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Date: '),
                                            Text(DateFormat('dd/MM/yyyy')
                                                .format(deposit.creationDate)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Raison: '),
                                            Text(deposit.reasons ??
                                                'Non spécifiée'),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Statut: '),
                                            Text(deposit.status.displayName,
                                                style: TextStyle(
                                                    color: deposit.status ==
                                                            StatusDeposit
                                                                .VALIDATED
                                                        ? Colors.green
                                                        : null)),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return EditMouvement(deposit: deposit);
                                                  },
                                                ).then((_) {
                                                  tontineProvider.loadTontines();
                                                  tontineProvider.loadDeposits(currentTontine!.id);
                                                });
                                              },
                                              child: const Text('modifier'),
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                                                      title: const Text('Confirmation'),
                                                      content: const Text('Voulez-vous vraiment supprimer ce mouvement ?'),
                      actions: [
                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(),
                                                          child: const Text('Annuler'),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () async {
                                                            try {
                                                              await tontineProvider.deleteDeposit(
                                                                currentTontine!.id,
                                                                deposit.id,
                                                              );
                                                              if (!mounted) return;
                                                              Navigator.of(context).pop(); // Ferme le dialog de confirmation
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text('Mouvement supprimé avec succès'),
                                                                  backgroundColor: Colors.green,
                                                                ),
                                                              );
                                                              // Recharger les dépôts
                                                              tontineProvider.loadDeposits(currentTontine.id);
                                                            } catch (e) {
                                                              if (!mounted) return;
                            Navigator.of(context).pop();
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text('Erreur lors de la suppression'),
                                                                  backgroundColor: Colors.red,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          style: FilledButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                          ),
                                                          child: const Text('Supprimer'),
                        ),
                      ],
                    );
                  },
                );
              },
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                              ),
                                              child: const Text('supprimer'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 26,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      radius: 20,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      title: Text(deposit.reasons ?? ''),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(deposit.creationDate),
                      ),
                      trailing: Text(
                        '${deposit.amount} ${deposit.currency.name}',
                        style: TextStyle(
                          color:
                              deposit.amount >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
              ),
            ),
          ),
                  )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
                builder: (BuildContext context) {
                  return const EditMouvement();
                },
              ).then((_) {
                tontineProvider.loadTontines();
                tontineProvider.loadDeposits(currentTontine!.id);
              });
        },
        child: const Icon(Icons.add),
      ),
        );
      },
    );
  }
}
