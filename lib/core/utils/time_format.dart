import 'package:intl/intl.dart';

String timeFormat(DateTime dateTime) {
  final String formattedTime =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).replaceAll(' ', '+');
  return formattedTime;
}
