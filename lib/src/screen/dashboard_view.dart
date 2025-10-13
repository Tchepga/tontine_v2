import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../widgets/circular_order_card.dart';
import '../theme/app_theme.dart';
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

  void navigateToView(dynamic context, String route) {
    Navigator.pushNamed(context, route);
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
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    children: [
                      const SizedBox(height: 24),
                      _buildCurrentOrderSection(tontineProvider),
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
                          _buildMenuCard(
                              context,
                              'Banque',
                              'assets/images/undraw_wallet_diag.svg',
                              CashflowView.routeName),
                          _buildMenuCard(
                              context,
                              'Membres',
                              'assets/images/undraw_fans_icv6.svg',
                              AccountView.routeName),
                          _buildMenuCard(
                              context,
                              'Emprunts',
                              'assets/images/undraw_investment_ojxu.svg',
                              LoanView.routeName),
                          _buildMenuCard(
                              context,
                              'Événements',
                              'assets/images/undraw_special-event_hv54.svg',
                              EventView.routeName),
                          _buildMenuCard(
                              context,
                              'Rapports',
                              'assets/images/undraw_uploading_nu4x.svg',
                              RapportView.routeName),
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

  Widget _buildCurrentOrderSection(TontineProvider tontineProvider) {
    final orderData = tontineProvider.getCurrentAndNextPartOrders();
    final currentPart = orderData['current'];
    final nextPart = orderData['next'];

    if (currentPart == null && nextPart == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ordre de passage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (currentPart != null) ...[
                  Expanded(
                    child: CircularOrderCard(
                      partOrder: currentPart,
                      isCurrent: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (nextPart != null) ...[
                  Expanded(
                    child: CircularOrderCard(
                      partOrder: nextPart,
                      isNext: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, String title, String imagePath, String route) {
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
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: imagePath.endsWith('.svg')
                    ? SvgPicture.asset(
                        imagePath,
                        width: 70,
                        height: 70,
                      )
                    : Image.asset(
                        imagePath,
                        width: 40,
                        height: 40,
                      ),
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
