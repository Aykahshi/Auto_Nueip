import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:gl_nueip/core/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final int updatedFields = [company, name, userId, password]
        .where((field) => field != null)
        .length;

    if (updatedFields == 4) {
      emit(state.copyWith(
        user: User(
          company: company!,
          name: name!,
          id: userId!,
          password: password!,
        ),
      ));
    } else {
      emit(state.copyWith(
        user: state.user.copyWith(
          company: company,
          name: name,
          id: userId,
          password: password,
        ),
      ));
    }

    _saveState();
  }

  void reset() async {
    emit(const UserState(user: User()));
    _saveState();
  }

  bool isNotDefault() {
    const User defaultUser = User();
    return state.user != defaultUser;
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
