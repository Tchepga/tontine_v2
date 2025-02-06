import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/models/member.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/models/part.dart';
import '../../widgets/menu_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/models/enum/role.dart';
import '../services/dto/tontine_dto.dart';

class PartOrderView extends StatefulWidget {
  static const routeName = '/part-order';
  const PartOrderView({super.key});

  @override
  State<PartOrderView> createState() => _PartOrderViewState();
}

class _PartOrderViewState extends State<PartOrderView> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<TontineProvider, AuthProvider>(
      builder: (context, tontineProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final isPresident = authProvider.currentUser?.user?.roles?.contains(Role.PRESIDENT) ?? false;
        final parts = tontineProvider.parts;

        if (currentTontine == null) {
          return const Scaffold(
            body: Center(child: Text('Aucune tontine sélectionnée')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ordre de passage'),
          ),
          body: Column(
            children: [
              // En-tête avec les statistiques
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatistic(
                        'Total parts',
                        parts.length.toString(),
                      ),
                      _buildStatistic(
                        'Parts passées',
                        parts.where((p) => p.isPassed).length.toString(),
                      ),
                    ],
                  ),
                ),
              ),
              // Liste des parts
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: parts.length,
                  itemBuilder: (context, index) {
                    final part = parts[index];
                    return _buildPartCard(part, isPresident);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: isPresident
              ? FloatingActionButton(
                  onPressed: () => _showAddPartDialog(context, currentTontine.id, currentTontine.members),
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildStatistic(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPartCard(Part part, bool isPresident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: part.isPassed ? Colors.green : Colors.orange,
          child: Text(
            '${part.order}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(part.memberName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (part.passageDate != null)
              Text(
                'Date de passage: ${DateFormat('dd/MM/yyyy').format(part.passageDate!)}',
                style: TextStyle(
                  color: part.isPassed ? Colors.green : Colors.grey,
                ),
              )
            else
              const Text(
                'Date non définie',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
        trailing: isPresident && !part.isPassed
            ? IconButton(
                icon: const Icon(Icons.edit_calendar),
                onPressed: () => {
                  print('edit'),
                },
              )
            : null,
      ),
    );
  }

  

  Future<void> _showAddPartDialog(BuildContext context, int tontineId, List<Member> members) {
    final selectedMemberId = ValueNotifier<int?>(null);
    final orderController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une part'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Champ pour l'ordre
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ordre de passage',
                  hintText: 'Entrez l\'ordre de passage',
                ),
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
                    items: members.map((member) {
                      return DropdownMenuItem<int>(
                        value: member.id,
                        child: Text('${member.firstname} ${member.lastname}'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      selectedMemberId.value = newValue;
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
                if (selectedMemberId.value != null && orderController.text.isNotEmpty) {
                  final order = int.tryParse(orderController.text);
                  if (order != null) {
                    try {
                      final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
                      final partDto = PartOrderDto(
                        memberId: selectedMemberId.value!,
                        order: order,
                      );


                      await tontineProvider.addPart(
                        tontineId,
                        partDto,
                      );


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
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
} 