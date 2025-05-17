import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screen/login_view.dart';
import '../screen/notification/notification_view.dart';
import '../screen/tontine/setting_tontine_view.dart';

class ActionMenu extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  const ActionMenu({super.key, required this.title, this.showBackButton = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                    IconButton(
                      iconSize: 30.0,
                      color: Colors.white,
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.pushNamed(context, NotificationView.routeName);
                      },
                    ),
                    IconButton(
                      iconSize: 30.0,
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, SettingTontineView.routeName);
                      },
                    ),
                    IconButton(
                      iconSize: 30.0,
                      icon: const Icon(Icons.power_settings_new),
                      color: Colors.white,
                      onPressed: () {
                        authProvider.logout();
                        Navigator.of(context).pushReplacementNamed(LoginView.routeName);
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
  }
} 