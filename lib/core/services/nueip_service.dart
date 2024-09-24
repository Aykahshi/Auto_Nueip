import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/configs/curl_config.dart';
import 'package:gl_nueip/core/models/auth_headers_model.dart';
import 'package:gl_nueip/core/models/auth_session_model.dart';
import 'package:gl_nueip/core/models/location_model.dart';
import 'package:gl_nueip/core/models/log_response_model.dart';
import 'package:gl_nueip/core/utils/utils.dart';

class NueipService {
  late final CookieJar _cookieJar;
  late final Dio _dio;
  late final String? _redirectUrl;
  final AuthCubit _authCubit = locator<AuthCubit>();
  final ClockCubit _clockCubit = locator<ClockCubit>();
  final UserCubit _userCubit = locator<UserCubit>();

  NueipService() {
    _cookieJar = CookieJar();
    _dio = Dio(BaseOptions(headers: CurlConfig.headers, followRedirects: false))
      ..interceptors.add(CookieManager(_cookieJar))
      // ..interceptors.add(PrettyDioLogger(
      //   requestHeader: true,
      //   requestBody: true,
      //   responseBody: true,
      //   responseHeader: false,
      // ))
      ..transformer = CustomTransformer()
      ..options.validateStatus = (statusCode) => statusCode! < 400;
  }

  Future<void> clockIn() async {
    _clockCubit
      ..loading()
      ..clockInClick();
    var json = await _clockAction('1');
    final LogResponse logData = LogResponse.fromJson(json);
    if (logData.status == 'success') {
      _clockCubit.clockIn(logData.time);
    } else {
      _clockCubit.failed();
    }
  }

  Future<void> clockOut() async {
    _clockCubit
      ..loading()
      ..clockOutClick();
    var json = await _clockAction('2');
    final LogResponse logData = LogResponse.fromJson(json);
    if (logData.status == 'success') {
      _clockCubit.clockOut(logData.time);
    } else {
      _clockCubit.failed();
    }
  }

  Future<void> _login() async {
    final CurlBody body = {
      'inputCompany': _userCubit.state.user.company,
      'inputID': _userCubit.state.user.id,
      'inputPassword': _userCubit.state.user.password,
    };

    try {
      final Response response =
          await _dio.post(CurlConfig.LOGIN_URL, data: body);
      if (response.statusCode != 303) _authCubit.loginFailed();

      _redirectUrl = response.headers['location']?.first ?? '';

      if (_redirectUrl == '') _authCubit.loginFailed();

      if (_redirectUrl!.contains('/home')) {
        final String cookieHeader = await _getCookieHeader();
        final String csrfToken =
            await _getCrsfToken(cookieHeader: cookieHeader);
        final AuthHeaders newHeaders =
            AuthHeaders(cookie: cookieHeader, csrfToken: csrfToken);
        _authCubit.loginSuccess(newHeaders);
        await _getOauthToken();
      }
    } catch (e) {
      _authCubit.loginFailed();
    }
  }

  Future<void> _checkAuth() async {
    bool needsRefresh = false;
    final List<Cookie> cookies =
        await _cookieJar.loadForRequest(Uri.parse(CurlConfig.LOGIN_URL));
    for (final Cookie cookie in cookies) {
      if (cookie.expires != null && cookie.expires!.isAfter(DateTime.now())) {
        needsRefresh = true;
        break;
      }
    }
    if (_authCubit.state.headers?.csrfToken == null) needsRefresh = true;
    if (needsRefresh) await _login();
  }

  Future<String> _getCookieHeader() async {
    final List<Cookie> cookies =
        await _cookieJar.loadForRequest(Uri.parse(CurlConfig.LOGIN_URL));
    final String cookieHeader = parseCookies(cookies);
    return cookieHeader;
  }

  Future<String> _getCrsfToken({required String cookieHeader}) async {
    final Response response = await _dio.get(
      _redirectUrl!,
      options: Options(headers: {'Cookie': cookieHeader}),
    );
    final String csrfToken = extractToken(response.data);
    return csrfToken;
  }

