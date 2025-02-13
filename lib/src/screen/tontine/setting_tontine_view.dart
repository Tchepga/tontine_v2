import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/models/enum/loop_period.dart';
import '../../providers/models/enum/type_mouvement.dart';
import '../../providers/models/tontine.dart';
import '../../providers/tontine_provider.dart';
import '../services/dto/tontine_dto.dart';
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
  }

  Widget _buildRateMapSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Plages de taux',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showRateMapDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._rateMaps.map((rateMap) => Card(
                  child: ListTile(
                    title: Text('${rateMap.minAmount} - ${rateMap.maxAmount}'),
                    subtitle: Text('Taux: ${rateMap.rate}%'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _rateMaps.remove(rateMap);
                        });
                      },
                    ),
                  ),
                )),
          ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Ordre des parts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FilledButton(
              onPressed: () => _showAddPartDialog(context, tontineProvider.currentTontine!, _parts),
              child: const Text('Ajouter une part'),
            ),
            const SizedBox(height: 16),
            ..._parts.map((part) => Card(
                  child: ListTile(
                    title: Text(part.member.firstname ?? ''),
                    subtitle: Text(part.order.toString()),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPartDialog(BuildContext context, Tontine tontine, List<PartOrder> existingParts) async {
    final selectedMemberId = ValueNotifier<int?>(null);
    final selectedOrder = ValueNotifier<int?>(null);
    final selectedDate = ValueNotifier<DateTime?>(null);

    final now = DateTime.now();
    final firstDate = now;
    final lastDate = DateTime(now.year + 2, now.month, now.day); // 2 ans à partir d'aujourd'hui

    // Créer la liste des ordres disponibles
    final availableOrders = List.generate(
      tontine.members.length,
      (i) => i + 1,
    ).where((order) => !existingParts.any((part) => part.order == order)).toList();

    // Créer la liste des membres disponibles
    final availableMembers = tontine.members
        .where((member) => !existingParts.any((part) => part.member.id == member.id))
        .toList();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une part'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sélection de l'ordre
              ValueListenableBuilder<int?>(
                valueListenable: selectedOrder,
                builder: (context, value, child) {
                  return DropdownButtonFormField<int>(
                    value: value,
                    decoration: const InputDecoration(
                      labelText: 'Ordre de passage',
                      hintText: 'Sélectionnez l\'ordre',
                    ),
                    items: availableOrders.map((order) {
                      return DropdownMenuItem<int>(
                        value: order,
                        child: Text('Ordre $order'),
                      );
                    }).toList(),
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
                    value: value,
                    decoration: const InputDecoration(
                      labelText: 'Membre',
                      hintText: 'Sélectionnez un membre',
                    ),
                    items: availableMembers.map((member) {
                      return DropdownMenuItem<int>(
                        value: member.id,
                        child: Text('${member.firstname} ${member.lastname}'.trim()),
                      );
                    }).toList(),
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
                  return ListTile(
                    title: Text(
                      value != null 
                          ? DateFormat('dd/MM/yyyy').format(value)
                          : 'Sélectionner une date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
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
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedMemberId.value != null && selectedOrder.value != null) {
                  try {
                    final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
                    final partDto = PartOrderDto(
                      memberId: selectedMemberId.value!,
                      order: selectedOrder.value!,
                      period: selectedDate.value,
                    );

                    await tontineProvider.addPart(partDto);

                    if (!mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Part ajoutée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de l\'ajout de la part'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<TontineProvider, AuthProvider>(
      builder: (context, tontineProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        if (currentTontine == null) return const SizedBox();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Paramètres de la tontine'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paramètres des prêts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _defaultLoanRate.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Taux d\'intérêt par défaut (%)',
                          ),
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
                            _defaultLoanRate = double.parse(value!);
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _defaultLoanDuration.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Durée par défaut (jours)',
                          ),
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
                            _defaultLoanDuration = int.parse(value!);
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _minLoanAmount.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Montant minimum de prêt',
                          ),
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
                            _minLoanAmount = double.parse(value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paramètres des mouvements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<LoopPeriod>(
                          value: _loopPeriod,
                          decoration: const InputDecoration(
                            labelText: 'Périodicité',
                          ),
                          items: LoopPeriod.values.map((period) {
                            return DropdownMenuItem(
                              value: period,
                              child: Text(period.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _loopPeriod = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<MovementType>(
                          value: _movementType,
                          decoration: const InputDecoration(
                            labelText: 'Type de mouvement',
                          ),
                          items: MovementType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _movementType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _countPersonPerMovement.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Nombre de personnes par mouvement',
                          ),
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
                            _countPersonPerMovement = int.parse(value!);
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _countMaxMember.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Nombre maximum de membres',
                          ),
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
                            _countMaxMember = int.parse(value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRateMapSection(),
                const SizedBox(height: 16),
                _buildPartOrderSection(tontineProvider),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
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
                          ));
                      await tontineProvider.loadTontines();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paramètres mis à jour avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erreur lors de la mise à jour'),
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
        );
      },
    );
  }
}
