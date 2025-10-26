import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../providers/models/rapport_meeting.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/status_badge.dart';
import '../../theme/app_theme.dart';
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
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
                    decoration: InputDecoration(
                      labelText: 'Titre',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le titre est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Contenu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surface,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                      SnackBar(
                        content: const Text('Rapport créé avec succès'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.fixed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    _logger.log(Level.SEVERE, 'Error creating rapport: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Erreur lors de la création du rapport.'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.fixed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer le rapport'),
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.attach_file,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pièce jointe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.file_present
                          : Icons.attach_file,
                      color: AppColors.textSecondary,
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
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Choisir'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
          SnackBar(
            content: const Text('Erreur lors de la sélection du fichier'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final canEdit = currentUser?.user?.roles?.any((role) =>
            role == Role.PRESIDENT ||
            role == Role.SECRETARY ||
            role == Role.ACCOUNT_MANAGER ||
            role == Role.OFFICE_MANAGER) ??
        false;

    return Consumer<TontineProvider>(
      builder: (context, tontineProvider, child) {
        final rapports = tontineProvider.currentTontine?.rapports ?? [];
        final sanctions = tontineProvider.currentTontine?.sanctions ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Rapports & Sanctions'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withAlpha(150),
              tabs: const [
                Tab(
                  icon: Icon(Icons.description),
                  text: 'Rapports',
                ),
                Tab(
                  icon: Icon(Icons.gavel),
                  text: 'Sanctions',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab Rapports
              rapports.isEmpty
                  ? _buildEmptyState(
                      title: 'Aucun rapport',
                      message:
                          'Il n\'y a pas encore de rapport de réunion.\nSeuls les membres du bureau peuvent créer des rapports.',
                      icon: Icons.description_outlined,
                      onActionPressed: canEdit
                          ? () =>
                              _showCreateRapportDialog(context, tontineProvider)
                          : null,
                      actionLabel: canEdit ? 'Créer un rapport' : null,
                    )
                  : ListView.builder(
                      itemCount: rapports.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final rapport = rapports[index];
                        return _buildRapportCard(rapport);
                      },
                    ),
              // Tab Sanctions
              sanctions.isEmpty
                  ? _buildEmptyState(
                      title: 'Aucune sanction',
                      message:
                          'Il n\'y a pas encore de sanction enregistrée.\nSeuls les membres du bureau peuvent créer des sanctions.',
                      icon: Icons.gavel_outlined,
                      onActionPressed: canEdit
                          ? () => _showCreateSanctionDialog(
                              context, tontineProvider)
                          : null,
                      actionLabel: canEdit ? 'Créer une sanction' : null,
                    )
                  : ListView.builder(
                      itemCount: sanctions.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final sanction = sanctions[index];
                        return _buildSanctionCard(sanction, tontineProvider);
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      onPressed: () =>
                          _showCreateRapportDialog(context, tontineProvider),
                      child: const Icon(Icons.description),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'btn2',
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
        return StatefulBuilder(
          builder: (context, setState) {
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
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        items: tontineProvider.currentTontine?.members
                            .map((member) {
                          return DropdownMenuItem(
                            value: member.id,
                            child:
                                Text('${member.firstname} ${member.lastname}'),
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
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        initialValue: selectedType,
                        items: TypeSanction.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getSanctionTypeName(type)),
                          );
                        }).toList(),
                        onChanged: (value) => selectedType = value!,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Date de début',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.primary),
                                ),
                                suffixText:
                                    DateFormat('dd/MM/yyyy').format(startDate),
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    startDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Date de fin (optionnel)',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.primary),
                                ),
                                suffixText: endDate != null
                                    ? DateFormat('dd/MM/yyyy').format(endDate!)
                                    : 'Non définie',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: endDate ??
                                      startDate.add(const Duration(days: 30)),
                                  firstDate: startDate,
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    endDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
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
                            child: const Text(
                              'Annuler',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
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
                                    SnackBar(
                                      content: const Text(
                                          'Sanction créée avec succès'),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.fixed,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Erreur lors de la création'),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.fixed,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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
          backgroundColor: AppColors.surface,
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
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.description,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  rapport.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: AppColors.textSecondary,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        rapport.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (rapport.attachmentFilename != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: InkWell(
                          onTap: () => _downloadAttachment(rapport.id, context),
                          child: Row(
                            children: [
                              const Icon(Icons.attachment,
                                  color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rapport.attachmentFilename!,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.download,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ],
                          ),
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

  Widget _buildRapportCard(RapportMeeting rapport) {
    final isRecent = DateTime.now().difference(rapport.createdAt).inDays < 7;

    return ModernCard(
      type: isRecent ? ModernCardType.info : ModernCardType.secondary,
      icon: Icons.description,
      title: rapport.title,
      onTap: () => _showRapportDetails(context, rapport),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy à HH:mm')
                          .format(rapport.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (rapport.attachmentFilename != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.attachment,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rapport.attachmentFilename!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (rapport.attachmentFilename != null)
                IconButton(
                  onPressed: () => _downloadAttachment(rapport.id, context),
                  icon: const Icon(Icons.download),
                  tooltip: 'Télécharger',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSanctionCard(dynamic sanction, TontineProvider tontineProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final canDelete = currentUser?.user?.roles?.any((role) =>
            role == Role.PRESIDENT ||
            role == Role.SECRETARY ||
            role == Role.ACCOUNT_MANAGER ||
            role == Role.OFFICE_MANAGER) ??
        false;

    return ModernCard(
      type: _getSanctionCardType(sanction.type),
      icon: _getSanctionIcon(sanction.type),
      title: '${sanction.gulty.firstname} ${sanction.gulty.lastname}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sanction.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _getSanctionBadge(sanction.type),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy')
                    .format(sanction.startDate ?? DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteSanctionConfirmation(
                        context, sanction, tontineProvider),
                    tooltip: 'Supprimer la sanction',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  ModernCardType _getSanctionCardType(TypeSanction type) {
    switch (type) {
      case TypeSanction.WARNING:
        return ModernCardType.warning;
      case TypeSanction.FINANCIAL:
        return ModernCardType.error;
      case TypeSanction.SUSPENSION:
        return ModernCardType.error;
      case TypeSanction.EXCLUSION:
        return ModernCardType.error;
    }
  }

  IconData _getSanctionIcon(TypeSanction type) {
    switch (type) {
      case TypeSanction.WARNING:
        return Icons.warning;
      case TypeSanction.FINANCIAL:
        return Icons.monetization_on;
      case TypeSanction.SUSPENSION:
        return Icons.pause_circle;
      case TypeSanction.EXCLUSION:
        return Icons.block;
    }
  }

  String _getSanctionTypeName(TypeSanction type) {
    switch (type) {
      case TypeSanction.WARNING:
        return 'Avertissement';
      case TypeSanction.FINANCIAL:
        return 'Sanction financière';
      case TypeSanction.SUSPENSION:
        return 'Suspension';
      case TypeSanction.EXCLUSION:
        return 'Exclusion';
    }
  }

  Widget _getSanctionBadge(TypeSanction type) {
    switch (type) {
      case TypeSanction.WARNING:
        return const StatusBadge(
          text: 'Avertissement',
          color: AppColors.warning,
          icon: Icons.warning,
        );
      case TypeSanction.FINANCIAL:
        return const StatusBadge(
          text: 'Sanction financière',
          color: AppColors.error,
          icon: Icons.monetization_on,
        );
      case TypeSanction.SUSPENSION:
        return const StatusBadge(
          text: 'Suspension',
          color: AppColors.error,
          icon: Icons.pause_circle,
        );
      case TypeSanction.EXCLUSION:
        return const StatusBadge(
          text: 'Exclusion',
          color: AppColors.error,
          icon: Icons.block,
        );
    }
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteSanctionConfirmation(
      BuildContext context, dynamic sanction, TontineProvider tontineProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red.shade600,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Confirmation de suppression'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer cette sanction ?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sanction à supprimer :',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      '• Membre : ${sanction.gulty.firstname} ${sanction.gulty.lastname}'),
                  Text('• Type : ${_getSanctionTypeName(sanction.type)}'),
                  Text('• Description : ${sanction.description}'),
                  Text(
                      '• Date : ${DateFormat('dd/MM/yyyy').format(sanction.startDate ?? DateTime.now())}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                _handleDeleteSanction(context, sanction, tontineProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteSanction(BuildContext context, dynamic sanction,
      TontineProvider tontineProvider) async {
    try {
      Navigator.of(context).pop(); // Fermer le dialog de confirmation

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Suppression en cours...'),
            ],
          ),
        ),
      );

      final tontineId = tontineProvider.currentTontine!.id;
      await tontineProvider.deleteSanction(tontineId, sanction.id);

      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer l'indicateur de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sanction supprimée avec succès'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer l'indicateur de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression : ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
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
        SnackBar(
          content: const Text('Erreur lors du téléchargement'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
