import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tontine_v2/src/screen/casflow/cashflow_view.dart';
import 'package:tontine_v2/src/screen/event/event_view.dart';
import 'package:tontine_v2/src/screen/loan/loan_view.dart';
import 'package:tontine_v2/src/screen/member/member_view.dart';
import 'package:tontine_v2/src/screen/rapport/rapport_view.dart';

import '../providers/auth_provider.dart';
import '../providers/tontine_provider.dart';
import '../widgets/action_menu.dart';
import '../widgets/annual_movements_chart.dart';
import '../widgets/menu_widget.dart';
import '../widgets/circular_order_card.dart';
import '../widgets/responsive_padding.dart';
import '../utils/responsive_helper.dart';
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
          // Largeur maximale adaptative selon la taille de l'écran
          final maxWidth = ResponsiveHelper.getAdaptiveValue(
            context,
            small: double.infinity, // Pas de limite sur mobile
            medium: 900.0, // Limite à 900px sur tablette
            large: 1200.0, // Limite à 1200px sur desktop
          );
          
          return Scaffold(
            appBar: ActionMenu(title: 'Dashboard'),
            backgroundColor: AppColors.background,
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: ResponsiveHelper.getAdaptivePadding(
                          context,
                          horizontal: 16.0,
                          vertical: 0.0,
                        ),
                        children: [
                      ResponsiveSpacing(height: 24),
                      _buildCurrentOrderSection(context, tontineProvider),
                      ResponsiveSpacing(height: 24),
                      AnnualMovementsChart(deposits: tontineProvider.deposits),
                      ResponsiveSpacing(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount:
                            ResponsiveHelper.getAdaptiveCrossAxisCount(context),
                        mainAxisSpacing: ResponsiveHelper.getAdaptiveSpacing(
                            context,
                            base: 24.0),
                        crossAxisSpacing: ResponsiveHelper.getAdaptiveSpacing(
                            context,
                            base: 24.0),
                        childAspectRatio:
                            ResponsiveHelper.getAdaptiveAspectRatio(context),
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
                              MemberView.routeName),
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
              ),
            ),
            bottomNavigationBar: const MenuWidget(),
          );
        }
      },
    );
  }

  Widget _buildCurrentOrderSection(
      BuildContext context, TontineProvider tontineProvider) {
    final orderData = tontineProvider.getCurrentAndNextPartOrders();
    final currentPart = orderData['current'];
    final nextPart = orderData['next'];

    if (currentPart == null && nextPart == null) {
      return const SizedBox.shrink();
    }

    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 20.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 24.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 16.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: iconSize,
                ),
                SizedBox(width: spacing * 0.5),
                Text(
                  'Ordre de passage',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveValue(
                      context,
                      small: 16.0,
                      medium: 18.0,
                      large: 18.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              children: [
                if (currentPart != null) ...[
                  Expanded(
                    child: CircularOrderCard(
                      partOrder: currentPart,
                      isCurrent: true,
                    ),
                  ),
                  SizedBox(width: spacing),
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
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 70.0);
    final verticalPadding = ResponsiveHelper.getAdaptiveHeightValue(
      context,
      short: 16.0,
      medium: 20.0,
      tall: 10.0,
    );
    final horizontalPadding = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 6.0,
      medium: 8.0,
      large: 8.0,
    );
    final containerPadding =
        ResponsiveHelper.getAdaptivePadding(context, all: 16.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 16.0);
    final fontSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 13.0,
      medium: 14.0,
      large: 15.0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: verticalPadding, horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: containerPadding,
                child: imagePath.endsWith('.svg')
                    ? SvgPicture.asset(
                        imagePath,
                        width: iconSize,
                        height: iconSize,
                      )
                    : Image.asset(
                        imagePath,
                        width: iconSize * 0.57,
                        height: iconSize * 0.57,
                      ),
              ),
              SizedBox(height: spacing),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
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
