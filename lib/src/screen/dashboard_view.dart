import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        }

        final maxWidth = ResponsiveHelper.getAdaptiveValue(
          context,
          small: double.infinity,
          medium: 900.0,
          large: 1200.0,
        );

        return Scaffold(
          appBar: ActionMenu(title: 'Dashboard'),
          drawer: const AppDrawer(),
          backgroundColor: AppColors.background,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: ResponsiveHelper.getAdaptivePadding(
                  context,
                  horizontal: 16.0,
                  vertical: 0.0,
                ),
                children: [
                  ResponsiveSpacing(height: 16),
                  _buildCurrentOrderSection(context, tontineProvider),
                  ResponsiveSpacing(height: 16),
                  _buildQuickAccessSection(context),
                  ResponsiveSpacing(height: 20),
                  AnnualMovementsChart(deposits: tontineProvider.deposits),
                  ResponsiveSpacing(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildCurrentOrderSection(
      BuildContext context, TontineProvider tontineProvider) {
    final orderData = tontineProvider.getCurrentAndNextPartOrders();
    final members = tontineProvider.currentTontine?.members ?? const [];
    final currentPart = orderData['current'] == null
        ? null
        : enrichPartOrder(orderData['current']!, members);
    final nextPart = orderData['next'] == null
        ? null
        : enrichPartOrder(orderData['next']!, members);

    if (currentPart == null && nextPart == null) {
      return const SizedBox.shrink();
    }

    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 16.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 22.0);
    final spacing = ResponsiveHelper.getAdaptiveSpacing(context, base: 12.0);

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
                      small: 15.0,
                      medium: 17.0,
                      large: 17.0,
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

  /// Raccourcis compacts (2 colonnes) visibles sans scroller.
  Widget _buildQuickAccessSection(BuildContext context) {
    const items = [
      _QuickAccessItem(
        title: 'Trésorerie',
        icon: Icons.account_balance_wallet_outlined,
        route: CashflowView.routeName,
        color: AppColors.primary,
      ),
      _QuickAccessItem(
        title: 'Membres',
        icon: Icons.groups_outlined,
        route: MemberView.routeName,
        color: AppColors.info,
      ),
      _QuickAccessItem(
        title: 'Emprunts',
        icon: Icons.handshake_outlined,
        route: LoanView.routeName,
        color: AppColors.secondaryDark,
      ),
      _QuickAccessItem(
        title: 'Événements',
        icon: Icons.event_outlined,
        route: EventView.routeName,
        color: AppColors.success,
      ),
      _QuickAccessItem(
        title: 'Rapports',
        icon: Icons.bar_chart_outlined,
        route: RapportView.routeName,
        color: AppColors.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accès rapide',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 700 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 64,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _QuickAccessTile(item: item);
              },
            );
          },
        ),
      ],
    );
  }
}

class _QuickAccessItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  const _QuickAccessItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class _QuickAccessTile extends StatelessWidget {
  final _QuickAccessItem item;

  const _QuickAccessTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pushNamed(context, item.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
