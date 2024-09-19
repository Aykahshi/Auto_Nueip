import 'package:cookie_jar/cookie_jar.dart' show Cookie;

String parseCookies(List<Cookie> cookies) {
  final cookieList = cookies.map((cookie) {
    return {'name': cookie.name, 'value': cookie.value};
  }).toList();
  String cookieHeader = cookieList.map((cookie) {
    return '${cookie['name']}=${cookie['value']}';
  }).join('; ');
  return cookieHeader;
}
