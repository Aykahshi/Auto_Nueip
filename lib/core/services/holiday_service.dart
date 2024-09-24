import 'package:dio/dio.dart';
import 'package:gl_nueip/core/configs/curl_config.dart';
import 'package:gl_nueip/core/models/holiday_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class HolidayService {
  late final Dio _dio;

  HolidayService() {
    _dio = Dio()
      ..interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ));
  }

  // TODO: Needs to refactor
  Future<Holiday> getHolidays() async {
    final year = DateTime.now().year;
    final Response response = await _dio.get(
      "${CurlConfig.HOLIDAY_URL}/${year.toString()}.json",
    );

    final Holiday holiday = Holiday.fromJson(response.data);
    return holiday;
  }

  DateTime parseDateTime(String dateString) {
    int year = int.parse(dateString.substring(0, 4));
    int month = int.parse(dateString.substring(4, 6));
    int day = int.parse(dateString.substring(6, 8));
    DateTime date = DateTime(year, month, day);
    return date;
  }
}
