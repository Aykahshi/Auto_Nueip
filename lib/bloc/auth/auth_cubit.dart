import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gl_nueip/core/utils/enum.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  void loginSuccess() {
    emit(state.copyWith(status: LoginStatus.success));
  }

  void loginFailed(String error) {
    emit(state.copyWith(status: LoginStatus.failure, error: error));
  }

  void reset() {
    emit(const AuthState.initial());
  }
}
