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
import '../../providers/models/enum/type_sanction.dart';
import '../services/dto/sanction_dto.dart';

class RapportView extends StatefulWidget {
  static const routeName = '/rapport';
  const RapportView({super.key});

  @override
  State<RapportView> createState() => _RapportViewState();
}

class _RapportViewState extends State<RapportView>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger('RapportView');
  final QuillController _controller = QuillController.basic();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  PlatformFile? _selectedFile;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      if (!mounted) return;
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        tontineProvider
            .getRapportsForTontine(tontineProvider.currentTontine!.id);
        tontineProvider
            .getSanctionsForTontine(tontineProvider.currentTontine!.id);
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
                        QuillSimpleToolbar(
                          controller: _controller,
                          config: const QuillSimpleToolbarConfig(
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
                            child: QuillEditor(
                              focusNode: _editorFocusNode,
                              scrollController: _editorScrollController,
                              controller: _controller,
                              config: const QuillEditorConfig(
                                placeholder:
                                    'Saisissez le contenu du rapport...',
                              ),
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

                    final tontineId = tontineProvider.currentTontine!.id;
                    await tontineProvider.addRapport(tontineId, rapportDto);
                    await tontineProvider.getRapportsForTontine(tontineId);

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
        final sanctions = tontineProvider.currentTontine?.sanctions ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Rapports & Sanctions'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Rapports'),
                Tab(text: 'Sanctions'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab Rapports
              ListView.builder(
                itemCount: rapports.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final rapport = rapports[index];
                  return Card(
                    child: ListTile(
                      title: Text(rapport.title),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(rapport.createdAt),
                      ),
                      trailing: rapport.attachmentFilename != null
                          ? const Icon(Icons.attachment)
                          : null,
                      onTap: () => _showRapportDetails(context, rapport),
                    ),
                  );
                },
              ),
              // Tab Sanctions
              ListView.builder(
                itemCount: sanctions.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final sanction = sanctions[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          '${sanction.gulty.firstname} ${sanction.gulty.lastname}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sanction.description),
                          Chip(
                            label: Text(
                              sanction.type.displayName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _getSanctionColor(sanction.type),
                          ),
                        ],
                      ),
                      trailing: Text(
                        DateFormat('dd/MM/yyyy')
                            .format(sanction.startDate ?? DateTime.now()),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: canEdit
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'btn1',
                      onPressed: () =>
                          _showCreateRapportDialog(context, tontineProvider),
                      child: const Icon(Icons.description),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'btn2',
                      onPressed: () =>
                          _showCreateSanctionDialog(context, tontineProvider),
                      child: const Icon(Icons.gavel),
                    ),
                  ],
                )
              : null,
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Color _getSanctionColor(TypeSanction type) {
    switch (type) {
      case TypeSanction.WARNING:
        return Colors.orange;
      case TypeSanction.SUSPENSION:
        return Colors.red;
      case TypeSanction.EXCLUSION:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showCreateSanctionDialog(
      BuildContext context, TontineProvider tontineProvider) {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    TypeSanction selectedType = TypeSanction.WARNING;
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    int? selectedMemberId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nouvelle sanction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Membre',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        tontineProvider.currentTontine?.members.map((member) {
                      return DropdownMenuItem(
                        value: member.id,
                        child: Text('${member.firstname} ${member.lastname}'),
                      );
                    }).toList(),
                    onChanged: (value) => selectedMemberId = value,
                    validator: (value) {
                      if (value == null) return 'Sélectionnez un membre';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TypeSanction>(
                    decoration: const InputDecoration(
                      labelText: 'Type de sanction',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedType,
                    items: TypeSanction.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) => selectedType = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La description est requise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate() &&
                              selectedMemberId != null) {
                            try {
                              final sanctionDto = CreateSanctionDto(
                                type: selectedType,
                                description: descriptionController.text,
                                startDate: startDate,
                                endDate: endDate,
                                memberId: selectedMemberId!,
                              );

                              final tontineId =
                                  tontineProvider.currentTontine!.id;
                              await tontineProvider.addSanction(
                                  tontineId, sanctionDto);
                              await tontineProvider
                                  .getSanctionsForTontine(tontineId);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sanction créée avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
                        child: const Text('Créer'),
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
      if (file != null) {
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
}
