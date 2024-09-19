part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final LoginStatus status;
  final String? error;

  const AuthState({
    required this.status,
    this.error,
  });

  const AuthState.initial() : this(status: LoginStatus.unknown);

  AuthState copyWith({
    LoginStatus? status,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
