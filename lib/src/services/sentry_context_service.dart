import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/models/member.dart';
import '../providers/tontine_provider.dart';

/// Met à jour le contexte utilisateur Sentry (userId, tontineId).
class SentryContextService {
  static final _storage = GetStorage();

  static void syncFromStorage() {
    int? userId;
    try {
      final storedProfile = _storage.read(AuthProvider.KEY_PROFILE);
      if (storedProfile != null) {
        final member = Member.fromJson(jsonDecode(storedProfile));
        userId = member.id;
      }
    } catch (_) {
      // Profil illisible : on envoie seulement le tontineId si présent.
    }
    sync(userId: userId);
  }

  static void sync({int? userId}) {
    final rawTontineId = _storage.read(TontineProvider.KEY_SELECTED_TONTINE_ID);
    final tontineId = rawTontineId?.toString();

    Sentry.configureScope((scope) {
      if (userId == null && (tontineId == null || tontineId.isEmpty)) {
        scope.setUser(null);
        return;
      }

      scope.setUser(
        SentryUser(
          id: userId?.toString(),
          data: tontineId != null && tontineId.isNotEmpty
              ? {'tontineId': tontineId}
              : null,
        ),
      );
    });
  }

  static void clear() {
    Sentry.configureScope((scope) => scope.setUser(null));
  }
}
