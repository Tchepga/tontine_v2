import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/models/enum/role.dart';
import '../screen/casflow/cashflow_view.dart';
import '../screen/event/event_view.dart';
import '../screen/loan/loan_view.dart';
import '../screen/member/account_view.dart';
import '../screen/member/member_view.dart';
import '../screen/dashboard_view.dart';
import '../screen/rapport/rapport_view.dart';
import '../theme/app_theme.dart';

/// Routes de la barre de navigation principale (5 onglets).
const _routes = [
  CashflowView.routeName,  // 0 - Banque
  MemberView.routeName,    // 1 - Membres
  DashboardView.routeName, // 2 - Dashboard (centre)
  LoanView.routeName,      // 3 - Emprunts
  AccountView.routeName,   // 4 - Compte
];

int _routeToIndex(String? route) {
  final idx = _routes.indexOf(route ?? '');
  return idx < 0 ? 2 : idx; // Dashboard par défaut
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final selectedIndex = _routeToIndex(currentRoute);

    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      shadowColor: Colors.black12,
      elevation: 8,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      animationDuration: const Duration(milliseconds: 300),
      onDestinationSelected: (index) {
        final targetRoute = _routes[index];
        if (currentRoute == targetRoute) return;
        if (index == 2) {
          Navigator.of(context).pushReplacementNamed(targetRoute);
        } else {
          Navigator.of(context).pushNamed(targetRoute);
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
          label: 'Banque',
        ),
        NavigationDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people, color: AppColors.primary),
          label: 'Membres',
        ),
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: const Icon(Icons.trending_up_outlined),
          selectedIcon: Icon(Icons.trending_up, color: AppColors.primary),
          label: 'Emprunts',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Compte',
        ),
      ],
    );
  }
}

/// Drawer latéral pour les sections secondaires (Événements, Rapports).
/// Ajouter [drawer: const AppDrawer()] dans les Scaffold concernés.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isPresident =
        authProvider.currentUser?.user?.roles?.contains(Role.PRESIDENT) ?? false;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.savings, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tontine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.event_outlined,
                  label: 'Événements',
                  route: EventView.routeName,
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: Icons.description_outlined,
                  label: 'Rapports & Sanctions',
                  route: RapportView.routeName,
                  currentRoute: currentRoute,
                ),
                if (isPresident) ...[
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.download_outlined,
                    label: 'Exporter CSV',
                    route: null,
                    currentRoute: null,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Utilisez le menu de la tontine pour exporter'),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? route;
  final String? currentRoute;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = route != null && route == currentRoute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap ??
            () {
              Navigator.pop(context);
              if (route != null && route != currentRoute) {
                Navigator.pushNamed(context, route!);
              }
            },
      ),
    );
  }
}
