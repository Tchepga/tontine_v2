import 'package:flutter/foundation.dart';

/// Empêche les soumissions doubles (double-tap) sur opérations financières.
class SubmitGuard {
  SubmitGuard();

  bool _busy = false;

  bool get isBusy => _busy;

  /// Exécute [action] une seule fois tant qu'elle n'est pas terminée.
  Future<T?> run<T>(Future<T> Function() action) async {
    if (_busy) {
      debugPrint('SubmitGuard: ignored duplicate submit');
      return null;
    }
    _busy = true;
    try {
      return await action();
    } finally {
      _busy = false;
    }
  }
}
