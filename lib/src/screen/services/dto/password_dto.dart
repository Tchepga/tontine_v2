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
  final String usernameOrEmail;

  ForgotPasswordDto({
    required this.usernameOrEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': usernameOrEmail,
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
    };
  }
}