  Future<dynamic> _clockAction(String method) async {
    final String timeStamp = timeFormat(DateTime.now());
    final String? cookieHeader = _authCubit.state.headers!.cookie;
    final String? csrfToken = _authCubit.state.headers!.csrfToken;
    const Location location =
        Location(latitude: '22.6282043', longitude: '120.2930865');

    final formData = {
      'action': 'add',
      'id': method,
      'attendance_time': timeStamp,
      'token': csrfToken,
      'lat': location.latitude,
      'lng': location.longitude,
    };

    final Response response = await _dio.post(CurlConfig.CLOCK_URL,
        data: formData, options: Options(headers: {'Cookie': cookieHeader}));
    return response.data;
  }

  Future<void> _checkTokenExpired() async {
    if (_authCubit.state.session == null || _authCubit.state.headers == null) {
      await _authCubit.checkAuthState();
    }
    final bool needsRefresh = _authCubit.state.session!.isTokenExpired();
    if (needsRefresh) await _getOauthToken();
  }

  Future<void> _getOauthToken() async {
    try {
      final Response response = await _dio.get(CurlConfig.TOKEN_URL,
          options:
              Options(headers: {'Cookie': _authCubit.state.headers!.cookie}));
      final String accessToken = response.data['token_access_token'];
      final int expiresIn = response.data['token_expires_in'] as int;
      final DateTime expiryTime =
          DateTime.now().add(Duration(seconds: expiresIn));
      _authCubit.saveAuthSession(AuthSession(
        accessToken: accessToken,
        expiryTime: expiryTime,
      ));
    } catch (e) {
      if (kDebugMode) print('Failed to get oauth token: $e');
    }
  }

  Future<ClockedTime?> _getClockTime() async {
    final String? accessToken = _authCubit.state.session?.accessToken;
    if (kDebugMode) print('accessToken: $accessToken');
    if (accessToken != null) {
      try {
        final Response response = await _dio.get(
          CurlConfig.RECORD_URL,
          options: Options(headers: {
            'Authorization': 'Bearer $accessToken',
            'Cookie': _authCubit.state.headers!.cookie,
          }),
          queryParameters: {'type': 'view'},
        );
        final Map<String, dynamic> user = response.data['data']['user'];
        final String? clockInTime = user['A1'];
        final String? clockOutTime = user['A2'];
        _userCubit.saveUserNum(user['u_no']);
        return (clockInTime, clockOutTime);
      } catch (e) {
        if (kDebugMode) print('Failed to get clock logs: $e');
      }
    }
    return null;
  }

  Future<void> checkStatus() async {
    await _checkAuth();
    await _checkTokenExpired();
    if (kDebugMode) print('Checking Status Completed');
    final ClockedTime? clockedTime = await _getClockTime();
    if (kDebugMode) print('Get Clock Time Completed: $clockedTime');
    _clockCubit.initStatus(clockedTime);
  }

  Future<void> getDailyLogs(String date) async {
    final String? userNum = _userCubit.state.user.number;

    final DailyLogCubit dailyLogCubit = locator<DailyLogCubit>();
    final formData = {
      'action': 'attendance',
      'loadInBatch': '1',
      'loadBatchGroupNum': '1000',
      'loadBatchNumber': '1',
      'work_status': '1,4',
    };

    try {
      final Response response = await _dio.post(
        CurlConfig.DAILY_LOG_URL,
        data: formData,
        options: Options(headers: {
          'Cookie':
              'Search_42_date_start=$date; Search_42_date_end=$date; ${_authCubit.state.headers!.cookie}'
        }),
      );
      if (userNum != null) {
        final logData = response.data['data'][date][userNum];
        if (logData['timeoff'] == null && logData['punch'] == null) {
          dailyLogCubit.hasNoLogs();
        }

        if (logData['timeoff'] != null) {
          final String timeOffName = logData['timeoff'].first['rule_name'];
          dailyLogCubit.hasTimeOff(timeOffType: timeOffName);
        } else if (logData['punch'] != null) {
          final clockLogs = logData['punch'];
          final List<WorkLog> workLogs = [];

          if (clockLogs['onPunch'] != null) {
            workLogs.add((
              time: clockLogs['onPunch'].first['time'],
              status: 'status.clock_in'.tr()
            ));
          }
          if (clockLogs['offPunch'] != null) {
            workLogs.add((
              time: clockLogs['offPunch'].first['time'],
              status: 'status.clock_out'.tr()
            ));
          }
          dailyLogCubit.hasWorked(workLogs: workLogs);
        }
      } else {
        dailyLogCubit.hasError();
      }
    } catch (e) {
      if (kDebugMode) print('Failed to get daily logs: $e');
      dailyLogCubit.hasError();
    }
  }
}
