import 'dart:convert';

class User {
  const User({
    required this.name,
    required this.email,
    required this.homeName,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String,
    email: json['email'] as String,
    homeName: json['homeName'] as String,
    password: json['password'] as String,
  );

  factory User.fromJsonString(String source) =>
      User.fromJson(jsonDecode(source) as Map<String, dynamic>);

  final String name;
  final String email;
  final String homeName;
  final String password;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'homeName': homeName,
    'password': password,
  };

  String toJsonString() => jsonEncode(toJson());

  User copyWith({String? name, String? homeName, String? password}) => User(
    name: name ?? this.name,
    email: email,
    homeName: homeName ?? this.homeName,
    password: password ?? this.password,
  );
}
