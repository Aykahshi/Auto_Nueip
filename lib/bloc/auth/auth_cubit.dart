import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gl_nueip/core/utils/enum.dart';
import 'package:gl_nueip/core/utils/show_toast.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  void loginSuccess() {
    emit(state.copyWith(status: LoginStatus.success));
  }

  void loginFailed() {
    emit(state.copyWith(status: LoginStatus.failure));
  }

  void reset() {
    emit(const AuthState.initial());
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    switch (state.status) {
      case LoginStatus.success:
        showToast('login.success'.tr(), Colors.green[600]!);
      case LoginStatus.failure:
        showToast('login.failed'.tr(), Colors.red[700]!);
      default:
        return;
    }
  }
}
