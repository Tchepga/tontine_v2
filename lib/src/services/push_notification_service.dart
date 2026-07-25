import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'local_notification_service.dart';

/// Push distant FCM / APNs. No-op si Firebase n'est pas configuré.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _logger = Logger('PushNotificationService');
  bool _initialized = false;
  String? fcmToken;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _logger.info('Push permission: ${settings.authorizationStatus}');

      fcmToken = await messaging.getToken();
      _logger.info('FCM token obtained: ${fcmToken != null}');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? 'Thoua';
        final body = message.notification?.body ?? '';
        if (body.isNotEmpty) {
          LocalNotificationService().showNotification(
            title: title,
            body: body,
            payload: message.data['route'] as String?,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.info('Notification opened: ${message.data}');
      });

      _initialized = true;
    } catch (e, st) {
      // Pas de google-services.json / GoogleService-Info → skip sans planter
      _logger.warning('Push notifications unavailable: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: st);
      }
    }
  }
}
