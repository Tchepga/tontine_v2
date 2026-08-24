/// Parsing des liens d'auth (mot de passe oublié / reset).
///
/// Accepte :
/// - `/reset-password?token=…`
/// - `thoua://reset-password?token=…`
/// - arguments de route (`String` ou `{token: …}`)
class AuthDeepLink {
  static const resetPasswordPath = '/reset-password';

  static String? resetTokenFromRouteSettings(RouteArgs args) {
    final fromArgs = _tokenFromArguments(args.arguments);
    if (fromArgs != null) return fromArgs;
    return resetTokenFromLocation(args.name);
  }

  static String? resetTokenFromLocation(String? location) {
    final uri = _parse(location);
    if (uri == null || !_isResetPath(uri)) return null;
    final token = uri.queryParameters['token'] ??
        uri.queryParameters['resetToken'];
    if (token == null || token.trim().isEmpty) return null;
    return token.trim();
  }

  static String? _tokenFromArguments(Object? arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }
    if (arguments is Map) {
      final token = arguments['token'];
      if (token is String && token.trim().isNotEmpty) {
        return token.trim();
      }
    }
    return null;
  }

  static bool _isResetPath(Uri uri) {
    final path = uri.path;
    if (path == resetPasswordPath || path == 'reset-password') {
      return true;
    }
    if (path.isEmpty || path == '/') {
      return uri.host == 'reset-password';
    }
    return path.endsWith('/reset-password');
  }

  static Uri? _parse(String? location) {
    if (location == null || location.isEmpty) return null;
    return Uri.tryParse(location);
  }
}

/// Sous-ensemble de [RouteSettings] pour rester testable sans Flutter.
class RouteArgs {
  const RouteArgs({this.name, this.arguments});
  final String? name;
  final Object? arguments;
}
