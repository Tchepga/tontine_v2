import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/models/enum/currency.dart';
import '../../providers/models/enum/loop_period.dart';
import '../../providers/models/enum/system_type.dart';
import '../../providers/models/enum/type_mouvement.dart';
import '../../providers/tontine_provider.dart';
import '../../theme/app_theme.dart';
import '../services/dto/tontine_dto.dart';

class CreateTontineView extends StatefulWidget {
  const CreateTontineView({super.key});

  @override
  State<CreateTontineView> createState() => _CreateTontineViewState();
}

class _CreateTontineViewState extends State<CreateTontineView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _legacyController = TextEditingController();
  final _loanRateController = TextEditingController(text: '2');
  final _loanDurationController = TextEditingController(text: '30');
  final _minLoanAmountController = TextEditingController(text: '100');
  final _maxMembersController = TextEditingController(text: '12');
  final _countPersonPerMovementController = TextEditingController(text: '1');

  LoopPeriod _period = LoopPeriod.MONTHLY;
  MovementType _movementType = MovementType.ROTATIVE;
  Currency _currency = Currency.EUR;
  SystemType _systemType = SystemType.PART;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _legacyController.dispose();
    _loanRateController.dispose();
    _loanDurationController.dispose();
    _minLoanAmountController.dispose();
    _maxMembersController.dispose();
    _countPersonPerMovementController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  String? _validateNumber(String? value, {num min = 0}) {
    final requiredError = _validateRequired(value);
    if (requiredError != null) return requiredError;
    final parsed = double.tryParse(value!.trim().replaceAll(',', '.'));
    if (parsed == null) return 'Veuillez entrer un nombre valide';
    if (parsed < min) return 'Doit être ≥ $min';
    return null;
  }

  String? _validateInteger(String? value, {int min = 1}) {
    final requiredError = _validateRequired(value);
    if (requiredError != null) return requiredError;
    final parsed = int.tryParse(value!.trim());
    if (parsed == null) return 'Veuillez entrer un nombre entier';
    if (parsed < min) return 'Doit être ≥ $min';
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expirée. Reconnectez-vous.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final maxMembers = int.parse(_maxMembersController.text.trim());
    final perMovement =
        int.parse(_countPersonPerMovementController.text.trim());
    if (perMovement > maxMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le nombre de personnes par mouvement ne peut pas dépasser le maximum de membres.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final description = _legacyController.text.trim();
      final tontineDto = CreateTontineDto(
        title: _titleController.text.trim(),
        legacy: description.isEmpty ? null : description,
        memberDtos: const [],
        config: CreateConfigTontineDto(
          defaultLoanRate: double.parse(
            _loanRateController.text.trim().replaceAll(',', '.'),
          ),
          defaultLoanDuration: int.parse(_loanDurationController.text.trim()),
          loopPeriod: _period,
          minLoanAmount: double.parse(
            _minLoanAmountController.text.trim().replaceAll(',', '.'),
          ),
          countPersonPerMovement: perMovement,
          movementType: _movementType,
          countMaxMember: maxMembers,
          systemType: _systemType,
        ),
        currency: _currency,
      );

      await Provider.of<TontineProvider>(context, listen: false)
          .createTontine(tontineDto);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            raw.isEmpty ? 'Erreur lors de la création' : raw,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle tontine'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard(
                  title: 'Informations générales',
                  children: [
                    TextFormField(
                      controller: _titleController,
                      enabled: !_isSubmitting,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la tontine*',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _legacyController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: 'Configuration des prêts',
                  children: [
                    TextFormField(
                      controller: _loanRateController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Taux de prêt (%)*',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => _validateNumber(v, min: 0),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _loanDurationController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Durée de prêt (jours)*',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateInteger(v, min: 1),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _minLoanAmountController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Montant minimum de prêt*',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => _validateNumber(v, min: 0),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: 'Fonctionnement',
                  children: [
                    TextFormField(
                      controller: _maxMembersController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Nombre maximum de membres*',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateInteger(v, min: 2),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _countPersonPerMovementController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Personnes par tour*',
                        helperText:
                            'Combien de membres reçoivent la cagnotte à chaque période',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateInteger(v, min: 1),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LoopPeriod>(
                      initialValue: _period,
                      decoration: const InputDecoration(
                        labelText: 'Période*',
                        border: OutlineInputBorder(),
                      ),
                      items: LoopPeriod.values
                          .map(
                            (period) => DropdownMenuItem(
                              value: period,
                              child: Text(period.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _period = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MovementType>(
                      initialValue: _movementType,
                      decoration: const InputDecoration(
                        labelText: 'Type de mouvement*',
                        border: OutlineInputBorder(),
                      ),
                      items: MovementType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _movementType = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SystemType>(
                      initialValue: _systemType,
                      decoration: const InputDecoration(
                        labelText: 'Système*',
                        border: OutlineInputBorder(),
                      ),
                      items: SystemType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _systemType = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Currency>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Devise*',
                        border: OutlineInputBorder(),
                      ),
                      items: Currency.values
                          .map(
                            (currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(
                                '${currency.toString().split('.').last} (${currency.displayName})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _currency = value);
                              }
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 88),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Créer la tontine'),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
