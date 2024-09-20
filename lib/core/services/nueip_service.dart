import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/configs/curl_config.dart';
import 'package:gl_nueip/core/models/log_response_model.dart';
import 'package:gl_nueip/core/models/location_model.dart';
import 'package:gl_nueip/core/models/user_model.dart';
import 'package:gl_nueip/core/utils/utils.dart';

class NueipService {
  late final CookieJar _cookieJar;
  late final Dio _dio;
  late final String? _redirectUrl;
  late final String _cookieHeader;
  late final String _token;
  final String _loginUrl = '${CurlConfig.baseUrl}/login/index/param';
  final AuthCubit _authCubit = locator<AuthCubit>();
  final ClockCubit _clockCubit = locator<ClockCubit>();
  final User _userInfo = locator<UserCubit>().state.user;

  NueipService() {
    _cookieJar = CookieJar();
    _dio = Dio(BaseOptions(headers: CurlConfig.headers, followRedirects: false))
      ..interceptors.add(CookieManager(_cookieJar))
      ..transformer = CustomTransformer()
      ..options.validateStatus = (statusCode) => statusCode! < 400;
  }

  Future<void> clockIn() async {
    _clockCubit
      ..loading()
      ..clockInClick();
    await _fetchNueip();
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
    await _fetchNueip();
    var json = await _clockAction('2');
    final LogResponse logData = LogResponse.fromJson(json);
    if (logData.status == 'success') {
      _clockCubit.clockOut(logData.time);
    } else {
      _clockCubit.failed();
    }
  }

  Future<void> _fetchNueip() async {
    await _login();
    if (_redirectUrl!.contains('/home')) {
      await _getCookieHeader();
      await _getCrsfToken();
    }
  }

  Future<void> _login() async {
    final CurlBody body = {
      'inputCompany': _userInfo.company,
      'inputID': _userInfo.id,
      'inputPassword': _userInfo.password,
    };

    try {
      final Response response = await _dio.post(_loginUrl, data: body);
      if (response.statusCode != 303) {
        _authCubit.loginFailed('error.login_failed'.tr());
      }
      _redirectUrl = response.headers['location']?.first ?? '';
      if (_redirectUrl!.contains('/home')) {
        _authCubit.loginSuccess();
      }
    } catch (e) {
      _authCubit.loginFailed('error.common'.tr());
    }
  }

  Future<void> _getCookieHeader() async {
    final List<Cookie> cookies =
        await _cookieJar.loadForRequest(Uri.parse(_loginUrl));
    _cookieHeader = parseCookies(cookies);
  }

  Future<void> _getCrsfToken() async {
    try {
      final Response response = await _dio.get(
        _redirectUrl!,
        options: Options(headers: {'Cookie': _cookieHeader}),
      );
      if (response.statusCode == 200) {
        _token = extractToken(response.data);
      }
    } catch (e) {
      _authCubit.loginFailed('error.common'.tr());
    }
  }

  Future<dynamic> _clockAction(String method) async {
    const String clockUrl = '${CurlConfig.baseUrl}/time_clocks/ajax';
    final String timeStamp = timeFormat(DateTime.now());
    const Location location =
        Location(latitude: '22.6282043', longitude: '120.2930865');

    final formData = {
      'action': 'add',
      'id': method,
      'attendance_time': timeStamp,
      'token': _token,
      'lat': location.latitude,
      'lng': location.longitude,
    };

    try {
      final Response response = await _dio.post(
        clockUrl,
        data: formData,
        options: Options(
          headers: {'Cookie': _cookieHeader},
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('Error：${e.toString()}');
    }
  }

  Future<String> _getOauthToken() async {
    await _login();
    try {
      final Response response = await _dio.get(
        '${CurlConfig.baseUrl}/oauth2/token/api',
      );
      final String accessToken = response.data['token_access_token'];
      return accessToken;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get oauth token: $e');
      }
      return '';
    }
  }

  Future<ClockedTime?> _getClockTime() async {
    final String accessToken = await _getOauthToken();
    if (accessToken != '') {
      try {
        final Response response = await _dio.get(
          '${CurlConfig.baseUrl}/portal/Portal_punch_clock/ajax',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          queryParameters: {'type': 'view'},
        );
        final Map<String, dynamic> user = response.data['data']['user'];
        final String? clockInTime = user['A1'];
        final String? clockOutTime = user['A2'];
        locator<UserCubit>().saveUserNum(user['u_no']);
        return (clockInTime, clockOutTime);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to get clock logs: $e');
        }
      }
    }
    return null;
  }

  Future<void> checkStatus() async {
    final ClockedTime? clockedTime = await _getClockTime();
    _clockCubit.initStatus(clockedTime);
  }

  Future<void> getDailyLogs(String date) async {
    await _login();
    final String? userNum = locator<UserCubit>().state.user.number;

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
        '${CurlConfig.baseUrl}/attendance_record/ajax',
        data: formData,
        options: Options(headers: {
          'Cookie': 'Search_42_date_start=$date; Search_42_date_end=$date;'
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
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get daily logs: $e');
      }
      dailyLogCubit.hasError();
    }
  }
}
