import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/providers/models/tontine.dart';
import 'package:tontine_v2/src/screen/casflow/cashflow_view.dart';
import 'package:tontine_v2/src/screen/event/event_view.dart';
import 'package:tontine_v2/src/screen/loan/loan_view.dart';
import 'package:tontine_v2/src/screen/member/account_view.dart';
import 'package:tontine_v2/src/screen/rapport/rapport_view.dart';

import '../providers/auth_provider.dart';
import '../providers/tontine_provider.dart';
import '../widgets/action_menu.dart';
import '../widgets/annual_movements_chart.dart';
import '../widgets/menu_widget.dart';
import 'tontine/select_tontine_view.dart';

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
            appBar: ActionMenu(title: 'Dashboard'),
            backgroundColor: const Color(0xFFF6F8FB),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    children: [
                      const SizedBox(height: 24),
                      AnnualMovementsChart(deposits: tontineProvider.deposits),
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 1,
                        children: [
                          _buildMenuCard(context, 'Banque', Icons.balance, Colors.purple, CashflowView.routeName),
                          _buildMenuCard(context, 'Rapports', Icons.read_more, Colors.amber, RapportView.routeName),
                          _buildMenuCard(context, 'Emprunts', Icons.monetization_on, Colors.orange, LoanView.routeName),
                          _buildMenuCard(context, 'Événements', Icons.event, Colors.blue, EventView.routeName),
                          _buildMenuCard(context, 'Membres', Icons.person, Colors.teal, AccountView.routeName),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: const MenuWidget(),
          );
        }
      },
    );
  }


  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
