class ChangePasswordDto {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordDto({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class ForgotPasswordDto {
  final String email;

  ForgotPasswordDto({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': email,
    };
  }
}

class ResetPasswordDto {
  final String token;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordDto({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
