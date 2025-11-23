import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/tontine_provider.dart';
import '../screen/login_view.dart';
import '../screen/notification/notification_view.dart';
import '../screen/tontine/setting_tontine_view.dart';

class ActionMenu extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  const ActionMenu(
      {super.key, required this.title, this.showBackButton = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Consumer2<NotificationProvider, TontineProvider>(
      builder: (context, notificationProvider, tontineProvider, child) {
        // Démarrer automatiquement le service de notifications si une tontine est sélectionnée
        final currentTontine = tontineProvider.currentTontine;
        if (currentTontine != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notificationProvider.startChecking(currentTontine.id);
          });
        }

        // Calculer le nombre de notifications non lues
        final unreadCount =
            notificationProvider.notifications.where((n) => !n.isRead).length;

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: Container(
            color: Colors.amber[900],
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: kToolbarHeight + 16,
                child: Row(
                  children: [
                    if (showBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      )
                    else
                      const SizedBox(width: 16),
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton de notification avec badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              iconSize: 30.0,
                              color: Colors.white,
                              icon: const Icon(Icons.notifications),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, NotificationView.routeName);
                              },
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.amber[900]!,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          iconSize: 30.0,
                          icon: const Icon(Icons.settings),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(
                                context, SettingTontineView.routeName);
                          },
                        ),
                        IconButton(
                          iconSize: 30.0,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
