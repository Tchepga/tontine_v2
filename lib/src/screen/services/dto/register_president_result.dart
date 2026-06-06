import '../../../services/api_error_code.dart';

class RegisterPresidentResult {
  final int statusCode;
  final String? errorCode;
  final String? username;
  final bool emailSent;

  const RegisterPresidentResult({
    required this.statusCode,
    this.errorCode,
    this.username,
    this.emailSent = false,
  });

  bool get isSuccess => statusCode == 201;

  bool get isUserAlreadyExists =>
      statusCode == 409 ||
      (statusCode == 401 && errorCode == ApiErrorCode.userAlreadyExists);
}
