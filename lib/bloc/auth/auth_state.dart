part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  final AuthSession? session;
  final AuthHeaders? headers;

  const AuthState({this.session, this.headers});
}

final class AuthInitial extends AuthState {
  const AuthInitial() : super();

  @override
  List<Object> get props => [];
}

final class AuthGetTokenFailed extends AuthState {
  const AuthGetTokenFailed() : super();

  @override
  List<Object> get props => [];
}

final class AuthLoginFailed extends AuthState {
  const AuthLoginFailed() : super();

  @override
  List<Object> get props => [];
}

final class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess({required AuthHeaders headers})
      : super(headers: headers);

  @override
  List<Object?> get props => [headers];
}

final class AuthHasToken extends AuthState {
  const AuthHasToken({required AuthSession session}) : super(session: session);

  @override
  List<Object?> get props => [session];
}

final class AuthIntegrated extends AuthState {
  const AuthIntegrated({
    required AuthSession session,
    required AuthHeaders headers,
  }) : super(session: session, headers: headers);

  @override
  List<Object?> get props => [session, headers];
}
