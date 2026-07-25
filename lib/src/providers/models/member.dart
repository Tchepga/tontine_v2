import 'enum/role.dart';

class Member {
  final int? id;
  final String email;
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? avatar;
  final String? country;
  final User? user;
  // final Object? loans;
  Member({
    this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.avatar,
    required this.country,
   required this.user,
  //  required this.loans,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : rawId is num
            ? rawId.toInt()
            : int.tryParse(rawId?.toString() ?? '');

    return Member(
      id: id,
      email: json['email'] ?? '',
      firstname: json['firstname'],
      lastname: json['lastname'],
      phone: json['phone'],
      avatar: json['avatar'] ?? '',
      country: json['country'] ?? '',
      user: json['user'] != null
          ? User.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'avatar': avatar,
      'country': country,
      'user': user?.toJson(),
    };
  }

  Member copyWith({
    int? id,
    String? email,
    String? firstname,
    String? lastname,
    String? phone,
    String? avatar,
    String? country,
    User? user,
  }) {
    return Member(
      id: id ?? this.id,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      country: country ?? this.country,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class User {
  final String? username;
  final List<Role>? roles;

  User({
    this.username,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      roles: json['roles'] != null
          ? List<Role>.from(json['roles'].map((role) => parseRole(role)))
          : [],
    );
  }

  User copyWith({
    String? username,
    List<Role>? roles,
  }) {
    return User(
      username: username ?? this.username,
      roles: roles ?? this.roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'roles': roles?.map((role) => role.toString().split('.').last).toList(),
    };
  }
}