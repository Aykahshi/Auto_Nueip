part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final LoginStatus status;

  const AuthState({
    required this.status,
  });

  const AuthState.initial() : this(status: LoginStatus.initial);

  AuthState copyWith({
    LoginStatus? status,
  }) {
    return AuthState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
