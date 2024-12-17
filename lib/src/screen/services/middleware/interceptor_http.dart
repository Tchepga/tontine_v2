import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:get_storage/get_storage.dart';

class AuthInterceptor implements InterceptorContract {
  final storage = GetStorage();
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final token = storage.read('token');
    if (token != null) {
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
    return false;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return true;
  }
}

class ApiClient {
  static final client = InterceptedClient.build(
    interceptors: [AuthInterceptor()],
  );
}