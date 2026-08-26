import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/loan_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/models/enum/currency.dart';
import '../../providers/models/enum/loop_period.dart';
import '../../providers/models/enum/type_mouvement.dart';
import '../../providers/models/enum/tontine_status.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/status_badge.dart';
import '../../theme/app_theme.dart';
import '../dashboard_view.dart';
import '../login_view.dart';
import '../services/dto/member_dto.dart';
import '../services/dto/tontine_dto.dart';
import '../services/member_service.dart';
import '../../services/error_catchable.dart';

class SelectTontineView extends StatefulWidget {
  static const routeName = '/select-tontine';
  const SelectTontineView({super.key});

  @override
  State<SelectTontineView> createState() => _SelectTontineViewState();
}

class _SelectTontineViewState extends State<SelectTontineView> {
  final _logger = Logger('SelectTontineView');
  final MemberService memberService = MemberService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentTontine =
          Provider.of<TontineProvider>(context, listen: false).currentTontine;
      if (currentTontine != null) {
        Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
      } else {
        _loadTontines();
      }
    });
  }

  Future<void> _loadTontines() async {
    try {
      final isValidToken = await memberService.hasValidToken();
      if (!isValidToken) {
        if (mounted) {
          Provider.of<TontineProvider>(context, listen: false)
              .clearCurrentTontineSelection(
            eventProvider: context.read<EventProvider>(),
            loanProvider: context.read<LoanProvider>(),
            notificationProvider: context.read<NotificationProvider>(),
          );
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.of(context).pushReplacementNamed(LoginView.routeName);
        }
        return;
      }
      await Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
      if (!mounted) return;
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmation de déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleLogout(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Provider.of<TontineProvider>(context, listen: false)
        .clearCurrentTontineSelection(
      eventProvider: context.read<EventProvider>(),
      loanProvider: context.read<LoanProvider>(),
      notificationProvider: context.read<NotificationProvider>(),
    );
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginView.routeName,
      (route) => false,
    );
  }

  void _showCreateTontineDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final loanRateController = TextEditingController(text: '2');
    final loanDurationController = TextEditingController(text: '30');
    final minLoanAmountController = TextEditingController(text: '100');
    final maxMembersController = TextEditingController(text: '12');
    final countPersonPerMovementController = TextEditingController(text: '1');

    LoopPeriod selectedPeriod = LoopPeriod.MONTHLY;
    MovementType selectedMovementType = MovementType.ROTATIVE;
    Currency selectedCurrency = Currency.EUR;

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (dialogContext) {
          void submit() => _handleCreateTontine(
                dialogContext,
                formKey,
                titleController,
                loanRateController,
                loanDurationController,
                minLoanAmountController,
                maxMembersController,
                countPersonPerMovementController,
                selectedPeriod,
                selectedMovementType,
                selectedCurrency,
              );

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('Nouvelle tontine'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(dialogContext),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Se déconnecter',
                  onPressed: () => _showLogoutConfirmation(context),
                ),
                TextButton(
                  onPressed: submit,
                  child: const Text('Créer'),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le nom est requis';
                                }
                                final tontineProvider =
                                    Provider.of<TontineProvider>(
                                  dialogContext,
                                  listen: false,
                                );
                                if (tontineProvider
                                    .hasDuplicateTitle(value)) {
                                  return 'Une tontine avec ce nom existe déjà';
                                }
                                return null;
                              },
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
                              initialValue: selectedPeriod,
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
                              initialValue: selectedMovementType,
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
                              initialValue: selectedCurrency,
                              decoration: const InputDecoration(
                                labelText: 'Devise*',
                                border: OutlineInputBorder(),
                              ),
                              items: Currency.values.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(
                                      '${currency.toString().split('.').last} (${currency.displayName})'),
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
                  Material(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(dialogContext).scaffoldBackgroundColor,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: submit,
                        child: const Text('Créer la tontine'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    TextEditingController loanRateController,
    TextEditingController loanDurationController,
    TextEditingController minLoanAmountController,
    TextEditingController maxMembersController,
    TextEditingController countPersonPerMovementController,
    LoopPeriod selectedPeriod,
    MovementType selectedMovementType,
    Currency selectedCurrency,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = await authProvider.getCurrentUser();
    if (!context.mounted) return;

    if (currentUser?.user?.username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil utilisateur indisponible. Reconnectez-vous puis réessayez.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tontineProvider =
        Provider.of<TontineProvider>(context, listen: false);
    if (tontineProvider.hasDuplicateTitle(titleController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une tontine avec ce nom existe déjà'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final memberDto = CreateMemberDto(
        username: currentUser!.user!.username,
        firstname: currentUser.firstname ?? '',
        lastname: currentUser.lastname ?? '',
        phone: currentUser.phone ?? '',
        country: currentUser.country ?? '',
      );

      final tontineDto = CreateTontineDto(
        title: titleController.text.trim(),
        memberDtos: [memberDto],
        config: CreateConfigTontineDto(
          defaultLoanRate: double.parse(loanRateController.text),
          defaultLoanDuration: int.parse(loanDurationController.text),
          loopPeriod: selectedPeriod,
          minLoanAmount: double.parse(minLoanAmountController.text),
          countPersonPerMovement:
              int.parse(countPersonPerMovementController.text),
          movementType: selectedMovementType,
          countMaxMember: int.parse(maxMembersController.text),
        ),
        currency: selectedCurrency,
      );

      await tontineProvider.createTontine(tontineDto);
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      final message = e == ErrorCatchable.TONTINE_TITLE_ALREADY_EXISTS
          ? 'Une tontine avec ce nom existe déjà'
          : 'Erreur lors de la création';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner une tontine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
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
                          colors: [
                            Colors.orange.shade300,
                            Colors.orange.shade500
                          ],
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
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _showLogoutConfirmation(context),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Se déconnecter',
                              style: TextStyle(color: Colors.white),
                            ),
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
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tontine.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (tontine.status == TontineStatus.CLOSED)
                        const StatusBadge(
                          text: 'Clôturée',
                          color: AppColors.textSecondary,
                          icon: Icons.archive_outlined,
                          showIcon: true,
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${tontine.members.length} membres'),
                      Text(
                          'Solde: ${tontine.cashFlow.amount} ${tontine.cashFlow.currency.displayName}'),
                      if (tontine.isClosed)
                        Text(
                          'Consultation seule',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: tontine.id == tontineProvider.currentTontine?.id
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () async {
                    await tontineProvider.setCurrentTontine(
                      tontine,
                      refreshFromApi: true,
                      eventProvider: context.read<EventProvider>(),
                      loanProvider: context.read<LoanProvider>(),
                      notificationProvider:
                          context.read<NotificationProvider>(),
                    );
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushReplacementNamed(DashboardView.routeName);
                      // TODO: review after adding part order
                      // if (tontine.members.length < tontine.config.countMaxMember) {
                      //   Navigator.of(context).pushReplacementNamed(AddMembersView.routeName);
                      // } else {
                      //   Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
                      // }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'select_tontine_fab',
        onPressed: () => _showCreateTontineDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
