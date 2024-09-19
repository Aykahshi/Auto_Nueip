part of 'user_cubit.dart';

class UserState extends Equatable {
  final User user;

  const UserState({required this.user});

  UserState copyWith({User? user}) {
    return UserState(
      user: user ?? this.user,
    );
  }

  @override
  List<Object> get props => [user];

  Map<String, dynamic> toJson() => user.toJson();

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      user: User.fromJson(json),
    );
  }
}
