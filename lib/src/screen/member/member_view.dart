import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/models/enum/role.dart';
import '../../providers/models/member.dart';
import '../../widgets/menu_widget.dart';
import '../tontine/add_member_form.dart';
import '../../services/local_notification_service.dart';

class MemberView extends StatefulWidget {
  static const routeName = '/members';
  const MemberView({super.key});

  @override
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView> {
  final _notificationService = LocalNotificationService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  Future<void> _initializeUser() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentUser();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer2<TontineProvider, AuthProvider>(
      builder: (context, tontineProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final currentUser = authProvider.currentUser;
        final isPresident =
            currentUser?.user?.roles?.contains(Role.PRESIDENT) ?? false;

        if (currentTontine == null) {
          return const Scaffold(
            body: Center(child: Text('Aucune tontine sélectionnée')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Membres'),
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
                        'Total membres',
                        currentTontine.members.length.toString(),
                      ),
                      _buildStatistic(
                        'Places restantes',
                        (currentTontine.config.countMaxMember -
                                currentTontine.members.length)
                            .toString(),
                      ),
                    ],
                  ),
                ),
              ),
              // Liste des membres
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 56),
                  itemCount: currentTontine.members.length,
                  itemBuilder: (context, index) {
                    final member = currentTontine.members[index];
                    return _buildMemberCard(
                      member,
                      isPresident,
                      tontineProvider,
                      currentTontine.id,
                    );
                  },
                ),
              ),
            ],
          ),
          // Bouton d'ajout uniquement pour le président
          floatingActionButton: isPresident
              ? FloatingActionButton(
                  heroTag: 'member_fab',
                  onPressed: () =>
                      _showAddMemberDialog(context, tontineProvider),
                  child: const Icon(Icons.person_add),
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

  Widget _buildMemberCard(
    Member member,
    bool isPresident,
    TontineProvider tontineProvider,
    int tontineId,
  ) {
    final isAdmin = member.user?.roles?.contains(Role.PRESIDENT) ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAdmin ? Colors.orange : Colors.blue,
          child: Text(
            member.firstname?.isNotEmpty == true &&
                    member.lastname?.isNotEmpty == true
                ? '${member.firstname?.substring(0, 1)}${member.lastname?.substring(0, 1)}'
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('${member.firstname} ${member.lastname}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.user?.username ?? 'Pas de nom d\'utilisateur'),
            Text(member.phone ?? 'Pas de numéro de téléphone'),
          ],
        ),
        trailing: isPresident
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(
                  context,
                  member,
                  tontineProvider,
                  tontineId,
                ),
              )
            : null,
      ),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    TontineProvider tontineProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ajouter un membre',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AddMemberForm(
                    onSubmit: (memberDto) async {
                      try {
                        await tontineProvider.addMemberToTontine(
                          tontineProvider.currentTontine!.id,
                          memberDto,
                        );
                        await _notificationService.showNotification(
                          title: 'Nouveau membre',
                          body: 'Un nouveau membre a été ajouté à la tontine',
                          payload: '/members',
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Membre ajouté avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de l\'ajout du membre'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Member member,
    TontineProvider tontineProvider,
    int tontineId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Voulez-vous vraiment supprimer ${member.firstname} ${member.lastname} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              if (member.id != null) {
                try {
                  await tontineProvider.removeMemberFromTontine(
                      tontineId, member.id!);
                  await _notificationService.showNotification(
                    title: 'Membre supprimé',
                    body: 'Un membre a été retiré de la tontine',
                    payload: '/members',
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membre supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
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
