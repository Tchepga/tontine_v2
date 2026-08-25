import 'dart:convert';

import 'package:sentry_flutter/sentry_flutter.dart';

/// Télémétrie Sentry pour les emails d'auth (forgot / inscription).
///
/// Ne logge **jamais** l'identifiant en clair (PII). On envoie un fingerprint
/// stable, le type (email vs username) et le domaine éventuel.
class AuthEmailTelemetry {
  static const forgotPasswordFlow = 'forgot_password';
  static const registerPresidentFlow = 'register_president';

  static String identifierKind(String raw) {
    return emailDomain(raw) != null ? 'email' : 'username';
  }

  static String? emailDomain(String raw) {
    final trimmed = raw.trim();
    final at = trimmed.lastIndexOf('@');
    if (at <= 0 || at >= trimmed.length - 1) return null;
    final domain = trimmed.substring(at + 1).toLowerCase();
    if (!domain.contains('.') || domain.contains(' ')) return null;
    return domain;
  }

  /// Empreinte FNV-1a 32 bits, stable, non réversible.
  static String fingerprint(String raw) {
    final normalized = raw.trim().toLowerCase();
    var hash = 0x811C9DC5;
    for (final unit in utf8.encode(normalized)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static Map<String, dynamic>? parseBody(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  static String? apiMessageOf(Map<String, dynamic>? body) {
    if (body == null) return null;
    final message = body['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List) {
      final joined = message.whereType<String>().join(' ');
      return joined.isEmpty ? null : joined;
    }
    return null;
  }

  static bool? emailSentOf(Map<String, dynamic>? body) {
    if (body == null || !body.containsKey('emailSent')) return null;
    return body['emailSent'] == true;
  }

  static Future<void> record({
    required String flow,
    required String identifier,
    required int httpStatus,
    String? apiMessage,
    bool? emailSent,
    required int durationMs,
    String? errorType,
  }) async {
    try {
      final kind = identifierKind(identifier);
      final domain = emailDomain(identifier);
      final printId = fingerprint(identifier);
      final accepted = httpStatus == 200 || httpStatus == 201;
      final confirmed = emailSent == true;
      final outcome = _outcome(
        accepted: accepted,
        confirmed: confirmed,
        emailSent: emailSent,
        errorType: errorType,
      );

      final attributes = <String, SentryAttribute>{
        'auth.flow': SentryAttribute.string(flow),
        'auth.identifier_kind': SentryAttribute.string(kind),
        'auth.identifier_fingerprint': SentryAttribute.string(printId),
        'auth.identifier_length': SentryAttribute.int(identifier.trim().length),
        'http.status_code': SentryAttribute.int(httpStatus),
        'auth.email_sent': SentryAttribute.bool(confirmed),
        'auth.email_sent_present': SentryAttribute.bool(emailSent != null),
        'auth.duration_ms': SentryAttribute.int(durationMs),
        'auth.outcome': SentryAttribute.string(outcome),
        if (domain != null) 'auth.identifier_domain': SentryAttribute.string(domain),
        if (apiMessage != null && apiMessage.isNotEmpty)
          'auth.api_message': SentryAttribute.string(_clip(apiMessage, 180)),
        if (errorType != null) 'auth.error_type': SentryAttribute.string(errorType),
      };

      Sentry.addBreadcrumb(
        Breadcrumb(
          type: 'http',
          category: 'auth.email',
          message: '$flow $outcome',
          level: confirmed ? SentryLevel.info : SentryLevel.warning,
          data: {
            'flow': flow,
            'outcome': outcome,
            'httpStatus': httpStatus,
            'emailSent': emailSent,
            'identifierKind': kind,
            'identifierFingerprint': printId,
          },
        ),
      );

      if (!accepted || errorType != null) {
        await Sentry.logger.error(
          'Auth email request failed ($flow)',
          attributes: attributes,
        );
      } else if (!confirmed) {
        await Sentry.logger.warn(
          'Auth email request accepted but API did not confirm send ($flow)',
          attributes: attributes,
        );
      } else {
        await Sentry.logger.info(
          'Auth email send confirmed by API ($flow)',
          attributes: attributes,
        );
      }
    } catch (_) {
      // La télémétrie ne doit jamais casser le parcours utilisateur.
    }
  }

  static String _outcome({
    required bool accepted,
    required bool confirmed,
    required bool? emailSent,
    required String? errorType,
  }) {
    if (errorType != null || !accepted) return 'http_error';
    if (confirmed) return 'email_confirmed';
    if (emailSent == false) return 'email_not_sent';
    return 'accepted_unconfirmed';
  }

  static String _clip(String value, int max) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}…';
  }
}
