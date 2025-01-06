import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../providers/models/rapport_meeting.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import '../services/dto/rapport_dto.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart'
    show FilePicker, FilePickerResult, FileType, PlatformFile;
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/models/enum/role.dart';

class RapportView extends StatefulWidget {
  static const routeName = '/rapport';
  const RapportView({super.key});

  @override
  State<RapportView> createState() => _RapportViewState();
}

class _RapportViewState extends State<RapportView> {
  final Logger _logger = Logger('RapportView');
  final QuillController _controller = QuillController.basic();
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        await tontineProvider
            .getRapportsForTontine(tontineProvider.currentTontine!.id);
      }
    });
  }

  void _showCreateRapportDialog(
      BuildContext context, TontineProvider tontineProvider) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Nouveau rapport'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        QuillToolbar.simple(
                          controller: _controller,
                          configurations:
                              const QuillSimpleToolbarConfigurations(
                            showAlignmentButtons: false,
                            showBackgroundColorButton: false,
                            showCenterAlignment: false,
                            showClearFormat: false,
                            showCodeBlock: false,
                            showDirection: false,
                            showIndent: false,
                            showHeaderStyle: false,
                            showQuote: false,
                            showDividers: false,
                            showInlineCode: false,
                            showJustifyAlignment: false,
                            showLineHeightButton: false,
                            showClipboardCut: false,
                            showRedo: false,
                            showUndo: false,
                            showRightAlignment: false,
                            showLeftAlignment: false,
                            showSmallButton: false,
                            showSearchButton: false,
                            showSuperscript: false,
                            showSubscript: false,
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
                  const SizedBox(height: 16),
                  _buildAttachmentSection(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final rapportDto = CreateMeetingRapportDto(
                      title: titleController.text,
                      content: _controller.document.toPlainText(),
                      attachment: _selectedFile != null
                          ? await File(_selectedFile!.path!).readAsBytes()
                          : null,
                      attachmentFilename: _selectedFile?.name,
                    );

                    await tontineProvider.addRapport(
                        tontineProvider.currentTontine!.id, rapportDto);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rapport créé avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    _logger.log(Level.SEVERE, 'Error creating rapport: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de la création du rapport.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pièce jointe',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.file_present
                          : Icons.attach_file,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile?.name ?? 'Aucun fichier sélectionné',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_selectedFile != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _selectedFile = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _pickFile,
              child: const Text('Choisir'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      _logger.log(Level.INFO, 'Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sélection du fichier'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final canEdit = currentUser?.user?.roles
            ?.any((role) => role == Role.PRESIDENT || role == Role.SECRETARY) ??
        false;

    return Consumer<TontineProvider>(
      builder: (context, tontineProvider, child) {
        final rapports = tontineProvider.currentTontine?.rapports ?? [];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rapports de réunion'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: rapports.isEmpty
              ? const Center(child: Text('Aucun rapport trouvé'))
              : ListView.builder(
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
                        trailing: canEdit
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    onPressed: () => _showCreateRapportDialog(
                                        context, tontineProvider),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(
                                        context, rapport),
                                  ),
                                ],
                              )
                            : null,
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

  void _showRapportDetails(BuildContext context, RapportMeeting rapport) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            rapport.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(rapport.content),
                    if (rapport.attachmentFilename != null) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _downloadAttachment(rapport.id, context),
                        child: Row(
                          children: [
                            const Icon(Icons.attachment, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rapport.attachmentFilename!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadAttachment(int rapportId, BuildContext context) async {
    final tontineProvider =
        Provider.of<TontineProvider>(context, listen: false);
    try {
      final file = await tontineProvider.downloadRapportAttachment(
          tontineProvider.currentTontine!.id, rapportId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Téléchargement réussi')),
      );
      if(file != null) {
        OpenFile.open(file.path);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du téléchargement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, RapportMeeting rapport) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer ce rapport ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final tontineProvider =
                    Provider.of<TontineProvider>(context, listen: false);
                await tontineProvider.deleteRapport(
                  tontineProvider.currentTontine!.id,
                  rapport.id,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rapport supprimé')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
