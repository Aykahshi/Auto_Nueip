import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/models/user_model.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  static const String _userKey = 'user_info';
  final SharedPreferences _prefs;

  UserCubit(this._prefs) : super(const UserState(user: User())) {
    _loadState();
  }

  void saveAll({
    String? company,
    String? name,
    String? userId,
    String? password,
  }) async {
    emit(
      UserState(
        user: User(
          company: company ?? state.user.company,
          name: name ?? state.user.name,
          id: userId ?? state.user.id,
          password: password ?? state.user.password,
        ),
      ),
    );
    _saveState();
  }

  void saveUserNum(String number) {
    emit(UserState(user: state.user.copyWith(number: number)));
    _saveState();
  }

  void reset() async {
    emit(const UserState(user: User()));
    locator<AuthCubit>().setLoggedInState(false);
    _saveState();
  }

  void _loadState() async {
    final String? userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      final Map<String, dynamic> json = jsonDecode(userJson);
      emit(UserState.fromJson(json));
    }
  }

  Future<void> _saveState() async {
    final String userJson = json.encode(state.toJson());
    _prefs.setString(_userKey, userJson);
  }
}
