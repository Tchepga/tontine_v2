import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import 'package:intl/intl.dart';

class RapportView extends StatefulWidget {
  static const routeName = '/rapport';
  const RapportView({super.key});

  @override
  State<RapportView> createState() => _RapportViewState();
}

class _RapportViewState extends State<RapportView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        tontineProvider.getRapportsForTontine(tontineProvider.currentTontine!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TontineProvider>(
      builder: (context, tontineProvider, child) {
        final rapports = tontineProvider.currentTontine?.rapports ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Rapports de réunion'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rapports.length,
            itemBuilder: (context, index) {
              final rapport = rapports[index];
              return Card(
                child: ListTile(
                  title: Text(rapport.title),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(rapport.createdAt),
                  ),
                  trailing: Text(rapport.author.firstname ?? ''),
                  onTap: () {
                    // Afficher les détails du rapport
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rapport.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(rapport.content),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Fermer'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Ouvrir le formulaire de création de rapport
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }
} 