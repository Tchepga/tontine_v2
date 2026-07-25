import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:logging/logging.dart';

import '../../../services/session_manager.dart';
import '../../../services/token_storage.dart';

class AuthInterceptor implements HttpInterceptor {
  final _logger = Logger('AuthInterceptor');

  static const List<String> publicPaths = [
    'login',
    'logout',
    'verify',
    'register',
    'register-president',
    'forgot-password',
    'reset-password',
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

    final token = TokenStorage.instance.token;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    } else {
      _logger.warning(
          'interceptRequest [${request.method}] ${request.url.path} — '
          'aucun token, requête sans Authorization');
    }
    request.headers['Content-Type'] = 'application/json';
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    final path = response.request?.url.path ?? '';
    if (response.statusCode == 401 && !_isPublicPath(path)) {
      _logger.warning(
          'interceptResponse 401 Unauthorized — url=${response.request?.url}');
      await SessionManager.handleUnauthorized();
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
