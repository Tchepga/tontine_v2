import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'src/services/local_notification_service.dart';
import 'src/services/realtime_notification_service.dart';

import 'src/app.dart';
import 'src/providers/auth_provider.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/providers/tontine_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/providers/loan_provider.dart';
import 'src/providers/event_provider.dart';
import 'src/providers/notification_provider.dart';

// DotEnv dotenv = DotEnv() is automatically called during import.
// If you want to load multiple dotenv files or name your dotenv object differently, you can do the following and import the singleton into the relavant files:
// DotEnv another_dotenv = DotEnv()

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important !

  await dotenv.load(fileName: ".env");

  await GetStorage.init();

  // Initialiser les notifications locales
  await LocalNotificationService().init();

  // Initialiser le service de notifications en temps réel
  await RealtimeNotificationService().initialize();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  //await WebSocketService().connect();

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

  // Suppression de l'appel WebSocket
  // WebSocketService().connect();
}
