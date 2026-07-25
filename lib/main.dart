import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'src/services/local_notification_service.dart';
import 'src/services/push_notification_service.dart';
import 'src/services/realtime_notification_service.dart';
import 'src/services/token_storage.dart';

import 'src/app.dart';
import 'src/providers/auth_provider.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/providers/tontine_provider.dart';
import 'src/providers/loan_provider.dart';
import 'src/providers/event_provider.dart';
import 'src/providers/notification_provider.dart';

// Environnement injecté via --dart-define=ENV=local|staging|production
// Par défaut : production
const String _env = String.fromEnvironment('ENV', defaultValue: 'production');
const String _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envFile = 'assets/env/.env.$_env';
  await dotenv.load(fileName: envFile);
  debugPrint('Environnement chargé : $envFile');

  final apiUrl = dotenv.env['API_URL']?.trim();
  if (apiUrl == null || apiUrl.isEmpty) {
    throw StateError(
      'API_URL est absent ou vide dans $envFile. '
      'Ajoutez une ligne du type API_URL=https://votre-api (sans slash final).',
    );
  }

  await GetStorage.init();
  await TokenStorage.instance.init();

  Logger.root.level = kReleaseMode ? Level.WARNING : Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kReleaseMode && record.level < Level.WARNING) return;
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  Future<void> startApp() async {
    await LocalNotificationService().init();
    await PushNotificationService.instance.init();
    RealtimeNotificationService().initialize();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TontineProvider()),
          ChangeNotifierProvider(create: (_) => LoanProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: MyApp(settingsController: settingsController),
      ),
    );
  }

  final sentryDsn = _sentryDsn.isNotEmpty
      ? _sentryDsn
      : (dotenv.env['SENTRY_DSN']?.trim() ?? '');

  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = _env;
        options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
        options.sendDefaultPii = false;
      },
      appRunner: startApp,
    );
  } else {
    await startApp();
  }
}
