import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/models/enum/loop_period.dart';
import '../../providers/models/enum/type_mouvement.dart';
import '../../providers/models/enum/role.dart';
import '../../providers/models/tontine.dart';
import '../../providers/tontine_provider.dart';
import '../services/dto/tontine_dto.dart';
import '../../widgets/circular_order_card.dart';
import '../../theme/app_theme.dart';
import '../../providers/models/enum/currency.dart';
import 'package:intl/intl.dart';

class SettingTontineView extends StatefulWidget {
  static const routeName = '/setting-tontine';
  const SettingTontineView({super.key});

  @override
  State<SettingTontineView> createState() => _SettingTontineViewState();
}

class _SettingTontineViewState extends State<SettingTontineView> {
  final _formKey = GlobalKey<FormState>();
  late double _defaultLoanRate = 2.0;
  late int _defaultLoanDuration = 30; // in days
  late LoopPeriod _loopPeriod = LoopPeriod.MONTHLY;
  late double _minLoanAmount = 100;
  late int _countPersonPerMovement = 1;
  late MovementType _movementType = MovementType.ROTATIVE;
  late int _countMaxMember = 10;
  late bool _reminderMissingDepositsEnabled = false;
  List<RateMap> _rateMaps = [];
  List<PartOrder> _parts = [];

  @override
  void initState() {
    super.initState();
    final currentTontine =
        Provider.of<TontineProvider>(context, listen: false).currentTontine;
    if (currentTontine != null) {
      _initializeFields(currentTontine);
    }
  }

  void _initializeFields(Tontine tontine) {
    _defaultLoanRate = tontine.config.defaultLoanRate;
    _defaultLoanDuration = tontine.config.defaultLoanDuration ?? 30;
    _loopPeriod = tontine.config.loopPeriod;
    _minLoanAmount = tontine.config.minLoanAmount;
    _countPersonPerMovement = tontine.config.countPersonPerMovement;
    _movementType = tontine.config.movementType;
    _countMaxMember = tontine.config.countMaxMember;
    _rateMaps = List.from(tontine.config.rateMaps);
    _parts = List.from(tontine.config.parts ?? []);
    _reminderMissingDepositsEnabled =
        tontine.config.reminderMissingDepositsEnabled;
  }

