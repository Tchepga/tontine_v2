import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/models/enum/role.dart';
import '../../providers/models/enum/system_type.dart';
import '../../providers/models/member.dart';
import '../../providers/models/tontine.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/role_badge.dart';
import '../../theme/app_theme.dart';
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
  bool _isAddingMember = false;

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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
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
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
              child: Text(
                'Aucune tontine sélectionnée',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Membres'),
            backgroundColor: AppColors.primary,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (isPresident)
                IconButton(
                  onPressed: () =>
                      _shareInvitationLink(context, currentTontine),
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Partager le lien d\'invitation',
                ),
            ],
          ),
          body: Column(
            children: [
              // Section Bureau de la tontine
              _buildBureauSection(currentTontine),
              const SizedBox(height: 16),
              // En-tête avec les statistiques
              _buildStatisticsSection(currentTontine),
              const SizedBox(height: 16),
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
                  backgroundColor: AppColors.primary,
                  onPressed: _isAddingMember
                      ? null
                      : () => _showAddMemberDialog(context, tontineProvider),
                  child: _isAddingMember
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.person_add, color: Colors.white),
                )
              : null,
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildBureauSection(Tontine tontine) {
    final bureauMembers = _getBureauMembers(tontine.members);

    return Card(
      margin: const EdgeInsets.all(16),
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
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Bureau de la tontine',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...Role.values
                  .where((role) => role != Role.TONTINARD)
                  .map((role) {
                final member = bureauMembers[role];
                return _buildBureauMember(member, role);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBureauMember(Member? member, Role role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: role.color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: role.color.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: role.color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              role.icon,
              color: role.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: role.color,
                  ),
                ),
                Text(
                  member != null
                      ? '${member.firstname} ${member.lastname}'
                      : 'Non attribué',
                  style: TextStyle(
                    fontSize: 12,
                    color: member != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontStyle:
                        member == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(Tontine tontine) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatistic(
                'Total membres',
                tontine.members.length.toString(),
                Icons.people,
                AppColors.primary,
              ),
              _buildStatistic(
                'Places restantes',
                (tontine.config.countMaxMember - tontine.members.length)
                    .toString(),
                Icons.person_add,
                AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistic(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
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
    final roles = member.user?.roles ?? [Role.TONTINARD];
    final primaryRole =
        roles.contains(Role.PRESIDENT) ? Role.PRESIDENT : roles.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: primaryRole.color,
                child: Text(
                  _getInitials(member),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informations du membre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${member.firstname} ${member.lastname}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.user?.username ?? 'Pas de nom d\'utilisateur',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.phone ?? 'Pas de numéro de téléphone',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Badges des rôles
                    RoleBadgeList(
                      roles: roles,
                      showIcon: true,
                      fontSize: 10,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                    ),
                  ],
                ),
              ),
              // Actions
              if (isPresident) ...[
                const SizedBox(width: 8),
                // Bouton gérer les rôles
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.admin_panel_settings,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    onPressed: () => _showManageRolesDialog(
                      context,
                      member,
                      tontineProvider,
                      tontineId,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Bouton supprimer
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteConfirmation(
                      context,
                      member,
                      tontineProvider,
                      tontineId,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<Role, Member?> _getBureauMembers(List<Member> members) {
    final Map<Role, Member?> bureauMembers = {};

    for (final role in Role.values) {
      if (role != Role.TONTINARD) {
        try {
          bureauMembers[role] = members.firstWhere(
            (member) => member.user?.roles?.contains(role) ?? false,
          );
        } catch (e) {
          bureauMembers[role] = null;
        }
      }
    }

    return bureauMembers;
  }

  String _getInitials(Member member) {
    if (member.firstname?.isNotEmpty == true &&
        member.lastname?.isNotEmpty == true) {
      return '${member.firstname!.substring(0, 1)}${member.lastname!.substring(0, 1)}'
          .toUpperCase();
    }
    return '?';
  }

  void _showAddMemberDialog(
    BuildContext context,
    TontineProvider tontineProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          Icons.person_add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ajouter un membre',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AddMemberForm(
                    existingMembers:
                        tontineProvider.currentTontine?.members ?? [],
                    onSubmit: (memberDto) async {
                      setState(() {
                        _isAddingMember = true;
                      });

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
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de l\'ajout du membre'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isAddingMember = false;
                          });
                        }
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

  void _showManageRolesDialog(
    BuildContext context,
    Member member,
    TontineProvider tontineProvider,
    int tontineId,
  ) {
    final currentRoles = member.user?.roles ?? [Role.TONTINARD];
    final selectedRoles = List<Role>.from(currentRoles);
    final currentTontine = tontineProvider.currentTontine!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gérer les rôles de ${member.firstname}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: Role.values.map((role) {
                    final hasRole = selectedRoles.contains(role);
                    final isRoleOccupied = _isRoleOccupiedByOtherMember(
                        role, member, currentTontine);
                    final canSelect = !isRoleOccupied || hasRole;

                    return CheckboxListTile(
                      title: Row(
                        children: [
                          Icon(
                            role.icon,
                            color: canSelect ? role.color : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            role.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: canSelect ? role.color : Colors.grey,
                            ),
                          ),
                          if (isRoleOccupied && !hasRole) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Occupé',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (isRoleOccupied && !hasRole) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Ce rôle est déjà attribué à un autre membre',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      value: hasRole,
                      onChanged: canSelect
                          ? (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (!selectedRoles.contains(role)) {
                                    selectedRoles.add(role);
                                  }
                                } else {
                                  // Vérifier si c'est le dernier président
                                  if (role == Role.PRESIDENT) {
                                    final presidentCount = currentTontine
                                        .members
                                        .where((m) =>
                                            m.user?.roles
                                                ?.contains(Role.PRESIDENT) ??
                                            false)
                                        .length;
                                    if (presidentCount <= 1) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Il doit y avoir au moins un président'),
                                          backgroundColor: AppColors.warning,
                                        ),
                                      );
                                      return;
                                    }
                                  }
                                  selectedRoles.remove(role);
                                }
                              });
                            }
                          : null,
                      activeColor: role.color,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (selectedRoles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Un membre doit avoir au moins un rôle'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }

                    try {
                      await tontineProvider.updateMemberRoles(
                        tontineId,
                        member.id!,
                        selectedRoles,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rôles mis à jour avec succès'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Erreur lors de la mise à jour des rôles'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Sauvegarder'),
                ),
              ],
            );
          },
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
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la suppression'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  bool _isRoleOccupiedByOtherMember(
      Role role, Member currentMember, Tontine tontine) {
    // TONTINARD peut être attribué à plusieurs membres
    if (role == Role.TONTINARD) {
      return false;
    }

    return tontine.members.any((member) {
      if (member.id == currentMember.id) {
        return false; // Exclure le membre actuel
      }
      return member.user?.roles?.contains(role) ?? false;
    });
  }

  void _shareInvitationLink(BuildContext context, Tontine tontine) {
    // Générer le lien d'invitation (à adapter selon votre logique backend)
    final invitationLink = 'https://votre-app.com/join/${tontine.id}';

    // Message personnalisé pour WhatsApp
    final message = '''
🏦 *Invitation à rejoindre la tontine "${tontine.title}"*

Bonjour ! Vous êtes invité(e) à rejoindre notre tontine "${tontine.title}".

📱 *Pour vous connecter :*
1. Téléchargez l'application Tontine
2. Utilisez ces identifiants temporaires :
   👤 *Nom d'utilisateur :* ${tontine.title.toLowerCase().replaceAll(' ', '_')}_membre
   🔑 *Mot de passe :* changeme
3. Connectez-vous et rejoignez-nous !

🔐 *IMPORTANT - Sécurité :*
⚠️ *Changez votre mot de passe dès votre première connexion !*
• Allez dans "Mon compte" → "Modifier le mot de passe"
• Choisissez un mot de passe fort (8+ caractères, majuscules, chiffres)
• Ne partagez jamais vos identifiants

💰 *Détails de la tontine :*
• Nom : ${tontine.title}
• Membres actuels : ${tontine.members.length}
• Système : ${tontine.config.systemType.displayName}

Rejoignez-nous pour participer à cette aventure financière collective ! 🚀

---
*Message envoyé depuis l'application Tontine*
''';

    // Afficher un dialog pour choisir le mode de partage
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.share,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Partager l\'invitation'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choisissez comment partager le lien d\'invitation :',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildShareOption(
                context,
                'WhatsApp',
                Icons.message,
                Colors.green,
                () => _shareViaWhatsApp(message),
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                context,
                'Autres applications',
                Icons.share,
                AppColors.primary,
                () => _shareViaOtherApps(message),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(50)),
          borderRadius: BorderRadius.circular(12),
          color: color.withAlpha(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _shareViaWhatsApp(String message) async {
    try {
      // Encoder le message pour l'URL
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'https://wa.me/?text=$encodedMessage';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        // Fallback vers l'application de partage générale
        await Share.share(message);
      }
    } catch (e) {
      // En cas d'erreur, utiliser le partage général
      await Share.share(message);
    }
  }

  void _shareViaOtherApps(String message) async {
    try {
      await Share.share(
        message,
        subject: 'Invitation à rejoindre la tontine',
      );
    } catch (e) {
      // Gérer l'erreur si nécessaire
      print('Erreur lors du partage: $e');
    }
  }
}
