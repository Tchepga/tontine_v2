import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'dart:async';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  final _logger = Logger('LocalNotificationService');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callback pour la navigation
  static Function(String?)? onNotificationTap;

  // Compteur pour les IDs de notification uniques
  int _notificationId = 0;

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  /// Initialiser le service de notifications
  Future<void> init() async {
    // Configuration Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: false,
    );

    // Configuration macOS
    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );

    // Initialiser le plugin
    final bool? initialized = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _logger.info('Notification clicked: ${response.payload}');
        if (onNotificationTap != null) {
          onNotificationTap!(response.payload);
        }
      },
    );

    if (initialized == true) {
      _logger.info('LocalNotificationService initialized successfully');

      // Créer les canaux de notification Android
      await _createNotificationChannels();

      // Demander les permissions pour Android 13+
      await _requestPermissions();
    } else {
      _logger.warning('LocalNotificationService initialization failed');
    }
  }

  /// Créer les canaux de notification pour Android
  Future<void> _createNotificationChannels() async {
    // Canal principal pour les notifications de tontine
    const androidChannel = AndroidNotificationChannel(
      'tontine_notifications',
      'Tontine Notifications',
      description: 'Notifications pour les événements de la tontine',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _logger.info('Notification channels created');
  }

  /// Demander les permissions nécessaires
  Future<void> _requestPermissions() async {
    // Android 13+ nécessite une permission explicite
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted =
          await androidImplementation.requestNotificationsPermission();
      if (granted == true) {
        _logger.info('Android notification permission granted');
      } else {
        _logger.warning('Android notification permission denied');
      }
    }

    // iOS nécessite aussi des permissions
    final iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted == true) {
        _logger.info('iOS notification permission granted');
      } else {
        _logger.warning('iOS notification permission denied');
      }
    }
  }

  /// Afficher une notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Générer un ID unique pour chaque notification
      final notificationId = _notificationId++;

      // Configuration Android avec canal de notification
      const androidDetails = AndroidNotificationDetails(
        'tontine_notifications',
        'Tontine Notifications',
        channelDescription: 'Notifications pour les événements de la tontine',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      // Configuration iOS
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      // Configuration macOS
      const macosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: macosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      _logger.info('Notification displayed: $title');
    } catch (e) {
      _logger.severe('Error showing notification: $e');
    }
  }

  /// Afficher une notification avec un style personnalisé (BigText)
  Future<void> showBigTextNotification({
    required String title,
    required String body,
    String? summary,
    String? payload,
  }) async {
    try {
      final notificationId = _notificationId++;

      final androidDetails = AndroidNotificationDetails(
        'tontine_notifications',
        'Tontine Notifications',
        channelDescription: 'Notifications pour les événements de la tontine',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          body,
          summaryText: summary,
          htmlFormatBigText: false,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Configuration macOS
      const macosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: macosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      _logger.info('Big text notification displayed: $title');
    } catch (e) {
      _logger.severe('Error showing big text notification: $e');
    }
  }

  /// Annuler une notification spécifique
  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    _logger.info('Notification cancelled: $notificationId');
  }

  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    _logger.info('All notifications cancelled');
  }

  /// Obtenir les notifications en attente
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
