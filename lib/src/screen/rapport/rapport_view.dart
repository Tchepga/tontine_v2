import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import '../services/dto/rapport_dto.dart';
import 'package:intl/intl.dart';

class RapportView extends StatefulWidget {
  static const routeName = '/rapport';
  const RapportView({super.key});

  @override
  State<RapportView> createState() => _RapportViewState();
}

class _RapportViewState extends State<RapportView> {
  final QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        await tontineProvider.getRapportsForTontine(tontineProvider.currentTontine!.id);
      }
    });
  }

  void _showCreateRapportDialog(BuildContext context, TontineProvider tontineProvider) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(
              maxWidth: 800,
              maxHeight: 800,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nouveau rapport',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le titre est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Contenu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          QuillToolbar.simple(
                            controller: _controller,
                            configurations: const QuillSimpleToolbarConfigurations(
                              showBackgroundColorButton: false,
                              showAlignmentButtons: false,
                              showColorButton: false,
                              showDividers: false,
                              showIndent: false,
                              showHeaderStyle: false,
                              showListBullets: false,
                              showListNumbers: false,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: QuillEditor.basic(
                                controller: _controller,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              final rapportDto = CreateMeetingRapportDto(
                                title: titleController.text,
                                content: _controller.document.toPlainText(),
                              );
                              
                              await tontineProvider.addRapport(
                                tontineProvider.currentTontine!.id,
                                rapportDto,
                              );

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rapport créé avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erreur lors de la création'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                  onTap: () => _showRapportDetails(context, rapport),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateRapportDialog(context, tontineProvider),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  void _showRapportDetails(BuildContext context, rapport) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Par ${rapport.author.firstname} ${rapport.author.lastname}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
  }
} 