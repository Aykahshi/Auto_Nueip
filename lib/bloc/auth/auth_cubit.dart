import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gl_nueip/core/models/auth_headers_model.dart';
import 'package:gl_nueip/core/models/auth_session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SharedPreferences _prefs;

  static const String _sessionKey = 'auth_session';
  static const String _headersKey = 'auth_headers';

  AuthCubit(this._prefs) : super(const AuthInitial()) {
    checkAuthState();
  }

  void loginSuccess(AuthHeaders headers) async {
    saveAuthHeaders(state.headers!);
  }

  void loginFailed() async => emit(const AuthLoginFailed());

  Future<void> checkAuthState() async {
    final AuthSession? session = await loadAuthSession();
    final AuthHeaders? headers = await loadAuthHeaders();
    if (session == null || headers == null) {
      emit(const AuthHasNoToken());
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

  Future<void> saveAuthHeaders(AuthHeaders newHeaders) async {
    final AuthHeaders updatedHeaders = AuthHeaders(
      cookie: newHeaders.cookie,
      csrfToken: newHeaders.csrfToken,
    );
    final String jsonData = json.encode(updatedHeaders.toJson());
    await _prefs.setString(_headersKey, jsonData);
  }

  Future<AuthSession?> loadAuthSession() async {
    final String? jsonString = _prefs.getString(_sessionKey);
    if (jsonString == null) {
      return null;
    }
    final stateMap = jsonDecode(jsonString);
    final AuthSession sessionMap = AuthSession.fromJson(stateMap);
    return sessionMap;
  }

  Future<AuthHeaders?> loadAuthHeaders() async {
    final String? jsonString = _prefs.getString(_headersKey);
    if (jsonString == null) {
      return null;
    }
    final stateMap = jsonDecode(jsonString);
    final AuthHeaders headersMap = AuthHeaders.fromJson(stateMap);
    return headersMap;
  }
}
