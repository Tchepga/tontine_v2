import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tontine_v2/src/screen/casflow/cashflow_view.dart';
import 'package:tontine_v2/src/screen/dashboard_view.dart';
import 'package:tontine_v2/src/screen/login_view.dart';
import 'package:tontine_v2/src/screen/member/account_view.dart';
import 'package:tontine_v2/src/screen/splash_view.dart';

import 'screen/selected_language_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',
          

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'), // french, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blue[400],
            primaryColorDark: Colors.blue[700],
            primaryColorLight: Colors.blue[200],
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Colors.deepOrangeAccent,
              primary: Colors.blue,
              tertiary: Colors.green[300],
              error: Colors.red,
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontSize: 34.0),
              displayMedium: TextStyle(fontSize: 24.0),
              displaySmall: TextStyle(fontSize: 20.0),
              bodyLarge: TextStyle(fontSize: 16.0),
              bodyMedium: TextStyle(fontSize: 14.0),
              bodySmall: TextStyle(fontSize: 12.0),
            ),
            
            scaffoldBackgroundColor: Colors.white,
            secondaryHeaderColor: Colors.deepOrangeAccent,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          darkTheme: ThemeData.light(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case LoginView.routeName:
                    return const LoginView();
                  case DashboardView.routeName:
                    return const DashboardView();
                  case CashflowView.routeName:
                    return const CashflowView();
                  case AccountView.routeName:
                    return const AccountView();
                  case SelectedLanguageView.routeName:
                    return SelectedLanguageView();
                  default:
                    return const SplashView();
                }
              },
            );
          },
        );
      },
    );
  }
}
