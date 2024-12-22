import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tontine_provider.dart';
import '../dashboard_view.dart';
import 'package:logging/logging.dart';

class SelectTontineView extends StatefulWidget {
  static const routeName = '/select-tontine';
  const SelectTontineView({super.key});

  @override
  State<SelectTontineView> createState() => _SelectTontineViewState();
}

class _SelectTontineViewState extends State<SelectTontineView> {
  final _logger = Logger('SelectTontineView');

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTontines());
    if(Provider.of<TontineProvider>(context, listen: false).currentTontine != null) {
      Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
    }

  }

  Future<void> _loadTontines() async {
    try {
      await Provider.of<TontineProvider>(context, listen: false).loadTontines();
    } catch (e) {
      _logger.severe('Error loading tontines: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des tontines'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner une tontine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<TontineProvider>(
        builder: (context, tontineProvider, child) {
          
          if (tontineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tontineProvider.tontines.isEmpty) {
            return const Center(
              child: Text('Aucune tontine disponible'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tontineProvider.tontines.length,
            itemBuilder: (context, index) {
              final tontine = tontineProvider.tontines[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    tontine.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${tontine.members.length} membres'),
                      Text('Solde: ${tontine.cashFlow.amount} ${tontine.cashFlow.currency}'),
                    ],
                  ),
                  trailing: tontine.isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () async {
                    await tontineProvider.setCurrentTontine(tontine);
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 