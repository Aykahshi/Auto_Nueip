DateTime parseDateTime(String dateString) {
  int year = int.parse(dateString.substring(0, 4));
  int month = int.parse(dateString.substring(4, 6));
  int day = int.parse(dateString.substring(6, 8));
  DateTime date = DateTime(year, month, day);
  return date;
}
