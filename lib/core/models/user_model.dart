import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String company;
  final String name;
  final String id;
  final String password;
  final String? number;

  const User({
    this.company = '',
    this.name = 'Guest',
    this.id = '',
    this.password = '',
    this.number,
  });

  User copyWith({
    String? company,
    String? name,
    String? id,
    String? password,
    String? number,
  }) {
    return User(
      company: company ?? this.company,
      name: name ?? this.name,
      id: id ?? this.id,
      password: password ?? this.password,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toJson() => {
        'company': company,
        'name': name,
        'id': id,
        'password': password,
        'number': number,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      company: json['company'] as String,
      name: json['name'] as String,
      id: json['id'] as String,
      password: json['password'] as String,
      number: json['number'] as String?,
    );
  }

  @override
  List<Object?> get props => [company, name, id, password, number];
}
