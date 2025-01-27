import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/notification_service.dart';
import 'models/notification_tontine.dart';

class NotificationProvider extends ChangeNotifier {
  final _notificationService = NotificationService();
  final _logger = Logger('NotificationProvider');
  Timer? _timer;
  List<NotificationTontine> _notifications = [];
  static const _checkInterval = Duration(seconds: 60);

  List<NotificationTontine> get notifications => _notifications;

  void startChecking(int tontineId) {
    _timer?.cancel();
    _checkUpdates(tontineId);
    _timer = Timer.periodic(_checkInterval, (_) => _checkUpdates(tontineId));
  }

  Future<void> _checkUpdates(int tontineId) async {
    try {
      final newNotifications = await _notificationService.getNotification(tontineId);
      if (newNotifications != null) {
        _notifications = newNotifications;
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error checking notifications: $e');
    }
  }

  void stopChecking() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopChecking();
    super.dispose();
  }
} 