  Widget _buildReminderMissingDepositsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: AppColors.tertiary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Rappel des versements manquants',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.tertiary.withAlpha(25),
                  ),
                ),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Activer le rappel fin de mois',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Le dernier jour du mois à 18:00, les membres en retard recevront un rappel.',
                  ),
                  value: _reminderMissingDepositsEnabled,
                  onChanged: (v) {
                    setState(() {
                      _reminderMissingDepositsEnabled = v;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Règle: on exclut le bénéficiaire du mois. Un membre est considéré OK s’il a au moins un versement validé sur la période.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required String initialValue,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStyledDropdown<T>({
    required T value,
    required String labelText,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRateMapSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Plages de taux',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _showRateMapDialog(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_rateMaps.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune plage de taux configurée',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ..._rateMaps.map((rateMap) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.attach_money,
                            color: AppColors.tertiary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '${rateMap.minAmount.toStringAsFixed(0)} - ${rateMap.maxAmount.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        subtitle: Text(
                          'Taux: ${rateMap.rate}%',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _rateMaps.remove(rateMap);
                              });
                            },
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  void _showRateMapDialog() {
    final minController = TextEditingController();
    final maxController = TextEditingController();
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle plage de taux'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: minController,
              decoration: const InputDecoration(
                labelText: 'Montant minimum',
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: maxController,
              decoration: const InputDecoration(
                labelText: 'Montant maximum',
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'Taux (%)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final min = double.tryParse(minController.text);
              final max = double.tryParse(maxController.text);
              final rate = double.tryParse(rateController.text);

              if (min != null && max != null && rate != null) {
                setState(() {
                  _rateMaps.add(RateMap(
                    id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
                    minAmount: min,
                    maxAmount: max,
                    rate: rate,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartOrderSection(TontineProvider tontineProvider) {
    return Column(
      children: [
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.people_alt,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Ordres',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => _showAddPartDialog(
                            context, tontineProvider.currentTontine!, _parts),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                        label: const Text(
                          'Ajouter une part',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CircularOrderGrid(parts: _parts),
      ],
    );
  }

  Future<void> _showAddPartDialog(BuildContext context, Tontine tontine,
      List<PartOrder> existingParts) async {
    final selectedMemberId = ValueNotifier<int?>(null);
    final selectedOrder = ValueNotifier<int?>(null);
    final selectedDate = ValueNotifier<DateTime?>(null);
    final formKey = GlobalKey<FormState>();

    final now = DateTime.now();
    final firstDate = now;
    final lastDate = DateTime(
        now.year + 2, now.month, now.day); // 2 ans à partir d'aujourd'hui

    // Créer la liste des ordres disponibles
    final availableOrders = List.generate(
      tontine.members.length,
      (i) => i + 1,
    )
        .where((order) => !existingParts.any((part) => part.order == order))
        .toList();

    // Créer la liste des membres disponibles
    final availableMembers = tontine.members
        .where((member) =>
            !existingParts.any((part) => part.member.id == member.id))
        .toList();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une part'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sélection de l'ordre
                ValueListenableBuilder<int?>(
                  valueListenable: selectedOrder,
                  builder: (context, value, child) {
                    return DropdownButtonFormField<int>(
                      initialValue: value,
                      decoration: InputDecoration(
                        labelText: 'Ordre de passage',
                        hintText: 'Sélectionnez l\'ordre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      items: availableOrders.map((order) {
                        return DropdownMenuItem<int>(
                          value: order,
                          child: Text('Ordre $order'),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un ordre';
                        }
                        return null;
                      },
                      onChanged: (newValue) {
                        selectedOrder.value = newValue;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Sélection du membre
                ValueListenableBuilder<int?>(
                  valueListenable: selectedMemberId,
                  builder: (context, value, child) {
                    return DropdownButtonFormField<int>(
                      initialValue: value,
                      decoration: const InputDecoration(
                        labelText: 'Membre',
                        hintText: 'Sélectionnez un membre',
                      ),
                      items: availableMembers.map((member) {
                        return DropdownMenuItem<int>(
                          value: member.id,
                          child: Text(
                              '${member.firstname} ${member.lastname}'.trim()),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un membre';
                        }
                        return null;
                      },
                      onChanged: (newValue) {
                        selectedMemberId.value = newValue;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Sélection de la date
                ValueListenableBuilder<DateTime?>(
                  valueListenable: selectedDate,
                  builder: (context, value, child) {
                    return InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: value ?? now,
                          firstDate: firstDate,
                          lastDate: lastDate,
                        );
                        if (picked != null) {
                          selectedDate.value = picked;
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date de passage',
                          hintText: 'Sélectionner une date',
                          suffixIcon: const Icon(Icons.calendar_today),
                          errorText: value == null
                              ? 'Veuillez sélectionner une date'
                              : null,
                        ),
                        child: Text(
                          value != null
                              ? DateFormat('dd/MM/yyyy').format(value)
                              : 'Sélectionner une date',
                          style: TextStyle(
                            color: value == null ? Colors.grey : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    selectedMemberId.value != null &&
                    selectedOrder.value != null &&
                    selectedDate.value != null) {
                  try {
                    final tontineProvider =
                        Provider.of<TontineProvider>(context, listen: false);
                    final partDto = PartOrderDto(
                      memberId: selectedMemberId.value!,
                      order: selectedOrder.value!,
                      period: selectedDate.value,
                    );

                    await tontineProvider.addPart(partDto);

                    if (!mounted) return;
                    Navigator.of(context).pop();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Part ajoutée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de l\'ajout de la part'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDangerousActionsSection(TontineProvider tontineProvider,
      Tontine currentTontine, AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;
    final isPresident =
        currentUser?.user?.roles?.any((role) => role == Role.PRESIDENT) ??
            false;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade50,
              Colors.red.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Actions dangereuses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supprimer la tontine',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cette action est irréversible. Toutes les données de la tontine seront définitivement supprimées.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    if (!isPresident) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Seul le président peut supprimer la tontine',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isPresident
                            ? () => _showDeleteConfirmation(
                                context, tontineProvider, currentTontine)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPresident
                              ? Colors.red.shade600
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: const Text('Supprimer la tontine'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context,
      TontineProvider tontineProvider, Tontine currentTontine) {
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
              'Êtes-vous sûr de vouloir supprimer la tontine "${currentTontine.title}" ?',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Cette action supprimera définitivement :',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Tous les membres et leurs données'),
                  Text('• Tous les prêts et transactions'),
                  Text('• Tous les rapports et sanctions'),
                  Text('• Toutes les configurations'),
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
                _handleDeleteTontine(context, tontineProvider, currentTontine),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteTontine(BuildContext context,
      TontineProvider tontineProvider, Tontine currentTontine) async {
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

      await tontineProvider.deleteTontine(currentTontine.id);

      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer l'indicateur de chargement

      // Rediriger vers la sélection de tontine
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/select-tontine',
        (route) => false,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tontine supprimée avec succès'),
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
          content: const Text('Erreur lors de la suppression de la tontine'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TontineProvider, AuthProvider>(
      builder: (context, tontineProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        if (currentTontine == null) return const SizedBox();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Paramètres de la tontine'),
            backgroundColor: AppColors.primary,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPartOrderSection(tontineProvider),
                  const SizedBox(height: 16),
                  _buildReminderMissingDepositsSection(),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.account_balance,
                                    color: AppColors.secondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Paramètres des prêts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Affichage de la monnaie
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withAlpha(10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.tertiary.withAlpha(30),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.tertiary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.monetization_on,
                                      color: AppColors.tertiary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Monnaie de la tontine: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    currentTontine
                                        .cashFlow.currency.displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildStyledTextField(
                              initialValue: _defaultLoanRate.toString(),
                              labelText: 'Taux d\'intérêt par défaut (%)',
                              icon: Icons.percent,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est requis';
                                }
                                final rate = double.tryParse(value);
                                if (rate == null || rate < 0) {
                                  return 'Veuillez entrer un taux valide';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _defaultLoanRate = double.parse(value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildStyledTextField(
                              initialValue: _defaultLoanDuration.toString(),
                              labelText: 'Durée par défaut (jours)',
                              icon: Icons.schedule,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est requis';
                                }
                                final duration = int.tryParse(value);
                                if (duration == null || duration < 1) {
                                  return 'Veuillez entrer une durée valide';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _defaultLoanDuration = int.parse(value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildStyledTextField(
                              initialValue: _minLoanAmount.toString(),
                              labelText: 'Montant minimum de prêt',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est requis';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount < 0) {
                                  return 'Veuillez entrer un montant valide';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _minLoanAmount = double.parse(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.sync,
                                    color: AppColors.tertiary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Paramètres des mouvements',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildStyledDropdown<LoopPeriod>(
                              value: _loopPeriod,
                              labelText: 'Périodicité',
                              icon: Icons.calendar_today,
                              items: LoopPeriod.values.map((period) {
                                return DropdownMenuItem(
                                  value: period,
                                  child: Text(period.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _loopPeriod = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildStyledDropdown<MovementType>(
                              value: _movementType,
                              labelText: 'Type de mouvement',
                              icon: Icons.swap_horiz,
                              items: MovementType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _movementType = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildStyledTextField(
                              initialValue: _countPersonPerMovement.toString(),
                              labelText: 'Nombre de personnes par mouvement',
                              icon: Icons.people,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est requis';
                                }
                                final count = int.tryParse(value);
                                if (count == null || count < 1) {
                                  return 'Veuillez entrer un nombre valide';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _countPersonPerMovement = int.parse(value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildStyledTextField(
                              initialValue: _countMaxMember.toString(),
                              labelText: 'Nombre maximum de membres',
                              icon: Icons.group,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est requis';
                                }
                                final count = int.tryParse(value);
                                if (count == null || count < 1) {
                                  return 'Veuillez entrer un nombre valide';
                                }

                                // Vérifier que le nombre max n'est pas inférieur au nombre de membres actuels
                                final currentTontine =
                                    Provider.of<TontineProvider>(context,
                                            listen: false)
                                        .currentTontine;
                                if (currentTontine != null) {
                                  final currentMemberCount =
                                      currentTontine.members.length;
                                  if (count < currentMemberCount) {
                                    return 'Le nombre maximum ne peut pas être inférieur au nombre de membres actuels ($currentMemberCount)';
                                  }
                                }

                                return null;
                              },
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _countMaxMember = int.parse(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRateMapSection(),
                  const SizedBox(height: 16),
                  _buildDangerousActionsSection(
                      tontineProvider, currentTontine, authProvider),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      try {
                        await tontineProvider.updateTontineConfig(
                            currentTontine.id,
                            CreateConfigTontineDto(
                              defaultLoanRate: _defaultLoanRate,
                              defaultLoanDuration: _defaultLoanDuration,
                              loopPeriod: _loopPeriod,
                              minLoanAmount: _minLoanAmount,
                              countPersonPerMovement: _countPersonPerMovement,
                              movementType: _movementType,
                              rateMaps: _rateMaps,
                              countMaxMember: _countMaxMember,
                              reminderMissingDepositsEnabled:
                                  _reminderMissingDepositsEnabled,
                            ));
                        await tontineProvider.loadTontines();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Paramètres mis à jour avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de la mise à jour'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Enregistrer les paramètres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
