class Member {
  final int? id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final String? country;
  final User? user;
  final Object? loans;
  Member({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.avatar,
    required this.country,
   required this.user,
   required this.loans,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      avatar: json['avatar'] ?? '',
      country: json['country'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      loans: json['loans'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatar': avatar,
      'country': country,
    };
  }
}

class User {
  final String? username;
  final List<String>? roles;

  User({
    this.username,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}