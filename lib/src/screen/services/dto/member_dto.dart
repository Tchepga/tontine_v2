import '../../../models/enum/role.dart';

class CreateMemberDto {
  final String? username;
  final String? password;
  final String firstname;
  final String lastname;
  final String? email;
  final String phone;
  final String country;
  final List<Role>? roles;

  CreateMemberDto({
    this.username,
    this.password,
    required this.firstname,
    required this.lastname,
    this.email,
    required this.phone,
    required this.country,
    this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      'firstname': firstname,
      'lastname': lastname,
      if (email != null) 'email': email,
      'phone': phone,
      'country': country,
      if (roles != null)
        'roles': roles!.map((role) => role.toString().split('.').last).toList(),
    };
  }

  CreateMemberDto copyWith({
    String? username,
    String? password,
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? country,
    List<Role>? roles,
  }) {
    return CreateMemberDto(
      username: username ?? this.username,
      password: password ?? this.password,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      roles: roles ?? this.roles,
    );
  }
}
