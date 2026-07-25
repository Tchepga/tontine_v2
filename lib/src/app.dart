import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:tontine_v2/src/screen/auth/forgot_password_view.dart';
import 'package:tontine_v2/src/screen/casflow/cashflow_view.dart';
import 'package:tontine_v2/src/screen/dashboard_view.dart';
import 'package:tontine_v2/src/screen/auth/reset_password_view.dart';
import 'package:tontine_v2/src/screen/login_view.dart';
import 'package:tontine_v2/src/screen/member/account_view.dart';
import 'package:tontine_v2/src/screen/splash_view.dart';
import 'package:tontine_v2/src/screen/features_explanation_view.dart';
import 'package:tontine_v2/src/services/session_manager.dart';
import 'package:tontine_v2/src/widgets/auth_gate.dart';

import 'screen/selected_language_view.dart';
import 'screen/tontine/add_members_view.dart';
import 'screen/tontine/select_tontine_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'screen/check_connection_view.dart';
import 'screen/loan/loan_view.dart';
import 'screen/rapport/rapport_view.dart';
import 'screen/tontine/setting_tontine_view.dart';
import 'screen/auth/register_view.dart';
import 'screen/event/event_view.dart';
import 'screen/notification/notification_view.dart';
import 'package:tontine_v2/src/services/local_notification_service.dart';
import 'screen/member/member_view.dart';
import 'localization/app_localizations.dart';
import 'theme/app_theme.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  static const _publicRoutes = {
    LoginView.routeName,
    RegisterView.routeName,
    ForgotPasswordView.routeName,
    ResetPasswordView.routeName,
    SelectedLanguageView.routeName,
    CheckConnectionView.routeName,
    FeaturesExplanationView.routeName,
  };

  @override
  void initState() {
    super.initState();
    SessionManager.navigatorKey = _navigatorKey;
    _setupNotificationHandling();
  }

  void _setupNotificationHandling() {
    LocalNotificationService.onNotificationTap = (String? payload) {
      if (payload != null && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.pushNamed(payload);
      }
    };
  }

  Widget _maybeProtect(String? routeName, Widget child) {
    if (routeName != null && _publicRoutes.contains(routeName)) {
      return child;
    }
    return AuthGate(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          restorationScopeId: 'app',
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
            Locale('en', 'US'),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: widget.settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                final Widget page;
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    page = SettingsView(controller: widget.settingsController);
                    break;
                  case LoginView.routeName:
                    page = const LoginView();
                    break;
                  case DashboardView.routeName:
                    page = const DashboardView();
                    break;
                  case CashflowView.routeName:
                    page = const CashflowView();
                    break;
                  case AccountView.routeName:
                    page = const AccountView();
                    break;
                  case SelectedLanguageView.routeName:
                    page = const SelectedLanguageView();
                    break;
                  case CheckConnectionView.routeName:
                    page = const CheckConnectionView();
                    break;
                  case SelectTontineView.routeName:
                    page = const SelectTontineView();
                    break;
                  case LoanView.routeName:
                    page = const LoanView();
                    break;
                  case RapportView.routeName:
                    page = const RapportView();
                    break;
                  case SettingTontineView.routeName:
                    page = const SettingTontineView();
                    break;
                  case RegisterView.routeName:
                    page = const RegisterView();
                    break;
                  case AddMembersView.routeName:
                    page = const AddMembersView();
                    break;
                  case EventView.routeName:
                    page = const EventView();
                    break;
                  case NotificationView.routeName:
                    page = const NotificationView();
                    break;
                  case MemberView.routeName:
                    page = const MemberView();
                    break;
                  case ForgotPasswordView.routeName:
                    page = const ForgotPasswordView();
                    break;
                  case ResetPasswordView.routeName:
                    page = const ResetPasswordView();
                    break;
                  case FeaturesExplanationView.routeName:
                    page = const FeaturesExplanationView();
                    break;
                  default:
                    page = const SplashView();
                }
                return _maybeProtect(routeSettings.name, page);
              },
            );
          },
          initialRoute: CheckConnectionView.routeName,
          routes: {
            CheckConnectionView.routeName: (context) =>
                const CheckConnectionView(),
            SelectedLanguageView.routeName: (context) =>
                const SelectedLanguageView(),
          },
        );
      },
    );
  }
}
