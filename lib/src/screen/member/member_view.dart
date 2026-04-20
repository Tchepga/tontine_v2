import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/models/enum/role.dart';
import '../../providers/models/enum/system_type.dart';
import '../../providers/models/member.dart';
import '../../providers/models/tontine.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/responsive_padding.dart';
import '../../utils/responsive_helper.dart';
import '../../theme/app_theme.dart';
import '../tontine/add_member_form.dart';
import '../../services/local_notification_service.dart';

class MemberView extends StatefulWidget {
  static const routeName = '/members';
  const MemberView({super.key});

  @override
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView>
    with SingleTickerProviderStateMixin {
  final _notificationService = LocalNotificationService();
  bool _isInitialized = false;
  bool _isAddingMember = false;
  late TabController _tabController;

  String _appDownloadLink() {
    // Lien de téléchargement de l'app de test depuis .env
    // - iOS: APP_DOWNLOAD_LINK_IOS
    // - Android: APP_DOWNLOAD_LINK_ANDROID
    if (kIsWeb) {
      return dotenv.env['APP_DOWNLOAD_LINK_WEB'] ??
          dotenv.env['APP_DOWNLOAD_LINK_ANDROID'] ??
          dotenv.env['APP_DOWNLOAD_LINK_IOS'] ??
          '';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return dotenv.env['APP_DOWNLOAD_LINK_IOS'] ?? '';
      case TargetPlatform.android:
        return dotenv.env['APP_DOWNLOAD_LINK_ANDROID'] ?? '';
      default:
        return dotenv.env['APP_DOWNLOAD_LINK_ANDROID'] ??
            dotenv.env['APP_DOWNLOAD_LINK_IOS'] ??
            '';
    }
  }

  Rect? _sharePositionOrigin() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & renderObject.size;
    }
    return null;
  }

  Future<void> _safeShareText(
    String message, {
    String? subject,
    bool copyToClipboardOnError = true,
  }) async {
    try {
      await Share.share(
        message,
        subject: subject,
        sharePositionOrigin: _sharePositionOrigin(),
      );
    } on PlatformException catch (e) {
      debugPrint('Share PlatformException: ${e.code} ${e.message}');
      if (copyToClipboardOnError) {
        await Clipboard.setData(ClipboardData(text: message));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              copyToClipboardOnError
                  ? 'Partage impossible. Le message a été copié dans le presse-papiers.'
                  : 'Partage impossible: ${e.message ?? e.code}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Share error: $e');
      if (copyToClipboardOnError) {
        await Clipboard.setData(ClipboardData(text: message));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              copyToClipboardOnError
                  ? 'Erreur lors du partage. Le message a été copié dans le presse-papiers.'
                  : 'Erreur lors du partage: ${e.toString()}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        final isTontineFull = tontineProvider.isTontineFull();

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
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: Text('Membres', style: TextStyle(color: Colors.white)),
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
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.business),
                  text: 'Bureau',
                ),
                Tab(
                  icon: Icon(Icons.people),
                  text: 'Membres',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Onglet Bureau
              SingleChildScrollView(
                child: Column(
                  children: [
                    ResponsiveSpacing(height: 16),
                    _buildBureauSection(context, currentTontine),
                    ResponsiveSpacing(height: 16),
                  ],
                ),
              ),
              // Onglet Liste des membres
              Column(
                children: [
                  ResponsiveSpacing(height: 16),
                  _buildStatisticsSection(context, currentTontine),
                  ResponsiveSpacing(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 56.0,
                      ),
                      itemCount: currentTontine.members.length,
                      itemBuilder: (context, index) {
                        final member = currentTontine.members[index];
                        return _buildMemberCard(
                          context,
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
            ],
          ),
          // Bouton d'ajout uniquement pour le président
          floatingActionButton: isPresident || isTontineFull
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

  Widget _buildBureauSection(BuildContext context, Tontine tontine) {
    final bureauMembers = _getBureauMembers(tontine.members);
    final cardMargin = ResponsiveHelper.getAdaptivePadding(context, all: 16.0);
    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 20.0);
    final iconPadding = ResponsiveHelper.getAdaptivePadding(context, all: 8.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 20.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 12.0);

    return Card(
      margin: cardMargin,
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
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: iconPadding,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: AppColors.primary,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: spacing),
                  Text(
                    'Bureau de la tontine',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveValue(
                        context,
                        small: 16.0,
                        medium: 17.0,
                        large: 18.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ResponsiveSpacing(height: 16),
              ...Role.values
                  .where((role) => role != Role.TONTINARD)
                  .map((role) {
                final member = bureauMembers[role];
                return _buildBureauMember(context, member, role);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBureauMember(BuildContext context, Member? member, Role role) {
    final itemMargin = ResponsiveHelper.getAdaptiveSpacing(context, base: 8.0);
    final itemPadding = ResponsiveHelper.getAdaptivePadding(context, all: 12.0);
    final iconPadding = ResponsiveHelper.getAdaptivePadding(context, all: 8.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 20.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 12.0);

    return Container(
      margin: EdgeInsets.only(bottom: itemMargin),
      padding: itemPadding,
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
            padding: iconPadding,
            decoration: BoxDecoration(
              color: role.color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              role.icon,
              color: role.color,
              size: iconSize,
            ),
          ),
          SizedBox(width: spacing),
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

  Widget _buildStatisticsSection(BuildContext context, Tontine tontine) {
    final cardMargin =
        ResponsiveHelper.getAdaptivePadding(context, horizontal: 16.0);
    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 20.0);

    return Card(
      margin: cardMargin,
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
          padding: cardPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatistic(
                context,
                'Total membres',
                tontine.members.length.toString(),
                Icons.people,
                AppColors.primary,
              ),
              _buildStatistic(
                context,
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

  Widget _buildStatistic(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final iconPadding = ResponsiveHelper.getAdaptivePadding(context, all: 12.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 24.0);
    final valueFontSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 20.0,
      medium: 22.0,
      large: 24.0,
    );
    final labelFontSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 11.0,
      medium: 11.5,
      large: 12.0,
    );

    return Column(
      children: [
        Container(
          padding: iconPadding,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
        ResponsiveSpacing(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: labelFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    Member member,
    bool isPresident,
    TontineProvider tontineProvider,
    int tontineId,
  ) {
    final roles = member.user?.roles ?? [Role.TONTINARD];
    final primaryRole =
        roles.contains(Role.PRESIDENT) ? Role.PRESIDENT : roles.first;
    final cardMargin = ResponsiveHelper.getAdaptiveSpacing(context, base: 12.0);
    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 16.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 16.0);
    final avatarRadius = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 22.0,
      medium: 24.0,
      large: 25.0,
    );

    return Card(
      margin: EdgeInsets.only(bottom: cardMargin),
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
          padding: cardPadding,
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: primaryRole.color,
                child: Text(
                  _getInitials(member),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getAdaptiveValue(
                      context,
                      small: 14.0,
                      medium: 15.0,
                      large: 16.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: spacing),
              // Informations du membre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${member.firstname} ${member.lastname}',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveValue(
                          context,
                          small: 14.0,
                          medium: 15.0,
                          large: 16.0,
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ResponsiveSpacing(height: 4),
                    Text(
                      member.user?.username ?? 'Pas de nom d\'utilisateur',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveValue(
                          context,
                          small: 11.0,
                          medium: 11.5,
                          large: 12.0,
                        ),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    ResponsiveSpacing(height: 4),
                    Text(
                      member.phone ?? 'Pas de numéro de téléphone',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveValue(
                          context,
                          small: 11.0,
                          medium: 11.5,
                          large: 12.0,
                        ),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    ResponsiveSpacing(height: 8),
                    // Badges des rôles
                    RoleBadgeList(
                      roles: roles,
                      showIcon: true,
                      fontSize: ResponsiveHelper.getAdaptiveValue(
                        context,
                        small: 9.0,
                        medium: 9.5,
                        large: 10.0,
                      ),
                      padding: ResponsiveHelper.getAdaptivePadding(
                        context,
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
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
                // Bouton partager l'invitation
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.share,
                      color: AppColors.success,
                      size: 20,
                    ),
                    onPressed: () => _shareIndividualInvitation(
                        context, member, tontineProvider.currentTontine!),
                    tooltip: 'Partager l\'invitation',
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
    final downloadLink = _appDownloadLink();
    final step1 = downloadLink.isNotEmpty
        ? '1. Téléchargez l\'application Tontine : $downloadLink'
        : '1. Téléchargez l\'application Tontine';

    // Message personnalisé pour WhatsApp
    final message = '''
🏦 *Invitation à rejoindre la tontine "${tontine.title}"*

Bonjour ! Vous êtes invité(e) à rejoindre notre tontine "${tontine.title}".

📱 *Pour vous connecter :*
$step1
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

    // Afficher les options de partage
    _showShareOptionsDialog(context, message);
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
        final launched = await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          await _safeShareText(message);
        }
      } else {
        // Fallback vers l'application de partage générale
        await _safeShareText(message);
      }
    } catch (e) {
      // En cas d'erreur, utiliser le partage général
      await _safeShareText(message);
    }
  }

  void _shareViaOtherApps(String message) async {
    await _safeShareText(
      message,
      subject: 'Invitation à rejoindre la tontine',
    );
  }

  void _shareIndividualInvitation(
      BuildContext context, Member member, Tontine tontine) {
    final username = member.user?.username ?? 'non_defini';
    final downloadLink = _appDownloadLink();
    final downloadLine = downloadLink.isNotEmpty
        ? '• Téléchargez l\'application Tontine : $downloadLink'
        : '• Téléchargez l\'application Tontine';

    final message = '''
🏦 *Invitation personnelle - Tontine "${tontine.title}"*

Bonjour ${member.firstname} ${member.lastname} !

Vous êtes invité(e) à rejoindre notre tontine "${tontine.title}".

📱 *Vos identifiants de connexion :*
   👤 *Nom d'utilisateur :* $username
   🔑 *Mot de passe temporaire :* changeme

🔐 *IMPORTANT - Sécurité :*
⚠️ *Changez votre mot de passe dès votre première connexion !*
$downloadLine
• Connectez-vous avec les identifiants ci-dessus
• Allez dans "Mon compte" → "Modifier le mot de passe"
• Choisissez un mot de passe fort (8+ caractères, majuscules, chiffres)

💰 *Détails de la tontine :*
• Nom : ${tontine.title}
• Membres actuels : ${tontine.members.length}
• Système : ${tontine.config.systemType.displayName}

Bienvenue dans notre tontine ! 🚀

---
*Message envoyé depuis l'application Tontine*
''';

    // Afficher les options de partage
    _showShareOptionsDialog(context, message);
  }

  void _showShareOptionsDialog(BuildContext context, String message) {
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
                'Choisissez comment partager :',
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
}
