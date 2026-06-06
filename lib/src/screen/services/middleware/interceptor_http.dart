import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';

class AuthInterceptor implements HttpInterceptor {
  final storage = GetStorage();
  final _logger = Logger('AuthInterceptor');

  static const List<String> publicPaths = [
    'login',
    'logout',
    'verify',
    'register',
    'register-president',
  ];

  bool _isPublicPath(String path) {
    return publicPaths.any((publicPath) => path.endsWith(publicPath));
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    // Routes publiques : pas de token requis (inscription, login…)
    if (_isPublicPath(request.url.path)) {
      request.headers['Content-Type'] = 'application/json';
      return request;
    }

    final token = storage.read('token');
    // Toujours injecter le token (sans condition de comparaison) :
    // http_interceptor v3 peut reconstruire l'objet request et perdre les
    // headers passés manuellement dans les services.
    if (token != null) {
      final tokenStr = token.toString();
      request.headers['Authorization'] = 'Bearer $tokenStr';
      _logger.fine(
          'interceptRequest [${request.method}] ${request.url.path} '
          'token[0..15]="${tokenStr.substring(0, tokenStr.length.clamp(0, 15))}..."');
    } else {
      _logger.warning(
          'interceptRequest [${request.method}] ${request.url.path} — '
          'AUCUN token en storage, requête envoyée sans Authorization');
    }
    request.headers['Content-Type'] = 'application/json';
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    final path = response.request?.url.path ?? '';
    if (response.statusCode == 401 && !_isPublicPath(path)) {
      _logger.severe(
          'interceptResponse 401 Unauthorized — '
          'url=${response.request?.url} | '
          'token présent=${storage.hasData("token")}');
    }
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest({required BaseRequest request}) {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse({required BaseResponse response}) {
    return true;
  }
}

class RequestTimeoutConfig {
  static const Duration fast = Duration(seconds: 10);
  static const Duration normal = Duration(seconds: 30);
  static const Duration long = Duration(seconds: 60);
  static const Duration veryLong = Duration(seconds: 120);
}

class ApiClient {
  static final client = InterceptedClient.build(
    interceptors: [AuthInterceptor()],
    requestTimeout: RequestTimeoutConfig.normal,
  );
  static final fastClient = InterceptedClient.build(
    interceptors: [AuthInterceptor()],
    requestTimeout: RequestTimeoutConfig.fast,
  );

  static final longClient = InterceptedClient.build(
    interceptors: [AuthInterceptor()],
    requestTimeout: RequestTimeoutConfig.long,
  );

  static final veryLongClient = InterceptedClient.build(
    interceptors: [AuthInterceptor()],
    requestTimeout: RequestTimeoutConfig.veryLong,
  );

  static InterceptedClient createCustomClient(Duration timeout) {
    return InterceptedClient.build(
      interceptors: [AuthInterceptor()],
      requestTimeout: timeout,
    );
  }

  static InterceptedClient getClientForUrl(String url) {
    if (url.contains('/auth/login') ||
        url.contains('/auth/verify') ||
        url.contains('/auth/register') ||
        url.contains('/member/register-president')) {
      return fastClient;
    }

    if (url.contains('/rapport') ||
        url.contains('/download') ||
        url.contains('/upload') ||
        url.contains('/export') ||
        url.contains('/attachment')) {
      return longClient;
    }

    if (url.contains('/export') && url.contains('full')) {
      return veryLongClient;
    }
    return client;
  }
}
