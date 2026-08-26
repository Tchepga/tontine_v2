import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/loan_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/models/enum/tontine_status.dart';
import '../../providers/models/enum/currency.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/status_badge.dart';
import '../../theme/app_theme.dart';
import '../dashboard_view.dart';
import '../login_view.dart';
import '../services/member_service.dart';
import 'create_tontine_view.dart';

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
      final currentTontine = Provider.of<TontineProvider>(
        context,
        listen: false,
      ).currentTontine;
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
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.of(context).pushReplacementNamed(LoginView.routeName);
        }
        return;
      }
      await memberService.getProfile();
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

  Future<void> _openCreateTontine() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CreateTontineView(),
      ),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tontine créée')));
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
            return SafeArea(
              child: SingleChildScrollView(
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
                              Colors.orange.shade500,
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
                              'Vous n\'avez pas encore de tontine. Créez-en une avec le bouton ci-dessous.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _openCreateTontine,
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
                        'Solde: ${tontine.cashFlow.amount} ${tontine.cashFlow.currency.displayName}',
                      ),
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
                  trailing: tontine.isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () async {
                    await tontineProvider.setCurrentTontine(
                      tontine,
                      refreshFromApi: true,
                      eventProvider: context.read<EventProvider>(),
                      loanProvider: context.read<LoanProvider>(),
                      notificationProvider: context
                          .read<NotificationProvider>(),
                    );
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(DashboardView.routeName);
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
      floatingActionButton: Consumer<TontineProvider>(
        builder: (context, tontineProvider, _) {
          if (tontineProvider.tontines.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: FloatingActionButton(
              heroTag: 'select_tontine_fab',
              onPressed: _openCreateTontine,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
