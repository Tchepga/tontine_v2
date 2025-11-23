import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:get_storage/get_storage.dart';

class AuthInterceptor implements InterceptorContract {
  final storage = GetStorage();
  static const List<String> publicPaths = [
    'login',
    'logout',
    'verify',
    'register',
  ];

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    // Ne pas intercepter les routes publiques
    if (publicPaths.any((path) => request.url.path.endsWith(path))) {
      return request;
    }

    final token = storage.read('token');
    final authorisationHeader = request.headers['Authorization'];
    if (token != null && authorisationHeader != 'Bearer $token') {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Content-Type'] = 'application/json';
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
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
        url.contains('/auth/register')) {
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
