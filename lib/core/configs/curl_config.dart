typedef CurlBody = Map<String, String>;

class CurlConfig {
  static const String BASE_URL = 'https://cloud.nueip.com';
  static const String LOGIN_URL = '$BASE_URL/login/index/param';
  static const String CLOCK_URL = '$BASE_URL/time_clocks/ajax';
  static const String TOKEN_URL = '$BASE_URL/oauth2/token/api';
  static const String RECORD_URL = '$BASE_URL/portal/Portal_punch_clock/ajax';
  static const String DAILY_LOG_URL = '$BASE_URL/attendance_record/ajax';
  static const String HOLIDAY_URL =
      'https://cdn.jsdelivr.net/gh/ruyut/TaiwanCalendar/data/';

  static const Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  };
}
