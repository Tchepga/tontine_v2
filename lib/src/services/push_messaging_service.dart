import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../screen/services/member_service.dart';
import '../screen/services/middleware/interceptor_http.dart';
import '../services/local_notification_service.dart';

class PushMessagingService {
  static final PushMessagingService _instance = PushMessagingService._internal();
  factory PushMessagingService() => _instance;
  PushMessagingService._internal();

  final _logger = Logger('PushMessagingService');
  final _storage = GetStorage();

  bool _initialized = false;

  static const _storageKeyLastFcmToken = 'last_fcm_token';

  static String? resolvePlatform() {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return null;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Web: nécessite une config service worker spécifique, on n’active pas ici
      if (kIsWeb) return;

      // Permissions iOS/macOS
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground: afficher une notification locale (sinon iOS ne l’affiche pas)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final title = message.notification?.title ?? 'Notification';
        final body = message.notification?.body ?? '';
        await LocalNotificationService().showNotification(
          title: title,
          body: body,
          payload: '/notifications',
        );
      });

      // Token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        _logger.info('FCM token refreshed');
        await _registerTokenToBackend(token);
      });

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registerTokenToBackend(token);
      }
    } catch (e) {
      _logger.warning('Erreur init push: $e');
    }
  }

  Future<void> _registerTokenToBackend(String token) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null || apiUrl.isEmpty) return;

      // Ne tente pas de register si pas de token d'auth
      final authToken = _storage.read(MemberService.KEY_TOKEN);
      if (authToken == null) return;

      final platform = resolvePlatform();
      if (platform == null) return;

      final lastToken = _storage.read(_storageKeyLastFcmToken);
      if (lastToken == token) return; // rien à faire

      final client = ApiClient.client;
      final url = Uri.parse('$apiUrl/api/device-tokens');

      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token, 'platform': platform}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _storage.write(_storageKeyLastFcmToken, token);
        _logger.info('Device token enregistré côté API');
      } else {
        _logger.warning(
          'Erreur API device-tokens: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.warning('Erreur register token backend: $e');
    }
  }

  Future<void> unregisterFromBackend() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null || apiUrl.isEmpty) return;

      final authToken = _storage.read(MemberService.KEY_TOKEN);
      if (authToken == null) return;

      final token = _storage.read(_storageKeyLastFcmToken);
      if (token == null) return;

      final client = ApiClient.client;
      final url = Uri.parse(
        '$apiUrl/api/device-tokens/${Uri.encodeComponent(token)}',
      );

      final response = await client.delete(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _storage.remove(_storageKeyLastFcmToken);
      }
    } catch (e) {
      _logger.warning('Erreur unregister token backend: $e');
    }
  }
}


