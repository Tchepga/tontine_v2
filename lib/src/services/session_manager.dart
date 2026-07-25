import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';

import '../screen/services/member_service.dart';
import 'token_storage.dart';

/// Gère la fin de session (401, logout) et la redirection vers le login.
class SessionManager {
  SessionManager._();

  static final _logger = Logger('SessionManager');
  static GlobalKey<NavigatorState>? navigatorKey;
  static bool _handlingUnauthorized = false;

  static Future<void> handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      _logger.warning('Session expired (401) — clearing credentials');
      await TokenStorage.instance.clear();
      final storage = GetStorage();
      await storage.remove(MemberService.KEY_USER_INFO);
      await storage.remove(MemberService.KEY_PROFILE);
      await storage.remove('user_profile');

      final nav = navigatorKey?.currentState;
      if (nav != null) {
        nav.pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } finally {
      _handlingUnauthorized = false;
    }
  }

  static Future<void> clearSession() async {
    await TokenStorage.instance.clear();
    final storage = GetStorage();
    await storage.remove(MemberService.KEY_USER_INFO);
    await storage.remove(MemberService.KEY_PROFILE);
    await storage.remove('user_profile');
  }
}
