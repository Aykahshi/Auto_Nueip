class Holiday {
  final String date;
  final bool isHoliday;
  final String description;

  Holiday({
    required this.date,
    required this.isHoliday,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {'date': date, 'isHoliday': isHoliday, 'description': description};
  }

  factory Holiday.fromJson(Map<String, dynamic> map) {
    return Holiday(
      date: map['date'] as String,
      isHoliday: map['isHoliday'] as bool,
      description: map['description'] as String,
    );
  }
}
