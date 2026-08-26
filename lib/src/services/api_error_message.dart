import 'dart:convert';

/// Extrait un message lisible d'une réponse d'erreur JSON Nest/API.
String parseApiErrorMessage(String body, {int? statusCode}) {
  if (body.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
        if (message is List) {
          final joined = message.whereType<String>().join(' ').trim();
          if (joined.isNotEmpty) return joined;
        }
      }
    } catch (_) {
      final clipped = body.trim();
      if (clipped.length <= 180) return clipped;
    }
  }
  if (statusCode != null) {
    return 'Erreur HTTP $statusCode';
  }
  return 'Une erreur est survenue';
}
