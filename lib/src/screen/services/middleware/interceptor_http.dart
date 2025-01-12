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
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
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

class ApiClient {
  static final client = InterceptedClient.build(
    interceptors: [AuthInterceptor()],
    requestTimeout: const Duration(seconds: 30),
  );
}