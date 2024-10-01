import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/core/models/auth_headers_model.dart';
import 'package:gl_nueip/core/models/auth_session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SharedPreferences _prefs;

  static const String _sessionKey = 'auth_session';
  static const String _headersKey = 'auth_headers';
  static const String _authKey = 'hasLoggedIn';

  AuthCubit(this._prefs) : super(const AuthInitial()) {
    checkAuthState();
  }

  void loginSuccess(AuthHeaders headers) async {
    emit(AuthLoginSuccess(headers: headers));
    await _saveAuthHeaders(headers);
    await setLoggedInState(true);
  }

  void loginFailed() async => emit(const AuthLoginFailed());

  bool get isLoggedIn => hasLoggedIn();

  Future<void> checkAuthState() async {
    final AuthSession? session = await _loadAuthSession();
    final AuthHeaders? headers = await _loadAuthHeaders();
    if (session == null || headers == null) {
      emit(const AuthGetTokenFailed());
    } else {
      emit(AuthIntegrated(session: session, headers: headers));
    }
  }

  Future<void> saveAuthSession(AuthSession newSession) async {
    final AuthSession updatedSession = AuthSession(
      accessToken: newSession.accessToken,
      expiryTime: newSession.expiryTime,
    );
    emit(AuthHasToken(session: updatedSession));
    final String sessionJson = json.encode(updatedSession.toJson());
    await _prefs.setString(_sessionKey, sessionJson);
  }

  Future<void> _saveAuthHeaders(AuthHeaders newHeaders) async {
    final AuthHeaders updatedHeaders = AuthHeaders(
      cookie: newHeaders.cookie,
      csrfToken: newHeaders.csrfToken,
    );
    final String jsonData = json.encode(updatedHeaders.toJson());
    await _prefs.setString(_headersKey, jsonData);
  }

  Future<AuthSession?> _loadAuthSession() async {
    final String? jsonString = _prefs.getString(_sessionKey);
    if (jsonString == null) {
      return null;
    }
    final stateMap = jsonDecode(jsonString);
    final AuthSession sessionMap = AuthSession.fromJson(stateMap);
    return sessionMap;
  }

  Future<AuthHeaders?> _loadAuthHeaders() async {
    final String? jsonString = _prefs.getString(_headersKey);
    if (jsonString == null) {
      return null;
    }
    final stateMap = jsonDecode(jsonString);
    final AuthHeaders headersMap = AuthHeaders.fromJson(stateMap);
    return headersMap;
  }

  bool hasLoggedIn() {
    final bool? isEnabled = _prefs.getBool(_authKey);
    if (isEnabled != null) {
      return isEnabled;
    }
    return false;
  }

  Future<void> setLoggedInState(bool isLoggedIn) async {
    _prefs.setBool(_authKey, isLoggedIn);
  }
}
