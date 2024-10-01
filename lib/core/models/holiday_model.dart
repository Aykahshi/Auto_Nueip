class Holiday {
  final String date;
  final bool isHoliday;

  Holiday({
    required this.date,
    required this.isHoliday,
  });

  Map<String, dynamic> toJson() {
    return {'date': date, 'isHoliday': isHoliday};
  }

  factory Holiday.fromJson(Map<String, dynamic> map) {
    return Holiday(
      date: map['date'] as String,
      isHoliday: map['isHoliday'] as bool,
    );
  }
}
