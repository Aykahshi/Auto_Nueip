import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gl_nueip/core/configs/curl_config.dart';
import 'package:gl_nueip/core/models/holiday_model.dart';

class HolidayService {
  final Dio _dio = Dio();

  Future<List<Holiday>> getHolidays() async {
    final year = DateTime.now().year.toString();
    final Response response = await _dio.get(
      "${CurlConfig.HOLIDAY_URL}/$year.json",
    );

    final List<dynamic> fullData = response.data;
    final List<Holiday> holidays = fullData
        .map((e) => Holiday.fromJson(e))
        .where((element) => element.isHoliday)
        .toList();

    if (kDebugMode) print('Holidays: ${holidays.first.isHoliday}');

    return holidays;
  }
}
