import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/enum/currency.dart';
import '../../models/enum/loop_period.dart';
import '../../models/enum/type_mouvement.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../dashboard_view.dart';
import 'package:logging/logging.dart';

import '../services/dto/member_dto.dart';
import '../services/dto/tontine_dto.dart';
import 'add_members_view.dart';

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
    if(mounted) {
      if(Provider.of<TontineProvider>(context, listen: false).currentTontine != null) {
        Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
      }
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

  void _showCreateTontineDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final legacyController = TextEditingController();
    final loanRateController = TextEditingController(text: '2');
    final loanDurationController = TextEditingController(text: '30');
    final minLoanAmountController = TextEditingController(text: '100');
    final maxMembersController = TextEditingController(text: '12');
    final countPersonPerMovementController = TextEditingController(text: '1');
    
    LoopPeriod selectedPeriod = LoopPeriod.MONTHLY;
    MovementType selectedMovementType = MovementType.ROTATIVE;
    Currency selectedCurrency = Currency.EUR;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Nouvelle tontine'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations générales',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                labelText: 'Nom de la tontine*',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le nom est requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: legacyController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Configuration des prêts',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: loanRateController,
                              decoration: const InputDecoration(
                                labelText: 'Taux de prêt (%)*',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNumber(value),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: loanDurationController,
                              decoration: const InputDecoration(
                                labelText: 'Durée de prêt (jours)*',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateInteger(value),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: minLoanAmountController,
                              decoration: const InputDecoration(
                                labelText: 'Montant minimum de prêt*',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNumber(value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Configuration générale',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: maxMembersController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre maximum de membres*',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateInteger(value),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: countPersonPerMovementController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de personnes par mouvement*',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateInteger(value),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<LoopPeriod>(
                              value: selectedPeriod,
                              decoration: const InputDecoration(
                                labelText: 'Période*',
                                border: OutlineInputBorder(),
                              ),
                              items: LoopPeriod.values.map((period) {
                                return DropdownMenuItem(
                                  value: period,
                                  child: Text(period.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedPeriod = value!;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<MovementType>(
                              value: selectedMovementType,
                              decoration: const InputDecoration(
                                labelText: 'Type de mouvement*',
                                border: OutlineInputBorder(),
                              ),
                              items: MovementType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedMovementType = value!;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Currency>(
                              value: selectedCurrency,
                              decoration: const InputDecoration(
                                labelText: 'Devise*',
                                border: OutlineInputBorder(),
                              ),
                              items: Currency.values.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text('${currency.toString().split('.').last} (${currency.displayName})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedCurrency = value!;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _handleCreateTontine(
                context, 
                formKey, 
                titleController,
                legacyController,
                loanRateController,
                loanDurationController,
                minLoanAmountController,
                maxMembersController,
                countPersonPerMovementController,
                selectedPeriod,
                selectedMovementType,
                selectedCurrency,
              ),
              child: const Text('Créer la tontine',),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (double.tryParse(value) == null) {
      return 'Veuillez entrer un nombre valide';
    }
    return null;
  }

  String? _validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (int.tryParse(value) == null) {
      return 'Veuillez entrer un nombre entier';
    }
    return null;
  }

  Future<void> _handleCreateTontine(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController titleController,
    TextEditingController legacyController,
    TextEditingController loanRateController,
    TextEditingController loanDurationController,
    TextEditingController minLoanAmountController,
    TextEditingController maxMembersController,
    TextEditingController countPersonPerMovementController,
    LoopPeriod selectedPeriod,
    MovementType selectedMovementType,
    Currency selectedCurrency,
  ) async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (formKey.currentState!.validate() && currentUser != null) {
      try {
        final memberDto = CreateMemberDto(
          username: currentUser.user!.username,
          firstname: currentUser.firstname ?? '',
          lastname: currentUser.lastname ?? '',
          phone: currentUser.phone ?? '',
          country: currentUser.country ?? '',
        );

        final tontineDto = CreateTontineDto(
          title: titleController.text,
          legacy: legacyController.text,
          memberDtos: [memberDto],
          config: CreateConfigTontineDto(
            defaultLoanRate: double.parse(loanRateController.text),
            defaultLoanDuration: int.parse(loanDurationController.text),
            loopPeriod: selectedPeriod,
            minLoanAmount: double.parse(minLoanAmountController.text),
            countPersonPerMovement: int.parse(countPersonPerMovementController.text),
            movementType: selectedMovementType,
            countMaxMember: int.parse(maxMembersController.text),
          ),
          currency: selectedCurrency,
        );

        await Provider.of<TontineProvider>(context, listen: false)
            .createTontine(tontineDto);
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création'),
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade300, Colors.orange.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.group_add,
                            size: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bienvenue !',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Vous n\'avez pas encore de tontine. Créez votre première tontine en cliquant sur le bouton + ci-dessous.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => _showCreateTontineDialog(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.orange,
                            ),
                            child: const Text('Créer une tontine'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                      Text('Solde: ${tontine.cashFlow.amount} ${tontine.cashFlow.currency.displayName}'),
                    ],
                  ),
                  trailing: tontine.isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () async {
                    await tontineProvider.setCurrentTontine(tontine);
                    if (mounted) {
                      if (tontine.members.length < tontine.config.countMaxMember) {
                        Navigator.of(context).pushReplacementNamed(AddMembersView.routeName);
                      } else {
                        Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTontineDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
} 