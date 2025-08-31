import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/models/enum/type_notification.dart';
import '../../providers/notification_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/models/notification_tontine.dart';
import '../../widgets/menu_widget.dart';

class NotificationView extends StatefulWidget {
  static const routeName = '/notifications';
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .startChecking(tontineProvider.currentTontine!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotificationProvider, TontineProvider>(
      builder: (context, notificationProvider, tontineProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  if (tontineProvider.currentTontine != null) {
                    notificationProvider
                        .startChecking(tontineProvider.currentTontine!.id);
                  }
                },
              ),
            ],
          ),
          body: _buildNotificationList(notificationProvider),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildNotificationList(NotificationProvider notificationProvider) {
    if (notificationProvider.notifications.isEmpty) {
      return const Center(
        child: Text('Aucune notification'),
      );
    }

    return ListView.builder(
      itemCount: notificationProvider.notifications.length,
      itemBuilder: (context, index) {
        final notification = notificationProvider.notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationTontine notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.type.color.withAlpha(20),
          child: Icon(
            _getIconForType(notification.type),
            color: notification.type.color,
          ),
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.formattedDate,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: notification.type.color,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          // Marquer comme lu et naviguer vers la vue appropriée
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  IconData _getIconForType(TypeNotification type) {
    switch (type) {
      case TypeNotification.DEPOSIT:
        return Icons.attach_money;
      case TypeNotification.MEMBER:
        return Icons.person;
      case TypeNotification.SANCTION:
        return Icons.gavel;
      case TypeNotification.RAPPORT:
        return Icons.description;
      case TypeNotification.LOAN:
        return Icons.account_balance;
      case TypeNotification.EVENT:
        return Icons.event;
      case TypeNotification.OTHER:
        return Icons.notifications;
    }
  }

  void _handleNotificationTap(NotificationTontine notification) {
    // Implémenter la navigation selon le type de notification
    switch (notification.type) {
      case TypeNotification.DEPOSIT:
        Navigator.pushNamed(context, '/cashflow');
        break;
      case TypeNotification.MEMBER:
        Navigator.pushNamed(context, '/members');
        break;
      case TypeNotification.SANCTION:
      case TypeNotification.RAPPORT:
        Navigator.pushNamed(context, '/rapport');
        break;
      case TypeNotification.LOAN:
        Navigator.pushNamed(context, '/loan');
        break;
      case TypeNotification.EVENT:
        Navigator.pushNamed(context, '/event');
        break;
      case TypeNotification.OTHER:
        break;
    }
  }
}
