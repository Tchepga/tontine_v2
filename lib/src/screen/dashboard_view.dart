import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/providers/models/tontine.dart';
import 'package:tontine_v2/src/screen/event/event_view.dart';

import '../providers/auth_provider.dart';
import '../providers/tontine_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/menu_widget.dart';
import '../widgets/movements_chart.dart';
import 'login_view.dart';
import 'tontine/select_tontine_view.dart';
import 'tontine/setting_tontine_view.dart';
import 'notification/notification_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  static const routeName = '/dashboard';
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine == null) {
        Navigator.of(context).pushReplacementNamed(SelectTontineView.routeName);
      } else {
        tontineProvider.loadDeposits(tontineProvider.currentTontine!.id);
      }
    });
  }

  void navigateToView(context, String route) {
    Navigator.pushNamed(context, route);
  }


  double _calculateProgress(Tontine? tontine) {
    if (tontine == null) return 0.0;
    final monthlyTarget = _calculateMonthlyTarget(tontine);
    if (monthlyTarget == 0) return 0.0;
    return (tontine.cashFlow.amount / monthlyTarget).clamp(0.0, 1.0);
  }

  double _calculateMonthlyTarget(Tontine? tontine) {
    if (tontine == null) return 0.0;
    // Calculer l'objectif mensuel basé sur la configuration de la tontine
    // Par exemple : nombre de membres * cotisation mensuelle
    return tontine.members.length * 100; // À adapter selon votre logique métier
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, TontineProvider>(
      builder: (context, authProvider, tontineProvider, child) {
        if (authProvider.isLoading || tontineProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentTontine = tontineProvider.currentTontine;
        if (currentTontine == null) {
          return const Scaffold(
            body: Center(
              child: Text('Aucune tontine sélectionnée'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blue[400],
              actions: [
                IconButton(
                  iconSize: 30.0, // Increase the size of the button
                  color: Colors.white,
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.pushNamed(context, NotificationView.routeName);
                  },
                ),
                IconButton(
                  iconSize: 30.0, // Increase the size of the button
                  icon: const Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, SettingTontineView.routeName);
                  },
                ),
                IconButton(
                  iconSize: 30.0, // Increase the size of the button
                  icon: const Icon(Icons.power_settings_new),
                  color: Colors.white,
                  onPressed: () {
                    authProvider.logout();
                    Navigator.of(context)
                        .pushReplacementNamed(LoginView.routeName);
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte principale avec le solde
                  BalanceCard(
                    tontine: currentTontine,
                    progress: _calculateProgress(currentTontine),
                    monthlyTarget: _calculateMonthlyTarget(currentTontine),
                  ),
                  const SizedBox(height: 24),

                  // Graphique des mouvements
                  MovementsChart(
                    deposits: tontineProvider.deposits,
                  ),
                  const SizedBox(height: 24),

                  // Grille de boutons
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        context,
                        'Evénements',
                        Icons.calendar_month_outlined,
                        Colors.orange,
                        EventView.routeName,
                      ),
                      _buildMenuCard(
                        context,
                        'Prêts',
                        Icons.monetization_on,
                        Colors.green,
                        '/loan',
                      ),
                      _buildMenuCard(
                        context,
                        'Rapports',
                        Icons.description,
                        Colors.purple,
                        '/rapport',
                      ),
                      _buildMenuCard(
                        context,
                        'Membres',
                        Icons.people,
                        Colors.blue,
                        '/members',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const MenuWidget(),
          );
        }
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
